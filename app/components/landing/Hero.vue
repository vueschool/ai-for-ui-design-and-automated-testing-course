<script setup lang="ts">
import type { IndexCollectionItem } from '@nuxt/content'

defineProps<{
  page: IndexCollectionItem
}>()

const subjectOptions = [
  { label: 'Mathematics', value: 'mathematics' },
  { label: 'Physics', value: 'physics' },
  { label: 'Chemistry', value: 'chemistry' },
  { label: 'Biology', value: 'biology' },
  { label: 'Languages', value: 'languages' },
  { label: 'Music', value: 'music' },
  { label: 'Art', value: 'art' }
]

const levelOptions = [
  { label: 'Beginner', value: 'beginner' },
  { label: 'Intermediate', value: 'intermediate' },
  { label: 'Advanced', value: 'advanced' },
  { label: 'Expert', value: 'expert' }
]

const selectedSubject = ref<string>()
const selectedLevel = ref<string>()

const avatars = [
  { src: '/hero/random-1.avif', alt: 'Student 1' },
  { src: '/hero/random-2.avif', alt: 'Student 2' },
  { src: '/hero/random-3.avif', alt: 'Student 3' },
  { src: '/hero/random-4.avif', alt: 'Student 4' },
  { src: '/hero/random-5.avif', alt: 'Student 5' }
]
</script>

<template>
  <section class="relative min-h-[90vh] lg:min-h-screen overflow-hidden">
    <!-- Video Background -->
    <LandingHeroVideoBackground />

    <!-- Main Content -->
    <div class="relative z-20 max-w-7xl mx-auto px-6 lg:px-8 pt-16 lg:pt-0 lg:min-h-screen lg:flex lg:flex-col lg:justify-center">
      <div class="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
        <!-- Left Column - Text Content -->
        <div class="flex flex-col gap-6">
          <!-- Title -->
          <Motion
            :initial="{ opacity: 0, y: 30 }"
            :animate="{ opacity: 1, y: 0 }"
            :transition="{ duration: 0.6, delay: 0.1 }"
          >
            <h1 class="text-4xl sm:text-5xl lg:text-6xl text-white leading-[1.1] font-serif font-bold">
              Learn from Expert Teachers,
              <br>
              Anytime, Anywhere
            </h1>
          </Motion>

          <!-- Description -->
          <Motion
            :initial="{ opacity: 0, y: 30 }"
            :animate="{ opacity: 1, y: 0 }"
            :transition="{ duration: 0.6, delay: 0.3 }"
          >
            <p class="text-muted text-base sm:text-lg max-w-lg">
              {{ page.description }}
            </p>
          </Motion>

          <!-- CTA Buttons -->
          <Motion
            :initial="{ opacity: 0, y: 30 }"
            :animate="{ opacity: 1, y: 0 }"
            :transition="{ duration: 0.6, delay: 0.5 }"
          >
            <div
              v-if="page.hero?.links"
              class="flex flex-wrap gap-4"
            >
              <UButton
                v-for="(link, index) in page.hero.links"
                :key="index"
                v-bind="link"
                size="xl"
                :class="index === 0 ? 'px-8 py-3' : 'px-8 py-3'"
              />
            </div>
          </Motion>

          <!-- Search Bar -->
          <Motion
            :initial="{ opacity: 0, y: 30 }"
            :animate="{ opacity: 1, y: 0 }"
            :transition="{ duration: 0.6, delay: 0.7 }"
          >
            <div class="mt-2 p-2 rounded-xl glass-strong border border-primary/30 flex flex-col sm:flex-row gap-2">
              <USelect
                v-model="selectedSubject"
                placeholder="Subject"
                :items="subjectOptions"
                size="lg"
                variant="none"
                class="flex-1"
                :ui="{
                  base: 'bg-[#1a1f24] rounded-lg border border-white/10',
                  placeholder: 'text-white/50'
                }"
              />
              <USelect
                v-model="selectedLevel"
                placeholder="Level"
                :items="levelOptions"
                size="lg"
                variant="none"
                class="flex-1"
                :ui="{
                  base: 'bg-[#1a1f24] rounded-lg border border-white/10',
                  placeholder: 'text-white/50'
                }"
              />
              <UButton
                icon="i-lucide-search"
                size="xl"
                class="px-5"
                aria-label="Search"
              />
            </div>
          </Motion>
        </div>

        <!-- Right Column - Teacher Image -->
        <Motion
          :initial="{ opacity: 0, x: 50 }"
          :animate="{ opacity: 1, x: 0 }"
          :transition="{ duration: 0.8, delay: 0.4 }"
          class="hidden lg:block"
        >
          <!-- Video call frame with glassmorphism -->
          <div class="p-2 rounded-2xl bg-gradient-to-br from-white/10 to-white/5 backdrop-blur-sm border border-white/20 shadow-2xl shadow-primary/20">
            <VideoReveal
              src="/hero-video-bg.mp4"
              contained
              class="rounded-xl"
            >
              <template #trigger>
                <button
                  type="button"
                  class="relative cursor-pointer group block w-full text-left rounded-xl overflow-hidden"
                  aria-label="Play video"
                >
                  <NuxtImg
                    src="/teachers.png"
                    alt="Expert Teachers"
                    width="600"
                    height="450"
                    class="w-full h-auto object-cover transition-transform duration-500 group-hover:scale-105"
                  />
                  <!-- Play button overlay -->
                  <div class="absolute inset-0 flex items-center justify-center">
                    <div class="play-button">
                      <UIcon
                        name="i-lucide-play"
                        class="w-8 h-8 ml-1 text-white"
                      />
                    </div>
                  </div>
                </button>
              </template>
            </VideoReveal>
          </div>
        </Motion>
      </div>

      <!-- Social Proof Section -->
      <Motion
        :initial="{ opacity: 0, y: 30 }"
        :animate="{ opacity: 1, y: 0 }"
        :transition="{ duration: 0.6, delay: 0.9 }"
      >
        <div class="mt-12 lg:mt-16 p-6 rounded-2xl bg-gradient-to-r from-[#1a1a1a]/90 via-[#2a1a15]/80 to-[#1a1a1a]/90 backdrop-blur-md border border-primary/20">
          <div class="flex flex-col sm:flex-row items-center justify-between gap-6">
            <!-- Stars with orange-gold gradient -->
            <div class="flex gap-1">
              <svg
                v-for="i in 5"
                :key="i"
                class="w-10 h-10 sm:w-14 sm:h-14 drop-shadow-[0_0_12px_rgba(246,165,47,0.7)]"
                viewBox="0 0 24 24"
                fill="none"
              >
                <defs>
                  <linearGradient
                    :id="`star-grad-${i}`"
                    x1="0%"
                    y1="0%"
                    x2="100%"
                    y2="100%"
                  >
                    <stop
                      offset="0%"
                      stop-color="#FFCC4D"
                    />
                    <stop
                      offset="50%"
                      stop-color="#F6A52F"
                    />
                    <stop
                      offset="100%"
                      stop-color="#E88B26"
                    />
                  </linearGradient>
                </defs>
                <path
                  :fill="`url(#star-grad-${i})`"
                  d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                />
              </svg>
            </div>

            <!-- Avatars and Trust Text -->
            <div class="flex items-center gap-4">
              <div class="flex -space-x-3">
                <div
                  v-for="(avatar, index) in avatars"
                  :key="index"
                  class="relative"
                  :style="{ zIndex: avatars.length - index }"
                >
                  <NuxtImg
                    :src="avatar.src"
                    :alt="avatar.alt"
                    width="44"
                    height="44"
                    class="w-11 h-11 rounded-full border-2 border-[#1a1f24] object-cover"
                  />
                </div>
              </div>
              <div class="text-white">
                <p class="font-medium text-lg">
                  Trusted By
                </p>
                <p class="text-xl font-bold text-white">
                  10k+ Students
                </p>
              </div>
            </div>
          </div>
        </div>
      </Motion>
    </div>
  </section>
</template>

<style scoped>
.play-button {
  width: 5rem;
  height: 5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgba(246, 81, 47, 0.9) 0%, rgba(231, 20, 7, 0.9) 100%);
  border-radius: 50%;
  box-shadow:
    0 0 0 0 rgba(246, 81, 47, 0.4),
    0 8px 32px rgba(0, 0, 0, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.2);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
  animation: pulse-glow 2s ease-in-out infinite;
}

.group:hover .play-button {
  transform: scale(1.15);
  box-shadow:
    0 0 0 12px rgba(246, 81, 47, 0.15),
    0 12px 40px rgba(246, 81, 47, 0.4),
    inset 0 1px 0 rgba(255, 255, 255, 0.3);
}

@keyframes pulse-glow {
  0%, 100% {
    box-shadow:
      0 0 0 0 rgba(246, 81, 47, 0.4),
      0 8px 32px rgba(0, 0, 0, 0.3),
      inset 0 1px 0 rgba(255, 255, 255, 0.2);
  }
  50% {
    box-shadow:
      0 0 0 8px rgba(246, 81, 47, 0.1),
      0 8px 32px rgba(0, 0, 0, 0.3),
      inset 0 1px 0 rgba(255, 255, 255, 0.2);
  }
}
</style>
