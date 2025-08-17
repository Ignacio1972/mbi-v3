-- ============================================
-- ESQUEMA DE BASE DE DATOS PARA AUDIO LIBRARY
-- Compatible con SQLite existente del calendario
-- ============================================

-- Tabla de favoritos de audio
CREATE TABLE IF NOT EXISTS audio_favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,                -- Nombre del archivo (ej: tts20250813093045.mp3)
    user_session TEXT,                     -- Sesión del usuario (por ahora simple)
    is_active BOOLEAN DEFAULT 1,          -- Para soft delete
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Índice único por archivo y sesión
    UNIQUE(filename, user_session)
);

-- Tabla de metadata de archivos de audio
CREATE TABLE IF NOT EXISTS audio_metadata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL UNIQUE,        -- Nombre original del archivo
    display_name TEXT,                     -- Nombre legible para mostrar
    description TEXT,                      -- Descripción completa
    category TEXT DEFAULT 'general',      -- Categoría del audio
    
    -- Datos técnicos
    file_size INTEGER,                     -- Tamaño en bytes
    duration_seconds INTEGER,             -- Duración en segundos
    
    -- Estadísticas de uso
    play_count INTEGER DEFAULT 0,         -- Cuántas veces se reprodujo
    radio_sent_count INTEGER DEFAULT 0,   -- Cuántas veces se envió a radio
    last_played_at DATETIME,              -- Última reproducción
    last_radio_sent_at DATETIME,          -- Último envío a radio
    
    -- Control
    is_active BOOLEAN DEFAULT 1,          -- Para soft delete
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla futura para programación (calendario)
CREATE TABLE IF NOT EXISTS audio_schedule (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,               -- Archivo a reproducir
    title TEXT NOT NULL,                  -- Título del evento
    
    -- Programación 
    schedule_time TIME NOT NULL,          -- Hora del día (HH:MM:SS)
    schedule_days TEXT DEFAULT 'daily',   -- 'daily', 'weekdays', 'monday,friday', etc
    start_date DATE,                      -- Fecha de inicio (opcional)
    end_date DATE,                        -- Fecha de fin (opcional)
    
    -- Estado
    is_active BOOLEAN DEFAULT 1,
    priority INTEGER DEFAULT 5,           -- Prioridad (1-10)
    
    -- Metadata
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT,
    notes TEXT,
    
    FOREIGN KEY (filename) REFERENCES audio_metadata(filename) ON DELETE CASCADE
);

-- Tabla de historial de acciones
CREATE TABLE IF NOT EXISTS audio_actions_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,
    action TEXT NOT NULL,                 -- 'play', 'radio_sent', 'favorited', 'renamed'
    user_session TEXT,
    details TEXT,                         -- JSON con detalles adicionales
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================

-- Favoritos
CREATE INDEX IF NOT EXISTS idx_favorites_filename ON audio_favorites(filename);
CREATE INDEX IF NOT EXISTS idx_favorites_session ON audio_favorites(user_session);
CREATE INDEX IF NOT EXISTS idx_favorites_active ON audio_favorites(is_active, created_at);

-- Metadata
CREATE INDEX IF NOT EXISTS idx_metadata_filename ON audio_metadata(filename);
CREATE INDEX IF NOT EXISTS idx_metadata_category ON audio_metadata(category);
CREATE INDEX IF NOT EXISTS idx_metadata_active ON audio_metadata(is_active);
CREATE INDEX IF NOT EXISTS idx_metadata_usage ON audio_metadata(play_count DESC, radio_sent_count DESC);

-- Schedule (futuro)
CREATE INDEX IF NOT EXISTS idx_schedule_time ON audio_schedule(schedule_time, is_active);
CREATE INDEX IF NOT EXISTS idx_schedule_active ON audio_schedule(is_active, priority);

-- Log de acciones
CREATE INDEX IF NOT EXISTS idx_actions_filename ON audio_actions_log(filename, created_at);
CREATE INDEX IF NOT EXISTS idx_actions_type ON audio_actions_log(action, created_at);

-- ============================================
-- TRIGGERS PARA AUTO-UPDATE
-- ============================================

-- Actualizar timestamp en metadata
CREATE TRIGGER IF NOT EXISTS update_audio_metadata_timestamp 
    AFTER UPDATE ON audio_metadata
    BEGIN
        UPDATE audio_metadata 
        SET updated_at = CURRENT_TIMESTAMP 
        WHERE id = NEW.id;
    END;

-- Actualizar timestamp en schedule
CREATE TRIGGER IF NOT EXISTS update_audio_schedule_timestamp 
    AFTER UPDATE ON audio_schedule
    BEGIN
        UPDATE audio_schedule 
        SET updated_at = CURRENT_TIMESTAMP 
        WHERE id = NEW.id;
    END;

-- ============================================
-- DATOS INICIALES PARA TESTING
-- ============================================

-- Configuración del sistema de audio
INSERT OR REPLACE INTO system_config (key, value) VALUES 
    ('audio_favorites_enabled', '1'),
    ('audio_metadata_enabled', '1'),
    ('audio_schedule_enabled', '0'),  -- Deshabilitado hasta implementación completa
    ('audio_session_type', 'simple'), -- 'simple' o 'user_based'
    ('audio_cleanup_days', '365');    -- Limpiar logs después de 1 año