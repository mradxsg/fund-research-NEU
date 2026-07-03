import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      include: ['src/utils/**', 'src/api/**'],  // 只收集这些核心模块
      reporter: ['text', 'html']
    }
  }
})