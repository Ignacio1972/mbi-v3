<?php
/**
* Servicio TTS Enhanced - Versión Mejorada
* Ahora respeta los voice_settings que vienen del frontend
*/

// Incluir configuración
require_once dirname(__DIR__) . '/config.php';

/**
* Genera audio TTS con las voces nuevas
*/
function generateEnhancedTTS($text, $voice, $options = []) {
   logMessage("=== TTS-SERVICE: Options recibidas: " . json_encode($options));
   
   // Mapeo de voces nuevas
   $voiceMap = [
       'cristian' => 'nNS8uylvF9GBWVSiIt5h',
       'fernanda' => 'JM2A9JbRp8XUJ7bdCXJc',
       'rosa' => 'Yeu6FDmacNCxWs1YwWdK',
       'alejandro' => '0cheeVA5B3Cv6DGq65cT',
       'vicente' => 'toHqs8ENHjZX53stqKOK',
       'zabra' => 'G6LT3kjUUW86fQaWfBaj',
       // NUEVAS VOCES
       'azucena' => 'ay4iqk10DLwc8KGSrf2t',
       'valeria' => '22VndfJPBU7AZORAZZTT',
       'ninoska' => 'gt8UWQljAEAt5YLqG4LW',
       'ruben' => 'rp876bky8TK6Abie5pir',
       'yorman' => 'J2Jb9yZNvpXUNAL3a2bw',
       'santiago' => 'js7Ktj7UJCd7W0StVolw',
       'luis' => 'ziigB5Dny14v5lDIHo0x',

       // Mantener compatibilidad con voces antiguas
       'Rachel' => '21m00Tcm4TlvDq8ikWAM',
       'Domi' => 'AZnzlk1XvdvUeBnXmlld',
       'Bella' => 'EXAVITQu4vr4xnSDxMaL',
       'Elli' => 'MF3mGyEYCl7XYWbV9V6O',
       'Josh' => 'TxGEqnHWrfWFTfGW9XjX'
   ];
   
   // Cache estático para voces custom (se mantiene durante la ejecución del script)
   static $customVoicesCache = null;

   // Verificar primero en voces predefinidas
   if (isset($voiceMap[$voice])) {
       $voiceId = $voiceMap[$voice];
       logMessage("TTS Enhanced - Voz predefinida: $voice -> ID: $voiceId");
   } else {
       // Buscar en voces custom
       $voiceFound = false;
       
       // Cargar voces custom si no están en cache
       if ($customVoicesCache === null) {
           $customVoicesFile = dirname(__DIR__) . '/data/custom-voices.json';
           
           if (file_exists($customVoicesFile)) {
               $jsonContent = file_get_contents($customVoicesFile);
               $customVoicesCache = json_decode($jsonContent, true);
               
               // Validar que el JSON se decodificó correctamente
               if (json_last_error() !== JSON_ERROR_NONE) {
                   logMessage("ERROR: custom-voices.json mal formateado - " . json_last_error_msg());
                   $customVoicesCache = [];
               } else {
                   logMessage("Cache de voces custom cargado: " . count($customVoicesCache) . " voces");
               }
           } else {
               logMessage("ADVERTENCIA: No se encontró archivo custom-voices.json");
               $customVoicesCache = [];
           }
       }
       
       // Buscar la voz en el cache
       if (isset($customVoicesCache[$voice])) {
           $voiceId = $customVoicesCache[$voice]['id'];
           $voiceFound = true;
           logMessage("TTS Enhanced - Voz custom encontrada: $voice -> ID: $voiceId");
       } else {
           // Última opción: asumir que el valor es un ID directo de ElevenLabs
           $voiceId = $voice;
           logMessage("TTS Enhanced - Voz no encontrada en mapeos, usando como ID directo: $voice");
           
           // Log adicional para debugging
           if (!empty($customVoicesCache)) {
               logMessage("Voces custom disponibles: " . implode(', ', array_keys($customVoicesCache)));
           }
       }
   }
   
   logMessage("TTS Enhanced - Voz: $voice -> ID: $voiceId");
   
   // URL de ElevenLabs
   $url = ELEVENLABS_BASE_URL . "/text-to-speech/$voiceId";
   
   // CAMBIO PRINCIPAL: Construir voice_settings respetando valores del frontend
   $defaultVoiceSettings = [
       'stability' => 0.75,
       'similarity_boost' => 0.8,
       'style' => 0.5,
       'use_speaker_boost' => true
   ];
   
   // Si vienen voice_settings del frontend, mezclar con defaults
   if (isset($options['voice_settings']) && is_array($options['voice_settings'])) {
       $voiceSettings = array_merge($defaultVoiceSettings, $options['voice_settings']);
       logMessage("Voice settings mezclados con frontend: " . json_encode($voiceSettings));
   } else {
       $voiceSettings = $defaultVoiceSettings;
       logMessage("Usando voice settings por defecto");
   }
   
   // Asegurar que los valores estén en rango válido (0.0 - 1.0)
   $voiceSettings['stability'] = max(0, min(1, floatval($voiceSettings['stability'])));
   $voiceSettings['similarity_boost'] = max(0, min(1, floatval($voiceSettings['similarity_boost'])));
   $voiceSettings['style'] = max(0, min(1, floatval($voiceSettings['style'])));
   $voiceSettings['use_speaker_boost'] = (bool)$voiceSettings['use_speaker_boost'];
   
   // Datos para enviar - SOLO PARÁMETROS SOPORTADOS
   $data = [
       'text' => $text,
       'model_id' => $options['model_id'] ?? 'eleven_multilingual_v2',
       'voice_settings' => $voiceSettings
   ];
   
   // Log para debugging
   logMessage("Request a ElevenLabs: " . json_encode($data));
   logMessage("Voice settings finales: style={$voiceSettings['style']}, stability={$voiceSettings['stability']}, similarity={$voiceSettings['similarity_boost']}");
   
   // Hacer la petición
   $ch = curl_init();
   curl_setopt_array($ch, [
       CURLOPT_URL => $url,
       CURLOPT_RETURNTRANSFER => true,
       CURLOPT_POST => true,
       CURLOPT_HTTPHEADER => [
           'Accept: audio/mpeg',
           'Content-Type: application/json',
           'xi-api-key: ' . ELEVENLABS_API_KEY
       ],
       CURLOPT_POSTFIELDS => json_encode($data),
       CURLOPT_TIMEOUT => 30
   ]);
   
   $response = curl_exec($ch);
   $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
   $error = curl_error($ch);
   curl_close($ch);
   
   // Log de respuesta
   logMessage("Respuesta HTTP: $httpCode");
   
   if ($error) {
       logMessage("Error CURL: $error");
       throw new Exception("Error de conexión: $error");
   }
   
   if ($httpCode !== 200) {
       // Log más detallado para errores
       $errorInfo = json_decode($response, true);
       if ($errorInfo) {
           logMessage("Error ElevenLabs detallado: " . json_encode($errorInfo));
       } else {
           logMessage("Error ElevenLabs: HTTP $httpCode - Response: " . substr($response, 0, 200));
       }
       
       // Mensajes de error más específicos
       switch ($httpCode) {
           case 401:
               throw new Exception("API Key inválida o expirada");
           case 422:
               throw new Exception("Parámetros inválidos: " . ($errorInfo['detail']['message'] ?? 'Verificar texto o voz'));
           case 429:
               throw new Exception("Límite de rate excedido. Intente en unos segundos");
           default:
               throw new Exception("Error ElevenLabs API: HTTP $httpCode");
       }
   }
   
   if (!$response) {
       throw new Exception('Respuesta vacía de ElevenLabs');
   }
   
   logMessage("Audio generado exitosamente, tamaño: " . strlen($response) . " bytes");
   
   return $response;
}

/**
* Función helper para convertir valores del frontend (0-100) a API (0.0-1.0)
* Por si el frontend envía porcentajes
*/
function normalizeVoiceValue($value) {
   if ($value > 1 && $value <= 100) {
       // Si parece ser un porcentaje, convertir
       return $value / 100;
   }
   return $value;
}
?>