<template>
  <div class="fund-search">
    <!-- 搜索与操作栏 -->
    <div class="search-bar glass-card">
      <div class="search-left">
        <el-input v-model="keyword" placeholder="输入基金代码或名称" style="width: 220px" clearable size="large">
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-button type="primary" @click="search" :icon="Search" size="large">搜索</el-button>
        <el-button @click="reset" size="large">重置</el-button>
      </div>
      <div class="search-right">
        <el-button type="primary" :disabled="selectedFunds.length === 0" @click="savePortfolio" size="large">
          <el-icon :size="15"><FolderAdd /></el-icon> 保存为组合
        </el-button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="16" class="stat-cards">
      <el-col :xs="12" :sm="6" v-for="card in statCards" :key="card.label">
        <div class="stat-card glass-card-hoverable">
          <div class="stat-icon" :style="{ background: card.gradient }">
            <el-icon :size="20"><component :is="card.icon" /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ card.value }}</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 未登录提示 -->
    <div v-if="!isLoggedIn" class="login-hint glass-card-hoverable">
      <div class="hint-content">
        <el-icon :size="22"><InfoFilled /></el-icon>
        <span>登录后可保存组合、管理我的组合，并使用AI独家服务</span>
      </div>
      <el-button type="primary" @click="$router.push('/login')" round>立即登录</el-button>
    </div>

    <!-- 主内容区 -->
    <div class="content">
      <div class="tag-panel glass-card">
        <div class="panel-title"><el-icon :size="16"><Collection /></el-icon>标签筛选</div>
        <el-tree
          :data="tagTree" show-checkbox node-key="id"
          :props="{ children: 'children', label: 'name' }" ref="tagTreeRef" @check="onTagCheck"
        />
      </div>
      <div class="fund-table">
        <el-table
          :data="fundList"
          border
          @selection-change="handleSelectionChange"
          :default-sort="{ prop: 'code', order: 'ascending' }"
        >
          <el-table-column type="selection" width="50" />
          <el-table-column prop="code" label="基金代码" width="120" sortable />
          <el-table-column prop="name" label="基金名称" sortable />
          <el-table-column prop="type" label="类型" width="100" sortable />
          <el-table-column prop="unitNav" label="净值" width="100" sortable />
          <el-table-column prop="dailyReturn" label="日涨跌(%)" width="110" sortable>
            <template #default="{ row }">
              <span :class="row.dailyReturn >= 0 ? 'text-up' : 'text-down'">
                {{ row.dailyReturn >= 0 ? '+' : '' }}{{ row.dailyReturn }}
              </span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="80">
            <template #default="scope">
              <el-button size="small" type="primary" @click="goProfile(scope.row.id)">详情</el-button>
            </template>
          </el-table-column>
        </el-table>
        <div class="bottom-bar glass-card">
          <el-pagination
            class="pagination" background layout="total, prev, pager, next"
            :total="total" :page-size="20" v-model:current-page="page" @current-change="search"
          />
        </div>
      </div>
    </div>

    <el-dialog v-model="dialogVisible" title="保存组合" width="400px">
      <el-input v-model="portfolioName" placeholder="组合名称" size="large" />
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmSave">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Collection, Money, CircleCheck, FolderAdd, InfoFilled } from '@element-plus/icons-vue'
import request from '../api/index'
import { ElMessage } from 'element-plus'

const router = useRouter()
const keyword = ref('')
const page = ref(1)
const total = ref(0)
const fundList = ref([])
const tagTree = ref([])
const tagTreeRef = ref(null)
const checkedTags = ref([])
const selectedFunds = ref([])
const dialogVisible = ref(false)
const portfolioName = ref('')

const isLoggedIn = computed(() => !!localStorage.getItem('userId'))

const statCards = computed(() => [
  { label: '基金总数', value: total.value, icon: Money, gradient: 'linear-gradient(135deg, #b71c1c, #c62828)' },
  { label: '当前结果', value: fundList.value.length, icon: Search, gradient: 'linear-gradient(135deg, #c62828, #d32f2f)' },
  { label: '已选基金', value: selectedFunds.value.length, icon: CircleCheck, gradient: 'linear-gradient(135deg, #d4a017, #b8860b)' },
  { label: '标签筛选', value: checkedTags.value.length || 0, icon: Collection, gradient: 'linear-gradient(135deg, #2d6a4f, #1b4332)' }
])

const search = async () => {
  const params = { keyword: keyword.value, page: page.value - 1 }
  if (checkedTags.value.length > 0) params.tagIds = checkedTags.value.join(',')
  try {
    const res = await request.get('/funds', { params })
    if (res.data.code === 200) {
      fundList.value = res.data.data.records
      total.value = res.data.data.total
    }
  } catch (e) { ElMessage.error('查询失败') }
}

const reset = () => {
  keyword.value = ''
  page.value = 1
  checkedTags.value = []
  tagTreeRef.value?.setCheckedKeys([])
  search()
}

const onTagCheck = () => {
  checkedTags.value = tagTreeRef.value.getCheckedKeys()
  page.value = 1
  search()
}

const goProfile = (id) => router.push(`/funds/${id}`)
const handleSelectionChange = (rows) => { selectedFunds.value = rows }

const savePortfolio = () => {
  if (!localStorage.getItem('userId')) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  dialogVisible.value = true
}

const confirmSave = async () => {
  if (!portfolioName.value.trim()) { ElMessage.warning('请输入组合名称'); return }
  try {
    await request.post('/portfolios', {
      userId: Number(localStorage.getItem('userId')),
      name: portfolioName.value,
      fundIds: selectedFunds.value.map(f => f.id)
    })
    ElMessage.success('组合已保存')
    dialogVisible.value = false
    portfolioName.value = ''
  } catch (e) { ElMessage.error('保存失败') }
}

onMounted(async () => {
  try {
    const tagRes = await request.get('/tags', { params: { dimension: 'fund' } })
    tagTree.value = tagRes.data.data || []
  } catch (e) {}
  search()
})
</script>

<style scoped>
.fund-search { animation: fadeInUp 0.4s ease; }

/* 搜索与操作栏 */
.search-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 20px;
  padding: 14px 20px;
  flex-wrap: wrap;
}
.search-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}
.search-right {
  display: flex;
  align-items: center;
}

.stat-cards { margin-bottom: 20px; }
.stat-card {
  border-radius: var(--radius-lg);
  cursor: default;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 14px;
}
.stat-icon {
  width: 44px; height: 44px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(0,0,0,0.35);
}
.stat-info .stat-value {
  font-size: var(--font-size-xl);
  font-weight: 700;
  color: var(--text-primary);
  line-height: 1.2;
}
.stat-info .stat-label {
  font-size: var(--font-size-xs);
  color: var(--text-secondary);
  margin-top: 2px;
}

/* 未登录引导 */
.login-hint {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  margin-bottom: 16px;
}
.hint-content {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--text-secondary);
  font-size: var(--font-size-sm);
}

/* 内容布局 */
.content { display: flex; gap: 16px; }
.tag-panel {
  width: 260px; min-width: 260px;
  padding: 12px;
  align-self: flex-start;
}
.panel-title {
  display: flex; align-items: center; gap: 6px;
  font-size: var(--font-size-sm); font-weight: 600;
  color: var(--text-primary);
  padding: 8px 8px 12px;
  border-bottom: 1px solid var(--border-light);
  margin-bottom: 8px;
}
.fund-table { flex: 1; min-width: 0; }
.fund-table :deep(.el-table) { border-radius: var(--radius-md); overflow: hidden; }

/* 底部分页栏 */
.bottom-bar {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-top: 16px;
  flex-wrap: wrap;
  gap: 12px;
  padding: 12px 16px;
}

/* 涨跌颜色：红涨绿跌，符合股票习惯 */
.text-up {
  color: #c0392b;   /* 上涨红色 */
  font-weight: 500;
}
.text-down {
  color: #2d6a4f;   /* 下跌绿色 */
  font-weight: 500;
}

/* 响应式 */
@media (max-width: 1024px) {
  .content { flex-direction: column; }
  .tag-panel { width: 100%; min-width: 100%; }
}
@media (max-width: 768px) {
  .search-bar {
    flex-direction: column;
    align-items: stretch;
    padding: 14px;
  }
  .search-left {
    flex-direction: column;
    align-items: stretch;
  }
  .search-left .el-input { width: 100% !important; }
  .search-right {
    justify-content: flex-end;
  }
  .bottom-bar { justify-content: center; }
}
</style>