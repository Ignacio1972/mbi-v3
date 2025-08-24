<?php
/**
// Configurar zona horaria de Chiledate_default_timezone_set('America/Santiago');
 * API de Generación de Audio TTS - VERSIÓN SIMPLIFICADA
 * Mantiene toda la funcionalidad de AzuraCast
 */
require_once 'config.php';
require_once 'services/announcement-module/announcement-templates.php';
require_once 'services/announcement-module/announcement-generator.php';
require_once 'services/audio-processor.php';


// Función de logging
function logMessage($message) {
    $timestamp = date('Y-m-d H:i:s');
    $logFile = __DIR__ . '/logs/tts-' . date('Y-m-d') . '.log';
    
    if (!file_exists(dirname($logFile))) {
        mkdir(dirname($logFile), 0755, true);
    }
    
    file_put_contents($logFile, "[$timestamp] $message\n", FILE_APPEND | LOCK_EX);
}

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Manejar preflight OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('No se recibieron datos');
    }
    
    logMessage("Datos recibidos: " . json_encode($input));

      // ============= CÓDIGO DEL PLAYGROUND AQUÍ =============
    // Detectar si viene del playground
    $isPlayground = isset($input['source']) && $input['source'] === 'playground';
    
    if ($isPlayground) {
        // Logger especial para playground
        require_once __DIR__ . '/../playground/logger/tts-logger.php';
        $playgroundLogger = new TTSLogger('tts-playground', TTSLogger::LEVEL_DEBUG);
        $playgroundLogger->info('Request from playground', $input);
    }
    
    // Agregar action para listar voces
    if ($input["action"] === "list_voices") {
        // Voces predefinidas del sistema
        $voices = [
            "cristian" => ["id" => "nNS8uylvF9GBWVSiIt5h", "label" => "Cristian", "gender" => "M"],
            "fernanda" => ["id" => "JM2A9JbRp8XUJ7bdCXJc", "label" => "Fernanda", "gender" => "F"],
            "rosa" => ["id" => "Yeu6FDmacNCxWs1YwWdK", "label" => "Rosa", "gender" => "F"],
            "juan" => ["id" => "qbzGYq8t9P2fKB7mLvgu", "label" => "Juan", "gender" => "M"],
            "diego" => ["id" => "mX8uUHrVzP97QoLbmWfp", "label" => "Diego", "gender" => "M"],
            "sofia" => ["id" => "uGGNaPFCfjtigwmRAQxY", "label" => "Sofia", "gender" => "F"],
            "carlos" => ["id" => "TuC1BDNFGI6oLZUGo7UE", "label" => "Carlos", "gender" => "M"],
            "maria" => ["id" => "CtP21Y5JTRBqb42MMAcz", "label" => "María", "gender" => "F"],
            "laura" => ["id" => "FgCqc9CIJhmNjN5h3aFn", "label" => "Laura", "gender" => "F"],
            "pedro" => ["id" => "vF3v8rYiP0zqA5c6xYIx", "label" => "Pedro", "gender" => "M"],
            "esperanza" => ["id" => "Uw5YLCELfcm0jsXtoU0u", "label" => "Esperanza", "gender" => "F"],
            "andres" => ["id" => "qZ7fFaf3X1QQJPdmPXYp", "label" => "Andrés", "gender" => "M"]
        ];
        
        // Cargar voces personalizadas si existen
        $customVoicesFile = __DIR__ . "/data/custom-voices.json";
        if (file_exists($customVoicesFile)) {
            $customVoices = json_decode(file_get_contents($customVoicesFile), true);
            if ($customVoices && is_array($customVoices)) {
                // Combinar voces predefinidas con las personalizadas
                $voices = array_merge($voices, $customVoices);
                logMessage("Cargadas " . count($customVoices) . " voces personalizadas");
            }
        }
        
        echo json_encode(["success" => true, "voices" => $voices]);
        exit;
    }
    
    // Lista de templates disponibles
    if ($input['action'] === 'list_templates') {
        $templates = AnnouncementTemplates::getAllTemplates();
        echo json_encode([
            'success' => true,
            'templates' => $templates
        ]);
        exit;
    }
    
    // Generar audio completo
    if ($input['action'] === 'generate_audio') {
        logMessage("Iniciando generación de audio");
        
        // Preparar opciones base - SOLO PARÁMETROS SOPORTADOS
        $generatorOptions = [];
        
        // Voice settings - SOLO los 4 parámetros válidos
        if (isset($input['voice_settings'])) {
            $generatorOptions['voice_settings'] = [
                'style' => $input['voice_settings']['style'] ?? 0.5,
                'stability' => $input['voice_settings']['stability'] ?? 0.75,
                'similarity_boost' => $input['voice_settings']['similarity_boost'] ?? 0.8,
                'use_speaker_boost' => $input['voice_settings']['use_speaker_boost'] ?? true
            ];
            logMessage("Voice settings recibidos: " . json_encode($generatorOptions['voice_settings']));
        }
        
        // Verificar si es template o texto directo
        if (!empty($input['template']) && !empty($input['template_category'])) {
            // Generar desde template
            logMessage("Generando desde template: {$input['template_category']}/{$input['template']}");
            
            $result = AnnouncementGenerator::generateFromTemplate(
                $input['template_category'],
                $input['template'],
                $input['template_variables'] ?? [],
                $input['voice'] ?? 'fernanda',
                $generatorOptions
            );
        } else if (!empty($input['text'])) {
            // Generar desde texto directo
            logMessage("Generando desde texto directo");
            
            $result = AnnouncementGenerator::generateSimple(
                $input['text'],
                $input['voice'] ?? 'fernanda',
                $generatorOptions
            );
        } else {
            throw new Exception('Debe proporcionar texto o seleccionar un template');
        }
        
        // Guardar archivo temporal LOCAL para preview
        $filename = 'test_' . time() . '.mp3';
        $filepath = UPLOAD_DIR . $filename;
        file_put_contents($filepath, $result['audio']);
        
        logMessage("Archivo temporal creado para preview: $filename");
        
        // ===== MANTENER TODA LA FUNCIONALIDAD DE AZURACAST =====
        require_once 'services/radio-service.php';
        require_once 'services/audio-processor.php';
        
        // Procesar audio (agregar silencios)
        $filepathCopy = copyFileForProcessing($filepath);
        $filepathWithSilence = addSilenceToAudio($filepathCopy);
        if ($filepathWithSilence === false) {
            $filepathWithSilence = $filepathCopy;
        }
        
        // Subir a AzuraCast
        $uploadResult = uploadFileToAzuraCast($filepathWithSilence, $filename);
        $actualFilename = $uploadResult['filename'];
        
        // Asignar a playlist
        assignFileToPlaylist($uploadResult['id']);
        
        // Limpiar archivos temporales DE PROCESAMIENTO (no el original)
        @unlink($filepathCopy);
        if ($filepathWithSilence !== $filepathCopy) {
            @unlink($filepathWithSilence);
        }
        
        logMessage("Audio generado y subido exitosamente: $actualFilename");
        echo json_encode([
            'success' => true,
            'filename' => $filename,           // Nombre local para preview
            'azuracast_filename' => $actualFilename,  // Nombre en AzuraCast
            'processed_text' => $result['processed_text']
        ]);
        exit;
    }
    
    // Enviar a radio - MANTENER INTACTO
    if ($input['action'] === 'send_to_radio') {
        logMessage("Procesando envío a radio");
        
        require_once 'services/radio-service.php';
        
        $filename = $input['filename'] ?? '';
        
        if (empty($filename)) {
            throw new Exception('No se especificó el archivo a enviar');
        }
        
        logMessage("Interrumpiendo radio con archivo: $filename");
        
        // Interrumpir la radio con el archivo
        $success = interruptRadio($filename);
        
        if ($success) {
            logMessage("Archivo enviado a radio exitosamente: $filename");
            echo json_encode([
                'success' => true,
                'message' => 'Anuncio enviado a la radio y reproduciéndose'
            ]);
        } else {
            throw new Exception('Error al interrumpir la radio');
        }
        exit;
    }
    
    // Si no es ninguna acción conocida
    throw new Exception('Acción no reconocida: ' . ($input['action'] ?? 'ninguna'));
    
} catch (Exception $e) {
    logMessage("Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>