import { describe, it, expect } from 'vitest'
import { toThousands, toPercent, formatDate } from '../format'

describe('工具函数格式化测试', () => {
  it('toThousands 应该格式化数字为千分位', () => {
    expect(toThousands(1234567.89)).toBe('1,234,567.89')
    expect(toThousands(1000)).toBe('1,000')
    expect(toThousands(null)).toBe('')
  })

  it('toPercent 应该转换为百分比字符串', () => {
    expect(toPercent(0.1234)).toBe('12.34%')
    expect(toPercent(0.05)).toBe('5.00%')
    expect(toPercent(null)).toBe('0.00%')
  })

  it('formatDate 应该格式化日期', () => {
    expect(formatDate('2026-06-30')).toBe('2026-06-30')
    expect(formatDate('')).toBe('')
  })
})