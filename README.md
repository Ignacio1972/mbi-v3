MBI-v3: Sistema de Radio y Text-to-Speech
Mall Barrio Independencia - Sistema de Anuncios Automatizados

Sistema profesional de generación y gestión de anuncios por voz para centros comerciales
Demo • Instalación • Documentación • Contribuir


📋 Tabla de Contenidos

Características
Arquitectura
Requisitos
Instalación
Configuración
Uso
Módulos
API
Desarrollo
Troubleshooting
Contribuir
Licencia


✨ Características Principales
🎯 Core Features

🎤 Text-to-Speech Avanzado: Integración con ElevenLabs para voces naturales en español
📻 Transmisión en Vivo: Interrupción automática de radio vía AzuraCast
📚 Biblioteca de Mensajes: Sistema CMS para gestión de anuncios
📅 Programación Automática: Calendario con ejecución vía cron
🎨 Interfaz Moderna: SPA con módulos lazy-loaded
🔄 Sin Compilación: ES6 modules nativos, no requiere build

🎙️ Voces Disponibles

30+ voces profesionales en español (chileno y neutro)
Configuración granular de estilo, estabilidad y expresividad
Perfiles pre-configurados por tipo de anuncio
Preview en tiempo real antes de transmitir

📡 Integración con Radio

Interrupción inmediata de programación
Cola de mensajes prioritarios
Historial de reproducción
Monitoreo en tiempo real


🏗️ Arquitectura
Frontend
┌─────────────────────────────────────┐
│         index.html (SPA)            │
├─────────────────────────────────────┤
│          Event Bus System           │
├──────────┬──────────┬──────────────┤
│  Router  │  Module  │   Storage    │
│          │  Loader  │   Manager    │
├──────────┴──────────┴──────────────┤
│            Modules                  │
├──────┬──────┬──────┬───────────────┤
│Config│ Lib  │ Cal  │    Radio      │
└──────┴──────┴──────┴───────────────┘
Backend
┌─────────────────────────────────────┐
│         PHP 8.1 REST API            │
├─────────────────────────────────────┤
│     ElevenLabs  │   AzuraCast       │
├─────────────────┴───────────────────┤
│     SQLite DB   │   File System     │
└─────────────────────────────────────┘

📦 Requisitos del Sistema
Servidor

OS: Ubuntu 20.04+ / Debian 11+
Web Server: Nginx 1.18+ o Apache 2.4+
PHP: 8.1+ con extensiones:

curl
json
sqlite3
mbstring


FFmpeg: Para procesamiento de audio
Docker: Para integración con AzuraCast

Cliente

Navegadores soportados:

Chrome 90+
Firefox 88+
Safari 14+
Edge 90+


JavaScript: ES6 modules support requerido

APIs Externas

ElevenLabs: API key requerida
AzuraCast: Instancia configurada con API key


🚀 Instalación Rápida
1. Clonar el repositorio
bashgit clone https://github.com/Ignacio1972/mbi-v3.git
cd mbi-v3
2. Configurar permisos
bash# Crear directorios necesarios
mkdir -p api/temp api/logs calendario/logs

# Asignar permisos
chmod -R 755 .
chmod -R 777 api/temp api/logs calendario/logs
chown -R www-data:www-data .
3. Configurar API keys
bash# Copiar archivo de configuración
cp api/config.example.php api/config.php

# Editar con tus credenciales
nano api/config.php
4. Inicializar base de datos
bash# Ejecutar script de inicialización
php calendario/api/db/init-db.php
5. Configurar servidor web
Nginx
nginxserver {
    listen 80;
    server_name tu-dominio.com;
    root /var/www/mbi-v3;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
Apache
apache<VirtualHost *:80>
    ServerName tu-dominio.com
    DocumentRoot /var/www/mbi-v3

    <Directory /var/www/mbi-v3>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/var/run/php/php8.1-fpm.sock|fcgi://localhost"
    </FilesMatch>
</VirtualHost>
6. Configurar cron para calendario (opcional)
bash# Agregar al crontab
crontab -e

# Ejecutar cada minuto
* * * * * php /var/www/mbi-v3/calendario/api/cron/check-events.php >> /var/www/mbi-v3/calendario/logs/cron.log 2>&1

⚙️ Configuración
API Keys (api/config.php)
php<?php
// ElevenLabs
define('ELEVENLABS_API_KEY', 'tu_api_key_aqui');
define('ELEVENLABS_BASE_URL', 'https://api.elevenlabs.io/v1');

// AzuraCast
define('AZURACAST_BASE_URL', 'http://tu-servidor-azuracast');
define('AZURACAST_API_KEY', 'tu_api_key_aqui');
define('AZURACAST_STATION_ID', 1);

// Playlist ID para anuncios
define('PLAYLIST_ID_GRABACIONES', 3);

// Directorios
define('UPLOAD_DIR', __DIR__ . '/temp/');
define('MAX_FILE_AGE', 3600); // 1 hora
?>
Voces Disponibles
El sistema incluye 30+ voces pre-configuradas. Ver archivo modules/message-configurator/voice-presets.js para la lista completa.

💻 Uso
Acceso al Sistema

Navegar a http://tu-dominio.com
El sistema carga automáticamente en el módulo Radio

Flujo de Trabajo Típico
1. Crear un Mensaje

Ir a "✏️ Texto Personalizado"
Escribir o seleccionar plantilla
Elegir voz y ajustar configuración
Click en "Generar Audio"
Escuchar preview
"Guardar en Biblioteca" o "Enviar a Radio"

2. Gestionar Biblioteca

Ir a "📚 Biblioteca"
Buscar o filtrar mensajes
Acciones disponibles:

▶️ Reproducir
✏️ Editar título
📻 Enviar a radio
🗑️ Eliminar



3. Programar Anuncios

Ir a "📅 Calendario"
Click en fecha/hora deseada
Seleccionar archivo de biblioteca
Configurar repetición (opcional)
Guardar evento


📦 Módulos del Sistema
1. 📻 Radio

Control de transmisión en vivo
Interrupción inmediata
Monitor de estado
Historial de reproducción

2. ✏️ Message Configurator

Editor de texto con contador
Selector de voces con preview
Controles de voz avanzados
Plantillas predefinidas
Generación y preview de audio

3. 📚 Campaign Library

Gestión de mensajes guardados
Categorización y búsqueda
Reproducción directa
Envío a radio
Metadata editable

4. 📅 Calendar

Vista mensual/semanal/diaria
Drag & drop de eventos
Programación recurrente
Integración con biblioteca
Ejecución automática vía cron


🔌 API Reference
Endpoints Principales
POST /api/generate.php
Genera audio desde texto usando ElevenLabs.
Request:
json{
  "action": "generate_audio",
  "text": "Texto del mensaje",
  "voice": "cristian",
  "voice_settings": {
    "style": 0.5,
    "stability": 0.75,
    "similarity_boost": 0.8,
    "use_speaker_boost": true
  }
}
Response:
json{
  "success": true,
  "filename": "test_1234567890.mp3",
  "azuracast_filename": "tts20241128120000.mp3",
  "processed_text": "Texto procesado"
}
POST /api/biblioteca.php
Gestión de archivos en biblioteca.
Actions:

list_library: Lista archivos
delete_library_file: Elimina archivo
send_library_to_radio: Envía a radio
rename_file: Renombra con descripción

POST /api/library-metadata.php
Gestión de metadata de mensajes.
Actions:

save: Guardar mensaje
list: Listar mensajes
update: Actualizar mensaje
delete: Eliminar mensaje

Eventos del Sistema
El sistema usa un event bus para comunicación entre módulos:
javascript// Escuchar evento
eventBus.on('audio:generated', (data) => {
  console.log('Audio generado:', data);
});

// Emitir evento
eventBus.emit('message:saved', messageData);
Eventos principales:

module:loaded - Módulo cargado
audio:generated - Audio generado
message:saved - Mensaje guardado
radio:interrupted - Radio interrumpida
calendar:event:created - Evento creado


🛠️ Desarrollo
Estructura del Proyecto
mbi-v3/
├── 📄 index.html           # Entry point
├── 📁 api/                 # Backend PHP
│   ├── generate.php        # TTS generation
│   ├── biblioteca.php      # File management
│   └── config.php          # Configuration
├── 📁 shared/              # Core modules
│   ├── event-bus.js        # Event system
│   ├── module-loader.js    # Dynamic loading
│   └── router.js           # Navigation
├── 📁 modules/             # Feature modules
│   ├── message-configurator/
│   ├── campaign-library/
│   ├── calendar/
│   └── radio/
└── 📁 assets/              # Static resources
Crear un Nuevo Módulo

Crear estructura de carpetas

bashmkdir -p modules/mi-modulo/{components,services,styles,templates}

Crear archivo principal (modules/mi-modulo/index.js)

javascriptexport default class MiModulo {
    constructor() {
        this.name = 'mi-modulo';
        this.container = null;
    }
    
    getName() { return this.name; }
    
    async load(container) {
        this.container = container;
        // Inicializar módulo
        console.log('Mi módulo cargado');
    }
    
    async unload() {
        // Limpiar recursos
        this.container = null;
    }
}

Registrar ruta (shared/router.js)

javascriptthis.routes.set('/mi-modulo', 'mi-modulo');

Agregar navegación (index.html)

html<button class="tab-button" data-route="/mi-modulo">
    🆕 Mi Módulo
</button>
Convenciones de Código
JavaScript

ES6 modules nativos
camelCase para variables y funciones
PascalCase para clases
Async/await sobre callbacks
JSDoc para documentación

PHP

PSR-12 coding standard
Type hints cuando sea posible
Try-catch para manejo de errores
Logging de operaciones críticas

CSS

BEM methodology para clases
CSS variables para temas
Mobile-first responsive design
No frameworks CSS (vanilla)

Testing
Frontend
javascript// Abrir consola del navegador
// Verificar módulos cargados
moduleLoader.getLoadedModules();

// Test event bus
eventBus.emit('test:event', {data: 'test'});

// Verificar rutas
router.getCurrentRoute();
Backend
bash# Test de endpoints
curl -X POST http://localhost/api/generate.php \
  -H "Content-Type: application/json" \
  -d '{"action":"list_templates"}'

# Verificar logs
tail -f api/logs/tts-*.log

🐛 Troubleshooting
Problemas Comunes
"Module not loading"
javascript// Verificar en consola
console.log(moduleLoader.getLoadedModules());
// Check: Ruta en router.js
// Check: Export default en módulo
"Audio no se genera"
bash# Verificar API key
php -r "require 'api/config.php'; echo ELEVENLABS_API_KEY;"

# Check logs
tail -f api/logs/tts-*.log

# Test directo
php api/test-elevenlabs.php
"Radio no se interrumpe"
bash# Test AzuraCast connection
php api/test-azuracast.php

# Verificar Docker
docker ps | grep azuracast

# Check playlist ID
curl -H "X-API-Key: YOUR_KEY" \
  http://azuracast-server/api/station/1/playlists
"Permisos denegados"
bash# Fix permissions
sudo chown -R www-data:www-data /var/www/mbi-v3
sudo chmod -R 755 /var/www/mbi-v3
sudo chmod -R 777 api/temp api/logs
Logs del Sistema
Ubicación de logs

PHP: /api/logs/
Calendario: /calendario/logs/
Browser: Console del navegador (F12)

Habilitar debug mode
javascript// En event-bus.js
this.debug = true; // Cambiar a true

// En PHP
error_reporting(E_ALL);
ini_set('display_errors', 1);

🤝 Contribuir
Cómo Contribuir

Fork el repositorio
Crea una rama (git checkout -b feature/AmazingFeature)
Commit cambios (git commit -m 'Add AmazingFeature')
Push a la rama (git push origin feature/AmazingFeature)
Abre un Pull Request

Guías de Contribución
Antes de codificar

Leer Developer Protocol
Revisar issues existentes
Discutir cambios grandes en un issue primero

Estándares

Código en inglés, comentarios en español
Tests para nuevas features
Documentación actualizada
Commits semánticos

Commit Messages
feat: Agregar nueva voz
fix: Corregir error en calendario
docs: Actualizar README
style: Formatear código
refactor: Reorganizar módulo X
test: Agregar tests para Y
chore: Actualizar dependencias

📄 Licencia
Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para detalles.
MIT License

Copyright (c) 2024 Mall Barrio Independencia

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...

👥 Equipo

Desarrollo: Ignacio1972
Diseño UX: Equipo MBI
Infraestructura: DevOps MBI
QA: Testing Team


🙏 Agradecimientos

ElevenLabs - Por su increíble API de TTS
AzuraCast - Por el sistema de radio
La comunidad open source


📞 Contacto y Soporte

Issues: GitHub Issues
Email: soporte@mallbarrioindependencia.cl
Documentación: Wiki


🔄 Estado del Proyecto

✅ v3.0.0 - Versión estable actual
🚧 v3.1.0 - En desarrollo (nuevas voces, analytics)
📋 Roadmap: Ver ROADMAP.md


<div align="center">
Hecho con ❤️ para Mall Barrio Independencia
⬆ Volver arriba
</div>