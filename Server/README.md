# Forlove Keyboard 服务端部署指南

## 📁 文件结构

```
Server/
├── config.php      # 配置文件（DeepSeek API Key）
├── prompts.php     # Prompt 模板库
├── generate.php    # 主 API 接口
└── README.md       # 本说明文件
```

## 🚀 部署步骤

### 1. 上传文件到阿里云服务器

将 `Server/` 目录下的三个 PHP 文件上传到你的网站根目录：

```bash
/www/wwwroot/aiin.bytepig.xyz/
├── config.php
├── prompts.php
└── generate.php
```

### 2. 配置 HTTPS（必须）

iOS App 要求所有网络请求必须使用 HTTPS。请确保你的阿里云服务器已配置 SSL 证书。

**阿里云免费 SSL 证书申请：**
1. 登录阿里云控制台
2. 进入「SSL证书」服务
3. 申请免费 DV 证书（域名型）
4. 按照提示配置 DNS 验证
5. 下载并安装证书到 Nginx/Apache

### 3. 配置 Nginx（如果使用）

确保 PHP 文件可以正常执行：

```nginx
server {
    listen 443 ssl;
    server_name aiin.bytepig.xyz;
    
    root /www/wwwroot/aiin.bytepig.xyz;
    index index.php index.html;
    
    # SSL 证书配置
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location ~ \.php$ {
        fastcgi_pass unix:/tmp/php-cgi.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### 4. 测试 API

使用 curl 测试接口是否正常：

```bash
curl -X POST https://aiin.bytepig.xyz/generate.php \
  -H "Content-Type: application/json" \
  -d '{
    "intent": "reply",
    "tag": "common",
    "context": {
      "last_message": "你好啊",
      "user_gender": "男",
      "target_gender": "女",
      "stage": "普通朋友"
    }
  }'
```

**预期返回：**
```json
{
  "success": true,
  "candidates": [
    {"text": "嗨～你也好呀", "tone": "common"},
    {"text": "你好你好，最近怎么样", "tone": "common"},
    {"text": "哈喽！在干嘛呢", "tone": "common"}
  ]
}
```

## 🔒 安全建议

1. **生产环境关闭调试模式**：在 `config.php` 中设置 `DEBUG_MODE` 为 `false`
2. **限制请求来源**：在 `config.php` 中设置 `ALLOWED_ORIGINS` 为你的 App Bundle ID
3. **添加请求频率限制**：防止恶意刷接口

## 📊 监控建议

可以在 `generate.php` 中添加日志记录：

```php
// 在 outputSuccess() 前添加
file_put_contents('/var/log/forlove.log', 
    date('Y-m-d H:i:s') . " - $intent - $tag\n", 
    FILE_APPEND
);
```

## 🐛 常见问题

### Q: 返回 "AI 服务暂时不可用"
A: 检查 DeepSeek API Key 是否正确，或者 DeepSeek 服务是否可用

### Q: iOS App 请求失败
A: 确保已配置 HTTPS，iOS 不允许 HTTP 请求

### Q: 返回乱码
A: 确保 PHP 文件使用 UTF-8 编码保存
