import { describe, it, expect } from 'vitest'
import request from '../../api/index'  // 改用我们封装的 request

describe('基金研究子系统 API 测试', () => {
  it('GET /api/funds 应返回 200 并包含 records', async () => {
    const res = await request.get('/funds', {
      params: { keyword: '华夏', page: 0 }
    })
    expect(res.status).toBe(200)
    expect(res.data.code).toBe(200)
    expect(res.data.data.records).toBeInstanceOf(Array)
    expect(res.data.data.total).toBeGreaterThan(0)
  })

  it('POST /api/user/login 应返回用户ID和用户名', async () => {
    const res = await request.post('/user/login', {
      username: 'test01',
      password: '123456'
    })
    expect(res.data.code).toBe(200)
    expect(res.data.data.userId).toBe(1)
    expect(res.data.data.username).toBe('test01')
  })

  it('GET /api/tags?dimension=fund 应返回树形数据', async () => {
    const res = await request.get('/tags', {
      params: { dimension: 'fund' }
    })
    expect(res.status).toBe(200)
    expect(res.data.code).toBe(200)
    expect(res.data.data).toBeInstanceOf(Array)
    expect(res.data.data.length).toBeGreaterThan(0)
  })

  it('GET /api/funds/1 应返回完整画像数据', async () => {
    const res = await request.get('/funds/1')
    expect(res.data.code).toBe(200)
    expect(res.data.data.name).toBeDefined()
    expect(res.data.data.navSeries).toBeInstanceOf(Array)
  })
})