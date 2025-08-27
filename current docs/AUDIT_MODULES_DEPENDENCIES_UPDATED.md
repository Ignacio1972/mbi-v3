# 📊 Auditoría Técnica: Arquitectura Modular MBI-v3 [ACTUALIZADO]

> **Última actualización:** 2025-08-27  
> **Estado:** Reflejando estructura actual del proyecto

## 🏗️ Arquitectura del Sistema

### Core Architecture Pattern
El sistema implementa una arquitectura **Event-Driven Modular** con las siguientes características:

- **Module Isolation**: Cada módulo es una unidad autocontenida con su propio namespace
- **Lazy Loading**: Módulos cargados dinámicamente mediante ES6 dynamic imports
- **Event Bus Pattern**: Comunicación desacoplada mediante pub/sub centralizado
- **Single Responsibility**: Cada módulo tiene una responsabilidad única y bien definida
- **Dependency Injection**: Las dependencias se inyectan a través del constructor o métodos

## 📦 Mapa de Módulos y Dependencias

### Dependency Graph [ACTUALIZADO]
```mermaid
graph TD
    subgraph "Shared Infrastructure"
        EB[event-bus.js]
        AC[api-client.js]
        SM[storage-manager.js]
        ML[module-loader.js]
        RT[router.js]
        DS[data-schemas.js]
        VS[voice-service.js] %% NUEVO
        AM[audio-manager.js] %% NUEVO
    end
    
    subgraph "Feature Modules"
        RM[Radio Module]
        MC[Message Configurator]
        CL[Campaign Library]
        AL[Audio Library]
        CM[Calendar Module]
    end
    
    subgraph "Playground System" %% NUEVO
        PG[Playground]
        VM[Voice Manager]
        MN[Monitors]
    end
    
    subgraph "Message Configurator Internals"
        SM2[state-manager.js]
        AI[api-integration.js]
        CF[component-factory.js]
        UH[ui-handler.js]
        AH[audio-handler.js]
        TH[template-handler.js]
        PH[profile-handler.js]
    end
    
    %% Infrastructure Dependencies
    RM --> EB
    RM --> AC
    
    MC --> EB
    MC --> SM
    MC --> SM2
    MC --> AI
    MC --> CF
    MC --> UH
    MC --> AH
    MC --> TH
    MC --> PH
    MC --> VS %% NUEVA DEPENDENCIA
    
    CL --> EB
    CL --> SM
    CL --> AC
    
    AL --> EB
    AL --> AC
    
    CM --> EB
    CM --> AC
    
    %% Nuevas dependencias de Voice Service
    PG --> VS
    VM --> VS
    
    %% Audio Manager dependencies
    AM --> EB
    AM --> AC
    MC --> AM
    
    %% Module Loader manages all
    ML --> RM
    ML --> MC
    ML --> CL
    ML --> AL
    ML --> CM
    
    %% Router controls Module Loader
    RT --> ML
```

### Module Specifications

#### 1. **Radio Module** (`/modules/radio/`)
```javascript
Dependencies: {
    runtime: ['event-bus', 'api-client'],
    external: ['AzuraCast API'],
    styles: ['style.css']
}
Interface: {
    load: (container: HTMLElement) => Promise<void>,
    unload: () => Promise<void>,
    getName: () => string
}
Responsibilities: [
    'Stream player management',
    'Metadata display',
    'Volume control',
    'Popup window handling'
]
```

#### 2. **Message Configurator** (`/modules/message-configurator/`)
```javascript
Dependencies: {
    runtime: ['event-bus', 'storage-manager', 'voice-service'], // voice-service AGREGADO
    internal: ['state-manager', 'api-integration', 'component-factory'],
    handlers: ['ui-handler', 'audio-handler', 'template-handler', 'profile-handler'],
    external: ['ElevenLabs API', 'Custom TTS Service'],
    styles: ['styles/configurator-layout.css', 'styles/save-message-modal.css']
}
State Management: {
    persistence: 'localStorage',
    schema: 'MessageConfigState',
    sync: 'bidirectional with UI components'
}
Voice Management: { // NUEVO
    service: 'shared/voice-service.js',
    dynamic_loading: true,
    cache_duration: '60 seconds'
}
```

#### 3. **Campaign Library** (`/modules/campaign-library/`)
```javascript
Dependencies: {
    runtime: ['event-bus', 'storage-manager', 'api-client'],
    dynamic: ['./schedule-modal.js'],
    plugins: ['./plugins/scheduler-plugin.js'], // NUEVO
    styles: ['styles/library.css', 'styles/schedule-modal.css']
}
Data Sources: {
    local: 'localStorage:mbi_messages',
    remote: '/api/biblioteca.php',
    merge_strategy: 'union with deduplication by ID'
}
```

#### 4. **Audio Library** (`/modules/audio-library/`)
```javascript
Dependencies: {
    runtime: ['event-bus', 'api-client'],
    styles: ['styles/library.css']
}
Database Integration: {
    endpoints: ['/api/audio-favorites.php', '/api/audio-metadata.php'],
    migration: 'localStorage → SQLite',
    schema: 'audio_files, audio_favorites tables'
}
```

#### 5. **Calendar Module** (`/modules/calendar/`)
```javascript
Dependencies: {
    runtime: ['event-bus', 'api-client'],
    components: ['calendar-view', 'calendar-filters', 'event-list', 'event-modal'],
    styles: ['styles/style.css', 'styles/calendar-tooltips.css']
}
Schedule Management: {
    types: ['interval', 'specific', 'once'],
    storage: 'SQLite database',
    cron_integration: true,
    database_path: '/calendario/api/db/calendar.db'
}
```

### 🆕 Nuevos Componentes No Documentados Previamente

#### 6. **Voice Service** (`/shared/voice-service.js`)
```javascript
Purpose: 'Servicio centralizado para cargar voces dinámicamente'
Features: {
    cache_management: true,
    cache_duration: 60000, // 1 minuto
    fallback_voice: 'juan_carlos',
    api_endpoint: '/api/generate.php'
}
Methods: {
    loadVoices: 'Carga voces desde API con cache',
    clearCache: 'Limpia cache de voces'
}
```

#### 7. **Audio Manager** (`/shared/audio-manager.js`)
```javascript
Purpose: 'Gestión de reproducción y generación de audio'
Dependencies: {
    runtime: ['event-bus', 'api-client']
}
Features: {
    audio_generation: true,
    audio_playback: true,
    cache_system: 'Map-based cache',
    event_emissions: ['audio:generating', 'audio:generated', 'audio:error']
}
```

#### 8. **Playground System** (`/playground/`)
```javascript
Purpose: 'Sistema de testing y administración de voces'
Structure: {
    main: '/playground/index.html',
    scripts: [
        'assets/js/playground.js',
        'assets/js/voice-admin.js', 
        'assets/js/monitors.js'
    ],
    api_endpoints: [
        '/playground/api/voice-manager.php',
        '/playground/api/voice-admin.php',
        '/playground/api/logs.php',
        '/playground/api/quota.php',
        '/playground/api/ping.php'
    ]
}
Features: {
    voice_testing: true,
    api_monitoring: true,
    log_viewer: true,
    quota_tracking: true
}
```

## 🔄 Data Flow Architecture

### 1. Event-Driven Communication Flow

```typescript
interface SystemEvent {
    type: string;
    payload: any;
    timestamp: number;
    source?: string;
}

// Event flow patterns
MessageFlow {
    Producer: 'message-configurator'
    Event: 'message:saved:library'
    Consumers: ['campaign-library', 'audio-library?']
    Payload: {
        id: string,
        title: string,
        content: string,
        audioUrl: string,
        metadata: Object
    }
}

NavigationFlow {
    Producer: 'router'
    Event: 'navigation:change'
    Consumers: ['module-loader', 'all-modules']
    Sideeffects: [
        'Module unload/load cycle',
        'CSS stylesheet swap',
        'Memory cleanup',
        'Event listener cleanup'
    ]
}

// NUEVO: Voice Service Flow
VoiceFlow {
    Producer: 'voice-service'
    Events: ['voices:loaded', 'voices:cache:cleared']
    Consumers: ['message-configurator', 'playground']
    Cache: '60-second TTL'
}
```

### 2. API Request Flow [ACTUALIZADO]

```javascript
// Centralized API flow through api-client
RequestFlow {
    1. Module initiates: apiClient.request(config)
    2. Pre-request: emit('api:request:start', config)
    3. Execute: fetch() with config
    4. Success: emit('api:response', response)
    5. Error: emit('api:error', error)
    6. Post-process: Module handles response
}

// Example: Audio generation flow
AudioGenerationFlow {
    1. UI Event: user clicks "Generate"
    2. Handler: audioHandler.generate(state)
    3. Voice Load: VoiceService.loadVoices() // NUEVO
    4. API Call: POST /api/generate.php
    5. Response: { audioUrl, duration, tokens }
    6. State Update: stateManager.update(response)
    7. UI Update: updateComponentsFromState()
    8. Event Emit: 'audio:generated'
}
```

### 3. State Management Patterns

```javascript
// Three-tier state architecture
GlobalState {
    Layer: 'Event Bus',
    Scope: 'Cross-module communication',
    Persistence: 'None (ephemeral)',
    Examples: ['loading states', 'navigation', 'errors']
}

ModuleState {
    Layer: 'Module Instance',
    Scope: 'Module lifecycle',
    Persistence: 'Optional (localStorage)',
    Examples: ['form data', 'UI preferences', 'cached data']
}

ComponentState {
    Layer: 'Component Instance',
    Scope: 'Component lifecycle',
    Persistence: 'None',
    Examples: ['input values', 'dropdown states', 'toggles']
}

// NUEVO: Voice Cache State
VoiceCacheState {
    Layer: 'VoiceService Class',
    Scope: 'Application-wide',
    Persistence: 'Memory with TTL',
    TTL: 60000 // 1 minute
}
```

### 4. Module Lifecycle State Machine

```javascript
ModuleLifecycle {
    States: {
        UNLOADED: 'Module not in memory',
        LOADING: 'Fetching module code',
        LOADED: 'Module in memory, not mounted',
        MOUNTING: 'Rendering UI',
        ACTIVE: 'Module operational',
        UNMOUNTING: 'Cleanup in progress',
        ERROR: 'Failed state'
    },
    
    Transitions: {
        'UNLOADED -> LOADING': 'router.navigate()',
        'LOADING -> LOADED': 'import() success',
        'LOADED -> MOUNTING': 'module.load()',
        'MOUNTING -> ACTIVE': 'DOM ready',
        'ACTIVE -> UNMOUNTING': 'navigation change',
        'UNMOUNTING -> UNLOADED': 'cleanup complete',
        '* -> ERROR': 'any failure'
    }
}
```

## 🔧 Critical Integration Points

### 1. Module Loader Integration
```javascript
// Module contract enforcement
interface IModule {
    load(container: HTMLElement): Promise<void>;
    unload(): Promise<void>;
    getName(): string;
}

// CSS isolation strategy
CSSManagement {
    Strategy: 'Per-module stylesheets',
    Loading: 'Dynamic link injection',
    Cleanup: 'Remove on module unload',
    Naming: '/modules/{module-name}/style.css'
}
```

### 2. Event Bus Integration
```javascript
// Event namespacing convention
EventNaming {
    System: 'system:*',      // Core system events
    Module: '{module}:*',     // Module-specific events
    UI: 'ui:*',              // UI state changes
    API: 'api:*',            // API lifecycle events
    Navigation: 'nav:*',      // Routing events
    Audio: 'audio:*',        // Audio-related events (NUEVO)
    Voice: 'voices:*'        // Voice service events (NUEVO)
}

// Event cleanup strategy
CleanupStrategy {
    OnUnload: 'eventBus.clear("{module}:*")',
    OnError: 'eventBus.emit("system:error", error)',
    Memory: 'Remove all references and listeners'
}
```

### 3. Storage Layer Integration
```javascript
// Storage strategy per module
StorageStrategy {
    'message-configurator': {
        keys: ['mbi_messageState', 'mbi_voiceProfiles'],
        format: 'JSON',
        migration: 'v1 -> v2 schema'
    },
    'campaign-library': {
        keys: ['mbi_messages', 'mbi_campaigns'],
        format: 'JSON array',
        sync: 'merge with backend'
    },
    'audio-library': {
        keys: ['favorites_migration_complete'],
        backend: 'SQLite via PHP API',
        migration: 'localStorage -> DB'
    }
}
```

## 🚨 Critical Dependencies & Failure Points

### Single Points of Failure
1. **Event Bus** - Central communication hub
2. **Module Loader** - Controls all module lifecycle
3. **Router** - Navigation controller
4. **API Client** - Backend communication
5. **Voice Service** - Voice loading system (NUEVO)

### ⚠️ Known Issues
1. **Router Issue**: `/historial` route maps to non-existent `audio-history` module
   - Should map to `audio-library` or be removed
2. **Duplicate Route**: `/calendario` route defined twice (line 16 and commented line 18)

### Circular Dependencies
```javascript
// None detected - clean dependency graph
```

### External Dependencies [ACTUALIZADO]
```javascript
ExternalDependencies {
    'AzuraCast API': {
        modules: ['radio'],
        fallback: 'Show error message',
        critical: true
    },
    'ElevenLabs API': {
        modules: ['message-configurator', 'voice-service', 'playground'],
        centralized_access: 'voice-service.js',
        fallback: 'Use juan_carlos voice only',
        critical: true
    },
    'PHP Backend': {
        modules: ['all'],
        endpoints: 14, // Actualizado de 7
        new_endpoints: [
            '/api/test-voices.php',
            '/api/saved-messages.php',
            '/api/test-azuracast.php',
            '/playground/api/*'
        ],
        critical: true
    }
}
```

## 📈 Performance Considerations

### Module Loading Performance
```javascript
LoadingMetrics {
    'radio': ~150ms,
    'message-configurator': ~350ms,  // Aumentado por voice-service
    'campaign-library': ~200ms,
    'audio-library': ~180ms,
    'calendar': ~250ms,
    'playground': ~400ms  // NUEVO
}

OptimizationOpportunities {
    1. 'Preload critical modules',
    2. 'Bundle common dependencies',
    3. 'Implement module prefetching',
    4. 'Add service worker caching',
    5. 'Optimize voice cache strategy' // NUEVO
}
```

### Memory Management
```javascript
MemoryProfile {
    BaseFootprint: '~2.5MB', // Aumentado
    PerModule: {
        'radio': '~500KB',
        'message-configurator': '~1.2MB', // Aumentado
        'campaign-library': '~800KB',
        'audio-library': '~600KB',
        'calendar': '~700KB'
    },
    CacheFootprint: { // NUEVO
        'voice-service': '~100KB per cache cycle',
        'audio-manager': '~500KB-2MB depending on cached audio'
    },
    Leaks: 'None detected with proper cleanup'
}
```

## 🔐 Security Considerations

### API Security
- All API calls go through centralized `api-client.js`
- No hardcoded credentials in frontend
- Token-based authentication ready
- Voice service uses cached API calls to reduce exposure

### XSS Prevention
- Dynamic HTML generation uses `textContent` where possible
- Event handlers attached via addEventListener
- No eval() or Function() constructors

### Data Validation
- Input validation in components
- Schema validation for API responses (via data-schemas.js)
- Type checking in critical paths

## 🎯 Architecture Strengths

1. **Loose Coupling** - Modules communicate only through events
2. **High Cohesion** - Each module has single responsibility
3. **Scalability** - Easy to add new modules
4. **Maintainability** - Clear separation of concerns
5. **Testability** - Modules can be tested in isolation
6. **Performance** - Lazy loading reduces initial load
7. **Voice Management** - Centralized voice service with caching (NUEVO)
8. **Testing Environment** - Playground system for development (NUEVO)

## ⚠️ Architecture Weaknesses

1. **Event Bus Bottleneck** - All communication goes through single point
2. **No TypeScript** - Lack of type safety
3. **No Build Process** - Missing optimization opportunities
4. **Manual Dependency Management** - No package manager
5. **Limited Error Recovery** - Basic error handling
6. **Router Inconsistency** - Contains invalid route mapping

## 🔄 Migration Impact Analysis

### High Risk Areas
1. Event Bus modifications - affects all modules
2. Module Loader changes - affects loading mechanism
3. Router updates - affects navigation (needs fix for audio-history)
4. Voice Service changes - affects message configurator and playground

### Low Risk Areas
1. Individual module UI updates
2. CSS modifications
3. Adding new modules
4. API endpoint changes (with versioning)

### Migration Strategy Recommendation
1. **Fix Router Issue** - Remove or correct audio-history mapping
2. **Parallel Development** - Keep current system running
3. **Feature Flags** - Toggle between old/new implementations
4. **Incremental Updates** - One module at a time
5. **Backward Compatibility** - Maintain event signatures
6. **Comprehensive Testing** - E2E tests for critical paths
7. **Document Playground** - Create separate docs for playground system

## 📝 Pending Documentation

The following components need separate documentation:
1. **Playground System** - Complete architecture and usage guide
2. **Voice Service** - API and caching strategy
3. **Audio Manager** - Playback and generation workflow
4. **New API Endpoints** - Purpose and usage of new PHP files

---

*This technical audit has been updated to reflect the current state of the MBI-v3 architecture as of 2025-08-27.*