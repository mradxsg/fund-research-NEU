<template>
  <canvas ref="canvasRef" id="particle-canvas" data-no-transition></canvas>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const canvasRef = ref(null)
let animationId = null
let particles = []
let mouse = { x: -9999, y: -9999 }

const CONFIG = {
  particleCount: 90,
  particleColor: 'rgba(198, 40, 40, 0.40)',
  particleColorAlt: 'rgba(200, 140, 30, 0.30)',
  lineColor: 'rgba(198, 40, 40, 0.10)',
  lineColorAlt: 'rgba(200, 140, 30, 0.06)',
  particleRadius: 1.5,
  particleRadiusLarge: 2.6,
  maxDistance: 155,
  mouseRadius: 130,
  speed: 0.30
}

function createParticles(width, height) {
  const count = Math.floor(CONFIG.particleCount * (width / 1440))
  particles = Array.from({ length: count }, (_, i) => ({
    x: Math.random() * width,
    y: Math.random() * height,
    vx: (Math.random() - 0.5) * CONFIG.speed,
    vy: (Math.random() - 0.5) * CONFIG.speed,
    radius: Math.random() > 0.12 ? CONFIG.particleRadius : CONFIG.particleRadiusLarge,
    isAlt: i % 5 === 0
  }))
}

function drawParticle(ctx, p) {
  ctx.beginPath()
  ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2)
  ctx.fillStyle = p.isAlt ? CONFIG.particleColorAlt : CONFIG.particleColor
  ctx.fill()
}

function drawLine(ctx, a, b, distance) {
  const opacity = 1 - distance / CONFIG.maxDistance
  const baseColor = a.isAlt && b.isAlt
    ? CONFIG.lineColorAlt
    : CONFIG.lineColor
  // Extract the alpha value and replace with calculated opacity
  const colorParts = baseColor.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)/)
  if (!colorParts) return
  ctx.beginPath()
  ctx.moveTo(a.x, a.y)
  ctx.lineTo(b.x, b.y)
  ctx.strokeStyle = `rgba(${colorParts[1]}, ${colorParts[2]}, ${colorParts[3]}, ${(parseFloat(colorParts[4]) * opacity).toFixed(3)})`
  ctx.lineWidth = 0.5
  ctx.stroke()
}

function render(ctx, width, height) {
  ctx.clearRect(0, 0, width, height)

  for (let i = 0; i < particles.length; i++) {
    const p = particles[i]

    // Move
    p.x += p.vx
    p.y += p.vy

    // Wrap around edges
    if (p.x < -20) p.x = width + 20
    if (p.x > width + 20) p.x = -20
    if (p.y < -20) p.y = height + 20
    if (p.y > height + 20) p.y = -20

    // Mouse interaction — gentle attraction
    const dxM = p.x - mouse.x
    const dyM = p.y - mouse.y
    const distM = Math.sqrt(dxM * dxM + dyM * dyM)
    if (distM < CONFIG.mouseRadius && distM > 0) {
      const force = (CONFIG.mouseRadius - distM) / CONFIG.mouseRadius
      p.vx += (dxM / distM) * force * 0.03
      p.vy += (dyM / distM) * force * 0.03
    }

    // Dampen
    p.vx *= 0.999
    p.vy *= 0.999

    // Speed clamp
    const speed = Math.sqrt(p.vx * p.vx + p.vy * p.vy)
    if (speed > CONFIG.speed * 1.5) {
      p.vx = (p.vx / speed) * CONFIG.speed * 1.5
      p.vy = (p.vy / speed) * CONFIG.speed * 1.5
    }

    drawParticle(ctx, p)

    // Connections
    for (let j = i + 1; j < particles.length; j++) {
      const q = particles[j]
      const dx = p.x - q.x
      const dy = p.y - q.y
      const dist = Math.sqrt(dx * dx + dy * dy)
      if (dist < CONFIG.maxDistance) {
        drawLine(ctx, p, q, dist)
      }
    }
  }
}

function loop(ctx, width, height) {
  render(ctx, width, height)
  animationId = requestAnimationFrame(() => loop(ctx, width, height))
}

function resize() {
  if (!canvasRef.value) return
  const canvas = canvasRef.value
  const dpr = Math.min(window.devicePixelRatio || 1, 2)
  canvas.width = window.innerWidth * dpr
  canvas.height = window.innerHeight * dpr
  canvas.style.width = window.innerWidth + 'px'
  canvas.style.height = window.innerHeight + 'px'

  const ctx = canvas.getContext('2d')
  ctx.scale(dpr, dpr)
  createParticles(window.innerWidth, window.innerHeight)
}

function onMouseMove(e) {
  mouse.x = e.clientX
  mouse.y = e.clientY
}
function onMouseLeave() {
  mouse.x = -9999
  mouse.y = -9999
}

onMounted(() => {
  const canvas = canvasRef.value
  if (!canvas) return
  const ctx = canvas.getContext('2d')
  resize()
  loop(ctx, canvas.width, canvas.height)

  window.addEventListener('resize', resize)
  window.addEventListener('mousemove', onMouseMove, { passive: true })
  window.addEventListener('mouseleave', onMouseLeave)
})

onUnmounted(() => {
  if (animationId) cancelAnimationFrame(animationId)
  window.removeEventListener('resize', resize)
  window.removeEventListener('mousemove', onMouseMove)
  window.removeEventListener('mouseleave', onMouseLeave)
})
</script>
