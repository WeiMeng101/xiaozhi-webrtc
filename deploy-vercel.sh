#!/bin/bash
# XiaoZhi WebRTC 一键部署到 Vercel

set -e

echo "🚀 XiaoZhi WebRTC Vercel 部署脚本"
echo "=================================="
echo ""

# 检查是否已安装 Node.js 和 npm
if ! command -v node &> /dev/null; then
    echo "❌ 需要安装 Node.js"
    echo "访问: https://nodejs.org 安装最新版本"
    exit 1
fi

# 检查是否已安装 git
if ! command -v git &> /dev/null; then
    echo "❌ 需要安装 Git"
    exit 1
fi

# 步骤 1: 检查/安装 Vercel CLI
echo "📦 步骤 1/4: 检查 Vercel CLI..."
if ! command -v vercel &> /dev/null; then
    echo "📥 安装 Vercel CLI..."
    npm install -g vercel
    echo "✅ Vercel CLI 安装完成"
else
    echo "✅ Vercel CLI 已安装"
fi

# 步骤 2: 检查是否已登录
echo ""
echo "🔐 步骤 2/4: 检查 Vercel 登录状态..."
if ! vercel whoami &> /dev/null 2>&1; then
    echo "📝 需要登录 Vercel"
    vercel login
fi
echo "✅ 已登录 Vercel"

# 步骤 3: 提交并推送代码
echo ""
echo "📤 步骤 3/4: 提交代码到 GitHub..."
git add -A
if git diff-index --quiet HEAD --; then
    echo "✅ 没有新改动需要提交"
else
    COMMIT_MSG="chore: Vercel deployment at $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    git push origin main
    echo "✅ 代码已推送"
fi

# 步骤 4: 部署到 Vercel
echo ""
echo "🚀 步骤 4/4: 部署到 Vercel..."
vercel deploy --prod

echo ""
echo "=================================="
echo "✅ 部署完成！"
echo ""
echo "📝 查看部署状态："
echo "vercel list"
echo ""
echo "📊 查看日志："
echo "vercel logs"
echo ""
echo "🔄 回滚到前一版本："
echo "vercel rollback"
echo ""
echo "⚠️  提示："
echo "- Vercel Serverless Functions 最多运行 900 秒（15 分钟）"
echo "- 长连接支持有限，如遇问题可考虑其他部署方案"
echo ""
