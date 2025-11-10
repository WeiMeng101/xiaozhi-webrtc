# Vercel 部署指南

## 前置要求

1. **Vercel 账户** - 访问 [vercel.com](https://vercel.com) 创建账户
2. **GitHub 账户** - 项目需要托管在 GitHub
3. **环境变量** - 根据项目需要配置

## 部署步骤

### 方法一：一键命令行部署（推荐）⭐

```bash
# 进入项目目录
cd xiaozhi-webrtc

# 运行部署脚本（自动处理所有步骤）
bash deploy-vercel.sh
```

该脚本会自动：
- ✅ 检查并安装 Vercel CLI
- ✅ 验证 Vercel 登录状态
- ✅ 提交代码到 GitHub
- ✅ 部署到 Vercel（生产环境）

---

### 方法二：手动使用 Vercel CLI

```bash
# 1. 安装 Vercel CLI
npm install -g vercel

# 2. 登录 Vercel
vercel login

# 3. 推送代码到 GitHub
git add vercel.json .vercelignore
git commit -m "Add Vercel deployment configuration"
git push origin main

# 4. 部署到 Vercel
vercel deploy --prod
```

---

### 方法三：使用 GitHub 集成

1. 访问 [Vercel Dashboard](https://vercel.com/dashboard)
2. 点击 "Add New..." > "Project"
3. 选择你的 GitHub 仓库 `xiaozhi-webrtc`
4. Vercel 会自动检测 `vercel.json` 配置
5. 点击 "Deploy"
6. 等待自动部署完成

### 3. 配置环境变量

在 Vercel Dashboard 中：

1. 进入项目设置 > Environment Variables
2. 添加需要的环境变量：
   - `PORT`：通常不需要修改，Vercel 会自动设置
   - 其他项目特有的环境变量（如果有）

## 重要注意事项

⚠️ **WebRTC 长连接限制**

由于 Vercel Serverless Functions 的限制：
- 单个函数最多运行 **900 秒（15 分钟）**
- 不完全支持长连接（如 WebSocket）
- 每个请求都是独立的环境

这可能会影响 WebRTC 连接的稳定性和持久性。

## 推荐的替代方案

如果在 Vercel 上遇到连接问题，建议使用以下部署方案：

| 平台 | 优势 | 已配置 |
|------|------|--------|
| **Fly.io** | 支持长连接，成本低 | ✅ fly.toml |
| **Cloudflare Tunnel** | 免费，支持 WebRTC | ✅ deploy-with-cloudflare.sh |
| **Render** | 简单易用，支持长连接 | ✅ render.yaml |
| **Zeabur** | 国内友好，支持长连接 | ✅ zeabur.json |

## 监控和日志

在 Vercel Dashboard 中查看：
- **Deployments** - 查看部署历史
- **Logs** - 实时查看应用日志
- **Analytics** - 查看请求统计

## 故障排除

### 构建失败

检查：
- Python 版本是否 >= 3.9
- `pyproject.toml` 和 `uv.lock` 是否正确
- 环境变量是否正确配置

### 连接超时

如果遇到 WebRTC 连接超时：
1. 检查网络配置
2. 考虑使用推荐的部署方案
3. 检查 STUN/TURN 服务器配置

## 回滚部署

```bash
# 列出部署历史
vercel list

# 回滚到前一个版本
vercel rollback
```

## 更多帮助

- [Vercel Python 文档](https://vercel.com/docs/concepts/functions/serverless-functions/runtimes/python)
- [项目 README](./README.md)
