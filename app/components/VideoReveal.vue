<script setup lang="ts">
const props = defineProps<{
  src: string
  poster?: string
  contained?: boolean
}>()

const isOpen = ref(false)
const isRevealing = ref(false)
const videoRef = ref<HTMLVideoElement>()
const containerRef = ref<HTMLElement>()
const clipPath = ref('circle(0px at 50% 50%)')
const clickOrigin = ref({ x: 0, y: 0 })

const openVideo = (event: MouseEvent) => {
  if (props.contained && containerRef.value) {
    // Calculate position relative to container
    const rect = containerRef.value.getBoundingClientRect()
    const x = event.clientX - rect.left
    const y = event.clientY - rect.top
    clickOrigin.value = { x, y }

    // Calculate radius to cover container
    const endRadius = Math.hypot(
      Math.max(x, rect.width - x),
      Math.max(y, rect.height - y)
    )

    clipPath.value = `circle(0px at ${x}px ${y}px)`
    isOpen.value = true
    isRevealing.value = true

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        clipPath.value = `circle(${endRadius}px at ${x}px ${y}px)`
        setTimeout(() => {
          isRevealing.value = false
          videoRef.value?.play()
        }, 400)
      })
    })
  } else {
    // Fullscreen mode
    const x = event.clientX
    const y = event.clientY
    clickOrigin.value = { x, y }

    const endRadius = Math.hypot(
      Math.max(x, window.innerWidth - x),
      Math.max(y, window.innerHeight - y)
    )

    clipPath.value = `circle(0px at ${x}px ${y}px)`
    isOpen.value = true
    isRevealing.value = true

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        clipPath.value = `circle(${endRadius}px at ${x}px ${y}px)`
        setTimeout(() => {
          isRevealing.value = false
          videoRef.value?.play()
        }, 400)
      })
    })
  }
}

const closeVideo = (event?: MouseEvent) => {
  videoRef.value?.pause()

  if (props.contained && containerRef.value) {
    const rect = containerRef.value.getBoundingClientRect()
    const x = event ? event.clientX - rect.left : clickOrigin.value.x
    const y = event ? event.clientY - rect.top : clickOrigin.value.y

    clipPath.value = `circle(0px at ${x}px ${y}px)`
  } else {
    const x = event?.clientX ?? clickOrigin.value.x
    const y = event?.clientY ?? clickOrigin.value.y
    clipPath.value = `circle(0px at ${x}px ${y}px)`
  }

  isRevealing.value = true

  setTimeout(() => {
    isOpen.value = false
    isRevealing.value = false
    if (videoRef.value) {
      videoRef.value.currentTime = 0
    }
  }, 600)
}

// Close on escape key
const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && isOpen.value) {
    closeVideo()
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <div
    ref="containerRef"
    class="video-reveal"
    :class="{ 'video-reveal--contained': contained }"
  >
    <!-- Trigger slot -->
    <div @click="openVideo">
      <slot name="trigger" />
    </div>

    <!-- Contained mode: video inside parent -->
    <div
      v-if="contained && isOpen"
      class="video-reveal-contained-overlay"
      :style="{ clipPath }"
    >
      <video
        ref="videoRef"
        class="video-reveal-contained-player"
        :src="src"
        :poster="poster"
        playsinline
        controls
      />

      <!-- Close button -->
      <button
        class="video-reveal-close video-reveal-close--contained"
        :class="{ 'opacity-0': isRevealing }"
        aria-label="Close video"
        @click="closeVideo"
      >
        <UIcon
          name="i-lucide-x"
          class="w-5 h-5"
        />
      </button>
    </div>

    <!-- Fullscreen mode: teleport to body -->
    <Teleport
      v-if="!contained"
      to="body"
    >
      <div
        v-if="isOpen"
        class="video-reveal-overlay"
        :style="{ clipPath }"
      >
        <!-- Backdrop - click to close -->
        <div
          class="video-reveal-backdrop"
          @click="closeVideo"
        />

        <!-- Video container with margin -->
        <div class="video-reveal-container">
          <video
            ref="videoRef"
            class="video-reveal-player"
            :src="src"
            :poster="poster"
            playsinline
            controls
          />
        </div>

        <!-- Close button -->
        <button
          class="video-reveal-close"
          :class="{ 'opacity-0': isRevealing }"
          aria-label="Close video"
          @click="closeVideo"
        >
          <UIcon
            name="i-lucide-x"
            class="w-6 h-6"
          />
        </button>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
/* Base container */
.video-reveal {
  position: relative;
}

.video-reveal--contained {
  position: relative;
}

/* Contained mode styles */
.video-reveal-contained-overlay {
  position: absolute;
  inset: 0;
  z-index: 10;
  background: #000;
  border-radius: inherit;
  overflow: hidden;
  transition: clip-path 0.6s cubic-bezier(0.76, 0.32, 0.29, 0.99);
}

.video-reveal-contained-player {
  width: 100%;
  height: 100%;
  object-fit: cover;
  background: #000;
}

.video-reveal-close--contained {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  width: 2.25rem;
  height: 2.25rem;
}

/* Fullscreen mode styles */
.video-reveal-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  transition: clip-path 0.6s cubic-bezier(0.76, 0.32, 0.29, 0.99);
}

.video-reveal-backdrop {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

.video-reveal-container {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 1400px;
  max-height: calc(100vh - 4rem);
  aspect-ratio: 16 / 9;
  border-radius: 1rem;
  overflow: hidden;
  box-shadow:
    0 25px 50px -12px rgba(0, 0, 0, 0.5),
    0 0 0 1px rgba(255, 255, 255, 0.1);
  background: #000;
}

.video-reveal-player {
  width: 100%;
  height: 100%;
  object-fit: contain;
  background: #000;
}

.video-reveal-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  width: 3rem;
  height: 3rem;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 50%;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease, opacity 0.3s ease 0.4s;
  z-index: 10;
}

.video-reveal-close:hover {
  background: rgba(0, 0, 0, 0.8);
  border-color: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
}

.video-reveal-close.opacity-0 {
  opacity: 0;
  transition: opacity 0s;
}

@media (max-width: 768px) {
  .video-reveal-overlay {
    padding: 1rem;
  }

  .video-reveal-container {
    border-radius: 0.75rem;
  }

  .video-reveal-close {
    top: 0.5rem;
    right: 0.5rem;
    width: 2.5rem;
    height: 2.5rem;
  }
}
</style>
