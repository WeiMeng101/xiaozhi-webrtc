#!/bin/bash
# 一键部署脚本（带 Cloudflare Tunnel 自动 HTTPS）

echo "🚀 开始部署 XiaoZhi WebRTC..."

# 1. 安装 Docker
echo "📦 安装 Docker..."
curl -fsSL https://get.docker.com | sh
systemctl start docker
systemctl enable docker

# 2. 克隆代码
echo "📥 克隆代码..."
cd /root
git clone https://github.com/WeiMeng101/xiaozhi-webrtc.git
cd xiaozhi-webrtc

# 3. 启动应用
echo "🎬 启动应用..."
docker compose up -d

# 4. 安装 Cloudflare Tunnel
echo "🔒 安装 Cloudflare Tunnel..."
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared.deb

echo ""
echo "✅ 应用已启动！"
echo ""
echo "📝 下一步："
echo "1. 运行: cloudflared tunnel login"
echo "2. 运行: cloudflared tunnel create xiaozhi"
echo "3. 运行: cloudflared tunnel route dns xiaozhi xiaozhi.你的域名.com"
echo "4. 运行: cloudflared tunnel run --url http://localhost:51000 xiaozhi"
echo ""
echo "或者使用快速临时链接（无需域名）："
echo "cloudflared tunnel --url http://localhost:51000"
