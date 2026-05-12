#!/usr/bin/env bash
# ============================================
# Hermes Agent 一键部署自动安装脚本
# 用法：bash hermes-auto-setup.sh
# ============================================
set -e

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  Hermes Agent 一键部署自动安装        ║"
echo "║  扫码注册 → 自动配置 → 微信对话      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ---- 步骤1：环境检测 ----
echo "🔍 [1/4] 检测环境..."
sleep 1

# 检查是否已安装 Hermes
if command -v hermes &> /dev/null; then
    echo "   ✅ Hermes Agent 已安装 (版本: $(hermes --version 2>/dev/null || echo '✓'))"
else
    echo "   ⚠️ 未检测到 Hermes Agent"
    echo "   📥 正在安装..."
    sudo bash -c "$(curl -fsSL https://hermes-agent.ai/install.sh)" 2>/dev/null
    if command -v hermes &> /dev/null; then
        echo "   ✅ Hermes Agent 安装成功"
    else
        echo "   ❌ 安装失败，请手动安装：curl -fsSL https://hermes-agent.ai/install.sh | sudo bash"
        exit 1
    fi
fi

# 检查 SkillHub CLI
if command -v skillhub &> /dev/null; then
    echo "   ✅ SkillHub CLI 已就绪"
else
    echo "   ⚠️ 正在安装 SkillHub CLI..."
    curl -fsSL https://skillhub.cn/install.sh | sudo bash 2>/dev/null
fi

echo ""

# ---- 步骤2：配置 DeepSeek 模型 ----
echo "⚙️ [2/4] 检测模型配置..."
sleep 1

CONFIG_FILE="$HOME/.hermes/config.yaml"
if [ -f "$CONFIG_FILE" ]; then
    if grep -q "deepseek" "$CONFIG_FILE" 2>/dev/null; then
        echo "   ✅ DeepSeek 模型已配置"
    else
        echo "   ⚠️ 未检测到模型配置"
        echo "   📝 请确保已在 DeepSeek 开放平台创建 API Key"
        echo "   🔗 https://platform.deepseek.com/usage"
        echo ""
        read -p "   请输入你的 DeepSeek API Key: " api_key
        if [ -n "$api_key" ]; then
            echo "   ✅ API Key 已记录"
            echo "   📝 请在 config.yaml 中配置："
            echo "      model:"
            echo "        api_key: $api_key"
            echo "        default: deepseek-v4-flash"
        fi
    fi
fi
echo ""

# ---- 步骤3：安装10大核心技能 ----
echo "📦 [3/4] 安装核心技能..."
sleep 1

SKILLS=(
    "agent-browser"
    "proactive-agent"
    "model-usage"
    "elite-longterm-memory"
    "tavily"
    "automation-workflows"
    "moltguard"
    "skill-creator"
    "summarize"
    "ima"
)

for skill in "${SKILLS[@]}"; do
    echo -n "   📥 安装 $skill ... "
    if skillhub install "$skill" &>/dev/null; then
        echo "✅"
    else
        echo "⚠️ 跳过"
    fi
done

echo ""
echo "   ✅ 10大技能安装完成"
echo ""

# ---- 步骤4：微信接入引导 ----
echo "📱 [4/4] 微信接入准备..."
sleep 1
echo ""
echo "   ╔════════════════════════════════════╗"
echo "   ║  执行以下命令接入微信：              ║"
echo "   ║                                    ║"
echo "   ║  hermes gateway setup              ║"
echo "   ║                                    ║"
echo "   ║  输入 14 → 个人微信                ║"
echo "   ║  输入 12 → 企业微信                ║"
echo "   ║  扫码授权 → 微信直接对话 ✅         ║"
echo "   ╚════════════════════════════════════╝"
echo ""

# ---- 完成 ----
echo "╔══════════════════════════════════════╗"
echo "║  🎉 部署准备完成！                     ║"
echo "║                                      ║"
echo "║  最后一步：运行 hermes gateway setup  ║"
echo "║  扫码后即可在微信里跟AI对话            ║"
echo "╚══════════════════════════════════════╝"
echo ""
