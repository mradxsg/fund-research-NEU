/**
 * 格式化数字为千分位显示
 * @param {number} num
 * @returns {string}
 */
export function toThousands(num) {
  if (num == null) return ''
  const parts = num.toString().split('.')
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',')
  return parts.join('.')
}

/**
 * 百分比格式化（保留两位小数）
 * @param {number} value
 * @returns {string}
 */
export function toPercent(value) {
  if (value == null || isNaN(value)) return '0.00%'
  return (value * 100).toFixed(2) + '%'
}

/**
 * 日期格式转换：YYYY-MM-DD
 * @param {string|Date} date
 * @returns {string}
 */
export function formatDate(date) {
  if (!date) return ''
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}