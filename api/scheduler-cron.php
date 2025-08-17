#!/usr/bin/php
<?php
/**
 * Script cron para ejecutar programaciones automáticas
 * Ejecutar cada minuto: * * * * * /usr/bin/php /var/www/mbi-v3/api/scheduler-cron.php
 */

// Configuración
$dbPath = __DIR__ . '/../calendario/api/db/calendar.db';
$logFile = __DIR__ . '/logs/scheduler-' . date('Y-m-d') . '.log';

// Función para log
function logMessage($message) {
    global $logFile;
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents($logFile, "[$timestamp] $message\n", FILE_APPEND);
}

// Función para enviar audio a la radio
function sendToRadio($filename) {
    // Configuración de AzuraCast
    $azuracastUrl = 'http://51.222.25.222:8000';
    $apiKey = 'tu_api_key'; // Obtener de config.php
    
    // Aquí implementar la lógica real de envío a AzuraCast
    // Por ahora solo log
    logMessage("Enviando a radio: $filename");
    
    // Llamar al API existente
    $ch = curl_init('http://localhost/api/biblioteca.php');
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
        'action' => 'send_library_to_radio',
        'filename' => $filename
    ]));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return $httpCode === 200;
}

// Inicio del script
logMessage("=== Iniciando verificación de programaciones ===");

try {
    // Conectar a BD
    $db = new PDO("sqlite:$dbPath");
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Obtener programaciones a ejecutar
    $ch = curl_init('http://localhost:3000/api/audio-scheduler.php');
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['action' => 'check_execute']));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    $response = curl_exec($ch);
    curl_close($ch);
    
    $result = json_decode($response, true);
    
    if ($result && $result['success'] && !empty($result['schedules'])) {
        logMessage("Encontradas " . count($result['schedules']) . " programaciones para ejecutar");
        
        foreach ($result['schedules'] as $schedule) {
            logMessage("Ejecutando: " . $schedule['title'] . " (" . $schedule['filename'] . ")");
            
            // Enviar a la radio
            $success = sendToRadio($schedule['filename']);
            
            // Registrar ejecución
            $ch = curl_init('http://localhost:3000/api/audio-scheduler.php');
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
                'action' => 'log_execution',
                'schedule_id' => $schedule['id'],
                'status' => $success ? 'success' : 'failed',
                'message' => $success ? 'Enviado correctamente' : 'Error al enviar'
            ]));
            curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_exec($ch);
            curl_close($ch);
            
            if ($success) {
                logMessage("✅ Ejecutado exitosamente: " . $schedule['filename']);
            } else {
                logMessage("❌ Error ejecutando: " . $schedule['filename']);
            }
        }
    } else {
        logMessage("No hay programaciones para ejecutar en este momento");
    }
    
} catch (Exception $e) {
    logMessage("ERROR: " . $e->getMessage());
}

logMessage("=== Verificación completada ===\n");