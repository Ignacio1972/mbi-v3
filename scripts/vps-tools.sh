#!/bin/bash

# 🚀 VPS Tools Script for MBI-v3 Project
# Herramientas automatizadas para trabajar con el VPS desde Claude Code

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración VPS
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

# Función para ejecutar comandos en VPS
vps_exec() {
    local cmd="$1"
    print_status "Ejecutando en VPS: $cmd"
    $SSH_CMD "cd $VPS_PROJECT_PATH && $cmd"
}

# Función para verificar conexión VPS
vps_check() {
    print_status "Verificando conexión al VPS..."
    
    if $SSH_CMD "echo 'Conexión exitosa'" >/dev/null 2>&1; then
        print_success "✅ VPS conectado correctamente"
        return 0
    else
        print_error "❌ No se pudo conectar al VPS"
        return 1
    fi
}

# Función para mostrar estado del proyecto
vps_status() {
    print_status "📊 Estado del proyecto en VPS:"
    echo
    
    echo -e "${BLUE}=== GIT STATUS ===${NC}"
    vps_exec "git status"
    echo
    
    echo -e "${BLUE}=== DISK USAGE ===${NC}"
    vps_exec "df -h /var/www"
    echo
    
    echo -e "${BLUE}=== LAST COMMITS ===${NC}"
    vps_exec "git log --oneline -5"
    echo
    
    echo -e "${BLUE}=== PROJECT URL ===${NC}"
    echo "🌐 http://51.222.25.222:3000/"
}

# Función para hacer commit y push desde VPS
vps_deploy() {
    local message="$1"
    
    if [ -z "$message" ]; then
        message="VPS Update: $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    print_status "🚀 Desplegando cambios desde VPS..."
    
    vps_exec "git add -A"
    vps_exec "git commit -m \"$message\""
    vps_exec "git push origin main"
    
    if [ $? -eq 0 ]; then
        print_success "✅ Deploy completado exitosamente"
    else
        print_error "❌ Error en el deploy"
    fi
}

# Función para sincronizar VPS → Local
vps_sync_to_local() {
    print_status "🔄 Sincronizando VPS → Local..."
    
    cd "$(dirname "$0")/.." || exit 1
    
    git pull origin main
    
    if [ $? -eq 0 ]; then
        print_success "✅ Sincronización completada"
    else
        print_error "❌ Error en sincronización"
    fi
}

# Función para sincronizar Local → VPS
local_sync_to_vps() {
    print_status "🔄 Sincronizando Local → VPS..."
    
    cd "$(dirname "$0")/.." || exit 1
    
    # Commit local si hay cambios
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_status "Commitando cambios locales..."
        git add -A
        git commit -m "Local changes: $(date '+%Y-%m-%d %H:%M:%S')"
        git push origin main
    fi
    
    # Pull en VPS
    vps_exec "git pull origin main"
    
    if [ $? -eq 0 ]; then
        print_success "✅ Sincronización completada"
    else
        print_error "❌ Error en sincronización"
    fi
}

# Función para backup del VPS
vps_backup() {
    local backup_name="mbi-v3-backup-$(date +%Y%m%d-%H%M).tar.gz"
    
    print_status "💾 Creando backup: $backup_name"
    
    $SSH_CMD "cd /var/www && tar -czf $backup_name mbi-v3/ --exclude='mbi-v3/.git' --exclude='mbi-v3/api/temp/*'"
    
    if [ $? -eq 0 ]; then
        print_success "✅ Backup creado: /var/www/$backup_name"
    else
        print_error "❌ Error creando backup"
    fi
}

# Función para ver logs del proyecto
vps_logs() {
    print_status "📄 Logs del proyecto:"
    
    echo -e "${BLUE}=== ERROR LOGS ===${NC}"
    vps_exec "find . -name '*.log' -exec echo '--- {} ---' \; -exec tail -n 10 {} \;"
    
    echo -e "${BLUE}=== NGINX LOGS ===${NC}"
    $SSH_CMD "tail -n 20 /var/log/nginx/error.log"
}

# Función para verificar servicios
vps_services() {
    print_status "🔧 Estado de servicios:"
    
    echo -e "${BLUE}=== NGINX ===${NC}"
    $SSH_CMD "systemctl status nginx --no-pager -l"
    
    echo -e "${BLUE}=== AZURACAST ===${NC}"
    $SSH_CMD "docker ps | grep azuracast"
    
    echo -e "${BLUE}=== PHP-FPM ===${NC}"
    $SSH_CMD "systemctl status php8.1-fpm --no-pager -l"
}

# Función para mostrar ayuda
show_help() {
    echo "🚀 VPS Tools for MBI-v3 Project"
    echo
    echo "Uso: $0 [COMANDO]"
    echo
    echo "Comandos disponibles:"
    echo "  check       - Verificar conexión al VPS"
    echo "  status      - Mostrar estado del proyecto"
    echo "  deploy      - Commit y push desde VPS"
    echo "  sync-down   - Sincronizar VPS → Local"
    echo "  sync-up     - Sincronizar Local → VPS"
    echo "  backup      - Crear backup del proyecto"
    echo "  logs        - Ver logs del proyecto"
    echo "  services    - Verificar estado de servicios"
    echo "  help        - Mostrar esta ayuda"
    echo
    echo "Ejemplos:"
    echo "  $0 status"
    echo "  $0 deploy \"Nuevo feature implementado\""
    echo "  $0 sync-up"
}

# Script principal
case "$1" in
    "check")
        vps_check
        ;;
    "status")
        vps_check && vps_status
        ;;
    "deploy")
        vps_check && vps_deploy "$2"
        ;;
    "sync-down")
        vps_check && vps_sync_to_local
        ;;
    "sync-up")
        vps_check && local_sync_to_vps
        ;;
    "backup")
        vps_check && vps_backup
        ;;
    "logs")
        vps_check && vps_logs
        ;;
    "services")
        vps_check && vps_services
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