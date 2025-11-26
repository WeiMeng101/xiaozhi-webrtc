# TURN 服务器配置指南

## 问题说明

WebRTC 连接在以下情况需要 TURN 服务器:
- 客户端在 NAT/防火墙后面
- 无法建立 P2P 直连
- 需要跨公网通信

## 方案一: 使用环境变量配置自定义 TURN 服务器(推荐)

在 Docker 部署时添加环境变量:

```bash
docker run -d \
  -p 51000:51000 \
  -e TURN_SERVER_URL="turn:your-turn-server.com:3478" \
  -e TURN_USERNAME="your-username" \
  -e TURN_CREDENTIAL="your-password" \
  registry.cn-hangzhou.aliyuncs.com/weimeng2024/xiaozhi:1.0
```

## 方案二: 自建 Coturn TURN 服务器

### 1. 安装 Coturn (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install coturn
```

### 2. 配置 Coturn

编辑 `/etc/turnserver.conf`:

```bash
# 监听端口
listening-port=3478
tls-listening-port=5349

# 外网 IP (替换为您的服务器公网IP)
external-ip=YOUR_PUBLIC_IP

# Realm
realm=xiaozhi.wei2000.cn

# 用户认证
user=xiaozhi:your_password

# 日志
log-file=/var/log/turnserver.log
verbose

# 安全设置
fingerprint
lt-cred-mech

# 允许的 IP 范围
allowed-peer-ip=0.0.0.0-255.255.255.255
```

### 3. 启动 Coturn

```bash
sudo systemctl enable coturn
sudo systemctl start coturn
sudo systemctl status coturn
```

### 4. 防火墙配置

```bash
# 开放 TURN 端口
sudo ufw allow 3478/tcp
sudo ufw allow 3478/udp
sudo ufw allow 5349/tcp
sudo ufw allow 5349/udp
sudo ufw allow 49152:65535/udp  # 媒体端口范围
```

### 5. 配置到项目

```bash
docker run -d \
  -p 51000:51000 \
  -e TURN_SERVER_URL="turn:YOUR_PUBLIC_IP:3478" \
  -e TURN_USERNAME="xiaozhi" \
  -e TURN_CREDENTIAL="your_password" \
  registry.cn-hangzhou.aliyuncs.com/weimeng2024/xiaozhi:1.0
```

## 方案三: 使用腾讯云 TRTC (推荐国内用户)

腾讯云实时音视频提供免费的 TURN 服务:

1. 注册腾讯云 TRTC
2. 获取 TURN 服务器配置
3. 配置环境变量

## 方案四: 使用阿里云音视频通信

阿里云也提供类似的服务,可以获取 TURN 配置。

## 测试 TURN 服务器

使用 Trickle ICE 测试工具: https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/

输入您的 TURN 服务器配置,查看是否能成功获取 relay 类型的候选地址。

## 当前默认配置

项目默认使用公共 TURN 服务器(Metered.ca),但在国内可能不稳定。强烈建议:

1. 部署自己的 Coturn 服务器
2. 或使用国内云服务商的 TURN 服务
3. 通过环境变量配置

> Tip: 如果你希望在常驻信任网络中只使用 STUN（避免默认 TURN 连接），可以设置 `ENABLE_DEFAULT_TURN_SERVERS=0`，此时只有你显式配置的 TURN 服务才会暴露给客户端。

## 调试技巧

1. 查看浏览器控制台的 ICE 候选信息
2. 检查是否有 `relay` 类型的候选
3. 监控 TURN 服务器日志: `tail -f /var/log/turnserver.log`
