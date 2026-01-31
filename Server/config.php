<?php
/**
 * Forlove Keyboard - 服务端配置文件
 * 部署路径：/www/wwwroot/aiin.bytepig.xyz/config.php
 */

// DeepSeek API 配置
define('DEEPSEEK_API_KEY', 'sk-31c8fb39724d4f0384398c47135a3edf');
define('DEEPSEEK_API_URL', 'https://api.deepseek.com/v1/chat/completions');
define('DEEPSEEK_MODEL', 'deepseek-chat');

// 安全配置
define('ALLOWED_ORIGINS', ['*']); // 生产环境可限制为你的 App Bundle ID

// 生成配置
define('DEFAULT_CANDIDATE_COUNT', 3);
define('MAX_TOKENS', 500);
define('TEMPERATURE', 0.7);

// 调试模式（生产环境设为 false）
define('DEBUG_MODE', false);
