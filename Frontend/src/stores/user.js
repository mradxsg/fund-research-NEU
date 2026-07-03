import { defineStore } from 'pinia'
import { login as loginApi, register as registerApi } from '@/api/user'

export const useUserStore = defineStore('user', {
  state: () => ({
    userId: localStorage.getItem('userId') || null,
    username: localStorage.getItem('username') || ''
  }),
  getters: {
    isLoggedIn: (state) => !!state.userId
  },
  actions: {
    async login(username, password) {
      const res = await loginApi({ username, password })
      if (res.code === 200) {
        this.userId = res.data.userId
        this.username = res.data.username
        localStorage.setItem('userId', res.data.userId)
        localStorage.setItem('username', res.data.username)
        return true
      }
      return false
    },
    async register(username, password) {
      await registerApi({ username, password })
      // 成功后直接跳转登录，不自动登录
    },
    logout() {
      this.userId = null
      this.username = ''
      localStorage.removeItem('userId')
      localStorage.removeItem('username')
      // 跳转到首页
    }
  }
})