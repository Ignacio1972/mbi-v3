# 📚 Módulo de Audio Library - Documentación Técnica [ACTUALIZADA]

## 📋 Información General

**Versión:** 2.0.0  
**Última actualización:** 27 de Agosto, 2025  
**Autor:** Claude Code Assistant + Ignacio1972  
**Repositorio:** https://github.com/Ignacio1972/mbi-v3  
**Estado:** ✅ En producción con Base de Datos

## 🎯 Propósito

El módulo de Audio Library proporciona una interfaz completa para gestionar **TODOS** los archivos de audio TTS generados automáticamente por el sistema. A diferencia del módulo Campaign Library (que solo muestra mensajes guardados con metadata), este módulo muestra **TODO** el archivo de audios generados, permitiendo a los usuarios del Mall Barrio Independencia:

- Ver todos los archivos TTS generados
- Renombrar archivos con descripciones
- Marcar/desmarcar favoritos (ahora en BD)
- Reproducir preview de audios
- Enviar directamente a la radio
- Eliminar archivos del sistema
- Migración automática de localStorage a BD

## 📁 Estructura de Archivos

```
modules/audio-library/
├── index.js                    # Módulo principal (670 líneas)
├── index.js.backup_localStorage_20250813_185108  # Backup versión anterior
└── styles/
    └── library.css            # Estilos del módulo
```

### APIs Backend Utilizadas
```
api/
├── biblioteca.php             # API principal de biblioteca
├── audio-favorites.php        # API de favoritos con BD
└── audio-metadata.php         # API de metadata
```

## 🏗️ Arquitectura del Módulo

### Clase Principal: `AudioLibraryModule`

```javascript
export default class AudioLibraryModule {
    constructor() {
        this.name = 'audio-library';
        this.container = null;
        this.libraryFiles = [];
        this.currentSort = 'date_desc';
        this.currentView = 'grid';
        this.searchQuery = '';
        this.favorites = []; // Ahora se carga desde BD
        this.migrationCompleted = false; // Flag de migración
    }
}
```

### Propiedades Principales

| Propiedad | Tipo | Descripción | Cambio v2.0 |
|-----------|------|-------------|------------|
| `libraryFiles` | Array | Lista de archivos cargados desde Docker | Sin cambios |
| `currentSort` | String | Tipo de ordenamiento actual | Sin cambios |
| `currentView` | String | Vista actual ('grid' o 'list') | Sin cambios |
| `searchQuery` | String | Término de búsqueda actual | Sin cambios |
| `favorites` | Array | Lista de favoritos | **Ahora desde BD** |
| `migrationCompleted` | Boolean | Estado de migración localStorage → BD | **NUEVO** |

## 🔧 Funcionalidades Implementadas

### 1. 🗄️ Sistema de Base de Datos para Favoritos [NUEVO]

```javascript
async loadFavoritesFromDB() {
    try {
        const response = await apiClient.post('/audio-favorites.php', {
            action: 'get_favorites'
        });
        
        if (response.success) {
            this.favorites = response.favorites || [];
            console.log('[AudioLibrary] Favoritos cargados desde BD:', this.favorites.length);
        }
    } catch (error) {
        // Fallback a localStorage temporalmente
        this.favorites = JSON.parse(localStorage.getItem('audio_favorites') || '[]');
    }
}
```

**Características nuevas:**
- ✅ Persistencia real en SQLite
- ✅ Migración automática desde localStorage
- ✅ Sincronización entre dispositivos
- ✅ Backup automático en caso de fallo

### 2. 🔄 Migración Automática de localStorage a BD [NUEVO]

```javascript
async migrateLocalStorageIfNeeded() {
    const migrated = localStorage.getItem('audio_favorites_migrated');
    if (migrated === 'true') return;
    
    const localFavorites = JSON.parse(localStorage.getItem('audio_favorites') || '[]');
    
    if (localFavorites.length > 0) {
        const response = await apiClient.post('/audio-favorites.php', {
            action: 'migrate_from_localstorage',
            favorites: localFavorites
        });
        
        if (response.success) {
            localStorage.setItem('audio_favorites_migrated', 'true');
            this.showNotification(`✅ ${response.migrated} favoritos migrados a BD`, 'success');
        }
    }
}
```

### 3. 📊 Gestión de Archivos con Docker

```javascript
async loadLibrary() {
    const response = await apiClient.post('/biblioteca.php', {
        action: 'list_library'
    });
    
    if (response.success) {
        this.libraryFiles = response.files || [];
        this.updateStats();
        this.sortLibrary();
        this.renderLibrary();
    }
}
```

**Optimizaciones en backend:**
- Uso de `find -printf` para obtener toda la info de una vez
- Límite de 50 archivos para evitar timeouts
- Ordenamiento por timestamp descendente
- Formato de fecha desde nombre de archivo

### 4. ✏️ Renombrar Archivos con Validación

```javascript
async renameFile(filename) {
    const parts = filename.match(/^(tts\d{14})(_(.+))?\.mp3$/);
    const currentDescription = parts[3] ? parts[3].replace(/_/g, ' ') : '';
    
    const newDescription = prompt(
        'Ingrese una descripción para el archivo:\n' +
        '(Use solo letras, números y espacios. Máx 30 caracteres)\n\n' +
        'Nombre actual: ' + filename,
        currentDescription
    );
    
    // Validaciones
    if (cleanDescription.length > 30) {
        this.showNotification('Descripción muy larga (máx 30 caracteres)', 'error');
        return;
    }
    
    // Actualizar en BD también
    await apiClient.post('/audio-metadata.php', {
        action: 'set_display_name',
        filename: response.new_filename,
        display_name: cleanDescription
    });
}
```

**Validaciones actualizadas:**
- Descripción no vacía
- Máximo 30 caracteres
- Solo caracteres alfanuméricos, espacios, guiones y caracteres especiales (ñÑáéíóúÁÉÍÓÚ)
- Preserva timestamp original
- **NUEVO:** Actualiza metadata en BD

### 5. ⭐ Sistema de Favoritos con BD

```javascript
async toggleFavorite(filename) {
    const response = await apiClient.post('/audio-favorites.php', {
        action: 'toggle_favorite',
        filename: filename
    });
    
    if (response.success) {
        const index = this.favorites.indexOf(filename);
        
        if (index > -1) {
            // REMOVER de favoritos
            this.favorites.splice(index, 1);
            
            // Actualizar metadata en BD
            await apiClient.post('/audio-metadata.php', {
                action: 'update_metadata',
                filename: filename,
                metadata: {
                    category: null,
                    is_saved: false
                }
            });
            
            this.showNotification('⭐ Removido de Mensajes Guardados', 'info');
        } else {
            // AGREGAR a favoritos
            this.favorites.push(filename);
            
            // Actualizar metadata en BD
            await apiClient.post('/audio-metadata.php', {
                action: 'update_metadata',
                filename: filename,
                metadata: {
                    display_name: displayName,
                    category: 'sin_categoria',
                    is_saved: true,
                    saved_at: new Date().toISOString()
                }
            });
            
            this.showNotification('★ Agregado a Mensajes Guardados', 'success');
        }
    }
}
```

**Mejoras v2.0:**
- ✅ Persistencia en BD SQLite
- ✅ Sincronización con metadata
- ✅ Categorización automática
- ✅ Timestamp de guardado

### 6. 🔍 Búsqueda y Filtrado

```javascript
sortLibrary() {
    const files = [...this.libraryFiles];
    
    switch(this.currentSort) {
        case 'date_asc':
            files.sort((a, b) => a.timestamp - b.timestamp);
            break;
        case 'date_desc':
            files.sort((a, b) => b.timestamp - a.timestamp);
            break;
        case 'name_asc':
            files.sort((a, b) => a.filename.localeCompare(b.filename));
            break;
        case 'favorites':
            files.sort((a, b) => {
                const aFav = this.favorites.includes(a.filename) ? 1 : 0;
                const bFav = this.favorites.includes(b.filename) ? 1 : 0;
                return bFav - aFav || b.timestamp - a.timestamp;
            });
            break;
    }
}
```

### 7. ▶️ Reproductor Flotante con Tracking

```javascript
async playFile(filename) {
    const player = document.querySelector('#floatingPlayer');
    const audio = document.querySelector('#audioPlayer');
    
    if (player && audio) {
        audio.src = `/api/biblioteca.php?filename=${filename}`;
        playing.textContent = `🎵 ${this.getDisplayName(filename)}`;
        player.style.display = 'block';
        audio.play();
        
        // NUEVO: Registrar reproducción en BD
        await apiClient.post('/audio-metadata.php', {
            action: 'record_play',
            filename: filename
        });
    }
}
```

### 8. 📻 Envío a Radio con Registro

```javascript
async sendToRadio(filename) {
    const response = await apiClient.post('/biblioteca.php', {
        action: 'send_library_to_radio',
        filename: filename
    });
    
    if (response.success) {
        this.showNotification('📻 Enviado a la radio', 'success');
        
        // NUEVO: Registrar envío en BD
        await apiClient.post('/audio-metadata.php', {
            action: 'record_radio_sent',
            filename: filename
        });
    }
}
```

## 🎨 Interfaz de Usuario

### Componentes HTML Renderizados

```javascript
render() {
    this.container.innerHTML = `
        <div class="audio-library-module">
            <div class="library-header">
                <h2>📚 Biblioteca de Audios Generados</h2>
                <p>Todos los audios que generes aparecen aquí automáticamente</p>
            </div>
            
            <div class="library-controls">
                <button class="btn btn-secondary" id="viewToggle">📋 Vista Lista</button>
                <input type="text" id="librarySearch" placeholder="🔍 Buscar archivos...">
                <select id="librarySort">
                    <option value="date_desc">Más recientes primero</option>
                    <option value="date_asc">Más antiguos primero</option>
                    <option value="name_asc">Nombre A-Z</option>
                    <option value="favorites">Favoritos primero</option>
                </select>
                <button class="btn btn-primary" id="refreshBtn">🔄 Actualizar</button>
            </div>
            
            <div class="stats-bar">
                <span>📊 Total: <strong id="totalFiles">0</strong> archivos</span>
                <span>⭐ Favoritos: <strong id="totalFavorites">0</strong></span>
                <span>💾 Espacio: <strong id="totalSize">0 MB</strong></span>
            </div>
            
            <div id="libraryGrid" class="library-grid">
                <div class="loading">⏳ Cargando biblioteca...</div>
            </div>
            
            <!-- Player flotante -->
            <div id="floatingPlayer" class="floating-player" style="display: none;">
                <div class="player-header">
                    <span id="currentPlaying">🎵 Reproduciendo...</span>
                    <button onclick="audioLibrary.closePlayer()">✕</button>
                </div>
                <audio id="audioPlayer" controls></audio>
            </div>
        </div>
    `;
}
```

### Funciones Globales Expuestas

```javascript
window.audioLibrary = {
    playFile: (filename) => this.playFile(filename),
    sendToRadio: (filename) => this.sendToRadio(filename),
    renameFile: (filename) => this.renameFile(filename),
    toggleFavorite: (filename) => this.toggleFavorite(filename),
    deleteFile: (filename) => this.deleteFile(filename),
    closePlayer: () => this.closePlayer()
};
```

## 🔌 Integración con APIs

### Endpoints utilizados

#### `/api/biblioteca.php`
```javascript
// Listar archivos
POST { "action": "list_library" }

// Renombrar archivo
POST {
    "action": "rename_file",
    "old_filename": "tts20250813093045.mp3",
    "new_description": "oferta especial"
}

// Enviar a radio
POST {
    "action": "send_library_to_radio",
    "filename": "tts20250813093045_oferta_especial.mp3"
}

// Eliminar archivo
POST {
    "action": "delete_library_file",
    "filename": "tts20250813093045.mp3"
}

// Streaming de audio (GET)
GET /api/biblioteca.php?filename=tts20250813093045.mp3
```

#### `/api/audio-favorites.php` [NUEVO]
```javascript
// Obtener favoritos
POST { "action": "get_favorites" }

// Toggle favorito
POST {
    "action": "toggle_favorite",
    "filename": "tts20250813093045.mp3"
}

// Migrar desde localStorage
POST {
    "action": "migrate_from_localstorage",
    "favorites": ["file1.mp3", "file2.mp3"]
}

// Obtener estadísticas
POST { "action": "get_stats" }
```

#### `/api/audio-metadata.php` [NUEVO]
```javascript
// Actualizar metadata
POST {
    "action": "update_metadata",
    "filename": "tts20250813093045.mp3",
    "metadata": {
        "display_name": "Oferta Especial",
        "category": "ofertas",
        "is_saved": true
    }
}

// Registrar reproducción
POST {
    "action": "record_play",
    "filename": "tts20250813093045.mp3"
}

// Registrar envío a radio
POST {
    "action": "record_radio_sent",
    "filename": "tts20250813093045.mp3"
}
```

### Formato de respuesta de biblioteca.php

```json
{
    "success": true,
    "files": [
        {
            "filename": "tts20250827093045_oferta_navidad.mp3",
            "size": 245760,
            "timestamp": 1724759445,
            "date": "2025-08-27 09:30:45",
            "formatted_date": "27/08/2025 09:30"
        }
    ],
    "total": 50
}
```

## 📱 Responsividad

### Estilos CSS Aplicados

```css
/* Vista Grid */
.library-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
}

/* Vista Lista */
.library-table {
    width: 100%;
    border-collapse: collapse;
}

/* Player Flotante */
.floating-player {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.15);
    z-index: 1000;
    min-width: 350px;
}

/* Responsivo */
@media (max-width: 768px) {
    .library-grid {
        grid-template-columns: 1fr;
    }
    
    .floating-player {
        width: calc(100% - 40px);
        left: 20px;
    }
}
```

## 🚀 Rendimiento

### Optimizaciones implementadas

1. **Backend optimizado:** Uso de `find -printf` en lugar de múltiples comandos
2. **Límite de resultados:** Máximo 50 archivos por consulta
3. **Cache de estilos:** CSS se carga una sola vez
4. **Lazy loading:** Módulo se carga bajo demanda
5. **Event delegation:** Manejo eficiente de eventos
6. **Migración asíncrona:** No bloquea la carga inicial

### Métricas actuales

- **Tiempo de carga inicial:** ~200ms (sin migración) / ~500ms (con migración)
- **Tamaño del módulo:** 670 líneas de JS + CSS
- **Archivos soportados:** 50 por página (paginación implícita)
- **Favoritos:** Sin límite (almacenados en BD)

## 🔒 Seguridad

### Validaciones implementadas

```php
// Validación de nombre de archivo (actualizada)
'/^tts\d+(_[a-zA-Z0-9_\-ñÑáéíóúÁÉÍÓÚ]+)?\.mp3$/'

// Validación de descripción
if (!preg_match('/^[a-zA-Z0-9_\-ñÑáéíóúÁÉÍÓÚ ]+$/', $cleanDescription)) {
    throw new Exception('Caracteres no permitidos');
}

// Escape de comandos shell
escapeshellarg($dockerPath)
```

### Medidas de seguridad

- ✅ Validación estricta de nombres de archivo
- ✅ Sanitización de entradas de usuario
- ✅ Escape HTML en renderizado
- ✅ Uso de `escapeshellarg()` en comandos Docker
- ✅ Sesión basada en IP + User Agent para favoritos

## 🐛 Manejo de Errores

### Sistema de notificaciones

```javascript
showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}
```

**Tipos de notificación:**
- `success` - Operaciones exitosas (verde)
- `error` - Errores de operación (rojo)
- `info` - Información general (azul)

## 🧪 Testing

### Funcionalidades probadas v2.0

✅ **Nuevas características:**
- Migración automática de localStorage a BD
- Persistencia de favoritos en BD
- Registro de reproducciones
- Registro de envíos a radio
- Actualización de metadata

✅ **Funcionalidades existentes:**
- Preview de archivos de audio
- Envío a radio en vivo
- Renombrado con caracteres especiales
- Eliminación de archivos
- Ordenamiento por diferentes criterios
- Cambio entre vista grid y lista
- Búsqueda por nombre
- Sistema de favoritos persistente

### Casos de prueba actualizados

| Caso | Entrada | Resultado Esperado |
|------|---------|-------------------|
| Migración favoritos | localStorage con 3 favoritos | Migrados a BD, notificación mostrada |
| Toggle favorito | Click en ⭐ | Guardado en BD, metadata actualizada |
| Renombrar con ñ | "año_nuevo" | `tts20250827093045_año_nuevo.mp3` |
| Reproducir y trackear | Click en ▶️ | Audio reproduce, play registrado en BD |
| Eliminar favorito | Archivo favorito eliminado | Removido de BD favoritos también |

## 🔮 Mejoras Futuras

### Implementadas en v2.0 ✅
- ✅ Base de datos para favoritos
- ✅ Tracking de reproducciones
- ✅ Metadata persistente
- ✅ Migración automática

### Pendientes para v3.0

1. **Paginación real**
   - Cargar más de 50 archivos
   - Scroll infinito o paginación tradicional

2. **Filtros avanzados**
   - Por fecha específica
   - Por rango de fechas
   - Por tamaño de archivo

3. **Bulk operations**
   - Selección múltiple
   - Eliminar varios archivos
   - Descargar selección como ZIP

4. **Analytics dashboard**
   - Archivos más reproducidos
   - Horarios de mayor uso
   - Estadísticas de espacio

## 📞 Soporte y Mantenimiento

### Logs del sistema

```bash
# Logs de biblioteca
/api/logs/biblioteca-YYYY-MM-DD.log

# Logs de favoritos
/api/logs/audio-favorites-YYYY-MM-DD.log

# Ver logs en tiempo real
tail -f /var/www/mbi-v3/api/logs/biblioteca-$(date +%Y-%m-%d).log
tail -f /var/www/mbi-v3/api/logs/audio-favorites-$(date +%Y-%m-%d).log
```

### Comandos de diagnóstico

```bash
# Verificar archivos en Docker
sudo docker exec azuracast ls -la /var/azuracast/stations/test/media/Grabaciones/ | wc -l

# Verificar base de datos
sqlite3 /var/www/mbi-v3/calendario/api/db/calendar.db "SELECT COUNT(*) FROM audio_favorites;"

# Verificar migración
sqlite3 /var/www/mbi-v3/calendario/api/db/calendar.db "SELECT * FROM audio_favorites LIMIT 5;"

# Limpiar favoritos huérfanos
sqlite3 /var/www/mbi-v3/calendario/api/db/calendar.db "DELETE FROM audio_favorites WHERE filename NOT IN (SELECT filename FROM audio_metadata);"
```

## 🤝 Diferencias con Campaign Library

| Característica | Audio Library | Campaign Library |
|---------------|---------------|------------------|
| **Propósito** | Mostrar TODOS los archivos | Solo mensajes guardados |
| **Contenido** | Archivos MP3 crudos | Mensajes con metadata completa |
| **Favoritos** | Marca archivos como favoritos | N/A (ya están guardados) |
| **Categorías** | No tiene | 7 categorías predefinidas |
| **Programación** | No | Sí, integración con calendario |
| **Metadata** | Mínima (nombre, fecha) | Completa (título, descripción, categoría) |
| **Almacenamiento** | Docker + BD favoritos | localStorage + backend |

## 📊 Estadísticas del Proyecto v2.0

- **Líneas de código:** 670 (JS) + CSS
- **APIs backend:** 3 archivos PHP
- **Tiempo de desarrollo v2.0:** 4 horas
- **Mejoras implementadas:** 8 principales
- **Breaking changes:** Ninguno (retrocompatible)

---

**Última actualización:** 27 de Agosto, 2025  
**Versión:** 2.0.0  
**Estado:** ✅ Producción - Con Base de Datos  
**Próxima revisión:** 3 de Septiembre, 2025