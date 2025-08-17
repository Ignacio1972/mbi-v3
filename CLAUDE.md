# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.


**IMPORTANTE**: 

Vamos a trabajar LIVE en el VPS por lo tanto es MUY importante estar haciendo GITs y backups regularmente.

root@51.222.25.222 cd /var/var/www/mbi-v3
Password:39933993

### URL DE PRODUCCIÓN:
**🚨 IMPORTANTE:** El proyecto está disponible en: **http://51.222.25.222:3000/**

### PROCESO OBLIGATORIO:
1. REVISAR → 2. TESTEAR → 3. PROPONER 4. ESPERAR APROBACIÓN → 5.BACKUP o GIT 6. IMPLEMENTAR

### ⚠️ ADVERTENCIA CRÍTICA:
**NO TOCAR PUERTOS DE AZURACAST** - El servidor usa múltiples puertos para radio streaming. Solo usar puerto 3000 para el proyecto web.

### FILOSOFIA
Siempre encontrar la causa del problema antes de escribir codigo. 

## 📋 System Overview

**TTS Mall v3** - Sistema de Radio y Anuncios Automatizados para Mall Barrio Independencia

### ¿Qué es en términos simples?
Imagina una **radio inteligente del centro comercial** que puede:
- 🎤 Convertir texto escrito en voz natural (como Siri pero para el mall)
- 📻 Interrumpir la música para dar anuncios importantes
- 📅 Programar mensajes automáticos (ej: "El mall cierra en 30 minutos")
- 📚 Guardar una biblioteca de anuncios para reutilizar



### Estructura Técnica Real:
```
mbi-v3/
├── index.html              # Página principal (como la entrada del mall)
├── api/                    # Servidor (como la oficina administrativa)
│   ├── config.php          # Configuración (llaves del sistema)
│   ├── generate.php        # Generador de voz
│   └── biblioteca.php      # Gestor de archivos
├── shared/                 # Sistema central (como los pasillos del mall)
│   ├── event-bus.js        # Comunicación entre módulos
│   ├── module-loader.js    # Cargador de secciones
│   └── router.js           # Navegación
└── modules/                # Los 4 departamentos
    ├── radio/              # Módulo de radio en vivo
    ├── message-configurator/# Creador de mensajes
    ├── campaign-library/   # Biblioteca de anuncios
    └── calendar/           # Programador de eventos
```

## 🚀 Development Commands (Con Explicaciones)

### Iniciar el Sistema Localmente

```bash
# EXPLICACIÓN: Esto es como "prender" el sistema en tu computadora (SOLO DESARROLLO)
php -S localhost:8000

# Lo que verás: "Development server started at http://localhost:8000"
# Abre tu navegador y ve a esa dirección

# 🌐 PRODUCCIÓN: Usar siempre http://51.222.25.222:3000/
```

### Configuración Inicial (Primera vez)

```bash
# 1. COPIAR CONFIGURACIÓN
# Explicación: Como sacar una copia de las llaves del mall
cp api/config.example.php api/config.php
# Luego edita config.php con tus claves API

# 2. CREAR BASE DE DATOS
# Explicación: Como preparar el archivador de eventos
php calendario/api/db/init-db.php
# Verás: "✅ Base de datos inicializada"

# 3. DAR PERMISOS
# Explicación: Como darle acceso al sistema para guardar archivos
chmod -R 777 api/temp calendario/logs
# No verás nada, pero es necesario
```

### Comandos de Verificación

```bash
# VER SI HAY ERRORES PHP
# Como revisar si hay problemas en el sistema
php -l api/generate.php
# Verás: "No syntax errors detected"

# VER LOGS DEL SISTEMA
# Como ver el historial de lo que ha pasado
tail -f calendario/logs/scheduler/$(date +%Y-%m-%d).log
# Verás los eventos del día actual

# PROBAR CONEXIÓN CON RADIO
php api/test-azuracast.php
# Verás: "✅ Conexión exitosa" o un error explicativo
```

## 🔧 Configuration Explained

### Archivo: `api/config.php`

```php
// CLAVE DE ELEVENLABS (Servicio de Voz)
// Como: La llave para que el sistema pueda hablar
define('ELEVENLABS_API_KEY', 'tu_clave_aqui');

// CONEXIÓN CON LA RADIO
// Como: El número de teléfono de la radio del mall
define('AZURACAST_BASE_URL', 'http://51.222.25.222');
define('AZURACAST_API_KEY', 'tu_clave_de_radio');

// CARPETA DE ARCHIVOS TEMPORALES
// Como: El escritorio donde se guardan los borradores
define('UPLOAD_DIR', __DIR__ . '/temp/');
```


## 📚 Module Interface (Para Referencia Técnica)

Todos los módulos deben implementar:
```javascript
class MyModule {
    getName() { return 'module-name'; }
    async load(container) { /* Initialize */ }
    async unload() { /* Cleanup */ }
}
```

## 🎯 Key Technical Details

### Module Loading Flow
1. Usuario hace click en un botón del menú
2. Router detecta el cambio
3. ModuleLoader descarga módulo actual
4. Carga el nuevo módulo
5. El módulo se muestra en pantalla

### TTS Generation Pipeline
1. Usuario escribe texto
2. Sistema envía a ElevenLabs API
3. ElevenLabs genera audio MP3
4. Sistema procesa audio (agrega silencios)
5. Sube a AzuraCast (radio)
6. Usuario puede reproducir o enviar

### File Management
- **Temporales**: Se borran después de 1 hora
- **Biblioteca**: Se guardan permanentemente
- **Formatos**: Solo MP3 para compatibilidad

## 🔐 Security Notes

- **NUNCA** compartir API keys
- **SIEMPRE** usar config.php para claves
- **NO** subir config.php a GitHub
- Los archivos temporales se limpian automáticamente

## 📝 Common Development Tasks

### Agregar una Nueva Voz
```
UBICACIÓN: modules/message-configurator/voice-presets.js
AGREGAR: { id: 'nueva-voz', name: 'Nombre Visible' }
```

### Cambiar Duración de Mensajes
```
UBICACIÓN: api/config.php
MODIFICAR: define('MAX_MESSAGE_LENGTH', 500);
```

### Debugging Básico
```javascript
// En el navegador, presiona F12 y ve a Console
console.log('Verificando...'); // Para ver mensajes
```

## 🎓 Learning Path para Principiantes

### Semana 1: Operación Básica
- Crear anuncios simples
- Usar diferentes voces
- Enviar a radio

### Semana 2: Funciones Avanzadas
- Guardar en biblioteca
- Programar eventos
- Usar plantillas

### Mes 1: Administración
- Revisar logs
- Resolver problemas comunes
- Personalizar mensajes

## 🆘 Comandos de Emergencia

```bash
# SI TODO FALLA - Reiniciar desde cero
# 1. Detener el servidor (Ctrl+C)
# 2. Limpiar temporales
rm -rf api/temp/*.mp3
# 3. Reiniciar servidor (DESARROLLO)
php -S localhost:8000
# 🌐 PRODUCCIÓN: Verificar http://51.222.25.222:3000/
```

## 📞 Recordatorios Importantes

1. **Este es un sistema REAL** que afecta un negocio REAL
2. **Los errores pueden afectar** la experiencia de clientes
3. **Siempre hacer pruebas** antes de enviar a radio
4. **Guardar mensajes importantes** en la biblioteca
5. **Verificar el volumen** antes de transmitir

## 🎉 Mensajes de Éxito

Cuando algo funciona bien, verás:
- "✅ Audio generado correctamente"
- "📻 Enviado a la radio"
- "💾 Guardado en biblioteca"
- "📅 Evento programado"

## 🚀 Quick Reference Card

| Acción | Botón/Comando | Resultado |
|--------|---------------|-----------|
| Crear mensaje | ✏️ Texto Personalizado | Abre editor |
| Generar voz | 🎤 Generar Audio | Crea MP3 |
| Enviar a radio | 📻 Enviar a Radio | Suena en mall |
| Guardar | 💾 Guardar | Va a biblioteca |
| Programar | 📅 Calendario | Agenda evento |
| Ver biblioteca | 📚 Biblioteca | Lista mensajes |

---

**RECUERDA**: Siempre explica en términos simples ANTES de dar comandos técnicos. El usuario está aprendiendo y necesita entender el "por qué" antes del "cómo".