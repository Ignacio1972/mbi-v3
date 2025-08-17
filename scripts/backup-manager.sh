#!/bin/bash

# 🛡️ Backup Manager for MBI-v3 Project
# Sistema completo de backup y rollback con timestamp

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$PROJECT_DIR/backups"
VPS_HOST="51.222.25.222"
VPS_USER="root"
VPS_PASS="39933993"
VPS_PROJECT_PATH="/var/www/mbi-v3"
SSH_CMD="sshpass -p '$VPS_PASS' ssh -o StrictHostKeyChecking=no $VPS_USER@$VPS_HOST"

# Función para imprimir con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_backup() {
    echo -e "${PURPLE}[BACKUP]${NC} $1"
}

# Función para crear timestamp
get_timestamp() {
    date +"%Y%m%d_%H%M%S"
}

# Función para crear backup local
create_local_backup() {
    local description="$1"
    local timestamp=$(get_timestamp)
    local backup_name="local_backup_${timestamp}"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    print_backup "📦 Creando backup local: $backup_name"
    
    # Crear directorio de backup
    mkdir -p "$backup_path"
    
    # Copiar archivos del proyecto (excluyendo backups y git)
    cd "$PROJECT_DIR"
    cp -r . "$backup_path/" 2>/dev/null
    
    # Limpiar archivos innecesarios del backup
    rm -rf "$backup_path/backups"
    rm -rf "$backup_path/.git"
    rm -rf "$backup_path/api/temp/*" 2>/dev/null
    rm -rf "$backup_path/logs/*" 2>/dev/null
    
    # Crear archivo de información del backup
    cat > "$backup_path/BACKUP_INFO.txt" << EOF
=== BACKUP INFORMATION ===
Timestamp: $(date)
Description: ${description:-"Backup automático"}
Type: Local
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "No git info")
Git Branch: $(git branch --show-current 2>/dev/null || echo "No git info")
Project Path: $PROJECT_DIR
Created by: backup-manager.sh

=== FILES INCLUDED ===
$(find "$backup_path" -type f | head -20)
... $(find "$backup_path" -type f | wc -l) total files

=== RESTORE COMMAND ===
./scripts/backup-manager.sh restore-local $backup_name
EOF
    
    print_success "✅ Backup local creado: $backup_path"
    print_status "📄 Información guardada en: $backup_path/BACKUP_INFO.txt"
    
    echo "$backup_name"
}

# Función para crear backup del VPS
create_vps_backup() {
    local description="$1"
    local timestamp=$(get_timestamp)
    local backup_name="vps_backup_${timestamp}"
    local vps_backup_path="/var/www/backups/$backup_name"
    local local_backup_path="$BACKUP_DIR/$backup_name"
    
    print_backup "📦 Creando backup del VPS: $backup_name"
    
    # Crear directorio en VPS
    $SSH_CMD "mkdir -p /var/www/backups"
    
    # Crear backup en VPS
    $SSH_CMD "cd /var/www && cp -r mbi-v3 /var/www/backups/$backup_name"
    
    # Limpiar archivos innecesarios
    $SSH_CMD "cd /var/www/backups/$backup_name && rm -rf .git api/temp/* logs/* 2>/dev/null || true"
    
    # Crear archivo de información en VPS
    $SSH_CMD "cat > /var/www/backups/$backup_name/BACKUP_INFO.txt << 'EOF'
=== VPS BACKUP INFORMATION ===
Timestamp: $(date)
Description: ${description:-"VPS Backup automático"}
Type: VPS
Git Commit: \$(cd /var/www/mbi-v3 && git rev-parse HEAD 2>/dev/null || echo \"No git info\")
Git Branch: \$(cd /var/www/mbi-v3 && git branch --show-current 2>/dev/null || echo \"No git info\")
VPS Path: $VPS_PROJECT_PATH
Created by: backup-manager.sh

=== RESTORE COMMANDS ===
Local: ./scripts/backup-manager.sh restore-vps $backup_name
VPS: ./scripts/backup-manager.sh restore-vps-direct $backup_name
EOF"
    
    # Crear backup local del VPS también
    mkdir -p "$local_backup_path"
    
    # Descargar backup del VPS localmente usando tar
    print_status "📥 Descargando backup del VPS..."
    $SSH_CMD "cd /var/www/backups && tar -czf ${backup_name}.tar.gz $backup_name"
    sshpass -p "$VPS_PASS" scp -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST:/var/www/backups/${backup_name}.tar.gz" "$BACKUP_DIR/"
    
    # Extraer localmente
    cd "$BACKUP_DIR"
    tar -xzf "${backup_name}.tar.gz"
    rm "${backup_name}.tar.gz"
    
    # Limpiar archivo temporal en VPS
    $SSH_CMD "rm -f /var/www/backups/${backup_name}.tar.gz"
    
    print_success "✅ Backup del VPS creado: $local_backup_path"
    print_success "✅ Backup también disponible en VPS: $vps_backup_path"
    
    echo "$backup_name"
}

# Función para listar backups
list_backups() {
    print_status "📋 Backups disponibles:"
    echo
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        print_warning "⚠️ No hay backups disponibles"
        return
    fi
    
    cd "$BACKUP_DIR"
    for backup in */; do
        if [ -d "$backup" ]; then
            backup_name=$(basename "$backup")
            backup_path="$BACKUP_DIR/$backup"
            
            # Extraer información del backup
            if [ -f "$backup_path/BACKUP_INFO.txt" ]; then
                timestamp=$(grep "Timestamp:" "$backup_path/BACKUP_INFO.txt" | cut -d: -f2- | xargs)
                description=$(grep "Description:" "$backup_path/BACKUP_INFO.txt" | cut -d: -f2- | xargs)
                type=$(grep "Type:" "$backup_path/BACKUP_INFO.txt" | cut -d: -f2- | xargs)
                
                echo -e "${PURPLE}📦 $backup_name${NC}"
                echo -e "   📅 $timestamp"
                echo -e "   📝 $description"
                echo -e "   🏷️  $type"
                echo -e "   📂 $(du -sh "$backup_path" | cut -f1)"
                echo
            fi
        fi
    done
}

# Función para restore local
restore_local_backup() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$backup_path" ]; then
        print_error "❌ Backup no encontrado: $backup_name"
        return 1
    fi
    
    print_warning "⚠️ ¿Estás seguro de restaurar '$backup_name'? Esto sobrescribirá el proyecto actual."
    read -p "Escribe 'SI' para confirmar: " confirm
    
    if [ "$confirm" != "SI" ]; then
        print_status "❌ Operación cancelada"
        return 1
    fi
    
    # Crear backup del estado actual antes de restaurar
    print_status "🔄 Creando backup del estado actual antes de restaurar..."
    current_backup=$(create_local_backup "Pre-restore backup")
    
    print_backup "🔄 Restaurando backup: $backup_name"
    
    # Crear respaldo de archivos críticos
    mkdir -p "/tmp/mbi_restore_backup"
    cp -r "$PROJECT_DIR/.git" "/tmp/mbi_restore_backup/" 2>/dev/null || true
    cp "$PROJECT_DIR/api/config.php" "/tmp/mbi_restore_backup/" 2>/dev/null || true
    
    # Limpiar directorio actual (excepto backups y git)
    cd "$PROJECT_DIR"
    find . -maxdepth 1 -not -name "backups" -not -name ".git" -not -name "." -exec rm -rf {} + 2>/dev/null || true
    
    # Copiar archivos del backup
    cp -r "$backup_path"/* "$PROJECT_DIR/"
    
    # Restaurar archivos críticos
    cp -r "/tmp/mbi_restore_backup/.git" "$PROJECT_DIR/" 2>/dev/null || true
    cp "/tmp/mbi_restore_backup/config.php" "$PROJECT_DIR/api/" 2>/dev/null || true
    
    # Limpiar temporal
    rm -rf "/tmp/mbi_restore_backup"
    
    print_success "✅ Backup restaurado exitosamente"
    print_status "📦 Backup del estado anterior: $current_backup"
    
    # Mostrar información del backup restaurado
    if [ -f "$PROJECT_DIR/BACKUP_INFO.txt" ]; then
        echo
        print_status "📄 Información del backup restaurado:"
        cat "$PROJECT_DIR/BACKUP_INFO.txt"
        rm "$PROJECT_DIR/BACKUP_INFO.txt"
    fi
}

# Función para restore VPS
restore_vps_backup() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$backup_path" ]; then
        print_error "❌ Backup no encontrado: $backup_name"
        return 1
    fi
    
    print_warning "⚠️ ¿Estás seguro de restaurar '$backup_name' en el VPS? Esto afectará la producción."
    read -p "Escribe 'SI CONFIRMO' para continuar: " confirm
    
    if [ "$confirm" != "SI CONFIRMO" ]; then
        print_status "❌ Operación cancelada"
        return 1
    fi
    
    # Crear backup del VPS actual
    print_status "🔄 Creando backup del VPS actual antes de restaurar..."
    current_backup=$(create_vps_backup "Pre-restore VPS backup")
    
    print_backup "🔄 Restaurando backup en VPS: $backup_name"
    
    # Crear backup temporal en VPS
    $SSH_CMD "mkdir -p /tmp/vps_restore_backup"
    $SSH_CMD "cp -r $VPS_PROJECT_PATH/.git /tmp/vps_restore_backup/ 2>/dev/null || true"
    $SSH_CMD "cp $VPS_PROJECT_PATH/api/config.php /tmp/vps_restore_backup/ 2>/dev/null || true"
    
    # Subir backup al VPS
    cd "$backup_path"
    tar -czf "/tmp/${backup_name}_restore.tar.gz" .
    sshpass -p "$VPS_PASS" scp -o StrictHostKeyChecking=no "/tmp/${backup_name}_restore.tar.gz" "$VPS_USER@$VPS_HOST:/tmp/"
    
    # Restaurar en VPS
    $SSH_CMD "cd $VPS_PROJECT_PATH && find . -maxdepth 1 -not -name '.git' -not -name '.' -exec rm -rf {} + 2>/dev/null || true"
    $SSH_CMD "cd $VPS_PROJECT_PATH && tar -xzf /tmp/${backup_name}_restore.tar.gz"
    
    # Restaurar archivos críticos
    $SSH_CMD "cp -r /tmp/vps_restore_backup/.git $VPS_PROJECT_PATH/ 2>/dev/null || true"
    $SSH_CMD "cp /tmp/vps_restore_backup/config.php $VPS_PROJECT_PATH/api/ 2>/dev/null || true"
    
    # Limpiar temporales
    $SSH_CMD "rm -rf /tmp/vps_restore_backup /tmp/${backup_name}_restore.tar.gz"
    rm -f "/tmp/${backup_name}_restore.tar.gz"
    
    print_success "✅ Backup restaurado en VPS exitosamente"
    print_status "📦 Backup del estado anterior: $current_backup"
    print_status "🌐 Verificar en: http://51.222.25.222:3000/"
}

# Función para limpiar backups antiguos
cleanup_backups() {
    local keep_days="${1:-7}"
    
    print_status "🧹 Limpiando backups anteriores a $keep_days días..."
    
    find "$BACKUP_DIR" -type d -name "*backup_*" -mtime +$keep_days -exec rm -rf {} + 2>/dev/null
    
    # Limpiar también en VPS
    $SSH_CMD "find /var/www/backups -type d -name '*backup_*' -mtime +$keep_days -exec rm -rf {} + 2>/dev/null || true"
    
    print_success "✅ Limpieza completada"
}

# Función para mostrar ayuda
show_help() {
    echo "🛡️ Backup Manager for MBI-v3 Project"
    echo
    echo "Uso: $0 [COMANDO] [OPCIONES]"
    echo
    echo "Comandos disponibles:"
    echo "  backup-local [description]    - Crear backup local del proyecto"
    echo "  backup-vps [description]      - Crear backup del VPS"
    echo "  backup-full [description]     - Crear backup local y VPS"
    echo "  list                          - Listar todos los backups"
    echo "  restore-local <backup_name>   - Restaurar backup local"
    echo "  restore-vps <backup_name>     - Restaurar backup en VPS"
    echo "  cleanup [days]                - Limpiar backups antiguos (default: 7 días)"
    echo "  help                          - Mostrar esta ayuda"
    echo
    echo "Ejemplos:"
    echo "  $0 backup-local \"Antes de cambios de UI\""
    echo "  $0 backup-vps \"Backup de seguridad\""
    echo "  $0 restore-local local_backup_20240817_123456"
    echo "  $0 list"
}

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# Script principal
case "$1" in
    "backup-local")
        create_local_backup "$2"
        ;;
    "backup-vps")
        create_vps_backup "$2"
        ;;
    "backup-full")
        print_status "🔄 Creando backup completo (Local + VPS)..."
        local_backup=$(create_local_backup "$2")
        vps_backup=$(create_vps_backup "$2")
        print_success "✅ Backup completo creado:"
        print_success "   📦 Local: $local_backup"
        print_success "   📦 VPS: $vps_backup"
        ;;
    "list")
        list_backups
        ;;
    "restore-local")
        if [ -z "$2" ]; then
            print_error "❌ Especifica el nombre del backup"
            echo "Uso: $0 restore-local <backup_name>"
            exit 1
        fi
        restore_local_backup "$2"
        ;;
    "restore-vps")
        if [ -z "$2" ]; then
            print_error "❌ Especifica el nombre del backup"
            echo "Uso: $0 restore-vps <backup_name>"
            exit 1
        fi
        restore_vps_backup "$2"
        ;;
    "cleanup")
        cleanup_backups "$2"
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        print_error "Comando no reconocido: $1"
        echo
        show_help
        exit 1
        ;;
esac