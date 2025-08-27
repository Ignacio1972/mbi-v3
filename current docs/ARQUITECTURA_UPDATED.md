# 🏗️ Arquitectura del Sistema MBI-v3 [ACTUALIZADA]
**Sistema de Radio y Anuncios Automatizados para Mall Barrio Independencia**

> **Última actualización:** 2025-08-27  
> **Versión:** 3.1.0  
> **Estado:** En desarrollo activo

---

## 📋 Tabla de Contenidos
1. [Visión General](#visión-general)
2. [Arquitectura de Alto Nivel](#arquitectura-de-alto-nivel)
3. [Stack Tecnológico](#stack-tecnológico)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Módulos Principales](#módulos-principales)
6. [Sistema Playground](#sistema-playground)
7. [Sistema de Comunicación](#sistema-de-comunicación)
8. [APIs y Servicios](#apis-y-servicios)
9. [Flujo de Datos](#flujo-de-datos)
10. [Base de Datos](#base-de-datos)
11. [Seguridad](#seguridad)
12. [Despliegue](#despliegue)

---

## 🎯 Visión General

MBI-v3 es un sistema modular de gestión de audio automatizado diseñado para centros comerciales. Permite:
- Conversión de texto a voz (TTS) usando ElevenLabs con **voces dinámicas**
- Sistema de **testing y desarrollo** integrado (Playground)
- Interrumpir música en AzuraCast para anuncios
- Programación automática de mensajes
- Gestión de biblioteca de audios con favoritos
- **Administración de voces personalizadas**

### Características Principales
- **Arquitectura Modular**: Sistema basado en módulos independientes
- **Event-Driven**: Comunicación entre módulos via Event Bus
- **SPA (Single Page Application)**: Frontend reactivo sin recarga de página
- **API RESTful**: Backend PHP para procesamiento y persistencia
- **Real-time**: Integración con sistema de radio en vivo
- **Playground System**: Entorno de testing y desarrollo integrado

---

## 🏛️ Arquitectura de Alto Nivel [ACTUALIZADA]

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND (SPA)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Radio   │  │ Message  │  │ Campaign │  │ Calendar │       │
│  │  Module  │  │  Config  │  │  Library │  │  Module  │       │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘  └─────┬────┘       │
│        │              │              │              │            │
│  ┌─────┴──────────────┴──────────────┴─────────────┴─────┐     │
│  │                    Shared Core                         │     │
│  │  ┌────────────┐  ┌──────────────┐  ┌──────────────┐  │     │
│  │  │ Event Bus  │  │ Module Loader│  │  API Client  │  │     │
│  │  └────────────┘  └──────────────┘  └──────────────┘  │     │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │     │
│  │  │Voice Service │  │Audio Manager │  │Storage Mgr │  │     │
│  │  └──────────────┘  └──────────────┘  └────────────┘  │     │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    PLAYGROUND SYSTEM                      │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐               │   │
│  │  │TTS Tester│  │Voice Admin│  │ Monitors │               │   │
│  │  └──────────┘  └──────────┘  └──────────┘               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└──────────────────────────┬────────────────────────────────────┘
                           │ HTTP/AJAX
┌──────────────────────────┴────────────────────────────────────┐
│                         BACKEND (PHP)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  generate.php│  │biblioteca.php│  │scheduler.php │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                  │                  │                 │
│  ┌──────┴──────────────────┴──────────────────┴────────┐       │
│  │               Service Layer                          │       │
│  │  ┌─────────────────┐  ┌─────────┐  ┌─────────┐     │       │
│  │  │TTS Enhanced Mgr │  │File Mgr │  │Schedule │     │       │
│  │  └─────────────────┘  └─────────┘  └─────────┘     │       │
│  └────────────────────────────────────────────────────────┘     │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 Playground Backend APIs                   │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │   │
│  │  │voice-manager │  │voice-admin   │  │quota/logs    │   │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└──────────────────────────┬────────────────────────────────────┘
                           │
┌──────────────────────────┴────────────────────────────────────┐
│                    EXTERNAL SERVICES                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │  ElevenLabs  │  │  AzuraCast   │  │   SQLite DBs │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└────────────────────────────────────────────────────────────────┘
```

---

## 💻 Stack Tecnológico

### Frontend
- **HTML5/CSS3**: Estructura y estilos base
- **JavaScript ES6+**: Lógica de aplicación con módulos nativos
- **FullCalendar v6**: Visualización de calendario
- **No Framework**: Vanilla JS para máximo control y mínimo overhead
- **Voice Service**: Sistema centralizado de gestión de voces

### Backend
- **PHP 8.x**: Procesamiento del lado del servidor
- **SQLite**: Múltiples bases de datos para diferentes módulos
- **cURL**: Comunicación con APIs externas
- **TTS Enhanced Service**: Servicio mejorado de Text-to-Speech

### Servicios Externos
- **ElevenLabs API**: Conversión texto a voz con voces dinámicas
- **AzuraCast API**: Control de radio streaming
- **GitHub**: Control de versiones

### Infraestructura
- **VPS Linux**: Servidor de desarrollo (51.222.25.222)
- **Apache/Nginx**: Servidor web
- **Git**: Versionado y deployment
- **Cron**: Programación de tareas automáticas

---

## 📁 Estructura del Proyecto [ACTUALIZADA]

```
mbi-v3/
├── index.html                  # Punto de entrada SPA
├── api/                        # Backend PHP
│   ├── config.php              # Configuración y credenciales
│   ├── generate.php            # API de generación TTS con voces dinámicas
│   ├── biblioteca.php          # Gestión de archivos
│   ├── library-metadata.php   # Metadatos de biblioteca
│   ├── audio-scheduler.php    # Sistema de programación
│   ├── audio-favorites.php    # Sistema de favoritos
│   ├── audio-metadata.php     # Metadatos de audio
│   ├── saved-messages.php     # Mensajes guardados
│   ├── test-voices.php        # Testing de voces
│   ├── test-azuracast.php     # Testing de conexión radio
│   ├── data/                   # Datos de configuración
│   │   ├── voices-config.json # Configuración de voces dinámicas
│   │   └── custom-voices.json # Voces personalizadas
│   ├── db/                     # SQLite databases
│   │   └── schedules.db       # DB de programaciones
│   └── services/               # Servicios PHP
│       ├── tts-service-enhanced.php  # Servicio TTS mejorado
│       ├── audio-processor.php       # Procesamiento de audio
│       └── radio-service.php         # Servicio de radio
├── shared/                     # Core del sistema [EXPANDIDO]
│   ├── event-bus.js           # Sistema de eventos
│   ├── module-loader.js       # Cargador dinámico
│   ├── router.js              # Enrutamiento SPA
│   ├── api-client.js          # Cliente HTTP
│   ├── data-schemas.js        # Esquemas de datos
│   ├── voice-service.js       # Servicio de voces [NUEVO]
│   ├── audio-manager.js       # Gestor de audio [NUEVO]
│   └── storage-manager.js     # Gestor de almacenamiento [NUEVO]
├── modules/                    # Módulos funcionales
│   ├── radio/                 # Control de radio en vivo
│   │   ├── index.js
│   │   ├── popup.html
│   │   └── style.css
│   ├── message-configurator/  # Creador de mensajes
│   │   ├── index.js
│   │   ├── api-integration.js
│   │   ├── state-manager.js
│   │   ├── component-factory.js
│   │   ├── voice-presets.js
│   │   ├── components/        # Componentes UI
│   │   ├── handlers/          # Manejadores de eventos
│   │   └── templates/         # Plantillas HTML
│   ├── campaign-library/      # Biblioteca de campañas
│   │   ├── index.js
│   │   ├── schedule-modal.js
│   │   ├── plugins/           # Plugins del módulo
│   │   │   └── scheduler-plugin.js
│   │   └── styles/
│   ├── audio-library/         # Biblioteca de audio [NUEVO]
│   │   ├── index.js
│   │   └── styles/
│   └── calendar/              # Calendario de eventos
│       ├── index.js
│       ├── components/
│       │   ├── calendar-view.js
│       │   ├── calendar-filters.js
│       │   ├── event-list.js
│       │   └── event-modal.js
│       ├── services/
│       └── templates/
├── playground/                 # Sistema de Testing [NUEVO]
│   ├── index.html             # Interfaz principal
│   ├── api/                   # APIs del playground
│   │   ├── voice-manager.php  # Gestión de voces
│   │   ├── voice-admin.php    # Administración de voces
│   │   ├── clean-voices.php   # Limpieza de voces
│   │   ├── logs.php           # Visor de logs
│   │   ├── quota.php          # Monitor de quota
│   │   └── ping.php           # Health check
│   ├── assets/
│   │   ├── css/
│   │   │   └── playground.css
│   │   └── js/
│   │       ├── playground.js  # Controlador principal
│   │       ├── voice-admin.js # Admin de voces
│   │       └── monitors.js    # Monitores del sistema
│   ├── logger/                # Sistema de logging
│   └── logs/                  # Archivos de log
├── calendario/                 # Sistema de calendario [SEPARADO]
│   ├── api/
│   │   ├── calendar-api.php
│   │   ├── calendar-service.php
│   │   ├── scheduler.php
│   │   └── db/
│   │       └── calendar.db   # Base de datos del calendario
│   └── logs/
├── assets/                    # Recursos estáticos
│   └── css/
│       └── base.css
├── mockups/                   # Mockups de diseño [NUEVO]
├── backups/                   # Backups automáticos
├── logs/                      # Logs del sistema
├── current docs/              # Documentación actualizada [NUEVO]
└── old docs/                  # Documentación anterior [NUEVO]
```

---

## 🧩 Módulos Principales [ACTUALIZADO]

### 1. Radio Module (`/modules/radio/`)
**Propósito**: Control de radio en vivo y reproducción inmediata
- Interrumpir música para anuncios urgentes
- Preview de audios antes de transmitir
- Control de volumen y fade in/out
- Estado en tiempo real de AzuraCast
- Ventana popup para control independiente

### 2. Message Configurator (`/modules/message-configurator/`)
**Propósito**: Creación y generación de mensajes TTS
- Editor de texto con preview
- **Selección de voces dinámicas desde voice-service**
- Ajustes avanzados de voz (stability, similarity_boost, style)
- Generación y descarga de MP3
- Perfiles de voz personalizados
- Integración con voice-service.js

### 3. Campaign Library (`/modules/campaign-library/`)
**Propósito**: Gestión de biblioteca de audios
- Upload/download de archivos
- Organización por categorías
- Programación de reproducción (schedule-modal.js)
- Plugin de scheduler integrado
- Metadatos y búsqueda avanzada
- Sincronización con backend

### 4. Audio Library (`/modules/audio-library/`) [NUEVO]
**Propósito**: Gestión de favoritos y metadatos de audio
- Sistema de favoritos
- Metadatos extendidos
- Migración de localStorage a SQLite
- Búsqueda y filtrado

### 5. Calendar Module (`/modules/calendar/`)
**Propósito**: Visualización y gestión de programación
- Vista calendario (día/semana/mes)
- Filtros por tipo de schedule (interval/specific/once)
- Tooltips con información detallada
- Eventos próximos
- Lista de todas las programaciones activas
- Base de datos SQLite separada

---

## 🧪 Sistema Playground [NUEVA SECCIÓN]

### Propósito
Sistema de testing y desarrollo para probar funcionalidades del TTS y administrar voces.

### Características Principales
1. **TTS Tester**
   - Prueba de voces en tiempo real
   - **Envío directo de voces a generate.php**
   - Ajuste de parámetros de voz
   - Preview instantáneo

2. **Voice Explorer**
   - Exploración de voces disponibles
   - Comparación de voces
   - Testing de parámetros

3. **Voice Admin**
   - Administración de voces personalizadas
   - CRUD de voces en el sistema
   - Sincronización con ElevenLabs

4. **Monitors**
   - Monitor de quota de ElevenLabs
   - Visualización de logs en tiempo real
   - Health checks del sistema
   - Estadísticas de uso

### Integración con Sistema Principal
```javascript
// Playground puede enviar voces directamente al generador
PlaygroundApp.loadVoices() -> /api/generate.php (action: 'list_voices')
PlaygroundApp.generateTTS() -> /api/generate.php (action: 'generate_audio')
```

---

## 📡 Sistema de Comunicación [ACTUALIZADO]

### Event Bus (`/shared/event-bus.js`)
Sistema centralizado de eventos para comunicación entre módulos:

```javascript
// Eventos principales del sistema
'module:loaded'          // Módulo cargado
'module:unloaded'        // Módulo descargado
'navigation:change'      // Navegación entre módulos
'audio:generated'        // Audio TTS generado
'audio:generating'       // Audio en generación [NUEVO]
'audio:playing'          // Audio reproduciéndose [NUEVO]
'audio:ended'           // Audio terminado [NUEVO]
'library:file:added'     // Archivo agregado a biblioteca
'schedule:created'       // Schedule creado
'schedule:updated'       // Schedule actualizado
'schedule:deleted'       // Schedule eliminado
'radio:playing'          // Radio reproduciendo
'radio:stopped'          // Radio detenida
'radio:sending'         // Enviando a radio [NUEVO]
'radio:sent'           // Enviado a radio [NUEVO]
'voices:loaded'        // Voces cargadas [NUEVO]
'voices:cache:cleared' // Cache de voces limpiado [NUEVO]
```

### Module Loader (`/shared/module-loader.js`)
- Carga dinámica de módulos on-demand
- Gestión de ciclo de vida (load/unload)
- Inyección de dependencias
- Lazy loading de recursos
- Carga de estilos por módulo

### Voice Service (`/shared/voice-service.js`) [NUEVO]
- Carga dinámica de voces desde API
- Cache con TTL de 60 segundos
- Fallback a voz por defecto
- Sincronización con backend

### Audio Manager (`/shared/audio-manager.js`) [NUEVO]
- Gestión centralizada de reproducción
- Generación de audio via API
- Cache de audio generado
- Envío a radio

---

## 🔌 APIs y Servicios [ACTUALIZADO]

### APIs Internas (PHP)

#### 1. Generate API (`/api/generate.php`) [ACTUALIZADO]
```
POST /api/generate.php
Body: {
    action: 'generate_audio' | 'list_voices' | 'send_to_radio',
    text?: string,
    voice?: string,
    voice_settings?: {
        stability: number,
        similarity_boost: number,
        style: number,
        use_speaker_boost: boolean
    }
}
Response: {
    success: boolean,
    file_url?: string,
    voices?: object,
    error?: string
}
```

#### 2. Biblioteca API (`/api/biblioteca.php`)
```
GET /api/biblioteca.php?action=list
Response: {
    success: boolean,
    files: Array<{name, size, date}>
}

POST /api/biblioteca.php
Body: FormData (file upload)
Response: {
    success: boolean,
    filename: string
}
```

#### 3. Scheduler API (`/api/audio-scheduler.php`)
```
POST /api/audio-scheduler.php
Body: {
    action: 'create'|'list'|'delete'|'update',
    schedule_data?: {...}
}
Response: {
    success: boolean,
    schedules?: Array,
    id?: number
}
```

#### 4. Playground APIs [NUEVO]
```
POST /playground/api/voice-manager.php
- CRUD de voces personalizadas

POST /playground/api/voice-admin.php
- Administración avanzada de voces

GET /playground/api/quota.php
- Estado de quota de ElevenLabs

GET /playground/api/logs.php
- Visualización de logs del sistema
```

### APIs Externas

#### ElevenLabs TTS [ACTUALIZADO]
- Endpoint: `https://api.elevenlabs.io/v1/text-to-speech/`
- Autenticación: API Key en headers
- **Voces dinámicas cargadas desde configuración**
- Límites: Según plan contratado
- Cache de voces por 60 segundos

#### AzuraCast
- Endpoint: `http://51.222.25.222:8000/api/`
- Autenticación: API Key
- Funciones: play, stop, skip, queue

---

## 🔄 Flujo de Datos [ACTUALIZADO]

### Flujo de Generación TTS con Voces Dinámicas
```
1. Usuario selecciona voz en Message Configurator o Playground
2. Voice Service carga voces disponibles (con cache)
3. Frontend envía texto y configuración a generate.php
4. TTS Enhanced Service procesa con voice_settings
5. Backend llama a ElevenLabs API con voz seleccionada
6. Audio MP3 se guarda en /api/temp/
7. URL del archivo retorna al frontend
8. Usuario puede preview, descargar o enviar a radio
```

### Flujo de Playground Testing
```
1. Usuario accede a Playground
2. Sistema carga voces dinámicamente
3. Usuario configura parámetros de prueba
4. Envía directamente a generate.php
5. Preview instantáneo del resultado
6. Opción de guardar configuración
```

### Flujo de Programación
```
1. Usuario selecciona archivo en Campaign Library
2. Abre schedule-modal.js con plugin scheduler
3. Configura tipo (interval/specific/once)
4. Datos se envían a audio-scheduler.php
5. Se guarda en SQLite (calendar.db)
6. Calendar module se actualiza via Event Bus
7. Cron job ejecuta schedules activos
```

### Flujo de Reproducción en Vivo
```
1. Usuario hace clic en "Play" en Radio Module
2. Audio Manager envía comando a backend
3. Backend comunica con AzuraCast API
4. AzuraCast interrumpe stream actual
5. Reproduce archivo MP3
6. Eventos emitidos en cada etapa
7. Retorna a programación normal
```

---

## 💾 Base de Datos [ACTUALIZADO]

### Múltiples SQLite Databases

#### 1. Schedules DB (`/api/db/schedules.db`)
```sql
CREATE TABLE schedules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,
    title TEXT,
    schedule_type TEXT CHECK(schedule_type IN ('interval','specific','once')),
    interval_minutes INTEGER,
    interval_hours INTEGER,
    schedule_days TEXT,
    schedule_time TEXT,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 2. Calendar DB (`/calendario/api/db/calendar.db`)
```sql
CREATE TABLE calendar_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    start_datetime DATETIME,
    end_datetime DATETIME,
    type TEXT,
    audio_file TEXT,
    metadata TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audio_schedule (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id INTEGER,
    schedule_data TEXT,
    FOREIGN KEY (event_id) REFERENCES calendar_events(id)
);
```

#### 3. Audio Metadata DB
```sql
CREATE TABLE audio_files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT UNIQUE NOT NULL,
    title TEXT,
    duration INTEGER,
    size INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audio_favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,
    user_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔒 Seguridad

### Medidas Implementadas
1. **API Keys**: Protección de endpoints sensibles
2. **CORS**: Configurado para dominios permitidos
3. **Validación**: Input sanitization en PHP
4. **Rate Limiting**: En APIs externas y cache de voces
5. **HTTPS**: En producción (pendiente en dev)
6. **Voice Cache**: Reduce llamadas a API externa

### Consideraciones
- Credenciales en `config.php` (fuera de git)
- Archivos temporales con limpieza automática
- Logs de acceso y errores separados por módulo
- Backup automático de todas las DBs
- Sanitización de inputs en Playground

---

## 🚀 Despliegue

### Ambiente de Desarrollo
```bash
# VPS de desarrollo
ssh root@51.222.25.222
cd /var/www/mbi-v3

# Actualizar desde GitHub
git pull origin main

# Verificar servicios
systemctl status apache2
systemctl status php8.1-fpm

# Verificar Playground
curl http://51.222.25.222/mbi-v3/playground/
```

### Proceso de Deploy
1. **Development** (VPS): Cambios y pruebas
2. **Testing** (Playground): Validación de voces y TTS
3. **GitHub**: Commit y push
4. **Production**: Pull desde GitHub (cuando esté listo)

### Comandos Útiles
```bash
# Logs de PHP
tail -f /var/log/php8.1-fpm.log

# Logs de Apache
tail -f /var/log/apache2/error.log

# Logs de Playground
tail -f /var/www/mbi-v3/playground/logs/playground-*.log

# Verificar schedules activos
sqlite3 /var/www/mbi-v3/calendario/api/db/calendar.db "SELECT * FROM audio_schedule WHERE is_active=1;"

# Backup de bases de datos
for db in /var/www/mbi-v3/**/*.db; do 
    cp "$db" "/backup/$(basename $db .db)_$(date +%Y%m%d).db"
done

# Monitor de quota ElevenLabs
curl http://51.222.25.222/mbi-v3/playground/api/quota.php
```

---

## 📊 Métricas y Monitoreo

### KPIs del Sistema
- Uptime del servicio
- Cantidad de audios generados/día
- Voces más utilizadas
- Schedules activos
- Uso de API (ElevenLabs quota)
- Cache hits de voice-service
- Espacio en disco
- Performance de Playground

### Logs
- `/var/www/mbi-v3/logs/` - Logs de aplicación
- `/var/www/mbi-v3/api/logs/` - Logs de API
- `/var/www/mbi-v3/playground/logs/` - Logs de Playground
- `/var/www/mbi-v3/calendario/logs/` - Logs de calendario
- `/var/log/apache2/` - Logs del servidor

### Monitoreo en Playground
- Dashboard de métricas en tiempo real
- Visualización de logs
- Health checks automáticos
- Monitor de quota de API

---

## 🔮 Roadmap Técnico

### Próximas Mejoras
1. **WebSockets**: Para actualizaciones en tiempo real
2. **Docker**: Containerización del ambiente
3. **CI/CD**: Pipeline automatizado con GitHub Actions
4. **Tests**: Suite de pruebas automatizadas
5. **PWA**: Capacidades offline
6. **Multi-tenant**: Soporte para múltiples malls
7. **Voice Cloning**: Integración con servicios de clonación
8. **Analytics**: Dashboard de análisis de uso

### En Desarrollo
- Mejoras en Playground UI/UX
- Sistema de templates avanzado
- Integración con más servicios TTS
- Backup automatizado en la nube

---

## 📝 Notas de Arquitectura

### Decisiones de Diseño
- **No Framework JS**: Para mantener simplicidad y control total
- **Módulos independientes**: Facilita mantenimiento y escalabilidad
- **Event-driven**: Desacoplamiento entre componentes
- **SQLite múltiple**: Separación de concerns por dominio
- **PHP nativo**: Sin frameworks para reducir complejidad
- **Voice Service centralizado**: Optimización de llamadas API
- **Playground separado**: Testing sin afectar producción

### Patrones Utilizados
- **Module Pattern**: Encapsulación de funcionalidad
- **Observer Pattern**: Event Bus
- **Singleton Pattern**: Module Loader, API Client, Voice Service
- **Factory Pattern**: Creación de componentes UI
- **Repository Pattern**: Acceso a datos
- **Cache Pattern**: Voice Service con TTL
- **Service Layer**: Separación de lógica de negocio

### Convenciones
- **Nomenclatura**: camelCase para JS, snake_case para PHP
- **Estructura**: 1 archivo = 1 responsabilidad
- **Comentarios**: JSDoc para documentación
- **Versionado**: Semantic Versioning
- **Backups**: Timestamp-based naming
- **Logs**: Separados por módulo y fecha

### Integración Crítica: Playground → TTS
El Playground tiene capacidad de:
1. **Cargar voces dinámicamente** desde `/api/generate.php`
2. **Enviar configuraciones de voz personalizadas** al generador
3. **Testear en tiempo real** sin afectar el sistema principal
4. **Administrar voces** mediante APIs dedicadas
5. **Monitorear el uso** y quota de ElevenLabs

---

*Esta documentación refleja el estado actual de la arquitectura MBI-v3 incluyendo el sistema Playground y las capacidades de voces dinámicas.*