<template>
  <div class="profile-page">
    <div class="page-header">
      <h2><el-icon :size="22"><UserFilled /></el-icon>个人空间</h2>
    </div>

    <!-- 基本信息修改 -->
    <div class="glass-card section-card">
      <div class="section-title">基本信息</div>
      <el-form :model="infoForm" label-width="80px">
        <el-form-item label="用户名">
          <el-input :model-value="profile.username" disabled />
        </el-form-item>
        <el-form-item label="昵称">
          <div style="display:flex; gap:8px;">
            <el-input v-model="infoForm.nickname" placeholder="输入昵称" style="flex:1"/>
            <el-button type="primary" size="small" @click="saveNickname">保存</el-button>
          </div>
        </el-form-item>

        <!-- 新增：邮箱和手机号（只读展示） -->
        <el-form-item label="邮箱">
          <el-input v-model="profile.email" placeholder="未绑定" disabled>
            <template #suffix>
              <el-icon><Message /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="profile.phone" placeholder="未绑定" disabled>
            <template #suffix>
              <el-icon><Phone /></el-icon>
            </template>
          </el-input>
        </el-form-item>
      </el-form>
    </div>

    <!-- 修改密码 -->
    <div class="glass-card section-card">
      <div class="section-title">修改密码</div>
      <el-form :model="pwdForm" label-width="80px" ref="pwdFormRef" :rules="pwdRules">
        <el-form-item label="原密码" prop="oldPassword">
          <el-input v-model="pwdForm.oldPassword" show-password />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="pwdForm.newPassword" show-password />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="pwdForm.confirmPassword" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="changePassword">修改密码</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { UserFilled, Message, Phone } from '@element-plus/icons-vue'
import request from '../api/index'
import { ElMessage } from 'element-plus'

const userId = localStorage.getItem('userId')
const profile = ref({
  username: '',
  nickname: '',
  email: '',
  phone: ''
})
const infoForm = ref({ nickname: '' })
const pwdForm = ref({ oldPassword: '', newPassword: '', confirmPassword: '' })
const pwdFormRef = ref(null)
const pwdRules = {
  oldPassword: [{ required: true, message: '请输入原密码' }],
  newPassword: [{ required: true, min: 6, max: 20, message: '请输入6-20位新密码' }],
  confirmPassword: [{ required: true, message: '请再次输入新密码' }]
}

onMounted(async () => {
  if (!userId) return
  try {
    const res = await request.get('/user/profile', { params: { userId } })
    const data = res.data.data
    profile.value = {
      username: data.username || '',
      nickname: data.nickname || data.username || '',
      email: data.email || '',
      phone: data.phone || ''
    }
    infoForm.value.nickname = profile.value.nickname
  } catch (e) {
    ElMessage.error('获取用户信息失败')
  }
})

async function saveNickname() {
  try {
    await request.put('/user/profile/nickname', {
      userId: Number(userId),
      nickname: infoForm.value.nickname
    })
    profile.value.nickname = infoForm.value.nickname
    ElMessage.success('昵称已保存')
    localStorage.setItem('nickname', infoForm.value.nickname)
  } catch (e) {
    ElMessage.error('保存失败')
  }
}

async function changePassword() {
  if (!pwdFormRef.value) return
  const valid = await pwdFormRef.value.validate().catch(() => false)
  if (!valid) return
  if (pwdForm.value.newPassword !== pwdForm.value.confirmPassword) {
    ElMessage.error('两次新密码输入不一致')
    return
  }
  try {
    await request.put('/user/profile/password', {
      userId: Number(userId),
      oldPassword: pwdForm.value.oldPassword,
      newPassword: pwdForm.value.newPassword
    })
    ElMessage.success('密码已修改，请重新登录')
    localStorage.removeItem('userId')
    localStorage.removeItem('username')
    localStorage.removeItem('nickname')
    setTimeout(() => {
      location.href = '/login'
    }, 1000)
  } catch (e) {
    ElMessage.error('修改失败：' + (e.response?.data?.message || '未知错误'))
  }
}
</script>

<style scoped>
.profile-page {
  max-width: 800px;
  margin: 0 auto;
  animation: fadeInUp 0.4s ease;
}
.page-header {
  margin-bottom: 20px;
}
.page-header h2 {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--text-primary);
  font-size: var(--font-size-2xl);
}
.section-card {
  padding: 24px;
  margin-bottom: 16px;
}
.section-title {
  font-size: var(--font-size-md);
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 16px;
}
</style>