<?php
header('Content-Type: application/json');
$voicesFile = __DIR__ . '/../../api/data/voices-config.json';

$input = json_decode(file_get_contents('php://input'), true);
$action = $input['action'] ?? '';

switch($action) {
    case 'list_all':
        // Listar TODAS las voces (activas e inactivas)
        $config = json_decode(file_get_contents($voicesFile), true);
        echo json_encode(['success' => true, 'data' => $config]);
        break;
        
    case 'toggle':
        // Activar/desactivar voz
        $voiceKey = $input['voice_key'];
        $config = json_decode(file_get_contents($voicesFile), true);
        $config['voices'][$voiceKey]['active'] = !$config['voices'][$voiceKey]['active'];
        file_put_contents($voicesFile, json_encode($config, JSON_PRETTY_PRINT));
        echo json_encode(['success' => true]);
        break;
        
    case 'add':
        // Agregar nueva voz
        $config = json_decode(file_get_contents($voicesFile), true);
        $voiceKey = strtolower(str_replace(' ', '_', $input['label']));
        
        $config['voices'][$voiceKey] = [
            'id' => $input['voice_id'],
            'label' => $input['label'],
            'gender' => $input['gender'],
            'active' => true,
            'category' => 'custom',
            'added_date' => date('Y-m-d H:i:s')
        ];
        
        file_put_contents($voicesFile, json_encode($config, JSON_PRETTY_PRINT));
        echo json_encode(['success' => true]);
        break;
        
    case 'delete':
        // Eliminar voz (solo custom)
        $voiceKey = $input['voice_key'];
        $config = json_decode(file_get_contents($voicesFile), true);
        
        if ($config['voices'][$voiceKey]['category'] === 'custom') {
            unset($config['voices'][$voiceKey]);
            file_put_contents($voicesFile, json_encode($config, JSON_PRETTY_PRINT));
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Cannot delete system voices']);
        }
        break;
        
    case 'set_default':
        // Cambiar voz por defecto
        $config = json_decode(file_get_contents($voicesFile), true);
        $config['settings']['default_voice'] = $input['voice_key'];
        file_put_contents($voicesFile, json_encode($config, JSON_PRETTY_PRINT));
        echo json_encode(['success' => true]);
        break;
}