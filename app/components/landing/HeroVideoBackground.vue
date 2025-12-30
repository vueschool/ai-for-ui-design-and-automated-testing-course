<script setup lang="ts">
const props = defineProps<{
  src?: string
}>()

const videoSrc = props.src || '/hero-video-bg.mp4'
const CROSSFADE_DURATION = 0.5 // seconds

const video1Ref = ref<HTMLVideoElement>()
const video2Ref = ref<HTMLVideoElement>()
const duration = ref(0)
const isTransitioning = ref(false)
const activePlayer = ref(1)

// State for players
const player1State = reactive({ opacity: 1, zIndex: 2 })
const player2State = reactive({ opacity: 0, zIndex: 1 })

// Handle metadata load to get duration
const onLoadedMetadata = (e: Event) => {
  const video = e.target as HTMLVideoElement
  if (video.duration) {
    duration.value = video.duration
  }
}

// Watch time to trigger crossfade
const onTimeUpdate = (playerId: number) => {
  // Only process updates from the active player
  if (playerId !== activePlayer.value) return

  const activeVideo = activePlayer.value === 1 ? video1Ref.value : video2Ref.value
  const nextVideo = activePlayer.value === 1 ? video2Ref.value : video1Ref.value

  if (!activeVideo || !nextVideo || !duration.value || isTransitioning.value) return

  const timeRemaining = duration.value - activeVideo.currentTime

  // Start crossfade when we're within the crossfade window
  if (timeRemaining <= CROSSFADE_DURATION) {
    triggerCrossfade(nextVideo)
  }
}

onMounted(() => {
  if (video1Ref.value) {
    if (video1Ref.value.duration) {
      duration.value = video1Ref.value.duration
    }
    // Initialize state
    player1State.opacity = 1
    player1State.zIndex = 2
    player2State.opacity = 0
    player2State.zIndex = 1

    video1Ref.value.play().catch(e => console.error('Auto-play failed:', e))
  }
})

const triggerCrossfade = async (nextVideo: HTMLVideoElement) => {
  if (isTransitioning.value) return
  isTransitioning.value = true

  const nextPlayerId = activePlayer.value === 1 ? 2 : 1
  const currentPlayerState = activePlayer.value === 1 ? player1State : player2State
  const nextPlayerState = activePlayer.value === 1 ? player2State : player1State

  // Capture current video to pause it later
  const currentVideo = activePlayer.value === 1 ? video1Ref.value : video2Ref.value

  // 1. Prepare next video (still hidden)
  nextVideo.currentTime = 0

  // 2. Move next player to top, but keep it transparent initially
  // We keep current player underneath but visible
  nextPlayerState.zIndex = 2
  currentPlayerState.zIndex = 1

  // Ensure next player starts at 0 opacity
  nextPlayerState.opacity = 0

  try {
    // 3. Start playing next video
    await nextVideo.play()

    // 4. Fade in next video
    // Use requestAnimationFrame to ensure the browser has registered the play and initial opacity
    requestAnimationFrame(() => {
      nextPlayerState.opacity = 1
    })

    // 5. Update active player reference immediately so future time updates come from new player
    activePlayer.value = nextPlayerId

    // 6. Cleanup after transition
    setTimeout(() => {
      // Hide the old video (now covered)
      currentPlayerState.opacity = 0

      // Pause old video to save resources
      if (currentVideo) {
        currentVideo.pause()
      }

      isTransitioning.value = false
    }, CROSSFADE_DURATION * 1000 + 100) // Buffer
  } catch (err) {
    console.error('Video playback failed:', err)
    isTransitioning.value = false
  }
}
</script>

<template>
  <div class="absolute inset-0 pointer-events-none overflow-hidden bg-black">
    <Motion
      :initial="{ opacity: 0 }"
      :animate="{ opacity: 1 }"
      :transition="{ duration: 1.2, ease: 'easeOut' }"
      class="absolute inset-0"
    >
      <!-- Video Player 1 -->
      <video
        ref="video1Ref"
        muted
        playsinline
        class="absolute inset-0 w-full h-full object-cover transition-opacity duration-500 ease-linear"
        :style="{ opacity: player1State.opacity, zIndex: player1State.zIndex }"
        @loadedmetadata="onLoadedMetadata"
        @timeupdate="onTimeUpdate(1)"
      >
        <source
          :src="videoSrc"
          type="video/mp4"
        >
      </video>

      <!-- Video Player 2 -->
      <video
        ref="video2Ref"
        muted
        playsinline
        class="absolute inset-0 w-full h-full object-cover transition-opacity duration-500 ease-linear"
        :style="{ opacity: player2State.opacity, zIndex: player2State.zIndex }"
        @loadedmetadata="onLoadedMetadata"
        @timeupdate="onTimeUpdate(2)"
      >
        <source
          :src="videoSrc"
          type="video/mp4"
        >
      </video>

      <!-- Dark overlay -->
      <div class="absolute inset-0 bg-gradient-to-b from-black/60 via-black/40 to-black/70 z-10" />
    </Motion>
  </div>
</template>
