<template>
  <div class="portfolio-list">
    <div class="page-header">
      <h2><el-icon :size="22"><Folder /></el-icon>我的组合</h2>
    </div>

    <div v-if="!userId" class="empty-state glass-card">
      <el-empty description="请先登录以查看您的组合">
        <el-button type="primary" size="large" @click="$router.push('/login')">去登录</el-button>
      </el-empty>
    </div>

    <template v-else>
      <!-- 搜索与操作栏 -->
      <div class="toolbar glass-card">
        <div class="toolbar-left">
          <el-input v-model="searchKeyword" placeholder="搜索组合名称" style="width:240px" clearable size="large">
            <template #prefix><el-icon><Search /></el-icon></template>
          </el-input>
          <el-button type="primary" @click="resetSearch" size="large">重置</el-button>
        </div>
        <div class="toolbar-right">
          <el-button @click="batchMode = !batchMode" :type="batchMode ? 'warning' : 'default'" size="large">
            {{ batchMode ? '退出批量操作' : '批量操作' }}
          </el-button>
          <el-button v-if="batchMode && selectedPortfolios.length > 0" type="danger" @click="batchDelete" size="large">
            <el-icon :size="15"><Delete /></el-icon> 删除选中 ({{ selectedPortfolios.length }})
          </el-button>
        </div>
      </div>

      <!-- 组合列表 -->
      <div v-if="filteredPortfolios.length === 0" class="empty-state">
        <el-empty :description="portfolios.length === 0 ? '暂无组合，快去筛选并保存吧~' : '没有匹配的组合'">
          <el-button type="primary" size="large" @click="$router.push('/funds')">去筛选基金</el-button>
        </el-empty>
      </div>

      <el-row :gutter="20" v-else>
        <el-col :xs="24" :sm="12" :lg="8" v-for="p in filteredPortfolios" :key="p.id">
          <div
            class="portfolio-card glass-card-hoverable"
            :class="{ 'is-selected': selectedPortfolios.includes(p.id) }"
            @click="batchMode ? toggleSelect(p.id) : viewDetail(p.id)"
          >
            <div class="card-accent"></div>
            <div class="card-header">
              <el-checkbox
                v-if="batchMode"
                :model-value="selectedPortfolios.includes(p.id)"
                @change="(checked) => toggleSelect(p.id)"
                @click.stop
                class="card-checkbox"
              />
              <div class="card-icon"><el-icon :size="18"><Folder /></el-icon></div>
              <h4>{{ p.name }}</h4>
            </div>
            <p class="card-time">
              <el-icon :size="13"><Clock /></el-icon>
              创建于 {{ p.createdTime?.substring(0,10) }}
            </p>
            <div class="card-actions" @click.stop>
              <el-button size="small" type="primary" @click="viewDetail(p.id)" :icon="View" round>查看</el-button>
              <el-button size="small" @click="remove(p.id)" :icon="Delete" round plain>删除</el-button>
            </div>
          </div>
        </el-col>
      </el-row>
    </template>

    <el-dialog v-model="detailVisible" title="组合详情" width="700px">
      <el-table :data="detailFunds" border>
        <el-table-column prop="fundCode" label="代码" width="100" />
        <el-table-column prop="fundName" label="名称" />
        <el-table-column prop="fundType" label="类型" width="100" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Folder, View, Delete, Clock, Search } from '@element-plus/icons-vue'
import request from '../api/index'
import { ElMessage, ElMessageBox } from 'element-plus'

const userId = ref(localStorage.getItem('userId'))
const portfolios = ref([])
const selectedPortfolios = ref([])
const searchKeyword = ref('')
const batchMode = ref(false)
const detailVisible = ref(false)
const detailFunds = ref([])

const filteredPortfolios = computed(() => {
  if (!searchKeyword.value.trim()) return portfolios.value
  const kw = searchKeyword.value.trim().toLowerCase()
  return portfolios.value.filter(p => p.name.toLowerCase().includes(kw))
})

async function fetchPortfolios() {
  if (!userId.value) return
  try {
    const res = await request.get('/portfolios', { params: { userId: userId.value } })
    portfolios.value = res.data.data || []
  } catch (e) { portfolios.value = [] }
}

function resetSearch() { searchKeyword.value = '' }

function toggleSelect(id) {
  const idx = selectedPortfolios.value.indexOf(id)
  if (idx >= 0) {
    selectedPortfolios.value.splice(idx, 1)
  } else {
    selectedPortfolios.value.push(id)
  }
}

async function viewDetail(id) {
  try {
    const res = await request.get(`/portfolios/${id}`)
    detailFunds.value = res.data.data.funds || []
    detailVisible.value = true
  } catch (e) { ElMessage.error('获取详情失败') }
}

async function remove(id) {
  try {
    await request.delete(`/portfolios/${id}`)
    ElMessage.success('删除成功')
    selectedPortfolios.value = selectedPortfolios.value.filter(pid => pid !== id)
    await fetchPortfolios()
  } catch (e) { ElMessage.error('删除失败') }
}

async function batchDelete() {
  if (selectedPortfolios.value.length === 0) { ElMessage.warning('请先选择组合'); return }
  try {
    await ElMessageBox.confirm(`确定要删除选中的 ${selectedPortfolios.value.length} 个组合吗？`, '批量删除', {
      confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
    })
    for (const id of selectedPortfolios.value) {
      await request.delete(`/portfolios/${id}`)
    }
    ElMessage.success('批量删除成功')
    selectedPortfolios.value = []
    batchMode.value = false
    await fetchPortfolios()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error('批量删除失败')
  }
}

onMounted(() => fetchPortfolios())
</script>

<style scoped>
.portfolio-list { animation: fadeInUp 0.4s ease; max-width: var(--content-max-width); margin:0 auto; }
.page-header { margin-bottom: 24px; }
.page-header h2 { display:flex; align-items:center; gap:10px; color: var(--text-primary); font-size: var(--font-size-2xl); }
.empty-state { display:flex; justify-content:center; padding:80px 0; }

.toolbar {
  margin-bottom: 20px;
  padding: 14px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
}
.toolbar-left { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.toolbar-right { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }

.portfolio-card {
  position:relative; padding:24px 20px 20px; margin-bottom:16px; overflow:hidden;
  cursor: pointer;
  transition: all 0.25s ease;
}
.portfolio-card:hover:not(.is-selected) {
  border-color: rgba(198,40,40,0.3);
  transform: translateY(-2px);
}
.portfolio-card.is-selected {
  border-color: var(--brand-primary-light);
  box-shadow: 0 0 20px rgba(198,40,40,0.15);
}
.card-accent {
  position:absolute; top:0; left:0; right:0; height:3px;
  background: linear-gradient(90deg, #b71c1c, #c62828, #d4a017);
}
.card-header { display:flex; align-items:center; gap:10px; margin-bottom:10px; }
.card-checkbox { flex-shrink:0; }
.card-icon {
  width:36px; height:36px; border-radius:var(--radius-md);
  background:linear-gradient(135deg,rgba(198,40,40,0.18),rgba(160,30,30,0.12));
  display:flex; align-items:center; justify-content:center; color:#e53935;
}
.card-header h4 { color:var(--text-primary); font-size:var(--font-size-md); margin:0; font-weight:600; }
.card-time {
  color:var(--text-secondary); font-size:var(--font-size-xs); margin-bottom:16px;
  display:flex; align-items:center; gap:5px;
  padding-left: 46px;
}
.card-actions { display:flex; gap:8px; padding-left: 46px; }

@media (max-width:768px) {
  .page-header h2 { font-size:var(--font-size-lg); }
  .toolbar { flex-direction: column; align-items: stretch; }
  .toolbar-left { flex-direction: column; align-items: stretch; }
  .toolbar-left .el-input { width: 100% !important; }
  .toolbar-right { justify-content: flex-end; }
}
</style>
