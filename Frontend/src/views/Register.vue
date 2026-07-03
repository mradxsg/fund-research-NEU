<template>
  <div class="register-page">
    <div class="register-card glass-card">
      <div class="card-accent-bar"></div>
      <div class="card-logo">
        <div class="logo-icon">
          <el-icon :size="24"><UserFilled /></el-icon>
        </div>
      </div>
      <h2>创建账户</h2>
      <p class="card-subtitle">加入 FundResearch 平台</p>
      <el-form :model="form" ref="formRef" :rules="rules" size="large">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" :prefix-icon="UserFilled" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" placeholder="请输入密码" show-password :prefix-icon="Lock" />
        </el-form-item>
        <el-form-item class="form-actions">
          <el-button type="primary" @click="handleRegister" round class="btn-register">注册</el-button>
        </el-form-item>
        <p class="form-footer">已有账户？<router-link to="/login">返回登录</router-link></p>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { UserFilled, Lock } from '@element-plus/icons-vue'
import request from '../api/index'
import { ElMessage } from 'element-plus'

const router = useRouter()
const form = ref({ username:'', password:'' })
const formRef = ref(null)
const rules = {
  username:[{ required:true, message:'请输入用户名', trigger:'blur' }],
  password:[{ required:true, message:'请输入密码', trigger:'blur' }]
}

async function handleRegister() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  try {
    const res = await request.post('/user/register', {
      username: form.value.username,
      password: form.value.password
    })
    if (res.data.code === 200) {
      ElMessage.success('注册成功，请登录')
      router.push('/login')
    } else {
      ElMessage.error(res.data.message || '注册失败')
    }
  } catch (e) { ElMessage.error('注册请求失败') }
}
</script>

<style scoped>
.register-page {
  display:flex; justify-content:center; align-items:center;
  min-height: calc(100vh - var(--navbar-height) - 80px);
}
.register-card {
  width:420px; padding:40px 36px 32px; position:relative; overflow:hidden;
  animation: fadeInUp 0.5s ease;
}
.card-accent-bar {
  position:absolute; top:0; left:0; right:0; height:3px;
  background: var(--brand-gradient);
}
.card-logo { display:flex; justify-content:center; margin-bottom:20px; }
.logo-icon {
  width:48px; height:48px; border-radius:var(--radius-lg);
  background: linear-gradient(135deg, #c62828, #8e0000);
  display:flex; align-items:center; justify-content:center; color:#fff;
  box-shadow: 0 4px 20px rgba(198,40,40,0.30);
}
.register-card h2 { text-align:center; color:var(--text-primary); font-size:var(--font-size-2xl); margin-bottom:6px; }
.card-subtitle { text-align:center; color:var(--text-secondary); font-size:var(--font-size-sm); margin-bottom:28px; }
.form-actions { margin-top:4px; }
.btn-register { width:100%; }
.form-footer { text-align:center; color:var(--text-secondary); font-size:var(--font-size-sm); margin-top:6px; }
.form-footer a { color: var(--brand-primary-light); font-weight:500; }

@media (max-width:500px) {
  .register-card { width:92%; padding:28px 20px 24px; }
}
</style>
