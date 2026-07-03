<template>
  <div class="login-page">
    <div class="login-card glass-card">
      <div class="card-accent-bar"></div>
      <div class="card-logo">
        <div class="logo-icon"><el-icon :size="24"><TrendCharts /></el-icon></div>
      </div>
      <h2>欢迎回来</h2>
      <div class="quote-box">
        <el-icon :size="16"><TrendCharts /></el-icon>
        <span>市场有风险，投资需谨慎。让数据为您导航。</span>
      </div>
      <el-form :model="form" ref="formRef" :rules="rules" size="large">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" :prefix-icon="UserFilled" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" placeholder="请输入密码" show-password :prefix-icon="Lock" />
        </el-form-item>
        <el-form-item class="form-actions">
          <el-button type="primary" @click="handleLogin" :icon="RightIcon" round class="btn-login">登录</el-button>
        </el-form-item>
        <p class="form-footer">还没有账户？<router-link to="/register">立即注册</router-link></p>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { UserFilled, Lock, TrendCharts } from '@element-plus/icons-vue'
import { Right as RightIcon } from '@element-plus/icons-vue'
import request from '../api/index'
import { ElMessage } from 'element-plus'

const router = useRouter()
const form = ref({ username: '', password: '' })
const formRef = ref(null)
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  try {
    const res = await request.post('/user/login', {
      username: form.value.username,
      password: form.value.password
    })
    if (res.data.code === 200) {
        localStorage.setItem('userId', res.data.data.userId)
        localStorage.setItem('username', res.data.data.username)
        ElMessage.success('登录成功')
        window.location.href = '/funds'   // 直接跳转并刷新导航栏
    }else {
      ElMessage.error(res.data.message || '登录失败，请检查用户名密码')
    }
  } catch (e) {
    const msg = e.response?.data?.message || e.message || '登录请求失败，请检查网络'
    ElMessage.error(msg)
  }
}
</script>

<style scoped>
.login-page { display: flex; justify-content: center; align-items: center; min-height: calc(100vh - var(--navbar-height) - 80px); }
.login-card { width: 420px; padding: 40px 36px 32px; position: relative; overflow: hidden; animation: fadeInUp 0.5s ease; }
.card-accent-bar { position: absolute; top: 0; left: 0; right: 0; height: 3px; background: var(--brand-gradient); }
.card-logo { display: flex; justify-content: center; margin-bottom: 20px; }
.logo-icon { width: 48px; height: 48px; border-radius: var(--radius-lg); background: var(--brand-gradient); display: flex; align-items: center; justify-content: center; color: #fff; box-shadow: 0 4px 20px rgba(198,40,40,0.30); }
.login-card h2 { text-align: center; color: var(--text-primary); font-size: var(--font-size-2xl); margin-bottom: 6px; }
.quote-box { display: flex; align-items: center; justify-content: center; gap: 8px; margin: 0 0 24px 0; padding: 10px 16px; background: rgba(198,40,40,0.06); border-radius: var(--radius-md); color: var(--text-secondary); font-size: var(--font-size-sm); }
.form-actions { margin-top: 4px; }
.btn-login { width: 100%; }
.form-footer { text-align: center; color: var(--text-secondary); font-size: var(--font-size-sm); margin-top: 6px; }
.form-footer a { color: var(--brand-primary-light); font-weight: 500; }
@media (max-width: 500px) { .login-card { width: 92%; padding: 28px 20px 24px; } }
</style>