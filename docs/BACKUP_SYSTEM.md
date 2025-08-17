# 🛡️ Sistema de Backup y Rollback MBI-v3

## 🎯 **Objetivo**

Sistema completo de backup automático con timestamp y capacidad de rollback para proteger el proyecto en desarrollo y producción.

## 📦 **Tipos de Backup Disponibles**

### **1. Backup Local**
- Respalda el estado actual del proyecto local
- Rápido para proteger cambios durante desarrollo
- No incluye archivos de Git ni temporales

### **2. Backup VPS**
- Respalda el estado de producción en el VPS
- Incluye descarga local automática
- Crítico antes de cambios en producción

### **3. Backup Completo**
- Combina backup local + VPS
- Máxima protección para cambios importantes

## 🚀 **Uso Básico**

### **Crear Backups:**
```bash
# Backup local
./scripts/backup-manager.sh backup-local "Descripción del backup"

# Backup VPS
./scripts/backup-manager.sh backup-vps "Descripción del backup"

# Backup completo
./scripts/backup-manager.sh backup-full "Descripción del backup"

# Usando VPS tools (solo VPS)
./scripts/vps-tools.sh backup "Descripción del backup"
```

### **Listar Backups:**
```bash
./scripts/backup-manager.sh list
```

### **Restaurar Backups:**
```bash
# Restaurar en local
./scripts/backup-manager.sh restore-local local_backup_YYYYMMDD_HHMMSS

# Restaurar en VPS (¡CUIDADO! - Afecta producción)
./scripts/backup-manager.sh restore-vps vps_backup_YYYYMMDD_HHMMSS
```

### **Limpieza Automática:**
```bash
# Eliminar backups anteriores a 7 días
./scripts/backup-manager.sh cleanup

# Eliminar backups anteriores a X días
./scripts/backup-manager.sh cleanup 14
```

## 📁 **Estructura de Backups**

```
backups/
├── local_backup_20250817_191623/    # Backup local con timestamp
│   ├── BACKUP_INFO.txt              # Información del backup
│   ├── api/                         # Copia del proyecto
│   ├── modules/
│   └── ... (todo el proyecto)
├── vps_backup_20250817_191643/      # Backup VPS descargado
│   ├── BACKUP_INFO.txt
│   └── ... (estado del VPS)
└── .gitkeep                         # Para mantener carpeta en Git
```

## 📄 **Archivo BACKUP_INFO.txt**

Cada backup incluye información detallada:

```txt
=== BACKUP INFORMATION ===
Timestamp: Sun Aug 17 19:16:26 -04 2025
Description: Primer backup del sistema completo
Type: Local | VPS
Git Commit: 6bfa4bb...
Git Branch: feature/mejoras-agosto-13
Project Path: /path/to/project
Created by: backup-manager.sh

=== RESTORE COMMAND ===
./scripts/backup-manager.sh restore-local local_backup_20250817_191623
```

## ⚠️ **Proceso de Rollback Seguro**

### **Antes de Restaurar:**
1. **¡CREAR BACKUP DEL ESTADO ACTUAL!** (automático)
2. Confirmar que el backup a restaurar es correcto
3. Si es VPS, verificar que no hay usuarios activos

### **Rollback Local:**
```bash
# 1. Verificar backups disponibles
./scripts/backup-manager.sh list

# 2. Restaurar (pide confirmación)
./scripts/backup-manager.sh restore-local NOMBRE_BACKUP

# 3. El script automáticamente:
#    - Crea backup del estado actual
#    - Preserva archivos críticos (.git, config.php)
#    - Restaura el backup seleccionado
#    - Muestra información de lo restaurado
```

### **Rollback VPS (¡CRÍTICO!):**
```bash
# SOLO EN EMERGENCIAS - Afecta producción
./scripts/backup-manager.sh restore-vps NOMBRE_BACKUP

# Requiere confirmación: "SI CONFIRMO"
# Automáticamente:
# - Crea backup del VPS actual
# - Sube backup al VPS
# - Restaura en producción
# - Preserva .git y config.php
```

## 🔄 **Workflows Recomendados**

### **Desarrollo Diario:**
```bash
# Antes de empezar
./scripts/backup-manager.sh backup-local "Inicio del día"

# Antes de cambios importantes
./scripts/backup-manager.sh backup-local "Antes de implementar nueva feature"

# Después de completar feature
./scripts/backup-manager.sh backup-local "Feature completada - lista para testing"
```

### **Deploy a Producción:**
```bash
# SIEMPRE antes de deploy
./scripts/backup-manager.sh backup-vps "Pre-deploy backup"

# Después de deploy exitoso
./scripts/backup-manager.sh backup-vps "Post-deploy estable"
```

### **Emergencias:**
```bash
# Si algo se rompe en local
./scripts/backup-manager.sh list
./scripts/backup-manager.sh restore-local ULTIMO_BACKUP_BUENO

# Si algo se rompe en VPS
./scripts/backup-manager.sh restore-vps ULTIMO_BACKUP_VPS_BUENO
```

## 🛠️ **Características Técnicas**

### **Lo que se Incluye:**
- ✅ Todos los archivos del proyecto
- ✅ Base de datos SQLite
- ✅ Archivos de configuración (sin credenciales)
- ✅ Información de Git (commit, branch)
- ✅ Timestamp preciso

### **Lo que se Excluye:**
- ❌ Carpeta `.git` (preservada en rollback)
- ❌ `api/temp/*` (archivos temporales)
- ❌ `logs/*` (logs del sistema)
- ❌ `backups/*` (evitar backups recursivos)

### **Seguridad:**
- 🔒 Preserva `.git` y `config.php` durante restore
- 🔒 Requiere confirmación para operaciones críticas
- 🔒 Crea backup automático antes de restore
- 🔒 No incluye credenciales en backups

## 📊 **Integración con Otros Scripts**

### **VPS Tools:**
```bash
./scripts/vps-tools.sh backup "descripción"
# Usa backup-manager.sh internamente
```

### **Git Workflow:**
- Los backups se crean antes de operaciones Git críticas
- Información de commit incluida en BACKUP_INFO.txt
- Compatible con cualquier branch

## 🚨 **Situaciones de Emergencia**

### **Si el backup-manager falla:**
```bash
# Backup manual básico
cp -r . ../emergency_backup_$(date +%Y%m%d_%H%M%S)

# En VPS
sshpass -p '39933993' ssh root@51.222.25.222 "cd /var/www && cp -r mbi-v3 mbi-v3_emergency_$(date +%Y%m%d_%H%M%S)"
```

### **Si no puedes restaurar:**
```bash
# Verificar que existe el backup
ls -la backups/

# Restauración manual
cp -r backups/NOMBRE_BACKUP/* .
```

## 💡 **Mejores Prácticas**

1. **Backup antes de cambios importantes** ✅
2. **Verificar backups periódicamente** ✅
3. **Limpiar backups antiguos** (automático) ✅
4. **Probar proceso de restore** en desarrollo ✅
5. **Nunca restaurar VPS sin backup previo** ⚠️

## 🎯 **Para Claude Code**

**Comandos que puedes usar directamente:**

```bash
# Crear backup antes de cambios
./scripts/backup-manager.sh backup-full "Claude: Antes de implementar X"

# Listar backups disponibles
./scripts/backup-manager.sh list

# En emergencia (local)
./scripts/backup-manager.sh restore-local NOMBRE_BACKUP

# SOLO en emergencia crítica (VPS)
# ¡PREGUNTAR AL USUARIO PRIMERO!
./scripts/backup-manager.sh restore-vps NOMBRE_BACKUP
```

**Integración automática:**
- VPS tools incluye backup integrado
- Todos los scripts manejan errores gracefully
- Confirmaciones requeridas para operaciones críticas

---

**🛡️ ¡Tu proyecto está protegido! Nunca más perderás trabajo importante. 🛡️**