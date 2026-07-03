import { createRouter, createWebHistory } from 'vue-router'
import FundSearch from '../views/FundSearch.vue'
import FundProfile from '../views/FundProfile.vue'
import CompanySearch from '../views/CompanySearch.vue'
import ManagerSearch from '../views/ManagerSearch.vue'
import PortfolioList from '../views/PortfolioList.vue'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import Profile from '../views/Profile.vue'

const routes = [
  { path: '/login', component: Login },
  { path: '/register', component: Register },
  { path: '/funds', component: FundSearch },
  { path: '/funds/:id', component: FundProfile },
  { path: '/companies', component: CompanySearch },
  { path: '/managers', component: ManagerSearch },
  { path: '/profile', component: Profile, meta: { requiresAuth: true } } ,
  {
    path: '/portfolios',
    component: PortfolioList,
    meta: { requiresAuth: true }
  },
  { path: '/', redirect: '/funds' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫：需要登录的页面，检查 localStorage 中是否有 userId
router.beforeEach((to, from, next) => {
  if (to.meta.requiresAuth) {
    const userId = localStorage.getItem('userId')
    if (!userId) {
      next('/login')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
