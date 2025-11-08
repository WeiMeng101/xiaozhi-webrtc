#!/bin/bash
# XiaoZhi WebRTC 一键部署脚本（自动 HTTPS）

set -e

echo "🚀 XiaoZhi WebRTC 一键部署脚本"
echo "================================"
echo ""

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用 root 权限运行: sudo bash deploy.sh"
    exit 1
fi

# 1. 安装 Docker
echo "📦 步骤 1/4: 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
    echo "✅ Docker 安装完成"
else
    echo "✅ Docker 已安装"
fi

# 2. 克隆/更新代码
echo ""
echo "📥 步骤 2/4: 获取代码..."
if [ -d "/root/xiaozhi-webrtc" ]; then
    cd /root/xiaozhi-webrtc
    git pull
    echo "✅ 代码已更新"
else
    cd /root
    git clone https://github.com/WeiMeng101/xiaozhi-webrtc.git
    cd xiaozhi-webrtc
    echo "✅ 代码已克隆"
fi

# 3. 启动应用
echo ""
echo "🎬 步骤 3/4: 启动应用..."
docker compose down 2>/dev/null || true
docker compose up -d
echo "✅ 应用已启动在 http://localhost:51000"

# 4. 配置 HTTPS（Caddy）
echo ""
echo "🔒 步骤 4/4: 配置 HTTPS..."
if ! command -v caddy &> /dev/null; then
    # 安装 Caddy
    apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt update
    apt install -y caddy
    echo "✅ Caddy 安装完成"
else
    echo "✅ Caddy 已安装"
fi

# 复制 Caddyfile
cp Caddyfile /etc/caddy/Caddyfile
systemctl restart caddy
systemctl enable caddy

echo ""
echo "================================"
echo "✅ 部署完成！"
echo ""
echo "📝 访问方式："
echo "1. HTTP:  http://$(curl -s ifconfig.me)"
echo "2. 本地:  http://localhost:51000"
echo ""
echo "🔒 配置 HTTPS（需要域名）："
echo "1. 将域名 A 记录指向: $(curl -s ifconfig.me)"
echo "2. 编辑 /etc/caddy/Caddyfile，取消域名配置的注释"
echo "3. 运行: systemctl restart caddy"
echo ""
echo "📊 查看日志:"
echo "- 应用日志: docker compose logs -f"
echo "- Caddy 日志: journalctl -u caddy -f"
echo ""
