# 🔐 VPS Access Guide for Claude Code

**IMPORTANTE**: Este documento permite a Claude Code trabajar directamente en el VPS de producción.

## 🎯 **Acceso Directo al VPS**

**Claude Code PUEDE conectarse directamente al VPS usando estos comandos:**

### 🔑 **Credenciales VPS:**
- **Host:** `51.222.25.222`
- **Usuario:** `root`
- **Password:** `39933993`
- **Directorio del proyecto:** `/var/www/mbi-v3`

### 🔌 **Comandos Base de Conexión:**

```bash
# Comando SSH directo (funciona desde Claude Code)
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222

# Ejecutar comando específico
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "COMANDO_AQUI"

# Navegar al proyecto
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && pwd"
```

## 🛠️ **Operaciones Comunes VPS**

### **1. Git Operations:**
```bash
# Ver estado del repositorio
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && git status"

# Commit y push
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && git add -A && git commit -m 'MENSAJE' && git push origin main"

# Pull desde GitHub
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && git pull origin main"
```

### **2. File Operations:**
```bash
# Listar archivos
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && ls -la"

# Ver contenido de archivo
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && cat ARCHIVO.php"

# Editar archivo (requiere transferencia)
# Usar workflow Local → VPS para ediciones complejas
```

### **3. Service Operations:**
```bash
# Verificar servicios web
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "systemctl status nginx"

# Verificar AzuraCast
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "docker ps | grep azuracast"

# Ver logs del proyecto
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && find . -name '*.log' -exec tail -n 20 {} \;"
```

## 🔄 **Workflow VPS ↔ Local**

### **Escenario 1: Trabajar SOLO en VPS**
```bash
# Para cambios simples, configuración, debugging
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && COMANDOS"
```

### **Escenario 2: Workflow Híbrido (RECOMENDADO)**
```bash
# 1. Desarrollar localmente
cd /Users/hrm/Documents/MBI3/mbi-v3
# ... hacer cambios ...

# 2. Commit local
git add -A && git commit -m "Desarrollo local: CAMBIOS"

# 3. Push desde local
git push origin main

# 4. Pull en VPS
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && git pull origin main"

# 5. Verificar en producción
# http://51.222.25.222:3000/
```

### **Escenario 3: Sync VPS → Local**
```bash
# Si el VPS tiene cambios que necesitas localmente
cd /Users/hrm/Documents/MBI3/mbi-v3
git pull origin main
```

## ⚡ **Scripts de Automatización**

### **Script 1: VPS Quick Status**
```bash
alias vps-status='sshpass -p "39933993" ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && echo \"=== GIT STATUS ===\" && git status && echo \"=== DISK USAGE ===\" && df -h /var/www && echo \"=== LAST COMMITS ===\" && git log --oneline -5"'
```

### **Script 2: VPS Quick Deploy**
```bash
alias vps-deploy='sshpass -p "39933993" ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && git add -A && git commit -m \"VPS Update: $(date)\" && git push origin main"'
```

### **Script 3: VPS Emergency Backup**
```bash
alias vps-backup='sshpass -p "39933993" ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www && tar -czf mbi-v3-backup-$(date +%Y%m%d-%H%M).tar.gz mbi-v3/"'
```

## 🎯 **URLs del Proyecto**

- **🌐 Producción:** http://51.222.25.222:3000/
- **🎵 Radio Stream:** http://51.222.25.222/listen/ovh/radio.mp3
- **📡 AzuraCast Admin:** http://51.222.25.222:8000/

## ⚠️ **Consideraciones Importantes**

### **Seguridad:**
- ✅ VPS usa autenticación por password (no SSH keys requeridas)
- ✅ Conexión funciona desde Claude Code directamente
- ⚠️ Password está en plain text - solo para desarrollo

### **Limitaciones VPS:**
- ❌ **NO tocar configuración AzuraCast** (puertos 8000, 8443)
- ❌ **NO modificar configuración Nginx** sin backup
- ❌ **NO eliminar archivos de sistema** fuera de `/var/www/mbi-v3`
- ✅ **SÍ se puede** trabajar libremente en el directorio del proyecto

### **Backup Strategy:**
- 🔄 Git push automático cada cambio importante
- 💾 Backup manual antes de cambios críticos
- 📅 Claude Code puede ejecutar backups automáticos

## 🤖 **Instrucciones para Claude Code**

**Cuando un nuevo Claude instance lea este documento:**

1. **✅ PUEDES** usar comandos SSH directos con sshpass
2. **✅ PUEDES** hacer git operations en el VPS
3. **✅ PUEDES** leer/escribir archivos del proyecto
4. **✅ PUEDES** verificar servicios y logs
5. **⚠️ PREGUNTA** antes de modificar configuración del servidor
6. **⚠️ EVITA** cambios en AzuraCast o Nginx sin supervisión

### **Comandos de Verificación Inicial:**
```bash
# Verificar que SSH funciona
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "whoami && pwd"

# Verificar proyecto
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && ls -la && git status"

# Verificar URL funciona
curl -I http://51.222.25.222:3000/
```

## 📞 **Contacto de Emergencia**

Si algo falla gravemente:
1. **Rollback Git:** `git reset --hard HEAD~1`
2. **Backup Restore:** Usar backup más reciente
3. **Restart Services:** `systemctl restart nginx`
4. **Informar al usuario** inmediatamente

---

**RECUERDA: Este VPS ejecuta un sistema de radio EN VIVO. Los errores afectan un negocio real.**

⚡ **Siempre hacer backup antes de cambios críticos** ⚡