MBI-v3 Technical Documentation
Sistema Text-to-Speech para Mall Barrio Independencia
🎯 Overview
Sistema modular de generación y gestión de anuncios por voz para centros comerciales. Arquitectura ES6 con lazy loading, integración con ElevenLabs TTS y AzuraCast para streaming.

📁 Project Structure
mbi-v3/
├── index.html                    # Entry point - SPA container
├── api/                          # PHP Backend
│   ├── config.php                # API keys and settings
│   ├── generate.php              # TTS generation endpoint
│   ├── biblioteca.php            # Library management
│   ├── library-metadata.php     # Message metadata
│   └── services/                 # Backend services
│       ├── radio-service.php    # AzuraCast integration
│       └── audio-processor.php  # Audio processing
├── shared/                       # Core modules
│   ├── event-bus.js             # Event system (pub/sub)
│   ├── module-loader.js         # Dynamic module loading
│   ├── router.js                # Hash-based routing
│   ├── api-client.js            # HTTP client wrapper
│   ├── audio-manager.js         # Audio playback/generation
│   ├── storage-manager.js       # LocalStorage abstraction
│   └── data-schemas.js          # Data structures
├── modules/                      # Feature modules
│   ├── message-configurator/    # Message creation UI
│   ├── campaign-library/        # Message library
│   ├── calendar/                # Scheduling system
│   └── radio/                   # Live radio control
├── calendario/                   # Legacy calendar system
│   └── api/                     # Calendar backend
└── assets/                       
    └── css/                     # Global styles

🏗️ Architecture
Frontend Architecture

Module System: ES6 modules with dynamic imports
State Management: Per-module state managers
Event System: Global event bus for inter-module communication
Routing: Hash-based SPA routing
Storage: LocalStorage with fallback to memory

Backend Architecture

PHP 8.1: REST-like API endpoints
SQLite: Message metadata and scheduling
File Storage: MP3 files in temp/ and biblioteca/
External APIs: ElevenLabs (TTS), AzuraCast (streaming)


🔑 Core Components
Event Bus (/shared/event-bus.js)
javascript// Singleton event system
eventBus.emit('event:name', data);
eventBus.on('event:name', callback);
eventBus.once('event:name', callback);
eventBus.off('event:name', callback);

// System events
SystemEvents = {
    MODULE_LOADED: 'module:loaded',
    MODULE_UNLOADED: 'module:unloaded',
    NAVIGATION_CHANGE: 'navigation:change',
    AUDIO_GENERATED: 'audio:generated',
    MESSAGE_SAVED: 'message:saved'
}
Module Loader (/shared/module-loader.js)
javascript// Dynamic module loading with CSS injection
moduleLoader.init(container);
await moduleLoader.switchTo('module-name');
moduleLoader.unloadModule('module-name');

// Module interface requirement
class Module {
    getName() { return 'module-name'; }
    async load(container) { /* initialize */ }
    async unload() { /* cleanup */ }
}
Router (/shared/router.js)
javascript// Routes configuration
routes = {
    '/radio': 'radio',
    '/configuracion': 'message-configurator',
    '/campanas': 'campaign-library',
    '/calendario': 'calendar'
}
// Default route: '/radio'
API Client (/shared/api-client.js)
javascript// Centralized API communication
apiClient.post('/generate.php', {
    action: 'generate_audio',
    text: 'message',
    voice: 'cristian',
    voice_settings: { /* settings */ }
});

📦 Main Modules
1. Message Configurator
Path: /modules/message-configurator/
Purpose: Create and configure TTS messages
Key Files:

index.js - Main module class
state-manager.js - Message state management
api-integration.js - Backend communication
voice-presets.js - Voice configurations

State Structure:
javascriptMessageSchema = {
    id: 'msg_xxx',
    name: '',
    text: '',
    voice: 'cristian',
    settings: {
        speed: 'normal',
        style: 0.5,          // 0-1
        stability: 0.75,     // 0-1
        similarity_boost: 0.8, // 0-1
        use_speaker_boost: true
    },
    category: 'general',
    tags: [],
    audioFilename: null,     // Local file
    azuracastFilename: null, // Radio file
}
API Calls:
javascript// Generate audio
POST /api/generate.php
{
    action: 'generate_audio',
    text: 'message text',
    voice: 'cristian',
    voice_settings: { /* settings */ }
}

// Send to radio
POST /api/generate.php
{
    action: 'send_to_radio',
    filename: 'azuracast_filename.mp3'
}
2. Campaign Library
Path: /modules/campaign-library/
Purpose: Manage saved messages
Features:

Local + backend storage sync
Category filtering
Search and sort
Audio playback
Send to radio

Storage Pattern:
javascript// LocalStorage keys
'tts_mall_library_message_{id}' // Saved messages
'tts_mall_draft_{id}'           // Drafts

// Backend sync
POST /api/library-metadata.php
{
    action: 'save|list|update|delete',
    data: { /* message data */ }
}
3. Calendar Module
Path: /modules/calendar/
Purpose: Schedule announcements
Components:

calendar-view.js - FullCalendar wrapper
event-modal.js - Event creation/editing
calendar-api.js - Backend communication

Event Structure:
javascriptCalendarEvent = {
    id: 'evt_xxx',
    title: 'Event name',
    start_datetime: '2024-01-01T10:00:00',
    end_datetime: '2024-01-01T11:00:00',
    category: 'ofertas',
    file_path: 'audio_file.mp3',
    priority: 1,
    notes: ''
}

🔧 API Endpoints
/api/generate.php
php// Actions:
'list_templates'  // Get announcement templates
'generate_audio'  // Generate TTS audio
'send_to_radio'   // Interrupt radio with audio
/api/biblioteca.php
php// Actions:
'list_library'    // List audio files
'delete_library_file' // Delete audio file
'get_file'        // Stream audio file
/api/library-metadata.php
php// Actions:
'save'    // Save message metadata
'list'    // List all messages
'update'  // Update message
'delete'  // Delete message

🎤 Voice Configuration
Available Voices (ElevenLabs)
javascriptvoices = [
    'cristian', 'fernanda', 'juan', 'sofia',
    'carlos', 'laura', 'diego', 'maria'
    // 30+ voices total
]
Voice Settings Ranges
javascript{
    style: 0-1,           // Voice style (0=neutral, 1=expressive)
    stability: 0-1,       // Voice consistency (0=variable, 1=stable)
    similarity_boost: 0-1, // Voice clarity (0=low, 1=high)
    use_speaker_boost: boolean // Enhanced voice
}

🔄 Data Flow
Message Generation Flow

User enters text in Message Configurator
Selects voice and adjusts settings
Clicks "Generate Audio"
Frontend sends to /api/generate.php
Backend calls ElevenLabs API
Audio processed (add silence)
Uploaded to AzuraCast
Assigned to playlist
Returns filenames to frontend
User can save to library or send to radio

Radio Interrupt Flow

User clicks "Send to Radio"
Frontend sends filename to /api/generate.php
Backend calls AzuraCast API
Interrupts current playlist
Plays announcement
Returns to regular programming


🛠️ Development Patterns
Module Creation Template
javascriptexport default class NewModule {
    constructor() {
        this.name = 'module-name';
        this.container = null;
    }
    
    getName() { return this.name; }
    
    async load(container) {
        this.container = container;
        // Load template
        // Initialize components
        // Attach events
        eventBus.emit('module:loaded');
    }
    
    async unload() {
        // Cleanup
        this.container = null;
    }
}
Component Pattern
javascriptclass Component {
    constructor(container, options = {}) {
        this.container = container;
        this.options = options;
        this.init();
    }
    
    init() { /* setup */ }
    setValue(value) { /* update */ }
    getValue() { /* return value */ }
    destroy() { /* cleanup */ }
}
API Call Pattern
javascripttry {
    const response = await apiClient.post('/endpoint', {
        action: 'action_name',
        ...data
    });
    
    if (response.success) {
        // Handle success
    } else {
        throw new Error(response.error);
    }
} catch (error) {
    eventBus.emit('api:error', error);
}

🔐 Configuration
Required API Keys (/api/config.php)
phpELEVENLABS_API_KEY = 'your_key'
AZURACAST_API_KEY = 'station_key'
AZURACAST_BASE_URL = 'http://radio.url'
AZURACAST_STATION_ID = 1
PLAYLIST_ID_GRABACIONES = 3
File Paths
phpUPLOAD_DIR = '/api/temp/'        // Temporary files
BIBLIOTECA_DIR = '/biblioteca/'  // Saved audio files

📝 Conventions
Naming Conventions

Files: kebab-case (module-name.js)
Classes: PascalCase (MessageConfigurator)
Functions: camelCase (loadModule())
Events: colon-separated (module:event:detail)
IDs: underscore with timestamp (msg_1234567890_abc123)

Storage Keys

Prefix: tts_mall_
Messages: library_message_{id}
Drafts: draft_{id}
Profiles: voice_profile_{id}

CSS Classes

BEM-like: .module-name__element--modifier
States: .is-active, .is-loading
Actions: .btn, .btn-primary


🚀 Quick Start for New Features
Adding a New Module

Create folder in /modules/your-module/
Create index.js implementing module interface
Add route in /shared/router.js
Add navigation tab in index.html

Adding API Endpoint

Create PHP file or add to existing
Handle CORS headers
Parse JSON input
Return JSON response with success field

Adding Voice Setting

Update MessageSchema in data-schemas.js
Add UI control in message configurator
Update voice_settings in API call
Handle in backend generate.php


🐛 Common Issues & Solutions
Module Not Loading

Check route in router.js
Verify module exports default class
Check console for import errors

Audio Not Generating

Verify ElevenLabs API key
Check voice name is valid
Ensure text is not empty

Radio Not Interrupting

Verify AzuraCast API key
Check playlist ID is correct
Ensure file exists in AzuraCast

Storage Not Persisting

Check localStorage is enabled
Verify key prefix is correct
Check for quota exceeded


📚 External Dependencies
Frontend

No frameworks (vanilla JS)
ES6 modules (native)
FullCalendar (calendar module only)

Backend

PHP 8.1+
SQLite3
cURL for API calls
FFmpeg for audio processing

APIs

ElevenLabs TTS API v1
AzuraCast API v0.17+


🔗 Important URLs
Development

Local: http://localhost/mbi-v3/
API: http://localhost/mbi-v3/api/

Production

Frontend: Served via Nginx
Radio: http://51.222.25.222
AzuraCast: Port 8000


📌 Notes for LLM Context

Module Independence: Each module is self-contained with its own state
Event-Driven: Modules communicate via event bus, not direct calls
Progressive Enhancement: Core functionality works without all modules
Fallback Strategy: LocalStorage → Memory, Backend → Local
Voice Settings: Only 4 parameters are actually sent to ElevenLabs
File Handling: Two filenames - local for preview, azuracast for radio
No Build Process: Direct ES6 modules, no bundling required


🎯 Key Insights for Development

The system is designed for non-technical users (mall staff)
Audio quality and voice naturalness are critical
Real-time radio interruption is the core feature
Message library acts as a content management system
Calendar scheduling runs via cron jobs on backend
All UI text should be in Spanish (Chilean)
System must handle network failures gracefully