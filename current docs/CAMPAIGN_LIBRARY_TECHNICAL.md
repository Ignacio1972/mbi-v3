# 📚 Campaign Library - Documentación Técnica
**Sistema de Biblioteca de Mensajes y Campañas MBI-v3**

> **Última actualización:** 2025-08-27  
> **Versión:** 2.0  
> **Estado:** ✅ En producción

---

## 📋 Tabla de Contenidos
1. [Visión General](#visión-general)
2. [Arquitectura del Módulo](#arquitectura-del-módulo)
3. [Sistema de Almacenamiento Híbrido](#sistema-de-almacenamiento-híbrido)
4. [Tipos de Mensajes](#tipos-de-mensajes)
5. [Sistema de Botones y Acciones](#sistema-de-botones-y-acciones)
6. [Sistema de Categorías](#sistema-de-categorías)
7. [Filtros y Búsqueda](#filtros-y-búsqueda)
8. [APIs y Backend](#apis-y-backend)
9. [Estructura de Datos](#estructura-de-datos)
10. [Integración con Otros Módulos](#integración-con-otros-módulos)

---

## 🎯 Visión General

Campaign Library es el módulo central para gestionar todos los mensajes guardados del sistema. Combina mensajes de texto generados con TTS y archivos de audio subidos directamente, proporcionando una interfaz unificada para administrar, reproducir, enviar a radio y programar contenido.

### Características Principales
- **Almacenamiento híbrido**: LocalStorage + Base de datos SQLite
- **Dos tipos de contenido**: Mensajes TTS y archivos de audio
- **6 botones de acción** por mensaje
- **7 categorías** con colores distintivos
- **Filtros y búsqueda** en tiempo real
- **Integración completa** con radio y calendario

---

## 🏗️ Arquitectura del Módulo

### Estructura de Archivos
```
/modules/campaign-library/
├── index.js                    # Controlador principal
├── schedule-modal.js           # Modal de programación
├── plugins/
│   └── scheduler-plugin.js     # Plugin de scheduling
└── styles/
    ├── library.css            # Estilos principales
    └── schedule-modal.css     # Estilos del modal
```

### Clase Principal
```javascript
export default class CampaignLibraryModule {
    constructor() {
        this.name = 'campaign-library';
        this.messages = [];           // Todos los mensajes
        this.filteredMessages = [];   // Mensajes filtrados
        this.currentFilter = 'all';   // Filtro actual
        this.currentSort = 'date_desc'; // Ordenamiento
        this.searchQuery = '';        // Búsqueda actual
    }
}
```

---

## 💾 Sistema de Almacenamiento Híbrido

### Flujo de Carga de Mensajes

```mermaid
graph TD
    A[loadMessages()] --> B[loadLocalMessages()]
    A --> C[loadBackendMessages()]
    B --> D[LocalStorage<br/>tts_mall_library_message_*]
    C --> E[SQLite DB<br/>audio_metadata]
    D --> F[mergeMessages()]
    E --> F
    F --> G[displayMessages()]
```

### 1. **LocalStorage (Mensajes TTS)**
```javascript
// Prefijo: tts_mall_library_message_{id}
loadLocalMessages() {
    for (let key in localStorage) {
        if (key.startsWith('tts_mall_library_message_')) {
            const message = JSON.parse(localStorage.getItem(key));
            messages.push(message);
        }
    }
}
```

### 2. **Base de Datos (Archivos de Audio)**
```javascript
// Endpoint: /api/saved-messages.php
loadBackendMessages() {
    const response = await fetch('/api/saved-messages.php', {
        action: 'list'
    });
    // Retorna archivos con is_saved = 1
}
```

### 3. **Merge y Deduplicación**
```javascript
mergeMessages(local, backend) {
    const merged = new Map();
    backend.forEach(msg => merged.set(msg.id, msg));
    local.forEach(msg => merged.set(msg.id, msg));
    return Array.from(merged.values());
}
```

---

## 📝 Tipos de Mensajes

### 1. **Mensajes TTS (Text-to-Speech)**
```javascript
{
    id: 'msg_1234567890',
    type: 'text',
    title: 'Promoción de temporada',
    content: 'Texto completo del mensaje...',
    category: 'ofertas',
    voice: 'fernanda',
    audioFilename: 'tts20250827123456.mp3',
    azuracastFilename: 'tts20250827123456_promocion.mp3',
    savedAt: 1724788456000,
    timestamp: 1724788456000
}
```

### 2. **Archivos de Audio**
```javascript
{
    id: 'audio_recording123',
    type: 'audio',
    title: 'Grabación especial',
    content: 'Archivo de audio',
    category: 'eventos',
    filename: 'recording123.mp3',
    createdAt: '2025-08-27 10:30:00',
    playCount: 5,
    radioCount: 2,
    tags: 'evento,especial',
    notes: 'Grabación del evento principal'
}
```

---

## 🎛️ Sistema de Botones y Acciones

### Estructura HTML de Botones
```html
<div class="message-actions">
    <button onclick="playMessage(id)">▶️</button>      <!-- Reproducir -->
    <button onclick="editMessage(id)">✏️</button>      <!-- Editar título -->
    <button onclick="changeCategory(id)">🏷️</button>   <!-- Cambiar categoría -->
    <button onclick="sendToRadio(id)">📻</button>      <!-- Enviar a radio -->
    <button onclick="scheduleMessage(id)">🕐</button>   <!-- Programar (solo audio) -->
    <button onclick="deleteMessage(id)">🗑️</button>    <!-- Eliminar -->
</div>
```

### Funcionalidad de Cada Botón

#### 1. **▶️ Reproducir (`playMessage`)**
```javascript
async playMessage(id) {
    const message = this.messages.find(m => m.id === id);
    
    // Determinar archivo según tipo
    let audioFilename = message.type === 'audio' 
        ? message.filename 
        : message.audioFilename;
    
    // Crear player flotante
    const player = document.createElement('div');
    player.className = 'floating-player';
    player.innerHTML = `
        <audio controls autoplay>
            <source src="/api/biblioteca.php?filename=${audioFilename}">
        </audio>
    `;
    document.body.appendChild(player);
}
```

**Comportamiento:**
- Crea un reproductor flotante en la esquina inferior derecha
- Auto-reproduce el audio al abrir
- Permite cerrar con botón X
- Un solo player activo a la vez

#### 2. **✏️ Editar Título (`editMessage`)**
```javascript
async editMessage(id) {
    const newTitle = prompt('Editar título:', message.title);
    
    if (message.type === 'audio') {
        // Actualizar en BD
        await apiClient.post('/saved-messages.php', {
            action: 'update_display_name',
            id: message.id,
            display_name: newTitle
        });
    } else {
        // Actualizar en localStorage
        storageManager.save(`library_message_${id}`, message);
    }
}
```

**Comportamiento:**
- Muestra prompt con título actual
- Valida mínimo 3 caracteres
- Actualiza según tipo (BD o localStorage)
- Refresca la vista inmediatamente

#### 3. **🏷️ Cambiar Categoría (`changeCategory`)**
```javascript
async changeCategory(id) {
    const categories = {
        'sin_categoria': '📁 Sin categoría',
        'ofertas': '🛒 Ofertas',
        'eventos': '🎉 Eventos',
        'informacion': 'ℹ️ Información',
        'emergencias': '🚨 Emergencias',
        'servicios': '🛎️ Servicios',
        'horarios': '🕐 Horarios'
    };
    
    const selection = prompt('Selecciona categoría (1-7):', '1');
    
    if (message.type === 'audio') {
        await apiClient.post('/saved-messages.php', {
            action: 'update_category',
            id: message.id,
            category: newCategory
        });
    }
}
```

**Comportamiento:**
- Muestra lista numerada de categorías
- Usuario ingresa número (1-7)
- Actualiza color y emoji en tarjeta
- Persiste cambio según tipo

#### 4. **📻 Enviar a Radio (`sendToRadio`)**
```javascript
async sendToRadio(id) {
    const endpoint = message.type === 'audio' 
        ? '/biblioteca.php' 
        : '/generate.php';
        
    const action = message.type === 'audio' 
        ? 'send_library_to_radio' 
        : 'send_to_radio';
    
    await apiClient.post(endpoint, {
        action: action,
        filename: audioFilename
    });
}
```

**Comportamiento:**
- NO pide confirmación (comentado)
- Usa endpoint diferente según tipo
- Interrumpe radio actual
- Muestra notificación de éxito/error

#### 5. **🕐 Programar (`scheduleMessage`)**
```javascript
async scheduleMessage(id, title) {
    // Cargar modal dinámicamente
    if (!window.ScheduleModal) {
        const module = await import('./schedule-modal.js');
        window.ScheduleModal = module.ScheduleModal;
    }
    
    window.scheduleModal = new window.ScheduleModal();
    modal.show(message.filename, title, message.category);
}
```

**Comportamiento:**
- **SOLO disponible para archivos de audio**
- Carga modal de programación dinámicamente
- Pasa categoría del mensaje
- Integra con sistema de scheduling

#### 6. **🗑️ Eliminar (`deleteMessage`)**
```javascript
async deleteMessage(id) {
    if (!confirm(`¿Eliminar "${message.title}"?`)) return;
    
    // Eliminar de localStorage
    storageManager.delete(`library_message_${id}`);
    
    // Eliminar de array
    this.messages = this.messages.filter(m => m.id !== id);
    
    // Eliminar en backend
    await fetch('/api/library-metadata.php', {
        action: 'delete',
        id: message.id
    });
}
```

**Comportamiento:**
- Pide confirmación con alert
- Elimina de todas las fuentes
- Actualiza vista inmediatamente
- NO se puede deshacer

---

## 🎨 Sistema de Categorías

### Categorías Disponibles

| Categoría | Emoji | Color | Código Hex | Uso |
|-----------|-------|-------|------------|-----|
| ofertas | 🛒 | Verde | #22c55e | Promociones y descuentos |
| eventos | 🎉 | Azul | #3b82f6 | Eventos del mall |
| informacion | ℹ️ | Cyan | #06b6d4 | Avisos informativos |
| emergencias | 🚨 | Rojo | #ef4444 | Alertas urgentes |
| servicios | 🛎️ | Púrpura | #a855f7 | Servicios disponibles |
| horarios | 🕐 | Naranja | #f59e0b | Horarios y cambios |
| sin_categoria | 📁 | Gris | #6b7280 | Sin categorizar |

### Implementación Visual
```css
.category-badge {
    padding: 4px 12px;
    border-radius: 16px;
    font-size: 0.9rem;
}

.category-ofertas {
    background: rgba(34, 197, 94, 0.1);
    color: #22c55e;
    border: 1px solid rgba(34, 197, 94, 0.3);
}
```

---

## 🔍 Filtros y Búsqueda

### Sistema de Filtros
```javascript
// Botones de filtro con contadores
<button data-filter="all">Todos (25)</button>
<button data-filter="ofertas">🛒 Ofertas (8)</button>
<button data-filter="eventos">🎉 Eventos (5)</button>
```

### Búsqueda en Tiempo Real
```javascript
searchMessages(query) {
    this.searchQuery = query.toLowerCase();
    // Busca en: título + contenido + voz
    const searchIn = (msg.title + msg.text + msg.voice).toLowerCase();
    return searchIn.includes(this.searchQuery);
}
```

### Ordenamiento
- `date_desc`: Más recientes primero (default)
- `date_asc`: Más antiguos primero
- `title_asc`: Alfabético A-Z
- `title_desc`: Alfabético Z-A

---

## 🔌 APIs y Backend

### Endpoints Utilizados

| Endpoint | Método | Acción | Descripción |
|----------|--------|--------|-------------|
| `/api/saved-messages.php` | POST | list | Obtener mensajes guardados |
| `/api/saved-messages.php` | POST | update_display_name | Actualizar título |
| `/api/saved-messages.php` | POST | update_category | Cambiar categoría |
| `/api/biblioteca.php` | GET | ?filename=X | Stream de audio |
| `/api/biblioteca.php` | POST | send_library_to_radio | Enviar audio a radio |
| `/api/generate.php` | POST | send_to_radio | Enviar TTS a radio |
| `/api/library-metadata.php` | POST | update/delete | Gestión de metadata |

---

## 📊 Estructura de Datos

### Tabla `audio_metadata` (SQLite)
```sql
CREATE TABLE audio_metadata (
    filename TEXT PRIMARY KEY,
    display_name TEXT,
    category TEXT DEFAULT 'sin_categoria',
    is_saved BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    saved_at DATETIME,
    play_count INTEGER DEFAULT 0,
    radio_sent_count INTEGER DEFAULT 0,
    tags TEXT,
    notes TEXT
);
```

### LocalStorage Keys
```javascript
// Mensajes TTS guardados
tts_mall_library_message_{id}

// Estructura del valor
{
    id: string,
    title: string,
    content: string,
    category: string,
    voice: string,
    audioFilename: string,
    savedAt: number
}
```

---

## 🔗 Integración con Otros Módulos

### 1. **Con Message Configurator**
- Recibe mensajes guardados via Event Bus
- Evento: `message:saved:library`
- Agrega automáticamente a la biblioteca

### 2. **Con Schedule Modal**
- Carga dinámicamente para programación
- Pasa filename, título y categoría
- Solo para archivos de audio

### 3. **Con Calendar**
- Programaciones creadas aparecen en calendario
- Eventos con colores de categoría
- Sincronización via Event Bus

### 4. **Con Radio Module**
- Envío directo a AzuraCast
- Interrumpe reproducción actual
- Notificaciones de estado

---

## 🎯 Flujo de Usuario Típico

1. **Usuario guarda mensaje** desde Message Configurator
2. **Aparece en biblioteca** con categoría asignada
3. **Puede reproducir** con player flotante
4. **Edita título** si necesario
5. **Cambia categoría** para mejor organización
6. **Envía a radio** para reproducción inmediata
7. **O programa** para reproducción futura
8. **Elimina** cuando ya no necesita

---

## 🔧 Configuración y Personalización

### Constantes Configurables
```javascript
// Límites
const MIN_TITLE_LENGTH = 3;
const MAX_TITLE_LENGTH = 100;

// Timeouts
const NOTIFICATION_DURATION = 3000;
const API_TIMEOUT = 30000;

// Prefijos de storage
const STORAGE_PREFIX = 'tts_mall_library_message_';
```

### CSS Variables
```css
:root {
    --library-primary: #3b82f6;
    --library-danger: #ef4444;
    --library-success: #22c55e;
    --library-card-bg: #ffffff;
    --library-card-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
```

---

## 🚀 Mejoras Pendientes

### Funcionalidades
- [ ] Edición completa de mensajes (no solo título)
- [ ] Duplicar mensajes existentes
- [ ] Exportar/importar biblioteca
- [ ] Papelera de reciclaje (soft delete)

### UI/UX
- [ ] Vista de lista además de grilla
- [ ] Drag & drop para reordenar
- [ ] Multi-selección para acciones masivas
- [ ] Preview de audio en hover

### Performance
- [ ] Paginación para grandes volúmenes
- [ ] Lazy loading de audios
- [ ] Cache de thumbnails
- [ ] Indexación para búsqueda rápida

---

## 📝 Notas Técnicas

### Consideraciones de Diseño
- **Sin framework**: Vanilla JavaScript para máximo control
- **Carga dinámica**: Modal de scheduling solo cuando necesario
- **Storage híbrido**: Flexibilidad entre local y remoto
- **Event-driven**: Comunicación via Event Bus

### Compatibilidad
- ES6+ modules
- Async/await
- Template literals
- Array methods (map, filter, find)

### Seguridad
- Escape HTML en títulos
- Validación de inputs
- Sanitización en backend
- CORS configurado

---

*Esta documentación técnica refleja el estado actual del módulo Campaign Library con todas sus funcionalidades y sistemas integrados.*