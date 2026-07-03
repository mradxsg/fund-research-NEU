<template>
  <div class="app-root">
    <AnimatedBackground />
    <nav class="app-navbar" data-no-transition>
      <div class="navbar-inner">
        <router-link to="/funds" class="nav-brand">
          <div class="brand-icon">
            <el-icon :size="20"><TrendCharts /></el-icon>
          </div>
          <span class="brand-text">FundResearch</span>
        </router-link>

        <div class="nav-links">
          <router-link to="/funds"><el-icon :size="15"><Money /></el-icon><span>基金</span></router-link>
          <router-link to="/companies"><el-icon :size="15"><OfficeBuilding /></el-icon><span>公司</span></router-link>
          <router-link to="/managers"><el-icon :size="15"><UserFilled /></el-icon><span>经理</span></router-link>
          <router-link to="/portfolios"><el-icon :size="15"><Folder /></el-icon><span>我的组合</span></router-link>
        </div>

        <div class="nav-right">
          <button class="theme-toggle" @click="toggleTheme" :title="isDark ? '切换到明亮模式' : '切换到暗黑模式'">
            <el-icon :size="18">
              <Sunny v-if="!isDark" />
              <Moon v-else />
            </el-icon>
          </button>

          <template v-if="username">
            <div class="nav-user-badge" @click="$router.push('/profile')">
              <el-icon :size="15"><UserFilled /></el-icon>
              <span>{{ username }}</span>
            </div>
            <button class="btn-nav-glass" @click="logout">
              <el-icon :size="14"><SwitchButton /></el-icon><span>退出</span>
            </button>
          </template>
          <template v-else>
            <button class="btn-nav-glass btn-nav-login" @click="$router.push('/login')">
              <el-icon :size="15"><UserFilled /></el-icon><span>登录</span>
            </button>
          </template>
        </div>
      </div>
    </nav>

    <main>
      <router-view v-slot="{ Component }">
        <transition name="page-fade" mode="out-in"><component :is="Component" /></transition>
      </router-view>
    </main>

    <!-- AI 悬浮按钮始终可见 -->
    <div class="ai-float" @click="openChat" title="AI 助手">
      <div class="ai-float-glow"></div>
      <el-icon :size="22"><Service /></el-icon>
    </div>

    <transition name="chat-slide">
      <div v-if="showChat" class="ai-chat-window">
        <div class="chat-header">
          <span><el-icon :size="15"><Service /></el-icon> AI 助手</span>
          <div class="chat-header-actions">
            <div class="chat-dot"></div>
            <el-icon class="chat-close" :size="17" @click="showChat = false"><Close /></el-icon>
          </div>
        </div>
        <div class="chat-messages" ref="chatMsgs">{{ messages || 'AI 助手已就绪，输入基金相关问题...' }}</div>
        <div class="chat-input-wrap">
          <input v-model="inputMsg" @keyup.enter="sendMsg" placeholder="输入基金相关问题..." autocomplete="off" />
          <button class="chat-send-btn" @click="sendMsg" :disabled="!inputMsg.trim()">
            <el-icon :size="16"><Promotion /></el-icon>
          </button>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
  TrendCharts, Service, Close, UserFilled, SwitchButton,
  Money, OfficeBuilding, Folder, Promotion, Sunny, Moon
} from '@element-plus/icons-vue'
import AnimatedBackground from './components/AnimatedBackground.vue'
import request from './api/index'
import { ElMessage } from 'element-plus'

const username = ref(localStorage.getItem('username') || '')
const showChat = ref(false)
const messages = ref('')
const inputMsg = ref('')
const isDark = ref(true)

function applyTheme(dark) {
  isDark.value = dark
  document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light')
  localStorage.setItem('theme', dark ? 'dark' : 'light')
}
function toggleTheme() { applyTheme(!isDark.value) }

onMounted(() => {
  username.value = localStorage.getItem('username') || ''
  const saved = localStorage.getItem('theme') || 'dark'
  applyTheme(saved === 'dark')
})

function logout() {
  localStorage.removeItem('userId')
  localStorage.removeItem('username')
  localStorage.removeItem('nickname')
  username.value = ''
  showChat.value = false
}

function openChat() {
  if (!username.value) {
    ElMessage.warning('请先登录后再使用 AI 助手')
    return
  }
  showChat.value = !showChat.value
}

async function sendMsg() {
  if (!inputMsg.value.trim()) return
  const userMsg = inputMsg.value.trim()
  inputMsg.value = ''
  messages.value += `我：${userMsg}\n`
  try {
    const res = await request.post('/ai/chat', { message: userMsg })
    const reply = res.data.data?.reply || 'AI 暂时无法回答'
    messages.value += `AI：${reply}\n`
  } catch (e) {
    messages.value += 'AI：服务不可用\n'
  }
  setTimeout(() => {
    const el = document.querySelector('.chat-messages')
    if (el) el.scrollTop = el.scrollHeight
  }, 50)
}
</script>

<style scoped>
/* ============================================================
   Navbar — Premium Glassmorphism
   ============================================================ */
.app-navbar { position: sticky; top: 12px; z-index: 1000; padding: 0 24px; margin: 0 auto; }
.app-navbar * { transition: none !important; }
.navbar-inner {
  display: flex; align-items: center; justify-content: space-between;
  height: var(--navbar-height); padding: 0 20px;
  background: var(--glass-bg); backdrop-filter: var(--glass-blur-heavy);
  -webkit-backdrop-filter: var(--glass-blur-heavy);
  border: 1px solid var(--glass-border); border-radius: var(--radius-2xl);
  box-shadow: 0 8px 32px rgba(0,0,0,0.35); transition: border-color 0.28s ease, box-shadow 0.28s ease;
}
.navbar-inner:hover { border-color: rgba(198,40,40,0.25); box-shadow: 0 8px 32px rgba(0,0,0,0.35), 0 0 30px rgba(198,40,40,0.06); }
.nav-brand { display: flex; align-items: center; gap: 10px; text-decoration: none; transition: opacity 0.18s ease; }
.nav-brand:hover { opacity: 0.85; }
.brand-icon {
  width: 36px; height: 36px; border-radius: var(--radius-md);
  background: var(--brand-gradient); display: flex; align-items: center;
  justify-content: center; color: #fff; box-shadow: 0 2px 12px rgba(198,40,40,0.30);
}
.brand-text {
  font-size: var(--font-size-lg); font-weight: 700; letter-spacing: 0.5px;
  background: linear-gradient(135deg, #e8e4e4 0%, #e53935 100%);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
}
.nav-links { display: flex; gap: 2px; }
.nav-links a {
  display: flex; align-items: center; gap: 6px; color: var(--text-secondary);
  padding: 8px 16px; border-radius: var(--radius-full); font-size: var(--font-size-sm);
  font-weight: 500; transition: all 0.2s ease; text-decoration: none; position: relative;
}
.nav-links a:hover { color: var(--text-primary); background: rgba(198,40,40,0.08); }
.nav-links a.router-link-active {
  color: #fff; background: linear-gradient(135deg, rgba(198,40,40,0.35), rgba(180,40,40,0.25));
  box-shadow: 0 0 16px rgba(198,40,40,0.12);
}
.theme-toggle {
  width: 38px; height: 38px; border-radius: var(--radius-full);
  border: 1px solid var(--glass-border); background: var(--glass-bg);
  backdrop-filter: var(--glass-blur); -webkit-backdrop-filter: var(--glass-blur);
  color: var(--text-secondary); cursor: pointer; display: flex; align-items: center;
  justify-content: center; transition: all 0.30s cubic-bezier(0.4,0,0.2,1);
  position: relative; overflow: hidden;
}
.theme-toggle::before {
  content: ''; position: absolute; inset: 0; border-radius: var(--radius-full);
  background: radial-gradient(circle at center, rgba(198,40,40,0.0) 0%, transparent 70%);
  transition: background 0.35s ease;
}
.theme-toggle:hover {
  border-color: var(--brand-primary-light); color: var(--brand-primary-light);
  transform: rotate(30deg) scale(1.08); box-shadow: 0 0 18px rgba(198,40,40,0.20);
}
.theme-toggle:hover::before { background: radial-gradient(circle at center, rgba(198,40,40,0.15) 0%, transparent 70%); }
.theme-toggle:active { transform: rotate(30deg) scale(0.95); }
.nav-right { display: flex; align-items: center; gap: 10px; }
.nav-user-badge {
  display: flex; align-items: center; gap: 6px; padding: 5px 12px;
  border-radius: var(--radius-full); background: rgba(198,40,40,0.10);
  color: var(--text-primary); font-size: var(--font-size-sm);
  cursor: pointer; transition: all 0.2s ease;
}
.nav-user-badge:hover { background: rgba(198,40,40,0.15); transform: translateY(-1px); }
.btn-nav-glass {
  display: flex; align-items: center; gap: 5px; padding: 7px 16px;
  border-radius: var(--radius-full); background: var(--glass-bg);
  backdrop-filter: var(--glass-blur); -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid var(--glass-border); color: var(--text-secondary);
  font-size: var(--font-size-sm); cursor: pointer; transition: all 0.22s ease; font-family: inherit;
}
.btn-nav-glass:hover {
  background: var(--glass-bg-hover); border-color: var(--brand-primary-light);
  color: var(--text-primary); transform: translateY(-1px); box-shadow: 0 0 14px rgba(198,40,40,0.10);
}
.btn-nav-login {
  background: linear-gradient(135deg, rgba(198,40,40,0.30), rgba(160,30,30,0.18));
  border-color: rgba(198,40,40,0.30); color: #fff;
}
.btn-nav-login:hover {
  background: linear-gradient(135deg, rgba(198,40,40,0.48), rgba(160,30,30,0.30));
  border-color: rgba(198,40,40,0.55); box-shadow: 0 0 22px rgba(198,40,40,0.25); color: #fff;
}
main { max-width: var(--content-max-width); margin: 0 auto; padding: var(--page-padding); position: relative; z-index: 1; }
/* AI 悬浮按钮 */
.ai-float {
  position: fixed; bottom: 28px; right: 28px; width: 50px; height: 50px;
  background: linear-gradient(135deg, #b71c1c, #c62828); border-radius: var(--radius-full);
  display: flex; align-items: center; justify-content: center; cursor: pointer;
  z-index: 1000; color: #fff; box-shadow: 0 4px 20px rgba(198,40,40,0.35);
  transition: all 0.28s cubic-bezier(0.4,0,0.2,1); animation: glowPulse 3.5s ease-in-out infinite;
}
.ai-float-glow {
  position: absolute; inset: -5px; border-radius: var(--radius-full);
  background: linear-gradient(135deg, #b71c1c, #c62828); opacity: 0.25;
  filter: blur(10px); z-index: -1; transition: opacity 0.28s ease;
}
.ai-float:hover { transform: scale(1.10); box-shadow: 0 8px 32px rgba(198,40,40,0.55); }
.ai-float:hover .ai-float-glow { opacity: 0.45; }
.ai-chat-window {
  position: fixed; bottom: 92px; right: 28px; width: 380px; height: 460px;
  background: var(--bg-card); backdrop-filter: var(--glass-blur-heavy);
  -webkit-backdrop-filter: var(--glass-blur-heavy); border: 1px solid var(--glass-border);
  border-radius: var(--radius-xl); box-shadow: var(--shadow-xl);
  display: flex; flex-direction: column; z-index: 999; overflow: hidden;
}
.chat-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 12px 16px; background: var(--glass-bg); border-bottom: 1px solid var(--border-light);
  color: var(--text-primary); font-size: var(--font-size-sm); font-weight: 600;
}
.chat-header span { display: flex; align-items: center; gap: 7px; }
.chat-header-actions { display: flex; align-items: center; gap: 10px; }
.chat-dot { width: 7px; height: 7px; border-radius: 50%; background: #2d6a4f; box-shadow: 0 0 6px rgba(45,106,79,0.5); }
.chat-close { cursor: pointer; color: var(--text-secondary); transition: all 0.18s ease; }
.chat-close:hover { color: var(--text-primary); }
.chat-messages {
  flex: 1; overflow-y: auto; padding: 14px 16px; white-space: pre-wrap;
  font-size: var(--font-size-sm); line-height: 1.7; color: var(--text-regular);
}
.chat-input-wrap { display: flex; align-items: center; border-top: 1px solid var(--border-light); background: var(--glass-bg); }
.chat-input-wrap input {
  flex: 1; padding: 11px 14px; border: none; outline: none;
  font-size: var(--font-size-sm); background: transparent; color: var(--text-primary); font-family: inherit;
}
.chat-input-wrap input::placeholder { color: var(--text-placeholder); }
.chat-send-btn {
  display: flex; align-items: center; justify-content: center;
  width: 38px; height: 38px; margin: 4px; border: none; border-radius: var(--radius-md);
  background: rgba(198,40,40,0.20); color: var(--brand-primary-light);
  cursor: pointer; transition: all 0.20s ease;
}
.chat-send-btn:hover:not(:disabled) { background: rgba(198,40,40,0.45); color: #fff; }
.chat-send-btn:disabled { opacity: 0.3; cursor: not-allowed; }
/* 页面过渡 */
.page-fade-enter-active, .page-fade-leave-active { transition: opacity 0.35s ease, transform 0.35s ease; }
.page-fade-enter-from { opacity: 0; transform: translateY(14px); }
.page-fade-leave-to { opacity: 0; transform: translateY(-8px); }
.chat-slide-enter-active, .chat-slide-leave-active { transition: all 0.28s cubic-bezier(0.4,0,0.2,1); }
.chat-slide-enter-from, .chat-slide-leave-to { opacity: 0; transform: translateY(14px) scale(0.96); }
/* 响应式 */
@media (max-width: 768px) {
  .app-navbar { padding: 0 8px; top: 6px; }
  .navbar-inner { padding: 0 12px; height: 50px; border-radius: var(--radius-lg); }
  .brand-text { display: none; }
  .nav-links a { padding: 6px 10px; font-size: var(--font-size-xs); }
  .nav-links a span { display: none; }
  .nav-user-badge span { display: none; }
  .btn-nav-glass span { display: none; }
  .btn-nav-glass { padding: 7px 10px; }
  .ai-chat-window { width: calc(100vw - 16px); right: 8px; bottom: 76px; height: 400px; }
  .ai-float { bottom: 16px; right: 12px; width: 44px; height: 44px; }
  main { padding: 12px 10px; }
}
</style>
