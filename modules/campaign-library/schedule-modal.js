/**
 * Modal para programar reproducción automática de audios
 */

export class ScheduleModal {
    constructor() {
        this.modalId = 'scheduleModal';
        this.selectedFile = null;
        this.scheduleType = 'interval'; // interval, specific, once
    }
    
    show(filename, title) {
        this.selectedFile = filename;
        this.selectedTitle = title;
        this.createModal();
        document.getElementById(this.modalId).style.display = 'block';
    }
    
    hide() {
        const modal = document.getElementById(this.modalId);
        if (modal) {
            modal.style.display = 'none';
        }
    }
    
    createModal() {
        // Remover modal existente si hay
        const existing = document.getElementById(this.modalId);
        if (existing) existing.remove();
        
        const modal = document.createElement('div');
        modal.id = this.modalId;
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal-content schedule-modal">
                <div class="modal-header">
                    <h3>🕐 Programar Reproducción Automática</h3>
                    <button class="close-btn" onclick="window.scheduleModal.hide()">✕</button>
                </div>
                
                <div class="modal-body">
                    <div class="schedule-info">
                        <strong>Audio:</strong> ${this.selectedTitle || this.selectedFile}
                    </div>
                    
                    <div class="form-group">
                        <label>📅 Tipo de programación:</label>
                        <div class="radio-group">
                            <label>
                                <input type="radio" name="scheduleType" value="interval" checked 
                                       onchange="window.scheduleModal.changeType('interval')">
                                Por intervalos
                            </label>
                            <label>
                                <input type="radio" name="scheduleType" value="specific"
                                       onchange="window.scheduleModal.changeType('specific')">
                                Días y horas específicas
                            </label>
                            <label>
                                <input type="radio" name="scheduleType" value="once"
                                       onchange="window.scheduleModal.changeType('once')">
                                Una sola vez
                            </label>
                        </div>
                    </div>
                    
                    <!-- Configuración por intervalos -->
                    <div id="intervalConfig" class="config-section">
                        <div class="form-group">
                            <label>⏰ Repetir cada:</label>
                            <div class="interval-inputs">
                                <input type="number" id="intervalHours" min="0" max="24" value="4">
                                <span>horas</span>
                                <input type="number" id="intervalMinutes" min="0" max="59" value="0">
                                <span>minutos</span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Configuración días específicos -->
                    <div id="specificConfig" class="config-section" style="display:none;">
                        <div class="form-group">
                            <label>📅 Días de la semana:</label>
                            <div class="days-selector">
                                ${this.createDaysSelector()}
                            </div>
                        </div>
                        <div class="form-group">
                            <label>⏰ Horas del día:</label>
                            <div id="timesContainer">
                                <div class="time-input">
                                    <input type="time" class="schedule-time" value="14:00">
                                    <button onclick="window.scheduleModal.addTimeSlot()">➕</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Configuración una vez -->
                    <div id="onceConfig" class="config-section" style="display:none;">
                        <div class="form-group">
                            <label>📅 Fecha y hora:</label>
                            <input type="datetime-local" id="onceDateTime">
                        </div>
                    </div>
                    
                    <!-- Fechas de inicio y fin -->
                    <div class="form-group">
                        <label>📆 Fecha inicio:</label>
                        <input type="date" id="startDate" value="${new Date().toISOString().split('T')[0]}">
                    </div>
                    
                    <div class="form-group">
                        <label>📆 Fecha fin (opcional):</label>
                        <input type="date" id="endDate">
                    </div>
                    
                    <div class="form-group">
                        <label>📝 Notas (opcional):</label>
                        <textarea id="scheduleNotes" rows="2" placeholder="Ej: Oferta especial de temporada"></textarea>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button class="btn btn-primary" onclick="window.scheduleModal.save()">
                        ✅ Programar
                    </button>
                    <button class="btn btn-secondary" onclick="window.scheduleModal.hide()">
                        ❌ Cancelar
                    </button>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        this.addStyles();
    }
    
    createDaysSelector() {
        const days = [
            { value: 'monday', label: 'Lun' },
            { value: 'tuesday', label: 'Mar' },
            { value: 'wednesday', label: 'Mié' },
            { value: 'thursday', label: 'Jue' },
            { value: 'friday', label: 'Vie' },
            { value: 'saturday', label: 'Sáb' },
            { value: 'sunday', label: 'Dom' }
        ];
        
        return days.map(day => `
            <label class="day-checkbox">
                <input type="checkbox" value="${day.value}" class="schedule-day">
                <span>${day.label}</span>
            </label>
        `).join('');
    }
    
    changeType(type) {
        this.scheduleType = type;
        
        // Ocultar todas las secciones
        document.querySelectorAll('.config-section').forEach(section => {
            section.style.display = 'none';
        });
        
        // Mostrar la sección correspondiente
        if (type === 'interval') {
            document.getElementById('intervalConfig').style.display = 'block';
        } else if (type === 'specific') {
            document.getElementById('specificConfig').style.display = 'block';
        } else if (type === 'once') {
            document.getElementById('onceConfig').style.display = 'block';
        }
    }
    
    addTimeSlot() {
        const container = document.getElementById('timesContainer');
        const timeDiv = document.createElement('div');
        timeDiv.className = 'time-input';
        timeDiv.innerHTML = `
            <input type="time" class="schedule-time" value="16:00">
            <button onclick="this.parentElement.remove()">➖</button>
        `;
        container.appendChild(timeDiv);
    }
    
    async save() {
        const data = {
            action: 'create',
            filename: this.selectedFile,
            title: this.selectedTitle,
            schedule_type: this.scheduleType,
            start_date: document.getElementById('startDate').value,
            end_date: document.getElementById('endDate').value || null,
            notes: document.getElementById('scheduleNotes').value,
            is_active: true
        };
        
        // Agregar configuración según el tipo
        if (this.scheduleType === 'interval') {
            data.interval_hours = document.getElementById('intervalHours').value;
            data.interval_minutes = document.getElementById('intervalMinutes').value;
            
        } else if (this.scheduleType === 'specific') {
            // Obtener días seleccionados
            const days = [];
            document.querySelectorAll('.schedule-day:checked').forEach(checkbox => {
                days.push(checkbox.value);
            });
            data.schedule_days = days;
            
            // Obtener horas
            const times = [];
            document.querySelectorAll('.schedule-time').forEach(input => {
                if (input.value) times.push(input.value);
            });
            data.schedule_times = times;
            
        } else if (this.scheduleType === 'once') {
            const dateTime = document.getElementById('onceDateTime').value;
            if (dateTime) {
                const [date, time] = dateTime.split('T');
                data.start_date = date;
                data.schedule_times = [time];
            }
        }
        
        try {
            const response = await fetch('/api/audio-scheduler.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.showNotification('✅ Programación creada exitosamente', 'success');
                this.hide();
                
                // Recargar lista si existe
                if (window.campaignLibrary && window.campaignLibrary.loadSchedules) {
                    window.campaignLibrary.loadSchedules();
                }
            } else {
                this.showNotification('Error: ' + result.error, 'error');
            }
        } catch (error) {
            console.error('Error guardando programación:', error);
            this.showNotification('Error al guardar programación', 'error');
        }
    }
    
    showNotification(message, type) {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        document.body.appendChild(notification);
        
        setTimeout(() => notification.classList.add('show'), 10);
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }
    
    addStyles() {
        if (document.getElementById('schedule-modal-styles')) return;
        
        const styles = document.createElement('style');
        styles.id = 'schedule-modal-styles';
        styles.textContent = `
            .schedule-modal {
                max-width: 500px;
                max-height: 80vh;
                overflow-y: auto;
            }
            
            .schedule-info {
                background: #f5f5f5;
                padding: 10px;
                border-radius: 5px;
                margin-bottom: 15px;
            }
            
            .radio-group label {
                display: block;
                margin: 5px 0;
                cursor: pointer;
            }
            
            .interval-inputs {
                display: flex;
                align-items: center;
                gap: 10px;
            }
            
            .interval-inputs input {
                width: 60px;
            }
            
            .days-selector {
                display: flex;
                gap: 10px;
                flex-wrap: wrap;
            }
            
            .day-checkbox {
                display: flex;
                align-items: center;
                gap: 5px;
                padding: 5px 10px;
                border: 1px solid #ddd;
                border-radius: 5px;
                cursor: pointer;
            }
            
            .day-checkbox:has(input:checked) {
                background: #2196F3;
                color: white;
            }
            
            .time-input {
                display: flex;
                gap: 10px;
                margin: 5px 0;
                align-items: center;
            }
            
            .config-section {
                background: #f9f9f9;
                padding: 15px;
                border-radius: 5px;
                margin: 10px 0;
            }
            
            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0, 0, 0, 0.5);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 10000;
            }
            
            .modal-content {
                background: white;
                border-radius: 10px;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
            }
            
            .modal-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 20px;
                border-bottom: 1px solid #eee;
            }
            
            .modal-body {
                padding: 20px;
            }
            
            .modal-footer {
                padding: 20px;
                border-top: 1px solid #eee;
                display: flex;
                gap: 10px;
                justify-content: flex-end;
            }
        `;
        document.head.appendChild(styles);
    }
}

// Exponer globalmente
window.scheduleModal = new ScheduleModal();