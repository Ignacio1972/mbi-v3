# 🚨 CRITICAL FEATURES AUDIT - MBI-v3 System [ACTUALIZADO]

> **Última actualización:** 2025-08-27  
> **Versión:** 3.0  
> **Estado:** Sistema en producción activa

## Executive Summary

Este documento identifica **TODAS las funcionalidades críticas** que **NO DEBEN ROMPERSE** durante cualquier migración, refactorización o actualización de diseño del sistema MBI-v3. Estas características son esenciales para las operaciones automatizadas de radio del mall.

---

## 🎯 TIER 1: MISSION-CRITICAL FEATURES (Falla del Sistema si se Rompen)

### 1. **Text-to-Speech Generation** ✅ OPERACIONAL
**Priority:** MAXIMUM  
**Component:** `/api/generate.php`  
**Dependencies:** ElevenLabs API, audio-processor.php, tts-service-enhanced.php

#### Critical Functions:
```javascript
// CRITICAL: Voice settings conversion (UI → API)
{
    style: value !== undefined ? value : 0.5,  // MUST allow 0 value
    stability: 0-1 range,
    similarity_boost: 0-1 range,
    use_speaker_boost: boolean
}
```

#### What CANNOT break:
- ✅ Text input → Audio generation flow
- ✅ Voice selection with dynamic voices (5+ voces custom activas)
- ✅ Template support with variables
- ✅ Automatic silence padding (3 seconds)
- ✅ Upload to AzuraCast after generation
- ✅ Immediate radio interruption capability
- ✅ **NUEVO:** Voice Service con cache de 60 segundos

#### Validation Rules:
```php
// File naming convention (MUST maintain)
'/^tts\d+(_[a-zA-Z0-9_\-ñÑáéíóúÁÉÍÓÚ]+)?\.mp3$/'

// Voice settings (EXACT format required)
['style', 'stability', 'similarity_boost', 'use_speaker_boost']
```

**Estado Actual:** ✅ Funcionando con API key activa

---

### 2. **Radio Interruption System** ✅ OPERACIONAL
**Priority:** MAXIMUM  
**Component:** `/api/services/radio-service.php`  
**Dependencies:** AzuraCast API, Docker, Liquidsoap

#### Critical Configuration (VERIFICADO):
```php
AZURACAST_BASE_URL = 'http://51.222.25.222'  ✅
AZURACAST_STATION_ID = 1  ✅
PLAYLIST_ID_GRABACIONES = 3  ✅
AZURACAST_API_KEY = 'c3802cba5b5e61e8:fed31be9adb82ca57f1cf482d170851f'  ✅
```

#### What CANNOT break:
- ✅ Immediate radio interruption via liquidsoap.sock
- ✅ File upload to AzuraCast with base64 encoding
- ✅ Playlist assignment to "Grabaciones"
- ✅ Docker command execution for file management
- ✅ Stream metadata updates

#### Critical Commands (VERIFICADO):
```bash
# Radio interruption (EXACT format) - CONFIRMADO línea 104-105
echo "interrupting_requests.push file_uri" | \
socat - UNIX-CONNECT:/var/azuracast/stations/test/config/liquidsoap.sock
```

**Estado Actual:** ✅ Comando presente y funcional

---

### 3. **Audio Library Management** ✅ OPERACIONAL
**Priority:** HIGH  
**Component:** `/api/biblioteca.php`, `/modules/campaign-library/`  
**Dependencies:** File system, Docker, AzuraCast, SQLite

#### What CANNOT break:
- ✅ File listing with optimized find command
- ✅ Audio streaming for playback
- ✅ File deletion with Docker exec
- ✅ File renaming with descriptions
- ✅ Send to radio functionality
- ✅ **NUEVO:** Integración con Campaign Library mejorada
- ✅ **NUEVO:** Sistema de favoritos migrado a SQLite

#### Critical Paths:
```php
// Docker path (MUST be exact)
'/var/azuracast/stations/test/media/Grabaciones/'

// Local path - VACÍO actualmente (limpieza automática funcionando)
__DIR__ . '/temp/'  // 0 archivos
```

**Estado Actual:** ✅ Sistema completo funcionando

---

## 🎯 TIER 2: BUSINESS-CRITICAL FEATURES (Impacto Mayor si se Rompen)

### 4. **Automatic Scheduling System** ✅ OPERACIONAL v2.0
**Component:** `/api/audio-scheduler.php`  
**Database:** `/calendario/api/db/calendar.db` (385KB)

#### What CANNOT break:
- ✅ Schedule creation (interval, specific, once)
- ✅ Execution detection at scheduled times
- ✅ **Category support v2.0 (7 categorías con colores)**
- ✅ Schedule logging to database
- ✅ Active/inactive schedule management
- ✅ **NUEVO:** Plugin system para Campaign Library
- ✅ **NUEVO:** Cron job activo cada minuto

#### Critical Tables (VERIFICADAS):
```sql
audio_schedule      -- Active schedules con campo 'category'
audio_schedule_log  -- Execution history
audio_metadata      -- File metadata con favoritos
```

**Estado Actual:** ✅ Sistema completo con categorías funcionando

---

### 5. **Frontend Module System** ✅ OPERACIONAL
**Component:** `/shared/module-loader.js`

#### What CANNOT break:
- ✅ Dynamic module loading with lazy imports
- ✅ CSS isolation per module
- ✅ Module lifecycle (load/unload)
- ✅ Navigation between modules (5+ módulos activos)
- ✅ Event cleanup on module switch

#### Module Interface Contract (VERIFICADO):
```javascript
interface IModule {
    load(container: HTMLElement): Promise<void>
    unload(): Promise<void>
    getName(): string
}
```

**Módulos Activos:**
- ✅ message-configurator
- ✅ campaign-library
- ✅ calendar
- ✅ audio-library
- ✅ radio

---

### 6. **Event Bus Communication** ✅ OPERACIONAL
**Component:** `/shared/event-bus.js`

#### Critical Events (VERIFICADOS):
```javascript
// System events
MODULE_LOADED, MODULE_UNLOADED, MODULE_ERROR ✅
NAVIGATION_CHANGE ✅

// Feature events
message:saved:library ✅
schedule:created ✅
audio:generated ✅
audio:playing, audio:ended (NUEVOS) ✅

// API events
api:request, api:response, api:error ✅
```

---

### 7. **Dynamic Voice Management System** ✅ OPERACIONAL EXPANDIDO
**Priority:** HIGH  
**Components:** `/playground/api/voice-admin.php`, `/playground/api/voice-manager.php`  
**Configuration:** `/api/data/voices-config.json` (1.4KB), `/api/data/custom-voices.json` (1KB)  
**Dependencies:** ElevenLabs Voice IDs, Voice Service, Dynamic Voice Selector

#### Current Production Voices (VERIFICADAS):
```json
{
    "juan_carlos": {
        "id": "G4IAP30yc6c1gK0csDfu",  // DEFAULT VOICE ✅
        "label": "Juan Carlos",
        "gender": "M",
        "is_default": true
    },
    "alejandro": {
        "id": "6nZRiu6mJ5DiYZA30eh5",  // ACTIVE ✅
        "label": "alejandro",
        "gender": "M"
    },
    "jefry": {
        "id": "pXOYlNbO024q13bfqrw0",  // ACTIVE ✅
        "label": "jefry",
        "gender": "M"
    },
    "fernanda": {
        "id": "KXsGSneY5uCfMXaT52f5",  // ACTIVE ✅
        "label": "fernanda",
        "gender": "F"
    }
}
```

#### What CANNOT break:
- ✅ Voice configuration file structure and location
- ✅ Default voice assignment (juan_carlos)
- ✅ Voice key generation from label
- ✅ Integration with Message Configurator
- ✅ **NUEVO:** Voice Service con cache centralizado
- ✅ **NUEVO:** Playground voice admin interface

**Estado Actual:** ✅ 5+ voces custom activas y funcionales

---

## 🆕 TIER 2.5: NUEVAS FEATURES CRÍTICAS (No Documentadas Previamente)

### 8. **Playground System** ✅ OPERACIONAL
**Component:** `/playground/`  
**Purpose:** Testing y desarrollo de voces

#### Features Críticas:
- ✅ TTS Tester con preview instantáneo
- ✅ Voice Explorer con comparación
- ✅ Voice Admin para gestión CRUD
- ✅ Monitors con logs en tiempo real
- ✅ API tester integrado
- ✅ Quota tracker de ElevenLabs

#### Integration Points:
```javascript
// Playground → Generate API
PlaygroundApp.loadVoices() → /api/generate.php
PlaygroundApp.generateTTS() → /api/generate.php

// Playground → Voice Config
VoiceAdmin.addVoice() → /api/data/voices-config.json
```

---

### 9. **Voice Service Centralizado** ✅ OPERACIONAL
**Component:** `/shared/voice-service.js`  
**Purpose:** Gestión centralizada de voces con cache

#### Features Críticas:
```javascript
class VoiceService {
    static voicesCache = null;
    static cacheTimestamp = 0;
    static CACHE_DURATION = 60000; // 1 minuto ✅
    
    static async loadVoices() { ... }  ✅
    static clearCache() { ... }  ✅
}
```

---

### 10. **Audio Manager** ✅ OPERACIONAL
**Component:** `/shared/audio-manager.js`  
**Purpose:** Gestión centralizada de reproducción

#### Features Críticas:
- ✅ Generación de audio via API
- ✅ Reproducción con eventos
- ✅ Cache de audio
- ✅ Envío a radio centralizado

---

## 🎯 TIER 3: USER-CRITICAL FEATURES (Impacto UX si se Rompen)

### 11. **Message Configurator UI** ✅ OPERACIONAL
**Component:** `/modules/message-configurator/`

#### What CANNOT break:
- ✅ Voice selection dropdown (5+ voces activas)
- ✅ Slider controls (0-100% → 0-1 conversion)
- ✅ Template system with categories
- ✅ Save to library functionality
- ✅ Audio preview player
- ✅ Character count tracking
- ✅ **NUEVO:** Voice presets system

#### Critical State Management:
```javascript
// State persistence (VERIFICADO)
localStorage: 'mbi_messageState' ✅
localStorage: 'mbi_voiceProfiles' ✅
```

---

### 12. **Campaign Library Features** ✅ OPERACIONAL v2.0
**Component:** `/modules/campaign-library/`

#### What CANNOT break:
- ✅ Dual storage (localStorage + SQLite backend)
- ✅ Category filtering (7 categorías)
- ✅ Search functionality
- ✅ Floating audio player
- ✅ Schedule modal integration
- ✅ **NUEVO:** 6 botones de acción por mensaje
- ✅ **NUEVO:** Sistema de favoritos
- ✅ **NUEVO:** Plugin architecture

---

### 13. **Calendar Module** ✅ OPERACIONAL
**Component:** `/modules/calendar/`

#### What CANNOT break:
- ✅ Calendar view rendering (FullCalendar v6)
- ✅ Event display with tooltips
- ✅ Schedule management table
- ✅ Filter by event type
- ✅ Delete schedule confirmation
- ✅ **NUEVO:** Categorías con colores en eventos
- ✅ **NUEVO:** Múltiples eventos por schedule

---

## 🔧 CRITICAL INTEGRATIONS [ACTUALIZADO]

### External Services
| Service | Endpoint | Critical For | Status | Fallback |
|---------|----------|--------------|--------|----------|
| ElevenLabs | api.elevenlabs.io | TTS Generation | ✅ ACTIVE | None - System fails |
| AzuraCast | 51.222.25.222 | Radio Stream | ✅ ACTIVE | None - System fails |
| SQLite DB | calendar.db | Scheduling | ✅ 385KB | None - Feature fails |

### File System Requirements
| Path | Purpose | Permissions | Status | Clean-up |
|------|---------|-------------|--------|----------|
| /api/temp/ | Temporary files | 755 | ✅ EMPTY | Automatic (working) |
| /media/Grabaciones/ | Audio library | 755 | ✅ | Manual |
| /calendario/api/db/ | Database | 644 | ✅ 385KB | Never |
| /api/data/*.json | Voice configs | 644⚠️ | ⚠️ 666 | Never |

**⚠️ SECURITY ISSUE:** `voices-config.json` tiene permisos 666 (demasiado abiertos)

---

## 🚫 BREAKING CHANGES TO AVOID [ACTUALIZADO]

### 1. **DOM Structure Changes**
```javascript
// CRITICAL SELECTORS - DO NOT CHANGE
#app-container          // Module container ✅
.tab-button            // Navigation tabs ✅
#message-text          // Text input ✅
#audio-player-container // Player mount point ✅
.message-card          // Library cards ✅
.floating-player       // NUEVO - Audio player ✅
```

### 2. **Event Signatures**
```javascript
// MUST maintain payload structure
eventBus.emit('message:saved:library', {
    id: string,
    title: string,
    audioUrl: string,
    category: string  // NUEVO campo requerido
})
```

### 3. **API Response Formats**
```javascript
// generate.php response (MUST maintain)
{
    success: boolean,
    audioUrl: string,
    duration: number,
    characterCount: number,
    voices: object  // NUEVO - para list_voices action
}
```

### 4. **LocalStorage Keys**
```javascript
// DO NOT CHANGE these keys
'mbi_messages'        // Campaign library ✅
'mbi_messageState'    // Message configurator ✅
'mbi_voiceProfiles'   // Voice presets ✅
'tts_mall_library_message_*'  // NUEVO pattern ✅
```

---

## ✅ TESTING CHECKLIST [ACTUALIZADO]

### Before ANY Migration/Update:

#### Core Functionality Tests:
- [ ] Generate TTS with style=0 (edge case)
- [ ] Generate TTS with all voice settings
- [ ] Generate with cada voz custom (juan_carlos, alejandro, etc.)
- [ ] Upload and interrupt radio immediately
- [ ] List library with 20+ files
- [ ] Delete file from library
- [ ] Rename file with special characters
- [ ] **NUEVO:** Test voice cache (60 sec TTL)
- [ ] **NUEVO:** Test Playground TTS generation

#### Module System Tests:
- [ ] Navigate between all 5+ modules
- [ ] Verify CSS isolation
- [ ] Check memory cleanup on unload
- [ ] Test event propagation
- [ ] **NUEVO:** Test plugin loading

#### Scheduling Tests:
- [ ] Create interval schedule
- [ ] Create specific time schedule with category
- [ ] Delete active schedule
- [ ] Verify execution at scheduled time (cron cada minuto)
- [ ] **NUEVO:** Test schedule with all 7 categories

#### Integration Tests:
- [ ] ElevenLabs API connection
- [ ] AzuraCast streaming
- [ ] Database read/write (385KB actual)
- [ ] Docker command execution
- [ ] **NUEVO:** Voice Service cache
- [ ] **NUEVO:** Playground → Generate API

---

## 🔒 CONFIGURATION PROTECTION [ACTUALIZADO]

### Files That MUST NOT Change Without Backup:
```bash
/api/config.php                      # API keys ✅
/api/data/voices-config.json        # Voice configuration (1.4KB) ✅
/api/data/custom-voices.json        # Custom voices (1KB) ✅
/calendario/api/db/calendar.db      # Schedule database (385KB) ✅
```

### Environment Variables to Preserve (VERIFICADOS):
```php
ELEVENLABS_API_KEY = 'sk_f5d2f711a5cb2c117a2c6e2a00ab50bf34dbaec234bc61b2' ✅
AZURACAST_API_KEY = 'c3802cba5b5e61e8:fed31be9adb82ca57f1cf482d170851f' ✅
AZURACAST_BASE_URL = 'http://51.222.25.222' ✅
AZURACAST_STATION_ID = 1 ✅
PLAYLIST_ID_GRABACIONES = 3 ✅
```

---

## 📊 PERFORMANCE REQUIREMENTS [ACTUALIZADO]

### Response Time Limits:
- TTS Generation: < 30 seconds ✅
- Library Loading: < 2 seconds ✅
- Module Switch: < 500ms ✅
- Radio Interruption: < 3 seconds ✅
- **NUEVO:** Voice cache refresh: 60 seconds ✅
- **NUEVO:** Playground preview: < 5 seconds ✅

### Resource Limits:
- Max concurrent API calls: 5
- Max file upload size: 10MB
- Max temp directory size: 1GB (auto-clean working)
- Max localStorage usage: 5MB
- **NUEVO:** Voice cache size: ~10KB

---

## 🚨 EMERGENCY RECOVERY [ACTUALIZADO]

### If System Breaks:

1. **Check API Keys:**
   ```bash
   # Verify ElevenLabs key
   curl -X GET "https://api.elevenlabs.io/v1/user" \
     -H "xi-api-key: sk_f5d2f711a5cb2c117a2c6e2a00ab50bf34dbaec234bc61b2"
   ```

2. **Fix File Permissions:**
   ```bash
   chmod 755 /api/temp/
   chmod 644 /calendario/api/db/calendar.db
   chmod 644 /api/data/voices-config.json  # FIX from 666
   chmod 644 /api/data/custom-voices.json
   ```

3. **Clear Temp Files:**
   ```bash
   find /api/temp/ -name "*.mp3" -mtime +1 -delete
   ```

4. **Restart Services:**
   ```bash
   sudo docker restart azuracast
   sudo systemctl restart apache2
   ```

5. **Restore Voice Config if Corrupted:**
   ```bash
   # Minimal recovery
   echo '{
       "voices": {
           "juan_carlos": {
               "id": "G4IAP30yc6c1gK0csDfu",
               "label": "Juan Carlos",
               "gender": "M",
               "active": true,
               "is_default": true
           }
       },
       "settings": {
           "default_voice": "juan_carlos",
           "version": "2.0"
       }
   }' > /api/data/voices-config.json
   ```

6. **Check Cron Job:**
   ```bash
   crontab -l | grep scheduler-cron
   # Should show: * * * * * /usr/bin/php /var/www/mbi-v3/api/scheduler-cron.php
   ```

---

## 📝 MIGRATION RULES [ACTUALIZADO]

### Golden Rules for ANY Changes:

1. **NEVER** modify without testing in development first
2. **ALWAYS** backup database (385KB) and configs before changes
3. **MAINTAIN** backward compatibility for events
4. **PRESERVE** localStorage key names and patterns
5. **TEST** with style=0 voice setting (known edge case)
6. **VERIFY** Docker commands still work
7. **ENSURE** API response formats unchanged
8. **CHECK** all 7 categories still function
9. **VALIDATE** file naming conventions
10. **CONFIRM** radio interruption works
11. **TEST** voice cache functionality (60 sec)
12. **VERIFY** Playground integration
13. **CHECK** cron job execution (every minute)
14. **PRESERVE** all custom voices in config
15. **FIX** file permissions (voices-config.json from 666 to 644)

---

## 🔴 CRITICAL WARNINGS

### SECURITY ISSUES TO FIX:
1. **File Permissions:** `voices-config.json` has 666 (too open) → Should be 644
2. **API Keys:** Consider moving to environment variables
3. **No Authentication:** Voice admin endpoints are public

### DEPENDENCIES AT RISK:
1. **ElevenLabs:** API key must remain valid
2. **AzuraCast:** Connection must be maintained
3. **Docker:** Commands require sudo access

### PERFORMANCE MONITORING:
1. **Database Size:** calendar.db at 385KB (monitor growth)
2. **Temp Directory:** Currently empty (auto-clean working)
3. **Voice Cache:** 60-second TTL (adjust if needed)

---

*Este documento sirve como la referencia autoritativa actualizada para las características críticas del sistema que deben protegerse durante cualquier trabajo de desarrollo.*

*Última verificación del sistema: 2025-08-27 - Todas las features críticas operacionales*