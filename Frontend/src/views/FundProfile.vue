<template>
  <div class="fund-profile">
    <el-button @click="$router.back()" :icon="ArrowLeft" class="back-btn" round>返回</el-button>
    <div class="profile-header">
      <h2>{{ fund.name }}</h2>
      <span class="profile-code">{{ fund.code }}</span>
    </div>

    <div class="glass-card section-card">
      <div class="section-title"><el-icon :size="18"><Document /></el-icon>基本信息</div>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="类型">{{ fund.type }}</el-descriptions-item>
        <el-descriptions-item label="规模（亿元）">{{ fund.scale }}</el-descriptions-item>
        <el-descriptions-item label="成立日期">{{ fund.establishDate }}</el-descriptions-item>
        <el-descriptions-item label="公司">{{ fund.companyName }}</el-descriptions-item>
        <el-descriptions-item label="经理">{{ fund.managerName }}</el-descriptions-item>
        <el-descriptions-item label="风险等级">
          <el-tag :type="riskTagType" size="small" effect="dark">{{ fund.riskLevel }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="跟踪指数">{{ fund.benchmark }}</el-descriptions-item>
      </el-descriptions>
    </div>

    <div class="glass-card section-card" v-if="fund.tags.length">
      <div class="section-title"><el-icon :size="18"><CollectionTag /></el-icon>标签</div>
      <el-tag v-for="tag in fund.tags" :key="tag" class="fund-tag" effect="dark">{{ tag }}</el-tag>
    </div>

    <div class="glass-card section-card">
      <div class="section-title"><el-icon :size="18"><TrendCharts /></el-icon>业绩走势</div>
      <div id="navChart" class="chart-container" style="height:400px"></div>
    </div>

    <div class="glass-card section-card">
      <el-row :gutter="20">
        <el-col :xs="24" :md="12">
          <div class="section-title"><el-icon :size="18"><PieChart /></el-icon>行业配置</div>
          <div id="sectorChart" class="chart-container" style="height:300px"></div>
        </el-col>
        <el-col :xs="24" :md="12">
          <div class="section-title"><el-icon :size="18"><List /></el-icon>前十大重仓股</div>
          <el-table :data="fund.topHoldings" border size="small">
            <el-table-column prop="stockName" label="股票" />
            <el-table-column prop="ratio" label="占比(%)" width="90">
              <template #default="{ row }">
                <div class="ratio-bar">
                  <div class="ratio-fill" :style="{ width: row.ratio + '%' }"></div>
                  <span>{{ row.ratio }}</span>
                </div>
              </template>
            </el-table-column>
          </el-table>
        </el-col>
      </el-row>
    </div>

    <div class="glass-card section-card">
      <div class="section-title"><el-icon :size="18"><DataAnalysis /></el-icon>业绩归因</div>
      <p class="attribution-text">{{ fund.attributionText || '暂无数据' }}</p>
    </div>

    <div class="glass-card section-card">
      <div class="section-title"><el-icon :size="18"><Notification /></el-icon>基金公告</div>
      <el-table :data="fund.announcements" border size="small">
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="publishDate" label="日期" width="120" />
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { ArrowLeft, Document, CollectionTag, TrendCharts, PieChart, List, DataAnalysis, Notification } from '@element-plus/icons-vue'
import request from '../api/index'
import * as echarts from 'echarts'

const route = useRoute()
const fund = ref({ tags:[], navSeries:[], sectors:[], topHoldings:[], announcements:[] })

const riskTagType = computed(() => {
  const l = fund.value.riskLevel
  if (!l) return 'info'
  if (l.includes('高')||l.includes('R5')) return 'danger'
  if (l.includes('中高')||l.includes('R4')) return 'warning'
  if (l.includes('中')||l.includes('R3')) return ''
  return 'success'
})

onMounted(async () => {
  try {
    const res = await request.get(`/funds/${route.params.id}`)
    const d = res.data.data
    fund.value = {
      id:d.id, code:d.code, name:d.name, type:d.type,
      scale:d.scale, establishDate:d.establishDate,
      companyName:d.companyName, managerName:d.managerName,
      riskLevel:d.riskLevel, benchmark:d.benchmark,
      attributionText:d.attributionText,
      tags:d.tags||[], navSeries:d.navSeries||[],
      sectors:d.sectors||[], topHoldings:d.topHoldings||[],
      announcements:d.announcements||[]
    }
    await nextTick()
    renderCharts()
  } catch(e) { console.error('加载失败', e) }
})

function renderCharts() {
  const chartColors = ['#c62828','#d32f2f','#e53935','#ef5350','#d4a017','#e8b830','#2d6a4f','#40916c','#1b4332','#b71c1c']

  const navDom = document.getElementById('navChart')
  if (navDom && fund.value.navSeries.length) {
    const chart = echarts.init(navDom)
    chart.setOption({
      color:['#c62828'], backgroundColor:'transparent',
      xAxis:{ type:'category', data:fund.value.navSeries.map(n=>n.date),
        axisLine:{ lineStyle:{ color:'rgba(128,128,128,0.3)' } },
        axisTick:{ show:false }, axisLabel:{ color:'#857e7e', fontSize:11 } },
      yAxis:{ type:'value',
        splitLine:{ lineStyle:{ color:'rgba(128,128,128,0.10)', type:'dashed' } },
        axisLabel:{ color:'#857e7e', fontSize:11 } },
      series:[{ data:fund.value.navSeries.map(n=>n.unitNav), type:'line', smooth:true, symbol:'none',
        areaStyle:{ color:new echarts.graphic.LinearGradient(0,0,0,1,[
          { offset:0, color:'rgba(198,40,40,0.20)' },
          { offset:1, color:'rgba(198,40,40,0)' }
        ])},
        lineStyle:{ width:2.5, color:'#c62828' }, itemStyle:{ color:'#c62828' }
      }],
      tooltip:{ trigger:'axis', backgroundColor:'rgba(26,26,26,0.95)', borderColor:'rgba(255,255,255,0.08)', textStyle:{ color:'#e8e4e4', fontSize:12 } },
      grid:{ left:50, right:20, top:20, bottom:30 }
    })
  }

  const sectorDom = document.getElementById('sectorChart')
  if (sectorDom && fund.value.sectors.length) {
    const chart = echarts.init(sectorDom)
    chart.setOption({
      color:chartColors, backgroundColor:'transparent',
      series:[{ type:'pie', radius:['45%','72%'], center:['50%','52%'],
        data:fund.value.sectors.map(s=>({ name:s.sectorName, value:s.ratio })),
        label:{ fontSize:11, color:'#b0aaaa' },
        emphasis:{ itemStyle:{ shadowBlur:10, shadowOffsetX:0, shadowColor:'rgba(0,0,0,0.5)' } }
      }],
      tooltip:{ trigger:'item', backgroundColor:'rgba(26,26,26,0.95)', borderColor:'rgba(255,255,255,0.08)', textStyle:{ color:'#e8e4e4', fontSize:12 } }
    })
  }
}
</script>

<style scoped>
.fund-profile { animation: fadeInUp 0.5s ease; max-width: var(--content-max-width); margin:0 auto; }
.back-btn { margin-bottom: 16px; }
.profile-header { margin-bottom: 24px; }
.profile-header h2 { color: var(--text-primary); font-size: var(--font-size-2xl); margin-bottom:4px; }
.profile-code {
  color: var(--text-secondary); font-size: var(--font-size-sm);
  font-family: 'SF Mono','Menlo',monospace;
  background: var(--bg-input); padding:2px 10px; border-radius:var(--radius-sm);
}

.section-card { margin-bottom: 16px; padding: 20px; }
.section-title {
  display:flex; align-items:center; gap:8px;
  color: var(--text-primary); font-size: var(--font-size-md); font-weight:600; margin-bottom:16px;
}
.fund-tag { margin-right:8px; margin-bottom:4px; }
.chart-container { width:100%; }
.attribution-text { color: var(--text-regular); line-height:1.8; padding:4px 0; }

.ratio-bar { display:flex; align-items:center; gap:6px; position:relative; }
.ratio-fill {
  position:absolute; left:0; top:50%; transform:translateY(-50%);
  height:6px;
  background:linear-gradient(90deg, rgba(198,40,40,0.25), rgba(198,40,40,0.55));
  border-radius:var(--radius-full); z-index:0; max-width:80px;
}
.ratio-bar span { position:relative; z-index:1; font-weight:500; }

@media (max-width:768px) {
  .fund-profile { padding:0 2px; }
  .profile-header h2 { font-size:var(--font-size-lg); }
  .chart-container { height:260px!important; }
  .section-card { padding:14px; }
}
</style>
