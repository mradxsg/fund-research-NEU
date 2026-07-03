import axios from 'axios'

const service = axios.create({
  baseURL: '/api', // 开发环境可配置代理
  timeout: 10000
})

// 请求拦截：可从 localStorage 获取 userId 挂载到 params
service.interceptors.request.use(config => {
  const userId = localStorage.getItem('userId')
  if (userId && config.method === 'get') {
    config.params = { ...config.params, userId }
  } else if (userId && config.data) {
    config.data.userId = userId
  }
  return config
})

// 响应拦截：统一处理错误
service.interceptors.response.use(
  response => response.data,
  error => Promise.reject(error)
)

export default service