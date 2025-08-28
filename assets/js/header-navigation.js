// Header Navigation for MBI v3 - VERSIÓN CORREGIDA
(function() {
    'use strict';
    
    // Mapeo basado en el TEXTO de los tabs actuales
    const navigationMap = {
        'generador': '✏️ Texto Personalizado',
        'mensajes': '📝 Mensajes Guardados',
        'archivos': '📚 Biblioteca de Audio',
        'calendario': '📅 Calendario',
        'radio': '📻 Radio'
    };
    
    function initHeaderNavigation() {
        console.log('[Header Nav] Inicializando...');
        
        const navLinks = document.querySelectorAll('.mbi-nav-link');
        console.log('[Header Nav] Links encontrados:', navLinks.length);
        
        navLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                
                const targetModule = this.dataset.target;
                console.log('[Header Nav] Click en:', targetModule);
                
                const tabText = navigationMap[targetModule];
                console.log('[Header Nav] Buscando tab con texto:', tabText);
                
                if (tabText) {
                    // Buscar el tab por su texto
                    const allTabs = document.querySelectorAll('.tab-button');
                    let tabFound = false;
                    
                    allTabs.forEach(tab => {
                        // Normalizar espacios y comparar
                        const normalizedTabText = tab.textContent.trim().replace(/\s+/g, ' ');
                        const normalizedTarget = tabText.trim().replace(/\s+/g, ' ');
                        
                        if (normalizedTabText === normalizedTarget) {
                            console.log('[Header Nav] Tab encontrado! Haciendo click...');
                            tab.click();
                            tabFound = true;
                            
                            // Actualizar estado activo en header
                            navLinks.forEach(l => l.classList.remove('active'));
                            this.classList.add('active');
                        }
                    });
                    
                    if (!tabFound) {
                        console.error('[Header Nav] No se encontró tab con texto:', tabText);
                    }
                } else {
                    console.error('[Header Nav] No hay mapeo para:', targetModule);
                }
            });
        });
        
        // Sincronizar estado inicial
        syncActiveState();
    }
    
    function syncActiveState() {
        // Buscar tab activo
        const activeTab = document.querySelector('.tab-button--active');
        if (activeTab) {
            const activeText = activeTab.textContent.trim().replace(/\s+/g, ' ');
            console.log('[Header Nav] Tab activo:', activeText);
            
            // Buscar qué link del header corresponde
            const navLinks = document.querySelectorAll('.mbi-nav-link');
            navLinks.forEach(link => {
                const targetModule = link.dataset.target;
                const expectedText = navigationMap[targetModule];
                
                if (expectedText && expectedText === activeText) {
                    link.classList.add('active');
                } else {
                    link.classList.remove('active');
                }
            });
        }
    }
    
    // Observar cambios en los tabs para mantener sincronizado
    function observeTabChanges() {
        const tabContainer = document.querySelector('.configurator-tabs');
        if (tabContainer) {
            const observer = new MutationObserver(() => {
                syncActiveState();
            });
            
            observer.observe(tabContainer, {
                attributes: true,
                attributeFilter: ['class'],
                subtree: true
            });
        }
    }
    
    // Inicializar cuando el DOM esté listo
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(initHeaderNavigation, 100); // Pequeño delay para asegurar que todo está cargado
        });
    } else {
        setTimeout(initHeaderNavigation, 100);
    }
    
    // También observar cambios
    observeTabChanges();
    
})();