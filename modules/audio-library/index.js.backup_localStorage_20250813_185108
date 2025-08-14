/**
 * Audio Library Module - Biblioteca de Archivos de Audio
 * @module AudioLibraryModule
 */

import { eventBus } from '../../shared/event-bus.js';
import { apiClient } from '../../shared/api-client.js';

export default class AudioLibraryModule {
    constructor() {
        this.name = 'audio-library';
        this.container = null;
        this.libraryFiles = [];
        this.currentSort = 'date_desc';
        this.currentView = 'grid';
        this.searchQuery = '';
        this.favorites = JSON.parse(localStorage.getItem('audio_favorites') || '[]');
    }
    
    getName() {
        return this.name;
    }
    
    async load(container) {
        console.log('[AudioLibrary] Loading...');
        this.container = container;
        
        try {
            this.render();
            await this.loadStyles();
            this.attachEvents();
            await this.loadLibrary();
            eventBus.emit('audio-library:loaded');
        } catch (error) {
            console.error('[AudioLibrary] Load failed:', error);
            this.showNotification('Error al cargar la biblioteca', 'error');
        }
    }
    
    async unload() {
        console.log('[AudioLibrary] Unloading...');
        this.libraryFiles = [];
        this.container = null;
        if (window.audioLibrary) {
            delete window.audioLibrary;
        }
    }
    
    async loadStyles() {
        if (!document.querySelector('#audio-library-styles')) {
            const link = document.createElement('link');
            link.id = 'audio-library-styles';
            link.rel = 'stylesheet';
            link.href = '/modules/audio-library/styles/library.css';
            document.head.appendChild(link);
            await new Promise((resolve) => {
                link.onload = resolve;
                link.onerror = resolve;
            });
        }
    }
    
    render() {
        this.container.innerHTML = `
            <div class="audio-library-module">
                <div class="library-header">
                    <h2>📚 Biblioteca de Audios Generados</h2>
                    <p>Todos los audios que generes aparecen aquí automáticamente</p>
                </div>
                
                <div class="library-controls">
                    <button class="btn btn-secondary" id="viewToggle">
                        📋 Vista Lista
                    </button>
                    <input type="text" id="librarySearch" placeholder="🔍 Buscar archivos...">
                    <select id="librarySort">
                        <option value="date_desc">Más recientes primero</option>
                        <option value="date_asc">Más antiguos primero</option>
                        <option value="name_asc">Nombre A-Z</option>
                        <option value="favorites">Favoritos primero</option>
                    </select>
                    <button class="btn btn-primary" id="refreshBtn">
                        🔄 Actualizar
                    </button>
                </div>
                
                <div class="stats-bar">
                    <span>📊 Total: <strong id="totalFiles">0</strong> archivos</span>
                    <span>⭐ Favoritos: <strong id="totalFavorites">0</strong></span>
                    <span>💾 Espacio: <strong id="totalSize">0 MB</strong></span>
                </div>
                
                <div id="libraryGrid" class="library-grid">
                    <div class="loading">⏳ Cargando biblioteca...</div>
                </div>
                
                <div id="libraryList" class="library-list" style="display: none;">
                    <div class="loading">⏳ Cargando biblioteca...</div>
                </div>
                
                <div id="libraryEmpty" class="empty-state" style="display: none;">
                    <p>📭 No hay audios en la biblioteca</p>
                </div>
            </div>
            
            <!-- Player flotante -->
            <div id="floatingPlayer" class="floating-player" style="display: none;">
                <div class="player-header">
                    <span id="currentPlaying">🎵 Reproduciendo...</span>
                    <button onclick="audioLibrary.closePlayer()">✕</button>
                </div>
                <audio id="audioPlayer" controls></audio>
            </div>
        `;
        
        // Exponer funciones globalmente
        window.audioLibrary = {
            playFile: (filename) => this.playFile(filename),
            sendToRadio: (filename) => this.sendToRadio(filename),
            renameFile: (filename) => this.renameFile(filename),
            toggleFavorite: (filename) => this.toggleFavorite(filename),
            deleteFile: (filename) => this.deleteFile(filename),
            closePlayer: () => this.closePlayer()
        };
    }
    
    attachEvents() {
        // Vista toggle
        const viewToggle = this.container.querySelector('#viewToggle');
        viewToggle?.addEventListener('click', () => this.toggleView());
        
        // Búsqueda
        const searchInput = this.container.querySelector('#librarySearch');
        searchInput?.addEventListener('input', (e) => {
            this.searchQuery = e.target.value;
            this.filterLibrary();
        });
        
        // Ordenamiento
        const sortSelect = this.container.querySelector('#librarySort');
        sortSelect?.addEventListener('change', (e) => {
            this.currentSort = e.target.value;
            this.sortLibrary();
        });
        
        // Refrescar
        const refreshBtn = this.container.querySelector('#refreshBtn');
        refreshBtn?.addEventListener('click', () => this.loadLibrary());
    }
    
    async loadLibrary() {
        try {
            const response = await apiClient.post('/biblioteca.php', {
                action: 'list_library'
            });
            
            if (response.success) {
                this.libraryFiles = response.files || [];
                this.updateStats();
                this.sortLibrary();
                this.renderLibrary();
            }
        } catch (error) {
            console.error('[AudioLibrary] Error loading files:', error);
            this.showNotification('Error al cargar archivos', 'error');
        }
    }
    
    updateStats() {
        const totalFiles = this.container.querySelector('#totalFiles');
        const totalFavorites = this.container.querySelector('#totalFavorites');
        const totalSize = this.container.querySelector('#totalSize');
        
        if (totalFiles) totalFiles.textContent = this.libraryFiles.length;
        if (totalFavorites) totalFavorites.textContent = this.favorites.length;
        
        const totalBytes = this.libraryFiles.reduce((sum, file) => sum + (file.size || 0), 0);
        if (totalSize) totalSize.textContent = this.formatFileSize(totalBytes);
    }
    
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
        
        this.libraryFiles = files;
        this.renderLibrary();
    }
    
    filterLibrary() {
        this.renderLibrary();
    }
    
    renderLibrary() {
        const grid = this.container.querySelector('#libraryGrid');
        const list = this.container.querySelector('#libraryList');
        const empty = this.container.querySelector('#libraryEmpty');
        
        // Filtrar por búsqueda
        let filtered = this.libraryFiles;
        if (this.searchQuery) {
            const query = this.searchQuery.toLowerCase();
            filtered = filtered.filter(f => 
                f.filename.toLowerCase().includes(query)
            );
        }
        
        if (filtered.length === 0) {
            grid.style.display = 'none';
            list.style.display = 'none';
            empty.style.display = 'block';
            return;
        }
        
        empty.style.display = 'none';
        
        if (this.currentView === 'grid') {
            grid.style.display = 'grid';
            list.style.display = 'none';
            this.renderGridView(grid, filtered);
        } else {
            grid.style.display = 'none';
            list.style.display = 'block';
            this.renderListView(list, filtered);
        }
    }
    
    renderGridView(container, files) {
        container.innerHTML = files.map(file => {
            const isFavorite = this.favorites.includes(file.filename);
            const displayName = this.getDisplayName(file.filename);
            
            return `
                <div class="file-card">
                    <div class="card-header">
                        <button class="btn-favorite ${isFavorite ? 'active' : ''}" 
                                onclick="audioLibrary.toggleFavorite('${file.filename}')"
                                title="${isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos'}">
                            ${isFavorite ? '★' : '⭐'}
                        </button>
                        <span class="file-date">${file.formatted_date || file.date}</span>
                    </div>
                    
                    <div class="card-body">
                        <h4 class="file-name" title="${file.filename}">${displayName}</h4>
                        <div class="file-info">
                            <span>📊 ${this.formatFileSize(file.size)}</span>
                        </div>
                    </div>
                    
                    <div class="card-actions">
                        <button class="btn btn-play" onclick="audioLibrary.playFile('${file.filename}')">
                            ▶️ Preview
                        </button>
                        <button class="btn btn-primary" onclick="audioLibrary.sendToRadio('${file.filename}')">
                            📻 A Radio
                        </button>
                        <button class="btn btn-secondary" onclick="audioLibrary.renameFile('${file.filename}')">
                            ✏️
                        </button>
                        <button class="btn btn-danger" onclick="audioLibrary.deleteFile('${file.filename}')">
                            🗑️
                        </button>
                    </div>
                </div>
            `;
        }).join('');
    }
    
    renderListView(container, files) {
        const rows = files.map(file => {
            const isFavorite = this.favorites.includes(file.filename);
            const displayName = this.getDisplayName(file.filename);
            
            return `
                <tr>
                    <td>
                        <button class="btn-favorite ${isFavorite ? 'active' : ''}" 
                                onclick="audioLibrary.toggleFavorite('${file.filename}')">
                            ${isFavorite ? '★' : '⭐'}
                        </button>
                    </td>
                    <td class="file-name" title="${file.filename}">${displayName}</td>
                    <td>${file.formatted_date || file.date}</td>
                    <td>${this.formatFileSize(file.size)}</td>
                    <td class="actions">
                        <button class="btn-icon" onclick="audioLibrary.playFile('${file.filename}')" title="Preview">▶️</button>
                        <button class="btn-icon" onclick="audioLibrary.sendToRadio('${file.filename}')" title="A Radio">📻</button>
                        <button class="btn-icon" onclick="audioLibrary.renameFile('${file.filename}')" title="Renombrar">✏️</button>
                        <button class="btn-icon btn-danger" onclick="audioLibrary.deleteFile('${file.filename}')" title="Eliminar">🗑️</button>
                    </td>
                </tr>
            `;
        }).join('');
        
        container.innerHTML = `
            <table class="library-table">
                <thead>
                    <tr>
                        <th>⭐</th>
                        <th>Nombre</th>
                        <th>Fecha</th>
                        <th>Tamaño</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>${rows}</tbody>
            </table>
        `;
    }
    
    getDisplayName(filename) {
        // Extraer descripción si existe
        const match = filename.match(/^tts\d{14}(_(.+))?\.mp3$/);
        if (match && match[2]) {
            return match[2].replace(/_/g, ' ');
        }
        return filename;
    }
    
    toggleView() {
        const btn = this.container.querySelector('#viewToggle');
        this.currentView = this.currentView === 'grid' ? 'list' : 'grid';
        btn.textContent = this.currentView === 'grid' ? '📋 Vista Lista' : '📱 Vista Grid';
        this.renderLibrary();
    }
    
    async playFile(filename) {
        const player = document.querySelector('#floatingPlayer');
        const audio = document.querySelector('#audioPlayer');
        const playing = document.querySelector('#currentPlaying');
        
        if (player && audio) {
            audio.src = `/api/biblioteca.php?filename=${filename}`;
            playing.textContent = `🎵 ${this.getDisplayName(filename)}`;
            player.style.display = 'block';
            audio.play();
        }
    }
    
    closePlayer() {
        const player = document.querySelector('#floatingPlayer');
        const audio = document.querySelector('#audioPlayer');
        if (player) player.style.display = 'none';
        if (audio) {
            audio.pause();
            audio.src = '';
        }
    }
    
    async sendToRadio(filename) {
        try {
            const response = await apiClient.post('/biblioteca.php', {
                action: 'send_library_to_radio',
                filename: filename
            });
            
            if (response.success) {
                this.showNotification('📻 Enviado a la radio', 'success');
            }
        } catch (error) {
            this.showNotification('Error al enviar a radio', 'error');
        }
    }
    
    async renameFile(filename) {
        // Extraer timestamp y descripción actual
        const parts = filename.match(/^(tts\d{14})(_(.+))?\.mp3$/);
        if (!parts) {
            this.showNotification('Formato de archivo inválido', 'error');
            return;
        }
        
        const currentDescription = parts[3] ? parts[3].replace(/_/g, ' ') : '';
        
        const newDescription = prompt(
            'Ingrese una descripción para el archivo:\n' +
            '(Use solo letras, números y espacios. Máx 30 caracteres)\n\n' +
            'Nombre actual: ' + filename,
            currentDescription
        );
        
        if (newDescription === null) return;
        
        const cleanDescription = newDescription.trim();
        if (!cleanDescription) {
            this.showNotification('La descripción no puede estar vacía', 'error');
            return;
        }
        
        if (cleanDescription.length > 30) {
            this.showNotification('Descripción muy larga (máx 30 caracteres)', 'error');
            return;
        }
        
        try {
            const response = await apiClient.post('/biblioteca.php', {
                action: 'rename_file',
                old_filename: filename,
                new_description: cleanDescription
            });
            
            if (response.success) {
                this.showNotification('✅ Archivo renombrado', 'success');
                await this.loadLibrary();
            }
        } catch (error) {
            this.showNotification('Error al renombrar', 'error');
        }
    }
    
    toggleFavorite(filename) {
        const index = this.favorites.indexOf(filename);
        
        if (index > -1) {
            this.favorites.splice(index, 1);
            this.showNotification('⭐ Removido de favoritos', 'info');
        } else {
            this.favorites.push(filename);
            this.showNotification('★ Agregado a favoritos', 'success');
        }
        
        // Guardar en localStorage
        localStorage.setItem('audio_favorites', JSON.stringify(this.favorites));
        
        // Actualizar stats y re-renderizar
        this.updateStats();
        this.renderLibrary();
    }
    
    async deleteFile(filename) {
        if (!confirm(`¿Eliminar el archivo ${this.getDisplayName(filename)}?`)) {
            return;
        }
        
        try {
            const response = await apiClient.post('/biblioteca.php', {
                action: 'delete_library_file',
                filename: filename
            });
            
            if (response.success) {
                // Remover de favoritos si estaba
                const favIndex = this.favorites.indexOf(filename);
                if (favIndex > -1) {
                    this.favorites.splice(favIndex, 1);
                    localStorage.setItem('audio_favorites', JSON.stringify(this.favorites));
                }
                
                this.showNotification('🗑️ Archivo eliminado', 'success');
                await this.loadLibrary();
            }
        } catch (error) {
            this.showNotification('Error al eliminar', 'error');
        }
    }
    
    formatFileSize(bytes) {
        if (!bytes) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    }
    
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
}