<?php
/**
 * Forlove Keyboard - AI 生成接口 V5
 * 
 * 适配 5 大固定主分类 + 子分类矩阵结构
 * 同步 iOS 端参数：字数选择、风险激进程度、成人风格、输出格式规范
 */

require_once 'config.php';
require_once 'prompts.php';

// 设置响应头
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 处理 OPTIONS 预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 处理 GET 请求以便用户测试连接
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    echo json_encode(['success' => true, 'message' => 'Forlove AI API is alive. Please use POST for generation.'], JSON_UNESCAPED_UNICODE);
    exit;
}

// 仅接受 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    outputError('Method not allowed: ' . $_SERVER['REQUEST_METHOD'], 405);
}

// 获取请求体
$rawInput = file_get_contents('php://input');
$input = json_decode($rawInput, true);

if (!$input) {
    outputError('Invalid JSON input', 400);
}

// 解析核心请求参数
$mainCategory = $input['main_category'] ?? 'reply';
$subCategory = $input['sub_category'] ?? 'highEQ';
$context = $input['context'] ?? [];
$candidateCount = $input['count'] ?? DEFAULT_CANDIDATE_COUNT;

// 解析 V2 配置参数 (iOS 端在 config_v2 字段中发送)
if (isset($input['config_v2'])) {
    $configV2 = $input['config_v2'];
    $context['word_count'] = $configV2['word_count'] ?? '中';
    $context['aggression_level'] = $configV2['aggression_level'] ?? '中';
    $context['adult_style'] = $configV2['adult_style'] ?? '无';
}

// 解析传统风格参数 (ambiguity 等)
if (isset($input['style_params'])) {
    $context['ambiguity'] = $input['style_params']['ambiguity'] ?? 2;
    $context['emoji_density'] = $input['style_params']['emoji_density'] ?? '适中';
    $context['length'] = $input['style_params']['length'] ?? '中';
}

// 将主、子分类注入 context 供 PromptBuilder 使用
$context['main_category'] = $mainCategory;
$context['sub_category'] = $subCategory;

// 构建 Prompt
$systemPrompt = PromptBuilder::buildSystemPrompt($context);

// 构建 User Prompt
$chatContent = $context['last_message'] ?? $context['raw_text'] ?? $context['question'] ?? '';
$chatContext = $context['chat_context'] ?? ''; // 对话历史（可选）
$userPrompt = PromptBuilder::buildUserPrompt($mainCategory, $subCategory, $chatContent, $chatContext);

// 调用 DeepSeek API
$result = callDeepSeekAPI($systemPrompt, $userPrompt);

if (isset($result['error'])) {
    outputError($result['error'], 500);
}

// 解析并返回结果
$content = $result['choices'][0]['message']['content'] ?? '';
$parsed = json_decode($content, true);

if ($parsed && isset($parsed['candidates'])) {
    // 处理最终候选列表
    outputSuccess($parsed['candidates']);
} else {
    // 降级：如果非标准 JSON，按字符串处理
    $text = trim($content);
    $preview = mb_substr($text, 0, 30, 'UTF-8');
    outputSuccess([
        ['text' => $text, 'preview' => $preview]
    ]);
}

/**
 * 调用 DeepSeek API
 */
function callDeepSeekAPI($systemPrompt, $userPrompt) {
    $data = [
        'model' => DEEPSEEK_MODEL,
        'messages' => [
            ['role' => 'system', 'content' => $systemPrompt],
            ['role' => 'user', 'content' => $userPrompt]
        ],
        'max_tokens' => MAX_TOKENS,
        'temperature' => TEMPERATURE,
        'response_format' => ['type' => 'json_object'],
        'stream' => false
    ];
    
    $ch = curl_init(DEEPSEEK_API_URL);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => json_encode($data),
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'Authorization: Bearer ' . DEEPSEEK_API_KEY
        ],
        CURLOPT_TIMEOUT => 30,
        CURLOPT_SSL_VERIFYPEER => true
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode !== 200) {
        return ['error' => 'AI 服务异常: ' . $httpCode];
    }
    
    return json_decode($response, true);
}

function outputSuccess($candidates) {
    echo json_encode([
        'success' => true,
        'candidates' => $candidates
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

function outputError($message, $code = 400) {
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'error' => $message
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>
