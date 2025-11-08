#!/bin/bash
# Cloudflare Tunnel 持久化部署脚本

set -e

echo "🚀 XiaoZhi WebRTC - Cloudflare Tunnel 部署"
echo "=========================================="
echo ""

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用 root 权限运行: sudo bash setup-cloudflare-tunnel.sh"
    exit 1
fi

# 1. 安装 Docker
echo "📦 步骤 1/6: 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
    echo "✅ Docker 安装完成"
else
    echo "✅ Docker 已安装"
fi

# 2. 克隆代码
echo ""
echo "📥 步骤 2/6: 获取代码..."
if [ -d "/root/xiaozhi-webrtc" ]; then
    cd /root/xiaozhi-webrtc
    git pull
else
    cd /root
    git clone https://github.com/WeiMeng101/xiaozhi-webrtc.git
    cd xiaozhi-webrtc
fi
echo "✅ 代码已准备"

# 3. 启动应用
echo ""
echo "🎬 步骤 3/6: 启动应用..."
docker compose down 2>/dev/null || true
docker compose up -d
echo "✅ 应用已启动"

# 4. 安装 Cloudflared
echo ""
echo "🔒 步骤 4/6: 安装 Cloudflared..."
if ! command -v cloudflared &> /dev/null; then
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dpkg -i cloudflared.deb
    rm cloudflared.deb
    echo "✅ Cloudflared 安装完成"
else
    echo "✅ Cloudflared 已安装"
fi

# 5. 登录 Cloudflare
echo ""
echo "🔐 步骤 5/6: 登录 Cloudflare..."
echo "⚠️  即将打开浏览器，请在浏览器中授权"
echo "按 Enter 继续..."
read

cloudflared tunnel login

if [ ! -f ~/.cloudflared/cert.pem ]; then
    echo "❌ 登录失败，请重新运行脚本"
    exit 1
fi
echo "✅ Cloudflare 登录成功"

# 6. 创建隧道
echo ""
echo "🌐 步骤 6/6: 创建 Cloudflare Tunnel..."

TUNNEL_NAME="xiaozhi-webrtc"

# 检查隧道是否已存在
if cloudflared tunnel list | grep -q "$TUNNEL_NAME"; then
    echo "✅ 隧道已存在: $TUNNEL_NAME"
    TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
else
    cloudflared tunnel create $TUNNEL_NAME
    TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
    echo "✅ 隧道已创建: $TUNNEL_NAME"
fi

# 创建配置文件
mkdir -p ~/.cloudflared
cat > ~/.cloudflared/config.yml <<EOF
tunnel: $TUNNEL_ID
credentials-file: /root/.cloudflared/$TUNNEL_ID.json

ingress:
  - service: http://localhost:51000
EOF

echo "✅ 配置文件已创建"

# 创建 systemd 服务
cat > /etc/systemd/system/cloudflared.service <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/cloudflared tunnel run
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable cloudflared
systemctl restart cloudflared

echo ""
echo "=========================================="
echo "✅ 部署完成！"
echo ""
echo "🌐 访问地址："
echo "https://$TUNNEL_ID.cfargotunnel.com"
echo ""
echo "📝 管理命令："
echo "- 查看状态: systemctl status cloudflared"
echo "- 查看日志: journalctl -u cloudflared -f"
echo "- 重启服务: systemctl restart cloudflared"
echo "- 停止服务: systemctl stop cloudflared"
echo ""
echo "🔗 Cloudflare Dashboard:"
echo "https://one.dash.cloudflare.com/"
echo ""
