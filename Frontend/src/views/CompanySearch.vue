<template>
  <div class="company-search">
    <div class="page-header">
      <h2><el-icon :size="22"><OfficeBuilding /></el-icon>基金公司</h2>
    </div>

    <div class="search-bar glass-card">
      <div class="search-left">
        <el-input v-model="keyword" placeholder="输入公司名称" style="width:300px" clearable size="large">
          <template #prefix><el-icon><OfficeBuilding /></el-icon></template>
        </el-input>
        <el-button type="primary" @click="search" :icon="Search" size="large">搜索</el-button>
        <el-button @click="reset" size="large">重置</el-button>
      </div>
    </div>

    <el-table :data="companies" border @selection-change="handleSelectionChange"
              :default-sort="{ prop: 'name', order: 'ascending' }">
      <el-table-column type="selection" width="50" />
      <el-table-column prop="name" label="公司名称" sortable />
      <el-table-column prop="description" label="简介" show-overflow-tooltip />
      <el-table-column prop="fundCount" label="旗下基金数" width="120" align="center" sortable />
      <el-table-column label="操作" width="110" align="center">
        <template #default="scope">
          <el-button size="small" type="primary" @click="showFunds(scope.row.id)">查看基金</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="bottom-bar glass-card" v-if="selectedCompanies.length > 0">
      <el-button type="primary" @click="savePortfolio">
        <el-icon :size="15"><FolderAdd /></el-icon> 将旗下基金保存为组合
      </el-button>
    </div>

    <el-dialog v-model="fundsDialogVisible" title="旗下基金" width="80%">
      <el-table :data="fundsList" border>
        <el-table-column prop="code" label="代码" width="100" />
        <el-table-column prop="name" label="名称" />
        <el-table-column prop="type" label="类型" width="100" />
        <el-table-column prop="unitNav" label="净值" width="100" />
        <el-table-column prop="dailyReturn" label="日涨跌(%)" width="110" />
      </el-table>
    </el-dialog>

    <el-dialog v-model="portfolioDialogVisible" title="保存组合" width="400px">
      <el-input v-model="portfolioName" placeholder="组合名称" size="large" />
      <template #footer>
        <el-button @click="portfolioDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmSave">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Search, OfficeBuilding, FolderAdd } from '@element-plus/icons-vue'
import request from '../api/index'
import { ElMessage } from 'element-plus'

const keyword = ref('')
const companies = ref([])
const selectedCompanies = ref([])
const fundsDialogVisible = ref(false)
const fundsList = ref([])
const portfolioDialogVisible = ref(false)
const portfolioName = ref('')

const search = async () => {
  try {
    const res = await request.get('/companies', { params: { keyword: keyword.value } })
    companies.value = res.data.data.records
  } catch (e) { companies.value = [] }
}

const reset = () => { keyword.value = ''; search() }

const handleSelectionChange = (rows) => { selectedCompanies.value = rows }

const showFunds = async (companyId) => {
  try {
    const res = await request.get(`/companies/${companyId}/funds`)
    fundsList.value = res.data.data.records
    fundsDialogVisible.value = true
  } catch (e) { ElMessage.error('获取基金列表失败') }
}

const savePortfolio = () => {
  if (!localStorage.getItem('userId')) { ElMessage.warning('请先登录'); return }
  portfolioDialogVisible.value = true
}

const confirmSave = async () => {
  if (!portfolioName.value.trim()) { ElMessage.warning('请输入组合名称'); return }
  try {
    const allFundIds = []
    for (const company of selectedCompanies.value) {
      const res = await request.get(`/companies/${company.id}/funds`)
      const funds = res.data.data.records
      funds.forEach(f => allFundIds.push(f.id))
    }
    if (allFundIds.length === 0) { ElMessage.warning('所选公司旗下没有基金'); return }
    await request.post('/portfolios', {
      userId: Number(localStorage.getItem('userId')),
      name: portfolioName.value,
      fundIds: allFundIds
    })
    ElMessage.success('组合已保存')
    portfolioDialogVisible.value = false
    portfolioName.value = ''
  } catch (e) { ElMessage.error('保存失败') }
}

onMounted(() => search())
</script>

<style scoped>
.company-search { animation: fadeInUp 0.4s ease; max-width: var(--content-max-width); margin:0 auto; }
.page-header { margin-bottom:20px; }
.page-header h2 { display:flex; align-items:center; gap:10px; color:var(--text-primary); font-size:var(--font-size-2xl); }
.search-bar { padding:14px 20px; margin-bottom:16px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; }
.search-left { display:flex; align-items:center; gap:12px; flex-wrap:wrap; }
.bottom-bar { margin-top:16px; padding:12px 16px; display:flex; justify-content:flex-end; }
@media (max-width:768px) {
  .search-bar { flex-direction:column; padding:14px; }
  .search-bar .el-input { width:100%!important; }
  .page-header h2 { font-size:var(--font-size-lg); }
}
</style>
