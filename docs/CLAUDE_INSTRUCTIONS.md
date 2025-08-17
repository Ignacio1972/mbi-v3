# 🤖 Instrucciones para Claude Code - Proyecto MBI-v3

## 🎯 **CONTEXTO PRINCIPAL**

Eres Claude Code trabajando en el **Sistema TTS Mall v3** - un sistema de anuncios automatizados para Mall Barrio Independencia que funciona EN VIVO en producción.

## 🔐 **ACCESO DIRECTO AL VPS**

**✅ TIENES ACCESO COMPLETO AL VPS DE PRODUCCIÓN:**

- **Host:** `51.222.25.222`
- **Usuario:** `root` 
- **Password:** `39933993`
- **Proyecto:** `/var/www/mbi-v3`
- **URL Producción:** http://51.222.25.222:3000/

### **Comandos que PUEDES usar directamente:**

```bash
# Conexión SSH básica
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222

# Ejecutar comandos en el proyecto
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && COMANDO"

# Git operations en VPS
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && git status"

# Script automatizado
./scripts/vps-tools.sh status
```

## 🔄 **WORKFLOWS DISPONIBLES**

### **1. Trabajo Directo en VPS (Cambios Simples)**
- ✅ Modificaciones de configuración
- ✅ Debugging y troubleshooting
- ✅ Git operations
- ✅ Verificación de servicios

### **2. Desarrollo Local + Deploy (Cambios Complejos)**
- ✅ Desarrollo de nuevas funcionalidades
- ✅ Modificaciones de UI/UX
- ✅ Testing extensivo
- ✅ Deploy automático al VPS

### **3. Workflow Híbrido (RECOMENDADO)**
- 🔄 Desarrollo local para features nuevas
- 🔄 Testing directo en VPS
- 🔄 Ajustes finos en VPS
- 🔄 Sync bidireccional

## ⚠️ **LIMITACIONES CRÍTICAS**

### **NO TOCAR:**
- ❌ Configuración AzuraCast (puertos 8000, 8443)
- ❌ Configuración Nginx principal
- ❌ Archivos de sistema fuera de `/var/www/mbi-v3`
- ❌ Configuraciones de Docker de AzuraCast

### **SÍ PUEDES:**
- ✅ Modificar cualquier archivo del proyecto
- ✅ Hacer commits y push
- ✅ Instalar dependencias del proyecto
- ✅ Verificar logs y servicios
- ✅ Crear backups

## 📋 **PROCESO OBLIGATORIO**

Antes de cualquier cambio importante:

1. **REVISAR** → Entender el problema/requerimiento
2. **TESTEAR** → Verificar estado actual
3. **PROPONER** → Explicar la solución al usuario
4. **ESPERAR APROBACIÓN** → No proceder sin confirmación
5. **BACKUP** → Hacer backup si es cambio crítico
6. **IMPLEMENTAR** → Ejecutar los cambios

## 🛠️ **HERRAMIENTAS DISPONIBLES**

### **Scripts Automatizados:**
```bash
./scripts/vps-tools.sh check      # Verificar conexión
./scripts/vps-tools.sh status     # Estado del proyecto
./scripts/vps-tools.sh deploy     # Deploy desde VPS
./scripts/vps-tools.sh sync-up    # Local → VPS
./scripts/vps-tools.sh sync-down  # VPS → Local
./scripts/vps-tools.sh backup     # Crear backup
./scripts/vps-tools.sh logs       # Ver logs
./scripts/vps-tools.sh services   # Estado servicios
```

### **Documentación Clave:**
- `docs/VPS_ACCESS_GUIDE.md` - Guía completa de acceso VPS
- `docs/TECHNICAL_DOCUMENTATION.md` - Documentación técnica
- `CLAUDE.md` - Instrucciones principales

## 🎯 **COMANDOS DE VERIFICACIÓN INICIAL**

Cuando empieces a trabajar, ejecuta:

```bash
# 1. Verificar conexión VPS
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "whoami && pwd"

# 2. Verificar proyecto
sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && ls -la && git status"

# 3. Verificar que la web funciona
curl -I http://51.222.25.222:3000/
```

## 🚨 **SITUACIONES DE EMERGENCIA**

Si algo falla:

1. **Rollback inmediato:**
   ```bash
   sshpass -p '39933993' ssh -o StrictHostKeyChecking=no root@51.222.25.222 "cd /var/www/mbi-v3 && git reset --hard HEAD~1"
   ```

2. **Verificar servicios:**
   ```bash
   ./scripts/vps-tools.sh services
   ```

3. **Informar al usuario** inmediatamente del problema

## 💡 **TIPS PARA CLAUDE CODE**

1. **Siempre verificar** que los comandos SSH funcionan antes de ejecutar operaciones complejas
2. **Hacer backup** antes de cambios que afecten configuración crítica
3. **Probar en local** primero cuando sea posible
4. **Documentar** todos los cambios importantes
5. **Verificar URL** después de cada deploy: http://51.222.25.222:3000/

## 🎯 **ARQUITECTURA DEL SISTEMA**

- **Frontend:** Vanilla JS con módulos ES6
- **Backend:** PHP 8.1 con SQLite
- **TTS:** ElevenLabs API
- **Radio:** AzuraCast integration
- **Web Server:** Nginx
- **Audio:** MP3 files en `/api/temp/` y `/biblioteca/`

## 📞 **RECORDATORIO FINAL**

**Este es un sistema EN VIVO que afecta un negocio real.**

- Los errores pueden interrumpir el servicio de radio
- Los clientes del mall dependen de este sistema
- Siempre priorizar estabilidad sobre velocidad
- Cuando tengas dudas, pregunta al usuario

---

**¡Tienes todas las herramientas para trabajar eficientemente en este proyecto!**