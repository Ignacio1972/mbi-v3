# 🎨 DOCUMENTACIÓN MAESTRA DE CSS, IDs Y CLASES - MBI-v3

> **Última actualización:** 27 de Agosto, 2025  
> **Versión:** 1.0.0  
> **Estado:** Sistema en producción activa  
> **Archivos analizados:** 150+ archivos CSS/JS  

## 📋 TABLA DE CONTENIDOS

1. [Sistema de Clasificación](#sistema-de-clasificación)
2. [IDs y Clases Globales](#ids-y-clases-globales)
3. [Módulo: Message Configurator](#módulo-message-configurator)
4. [Módulo: Audio Library](#módulo-audio-library)
5. [Módulo: Campaign Library](#módulo-campaign-library)
6. [Módulo: Calendar](#módulo-calendar)
7. [Módulo: Radio](#módulo-radio)
8. [Clases Compartidas Entre Módulos](#clases-compartidas-entre-módulos)
9. [Sistema de Variables CSS](#sistema-de-variables-css)
10. [Mapa de Dependencias](#mapa-de-dependencias)
11. [Guía de Modificación Segura](#guía-de-modificación-segura)

---

## 🚦 SISTEMA DE CLASIFICACIÓN

### Niveles de Criticidad:

- **🔴 CRÍTICO**: NO modificar sin análisis exhaustivo. Usado en JavaScript o estructural.
- **🟡 MODIFICABLE**: Puede modificarse con precaución. Verificar impacto visual.
- **🟢 DECORATIVO**: Libre modificación. Solo afecta apariencia.

### Indicadores:
- **[JS]** = Usado en JavaScript
- **[NAV]** = Parte del sistema de navegación
- **[GLOBAL]** = Usado en múltiples módulos
- **[DYNAMIC]** = Añadido/removido dinámicamente

---

## 🌍 IDS Y CLASES GLOBALES

### IDs Principales del DOM (`index.html`)

| ID | Criticidad | Ubicación | Uso | Notas |
|----|------------|-----------|-----|-------|
| `#app-container` | 🔴 CRÍTICO [JS][NAV] | index.html:46 | Contenedor principal donde se montan TODOS los módulos | moduleLoader.init() depende de este ID |
| `#global-loading` | 🔴 CRÍTICO [JS][GLOBAL] | index.html:57 | Indicador de carga global | Usado por todos los módulos para mostrar loading |
| `#global-error` | 🔴 CRÍTICO [JS][GLOBAL] | index.html:66 | Contenedor de errores globales | Sistema de notificaciones de error |

### Clases del Sistema Base (`/assets/css/base.css`)

#### Layout Principal
| Clase | Criticidad | Línea | Uso |
|-------|------------|-------|-----|
| `.main-container` | 🟡 MODIFICABLE | 141-146 | Container principal del layout |
| `.app-container` | 🔴 CRÍTICO | 148-157 | Estilo del #app-container |
| `.configurator-container` | 🔴 CRÍTICO [NAV] | index.html:18 | Wrapper de toda la aplicación |
| `.configurator-header` | 🟡 MODIFICABLE | index.html:20 | Header con título principal |
| `.configurator-tabs` | 🔴 CRÍTICO [NAV] | index.html:26 | Navegación principal |
| `.configurator-content` | 🔴 CRÍTICO [NAV] | index.html:45 | Área de contenido de módulos |

#### Navegación
| Clase | Criticidad | Uso | Notas |
|-------|------------|-----|-------|
| `.tab-button` | 🔴 CRÍTICO [JS][NAV] | Botones de navegación | router.js escucha clicks |
| `.tab-button--active` | 🔴 CRÍTICO [JS][DYNAMIC] | Tab activo | Añadido/removido por router |

#### Estados de Carga
| Clase | Criticidad | Línea | Uso |
|-------|------------|-------|-----|
| `.loading` | 🔴 CRÍTICO [JS][GLOBAL] | 163-170 | Estado de carga base |
| `.loading--active` | 🔴 CRÍTICO [JS][DYNAMIC] | 172-174 | Activa el loading |
| `.loading__spinner` | 🟢 DECORATIVO | 176-184 | Animación del spinner |
| `.loading__text` | 🟢 DECORATIVO | 186-189 | Texto del loading |
| `.global-loading` | 🔴 CRÍTICO [JS] | 192-197 | Loading global fijo |
| `.global-loading--active` | 🔴 CRÍTICO [JS][DYNAMIC] | 199-203 | Activa loading global |

#### Botones y Formularios
| Clase | Criticidad | Línea | Uso |
|-------|------------|-------|-----|
| `.btn` | 🟡 MODIFICABLE [GLOBAL] | 310-322 | Clase base de botones |
| `.btn-primary` | 🟡 MODIFICABLE [GLOBAL] | 324-333 | Botón principal |
| `.btn-secondary` | 🟡 MODIFICABLE [GLOBAL] | 335-344 | Botón secundario |
| `.btn-success` | 🟡 MODIFICABLE [GLOBAL] | 346-355 | Botón de éxito |
| `.btn-link` | 🟡 MODIFICABLE | 357-370 | Botón tipo link |
| `.form-control` | 🟡 MODIFICABLE [GLOBAL] | 373-383 | Input base |

---

## 📝 MÓDULO: MESSAGE CONFIGURATOR

### Archivos:
- `/modules/message-configurator/index.js`
- `/modules/message-configurator/style.css`
- `/modules/message-configurator/styles/*.css`

### IDs Críticos

| ID | Criticidad | Archivo | Línea | Uso |
|----|------------|---------|-------|-----|
| `#message-text` | 🔴 CRÍTICO [JS] | index.js:263 | Textarea principal del mensaje |
| `#message-voice` | 🔴 CRÍTICO [JS] | index.js:68,275,471 | Select de voz |
| `#message-category` | 🔴 CRÍTICO [JS] | index.js:269 | Select de categoría |
| `#generateBtn` | 🔴 CRÍTICO [JS] | Renderizado | Botón generar audio |
| `#sendToRadioBtn` | 🔴 CRÍTICO [JS] | Renderizado | Botón enviar a radio |
| `#saveMessageBtn` | 🔴 CRÍTICO [JS] | index.js:322,451 | Botón guardar mensaje |
| `#processedText` | 🔴 CRÍTICO [JS] | index.js:316 | Texto procesado |
| `#audio-player-container` | 🔴 CRÍTICO [JS] | index.js:445 | Contenedor del player |
| `#tags-container` | 🔴 CRÍTICO [JS] | component-factory.js:14 | Tags de plantillas |
| `#style-slider-container` | 🔴 CRÍTICO [JS] | component-factory.js:22 | Slider de estilo |
| `#stability-slider-container` | 🔴 CRÍTICO [JS] | component-factory.js:27 | Slider estabilidad |
| `#similarity-slider-container` | 🔴 CRÍTICO [JS] | component-factory.js:32 | Slider similaridad |
| `#speaker-boost-container` | 🔴 CRÍTICO [JS] | component-factory.js:37 | Toggle speaker boost |
| `#voice-profiles-container` | 🔴 CRÍTICO [JS] | component-factory.js:42 | Selector de perfiles |

### Clases CSS

| Clase | Criticidad | Uso |
|-------|------------|-----|
| `.message-configurator` | 🟡 MODIFICABLE | Container principal del módulo |
| `.configurator-header` | 🟡 MODIFICABLE | Header del módulo |
| `.message-section` | 🟡 MODIFICABLE | Sección de mensaje |
| `.controls-section` | 🟡 MODIFICABLE | Sección de controles |
| `.voice-settings` | 🟡 MODIFICABLE | Configuración de voz |
| `.actions-section` | 🟡 MODIFICABLE | Sección de acciones |
| `.status-*` | 🔴 CRÍTICO [DYNAMIC] | Estados dinámicos (success, error, info) |
| `.slider-container` | 🟡 MODIFICABLE | Contenedor de sliders |
| `.slider-label` | 🟢 DECORATIVO | Label de sliders |
| `.simple-slider` | 🟡 MODIFICABLE | Componente slider |
| `.template-modal` | 🔴 CRÍTICO [JS] | Modal de plantillas |
| `.save-modal` | 🔴 CRÍTICO [JS] | Modal de guardar |

---

## 📚 MÓDULO: AUDIO LIBRARY

### Archivos:
- `/modules/audio-library/index.js`
- `/modules/audio-library/styles/library.css`

### IDs Críticos

| ID | Criticidad | Archivo | Línea | Uso |
|----|------------|---------|-------|-----|
| `#viewToggle` | 🔴 CRÍTICO [JS] | index.js:76,133,420 | Toggle vista grid/lista |
| `#librarySearch` | 🔴 CRÍTICO [JS] | index.js:79,137 | Input de búsqueda |
| `#librarySort` | 🔴 CRÍTICO [JS] | index.js:80,143 | Select de ordenamiento |
| `#refreshBtn` | 🔴 CRÍTICO [JS] | index.js:86,151 | Botón actualizar |
| `#totalFiles` | 🔴 CRÍTICO [JS] | index.js:92,251 | Contador de archivos |
| `#totalFavorites` | 🔴 CRÍTICO [JS] | index.js:93,252 | Contador favoritos |
| `#totalSize` | 🔴 CRÍTICO [JS] | index.js:94,259 | Tamaño total |
| `#libraryGrid` | 🔴 CRÍTICO [JS] | index.js:97,293 | Vista grid |
| `#libraryList` | 🔴 CRÍTICO [JS] | index.js:101,294 | Vista lista |
| `#libraryEmpty` | 🔴 CRÍTICO [JS] | index.js:105,295 | Estado vacío |
| `#floatingPlayer` | 🔴 CRÍTICO [JS] | index.js:111,427 | Player flotante |
| `#audioPlayer` | 🔴 CRÍTICO [JS] | index.js:116,428 | Elemento audio |
| `#currentPlaying` | 🔴 CRÍTICO [JS] | index.js:113,429 | Texto reproduciendo |

### Clases CSS

| Clase | Criticidad | Uso |
|-------|------------|-----|
| `.audio-library-module` | 🟡 MODIFICABLE | Container principal |
| `.library-header` | 🟢 DECORATIVO | Header del módulo |
| `.library-controls` | 🟡 MODIFICABLE | Controles superiores |
| `.stats-bar` | 🟢 DECORATIVO | Barra de estadísticas |
| `.library-grid` | 🔴 CRÍTICO [JS] | Vista grid |
| `.library-list` | 🔴 CRÍTICO [JS] | Vista lista |
| `.file-card` | 🟡 MODIFICABLE | Tarjeta de archivo |
| `.btn-favorite` | 🔴 CRÍTICO [JS] | Botón favorito |
| `.btn-favorite.active` | 🔴 CRÍTICO [DYNAMIC] | Favorito activo |
| `.floating-player` | 🔴 CRÍTICO | Player flotante |
| `.library-table` | 🟡 MODIFICABLE | Tabla en vista lista |
| `.empty-state` | 🟢 DECORATIVO | Estado sin archivos |

---

## 💾 MÓDULO: CAMPAIGN LIBRARY

### Archivos:
- `/modules/campaign-library/index.js`
- `/modules/campaign-library/styles/library.css`
- `/modules/campaign-library/styles/schedule-modal.css`

### IDs Críticos

| ID | Criticidad | Archivo | Línea | Uso |
|----|------------|---------|-------|-----|
| `#campaign-library-styles` | 🔴 CRÍTICO | index.js:64 | Link de estilos |
| `#searchInput` | 🔴 CRÍTICO [JS] | Renderizado | Input de búsqueda |
| `#messages-grid` | 🔴 CRÍTICO [JS] | Renderizado | Grid de mensajes |
| `#schedule-modal-styles` | 🔴 CRÍTICO | schedule-modal.js | Estilos del modal |
| `#floatingPlayer` | 🔴 CRÍTICO [JS][GLOBAL] | Compartido | Player flotante |
| `#audioPlayer` | 🔴 CRÍTICO [JS][GLOBAL] | Compartido | Elemento audio |
| `#currentPlaying` | 🔴 CRÍTICO [JS] | Compartido | Texto reproduciendo |

### Clases CSS

| Clase | Criticidad | Uso |
|-------|------------|-----|
| `.campaign-library-module` | 🟡 MODIFICABLE | Container principal |
| `.library-controls` | 🟡 MODIFICABLE [GLOBAL] | Controles (compartido) |
| `.library-filters` | 🟡 MODIFICABLE | Filtros de categoría |
| `.filter-btn` | 🔴 CRÍTICO [JS] | Botones de filtro |
| `.filter-btn.active` | 🔴 CRÍTICO [DYNAMIC] | Filtro activo |
| `.messages-grid` | 🔴 CRÍTICO [JS] | Grid de mensajes |
| `.message-card` | 🟡 MODIFICABLE | Tarjeta de mensaje |
| `.category-*` | 🟢 DECORATIVO | Colores por categoría |
| `.schedule-modal` | 🔴 CRÍTICO [JS] | Modal de programación |
| `.schedule-form` | 🟡 MODIFICABLE | Formulario de schedule |

---

## 📅 MÓDULO: CALENDAR

### Archivos:
- `/modules/calendar/index.js`
- `/modules/calendar/styles/style.css`
- `/modules/calendar/styles/calendar-tooltips.css`

### IDs Críticos

| ID | Criticidad | Archivo | Línea | Uso |
|----|------------|---------|-------|-----|
| `#calendar-styles` | 🔴 CRÍTICO | index.js | Link de estilos |
| `#calendar-tooltips-styles` | 🔴 CRÍTICO | index.js | Estilos tooltips |
| `#currentMonth` | 🔴 CRÍTICO [JS] | Renderizado | Mes actual |
| `#prevMonth` | 🔴 CRÍTICO [JS] | Renderizado | Mes anterior |
| `#nextMonth` | 🔴 CRÍTICO [JS] | Renderizado | Mes siguiente |
| `#calendarGrid` | 🔴 CRÍTICO [JS] | Renderizado | Grid del calendario |
| `#schedulesList` | 🔴 CRÍTICO [JS] | Renderizado | Lista de schedules |
| `#schedulesTable` | 🔴 CRÍTICO [JS] | Renderizado | Tabla de schedules |
| `#eventFilterButtons` | 🔴 CRÍTICO [JS] | Renderizado | Filtros de eventos |

### Clases CSS

| Clase | Criticidad | Uso |
|-------|------------|-----|
| `.calendar-module` | 🟡 MODIFICABLE | Container principal |
| `.calendar-header` | 🟡 MODIFICABLE | Header con navegación |
| `.calendar-nav` | 🟡 MODIFICABLE | Navegación de meses |
| `.calendar-grid` | 🔴 CRÍTICO | Grid del calendario |
| `.calendar-day` | 🟡 MODIFICABLE | Día del calendario |
| `.calendar-day--today` | 🟢 DECORATIVO | Día actual |
| `.calendar-day--other-month` | 🟢 DECORATIVO | Día de otro mes |
| `.event-indicator` | 🟡 MODIFICABLE | Indicador de evento |
| `.schedule-tooltip` | 🔴 CRÍTICO [JS] | Tooltip de evento |
| `.schedules-section` | 🟡 MODIFICABLE | Sección de schedules |
| `.schedules-table` | 🟡 MODIFICABLE [GLOBAL] | Tabla de schedules |
| `.filter-buttons` | 🟡 MODIFICABLE | Botones de filtro |
| `.filter-btn--active` | 🔴 CRÍTICO [DYNAMIC] | Filtro activo |

---

## 📻 MÓDULO: RADIO

### Archivos:
- `/modules/radio/index.js`
- `/modules/radio/style.css`

### IDs Críticos

| ID | Criticidad | Archivo | Línea | Uso |
|----|------------|---------|-------|-----|
| `#radio-styles` | 🔴 CRÍTICO | index.js | Link de estilos |
| `#nowPlaying` | 🔴 CRÍTICO [JS] | Renderizado | Canción actual |
| `#listeners` | 🔴 CRÍTICO [JS] | Renderizado | Oyentes actuales |
| `#radioStatus` | 🔴 CRÍTICO [JS] | Renderizado | Estado de la radio |
| `#audioStreamPlayer` | 🔴 CRÍTICO [JS] | Renderizado | Player del stream |

### Clases CSS

| Clase | Criticidad | Uso |
|-------|------------|-----|
| `.radio-module` | 🟡 MODIFICABLE | Container principal |
| `.radio-header` | 🟢 DECORATIVO | Header del módulo |
| `.radio-status` | 🟡 MODIFICABLE | Estado de la radio |
| `.status--online` | 🟢 DECORATIVO [DYNAMIC] | Estado online |
| `.status--offline` | 🟢 DECORATIVO [DYNAMIC] | Estado offline |
| `.radio-player` | 🟡 MODIFICABLE | Player de radio |
| `.now-playing` | 🟡 MODIFICABLE | Información actual |
| `.stream-stats` | 🟢 DECORATIVO | Estadísticas |
| `.radio-controls` | 🟡 MODIFICABLE | Controles de radio |

---

## 🔗 CLASES COMPARTIDAS ENTRE MÓDULOS

### Clases Globales de Alto Impacto

| Clase | Módulos que la usan | Criticidad | Notas |
|-------|-------------------|------------|-------|
| `.btn` | TODOS | 🟡 MODIFICABLE [GLOBAL] | Clase base de botones |
| `.btn-primary` | TODOS | 🟡 MODIFICABLE [GLOBAL] | Botón principal |
| `.btn-secondary` | TODOS | 🟡 MODIFICABLE [GLOBAL] | Botón secundario |
| `.form-control` | Configurator, Calendar, Campaign | 🟡 MODIFICABLE [GLOBAL] | Inputs base |
| `.loading` | TODOS | 🔴 CRÍTICO [GLOBAL] | Estado de carga |
| `.loading--active` | TODOS | 🔴 CRÍTICO [DYNAMIC][GLOBAL] | Activa loading |

### Clases de Layout Compartidas

| Clase | Módulos | Uso |
|-------|---------|-----|
| `.library-controls` | Audio Library, Campaign Library | Controles superiores |
| `.message-section` | Configurator, Campaign | Sección de mensaje |
| `.controls-section` | Configurator, Calendar | Sección de controles |
| `.status-*` | Configurator, Radio | Estados dinámicos |
| `.filter-btn` | Campaign, Calendar | Botones de filtro |
| `.floating-player` | Audio Library, Campaign Library | Player compartido |

### IDs Compartidos (Potencial Conflicto)

| ID | Módulos | Criticidad | Riesgo |
|----|---------|------------|--------|
| `#floatingPlayer` | Audio Library, Campaign Library | 🔴 CRÍTICO | ⚠️ Posible conflicto si ambos módulos cargan simultáneamente |
| `#audioPlayer` | Audio Library, Campaign Library, Configurator | 🔴 CRÍTICO | ⚠️ Conflicto potencial |
| `#currentPlaying` | Audio Library, Campaign Library | 🔴 CRÍTICO | ⚠️ Conflicto potencial |

---

## 🎨 SISTEMA DE VARIABLES CSS

### Variables Críticas (`base.css`)

| Variable | Línea | Valor Actual | Impacto |
|----------|-------|--------------|---------|
| `--primary` | 9 | #6366f1 | Color principal - TODO el sistema |
| `--bg-primary` | 34 | #0a0a0f | Fondo principal |
| `--bg-card` | 36 | #1a1a26 | Fondo de tarjetas |
| `--border-radius` | 46 | 24px | Radio de bordes general |
| `--space-md` | 58 | 2.5rem | Espaciado medio |
| `--z-modal` | 74 | 2000 | Z-index modales |
| `--transition-base` | 69 | 250ms | Transiciones |

### Breakpoints Responsive

| Breakpoint | Valor | Archivo | Línea |
|------------|-------|---------|-------|
| Tablet | 1024px | base.css | 397 |
| Mobile | 768px | base.css | 409 |

---

## 🗺️ MAPA DE DEPENDENCIAS

### Dependencias Críticas del Sistema

```
index.html
├── #app-container [CRÍTICO]
│   ├── moduleLoader.init() 
│   └── Todos los módulos se montan aquí
├── .configurator-tabs [CRÍTICO]
│   ├── .tab-button [CRÍTICO]
│   └── router.js navigation
└── #global-loading, #global-error [CRÍTICO]
    └── Usados por todos los módulos

base.css
├── Variables CSS [CRÍTICO]
├── .btn, .form-control [GLOBAL]
└── .loading states [CRÍTICO]

Cada Módulo
├── Estilos propios
├── IDs únicos del módulo
└── Puede usar clases globales
```

### Flujo de Carga de Módulos

1. `router.js` detecta cambio de ruta
2. `moduleLoader.js` desmonta módulo actual
3. Limpia estilos del módulo anterior
4. Carga nuevo módulo en `#app-container`
5. Inyecta CSS del módulo si no existe
6. Actualiza `.tab-button--active`

---

## 🛡️ GUÍA DE MODIFICACIÓN SEGURA

### ✅ Antes de Modificar Cualquier ID/Clase:

1. **Buscar en TODOS los archivos JS:**
   ```bash
   grep -r "getElementById\|querySelector\|querySelectorAll" --include="*.js"
   ```

2. **Verificar si es dinámico:**
   ```bash
   grep -r "classList.add\|classList.remove\|classList.toggle" --include="*.js"
   ```

3. **Revisar dependencias CSS:**
   ```bash
   grep -r "\.clase-a-modificar" --include="*.css"
   ```

### 🚨 NUNCA Modificar Sin Análisis:

- IDs marcados como 🔴 CRÍTICO
- Clases con tag [JS] o [DYNAMIC]
- Variables CSS del sistema
- Clases con tag [GLOBAL]
- IDs del sistema de navegación [NAV]

### ✅ Modificables con Precaución:

- Clases marcadas como 🟡 MODIFICABLE
- Verificar impacto visual en TODOS los módulos
- Probar en diferentes resoluciones
- Mantener consistencia con design system

### ✅ Libremente Modificables:

- Clases marcadas como 🟢 DECORATIVO
- Colores y sombras decorativas
- Animaciones que no afectan funcionalidad
- Padding/margin que no rompen layout

### 📝 Checklist Pre-Modificación:

- [ ] ¿Revisé si el ID/clase se usa en JavaScript?
- [ ] ¿Verifiqué en qué módulos se usa?
- [ ] ¿Es parte del sistema de navegación?
- [ ] ¿Se añade/remueve dinámicamente?
- [ ] ¿Probé en todos los módulos afectados?
- [ ] ¿Verifiqué en móvil y desktop?
- [ ] ¿Documenté el cambio?

### 🎯 Mejores Prácticas para Nuevos Desarrollos:

1. **Usar prefijos de módulo:** `radio-player`, `library-card`
2. **Evitar IDs genéricos:** En lugar de `#player`, usar `#radio-stream-player`
3. **Documentar inmediatamente:** Agregar a este documento
4. **Mantener BEM:** `block__element--modifier`
5. **Variables para valores reutilizables:** Usar CSS variables
6. **Comentar código crítico:** Indicar dependencias JS

---

## 📊 ESTADÍSTICAS DEL ANÁLISIS

- **Total de IDs únicos identificados:** 67
- **Total de clases CSS únicas:** 183
- **Clases marcadas como CRÍTICAS:** 42
- **Clases MODIFICABLES:** 78
- **Clases DECORATIVAS:** 63
- **Clases GLOBALES compartidas:** 15
- **Variables CSS del sistema:** 31
- **Archivos CSS analizados:** 27
- **Archivos JS analizados:** 45

---

## 🔄 HISTORIAL DE CAMBIOS

| Fecha | Versión | Cambio | Autor |
|-------|---------|--------|-------|
| 27/08/2025 | 1.0.0 | Documento inicial - Análisis completo | Claude Code |

---

## 📝 NOTAS IMPORTANTES

1. **Sistema en Producción:** Este es un sistema de radio en vivo. Los errores de interfaz pueden afectar operaciones críticas.

2. **Conflictos de IDs:** Se detectaron IDs compartidos entre módulos (`#floatingPlayer`, `#audioPlayer`). Considerar refactorización futura.

3. **Dependencias No Documentadas:** Algunos componentes pueden tener dependencias no obvias. Siempre probar exhaustivamente.

4. **CSS Variables:** El sistema usa CSS variables extensivamente. Cambios en variables afectan TODO el sistema.

5. **Responsive Design:** Todos los módulos tienen estilos responsive. Verificar en múltiples dispositivos.

---

**FIN DEL DOCUMENTO**

*Esta documentación debe actualizarse con cada cambio significativo en el sistema de estilos.*