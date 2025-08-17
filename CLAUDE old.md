# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🎯 CONTEXTO PRINCIPAL: Asistente para Usuario Principiante

**IMPORTANTE**: El usuario de este sistema es COMPLETAMENTE NUEVO en programación. Tu prioridad es:
- **Explicar TODO antes de hacerlo**
- **Verificar comprensión antes de continuar**
- **Nunca asumir conocimientos previos**

-A veces debemos trabajar directo en el VPS porque hay cosas que solo se pueden probar ahi, en especial lo que tenga que ver con la integracion de Azuracast. 
-El VPS esta en root@51.222.25.222 cd /var/var/www/mbi-v3
-Si trabajamos en el VPS es importante hacer backups y commits no solo en el git del servidor sino ademas en el github de este proyecto que esta en https://github.com/Ignacio1972/mbi-v3

### Estructura OBLIGATORIA para respuestas:
```
🎯 **Lo que vamos a hacer:** [explicación simple]
🏪 **Cómo ayuda al mall:** [beneficio para el negocio]
📝 **Por qué es importante:** [contexto]
⚡ **Pasos a seguir:**
   1. [explicación del paso]
   2. [comando exacto a copiar]
   3. [qué debe aparecer en pantalla]
💡 **Si algo sale mal:** [soluciones comunes]
✅ **Sabrás que funcionó cuando:** [cómo verificar éxito]
```

## 📋 System Overview

**TTS Mall v3** - Sistema de Radio y Anuncios Automatizados para Mall Barrio Independencia

### ¿Qué es en términos simples?
Imagina una **radio inteligente del centro comercial** que puede:
- 🎤 Convertir texto escrito en voz natural (como Siri pero para el mall)
- 📻 Interrumpir la música para dar anuncios importantes
- 📅 Programar mensajes automáticos (ej: "El mall cierra en 30 minutos")
- 📚 Guardar una biblioteca de anuncios para reutilizar

## 🏗️ Architecture (Explicada Simple)

### El Sistema es como un Mall con 4 Departamentos:

1. **📻 Radio** - "La cabina de radio"
   - Controla qué está sonando ahora
   - Puede interrumpir la música con anuncios

2. **✏️ Texto Personalizado** - "El estudio de grabación"
   - Donde escribes los anuncios
   - Eliges la voz (hombre/mujer)
   - Generas el audio

3. **📚 Biblioteca** - "El archivo de anuncios"
   - Guarda todos los mensajes
   - Los organiza por categorías
   - Permite reutilizarlos

4. **📅 Calendario** - "La agenda del mall"
   - Programa anuncios automáticos
   - Ej: "Ofertas del día" cada mañana

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
# EXPLICACIÓN: Esto es como "prender" el sistema en tu computadora
php -S localhost:8000

# Lo que verás: "Development server started at http://localhost:8000"
# Abre tu navegador y ve a esa dirección
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

## 💡 Analogías para Entender el Sistema

| Concepto Técnico | Analogía Simple |
|-----------------|-----------------|
| **API** | El teléfono entre el sistema y los servicios |
| **Base de datos** | El archivador de todos los anuncios |
| **Módulos** | Las diferentes tiendas/secciones del mall |
| **Event Bus** | El sistema de intercomunicadores |
| **Router** | El directorio que dice dónde está cada cosa |
| **LocalStorage** | La memoria de tu navegador |
| **Cron Job** | Un empleado robot que ejecuta tareas programadas |

## 🔄 Flujos de Trabajo Comunes

### 1. Crear y Enviar un Anuncio Rápido

```
SITUACIÓN: "Necesito anunciar una oferta YA"

1. Abrir sistema → http://localhost:8000
2. Click en "✏️ Texto Personalizado"
3. Escribir: "Atención clientes, 50% de descuento en zapatería planta baja"
4. Elegir voz: "Cristian" (voz masculina chilena)
5. Click "Generar Audio" → Esperar 3-5 segundos
6. Escuchar preview → Click play para verificar
7. Click "📻 Enviar a Radio" → El anuncio suena en el mall
```

### 2. Programar Anuncio de Cierre Diario

```
SITUACIÓN: "Recordar el cierre todos los días a las 8:30 PM"

1. Crear el mensaje (pasos anteriores)
2. Click "💾 Guardar en Biblioteca"
3. Ponerle nombre: "Aviso cierre 30 min"
4. Ir a "📅 Calendario"
5. Click en 8:30 PM de hoy
6. Seleccionar el mensaje guardado
7. Marcar "Repetir diariamente"
8. Guardar evento
```

## 🚨 Troubleshooting para Principiantes

### Problema: "No se genera el audio"
```
🔍 CAUSA: Como si el micrófono estuviera desconectado
🛠️ SOLUCIÓN:
1. Verifica que hayas escrito algo en el texto
2. Revisa que la voz esté seleccionada
3. Si sigue sin funcionar, revisa api/config.php
   - Busca ELEVENLABS_API_KEY
   - Debe tener una clave (no estar vacío)
```

### Problema: "La radio no se interrumpe"
```
🔍 CAUSA: Como si los parlantes estuvieran en otro canal
🛠️ SOLUCIÓN:
1. Verifica que la radio esté prendida
2. Prueba con: php api/test-azuracast.php
3. Si hay error, revisa api/config.php
   - AZURACAST_BASE_URL debe ser correcto
   - AZURACAST_API_KEY debe estar configurado
```

### Problema: "No puedo guardar mensajes"
```
🔍 CAUSA: Como si el archivador estuviera lleno o cerrado
🛠️ SOLUCIÓN:
1. Ejecuta: chmod -R 777 api/temp
2. Verifica espacio en disco
3. Intenta con un nombre diferente
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
# 3. Reiniciar servidor
php -S localhost:8000
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