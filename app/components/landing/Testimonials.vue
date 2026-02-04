<script setup lang="ts">
import { Motion, AnimatePresence } from 'motion-v'
import type { IndexCollectionItem } from '@nuxt/content'

interface Props {
  page: IndexCollectionItem
  autoplay?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  autoplay: false
})

const testimonials = computed(() => {
  return props.page.testimonials?.map((t: any) => ({
    quote: t.quote,
    name: t.author.name,
    designation: t.author.description,
    src: t.author.avatar.src,
    // generate stable random rotation for each item
    rotation: Math.floor(Math.random() * 21) - 10
  })) || []
})

const active = ref(0)

const handleNext = () => {
  active.value = (active.value + 1) % testimonials.value.length
}

const handlePrev = () => {
  active.value = (active.value - 1 + testimonials.value.length) % testimonials.value.length
}

const isActive = (index: number) => {
  return index === active.value
}

// Auto-play logic
let intervalId: any
onMounted(() => {
  if (props.autoplay) {
    intervalId = setInterval(handleNext, 5000)
  }
})

onUnmounted(() => {
  if (intervalId) clearInterval(intervalId)
})

const splitQuote = (quote: string) => {
  return quote.split(" ")
}
</script>

<template>
  <div v-if="testimonials.length" class="max-w-sm md:max-w-4xl mx-auto px-4 md:px-8 lg:px-12 py-20">
    <div class="relative grid grid-cols-1 md:grid-cols-2 gap-20">
      <div>
        <div class="relative h-80 w-full">
          <AnimatePresence>
            <Motion
              v-for="(testimonial, index) in testimonials"
              :key="testimonial.src"
              :initial="{
                opacity: 0,
                scale: 0.9,
                z: -100,
                rotate: testimonial.rotation,
              }"
              :animate="{
                opacity: isActive(index) ? 1 : 0.7,
                scale: isActive(index) ? 1 : 0.95,
                z: isActive(index) ? 0 : -100,
                rotate: isActive(index) ? 0 : testimonial.rotation,
                zIndex: isActive(index)
                  ? 999
                  : testimonials.length + 2 - index,
                y: isActive(index) ? [0, -80, 0] : 0,
              }"
              :exit="{
                opacity: 0,
                scale: 0.9,
                z: 100,
                rotate: testimonial.rotation,
              }"
              :transition="{
                duration: 0.4,
                ease: 'easeInOut',
              }"
              class="absolute inset-0 origin-bottom"
            >
              <NuxtImg
                :src="testimonial.src"
                :alt="testimonial.name"
                sizes="sm:100vw md:500px"
                draggable="false"
                class="h-full w-full rounded-3xl object-cover object-center"
              />
            </Motion>
          </AnimatePresence>
        </div>
      </div>
      <div class="flex flex-col justify-center gap-8 py-4">
        <AnimatePresence mode="wait">
          <Motion
            :key="active"
            :initial="{
              y: 20,
              opacity: 0,
            }"
            :animate="{
              y: 0,
              opacity: 1,
            }"
            :exit="{
              y: -20,
              opacity: 0,
            }"
            :transition="{
              duration: 0.2,
              ease: 'easeInOut',
            }"
          >
            <h3 class="text-2xl font-bold text-[var(--ui-text)] dark:text-white">
              {{ testimonials[active]?.name }}
            </h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">
              {{ testimonials[active]?.designation }}
            </p>
            <p class="text-lg text-gray-500 dark:text-gray-300 mt-8">
              <Motion
                v-for="(word, index) in splitQuote(testimonials[active]?.quote || '')"
                :key="index"
                tag="span"
                :initial="{
                  filter: 'blur(10px)',
                  opacity: 0,
                  y: 5,
                }"
                :animate="{
                  filter: 'blur(0px)',
                  opacity: 1,
                  y: 0,
                }"
                :transition="{
                  duration: 0.2,
                  ease: 'easeInOut',
                  delay: 0.02 * index,
                }"
                class="inline-block"
              >
                {{ word }}&nbsp;
              </Motion>
            </p>
          </Motion>
        </AnimatePresence>
        <div class="flex gap-4">
          <button
            @click="handlePrev"
            class="h-7 w-7 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center group/button hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
          >
            <UIcon
              name="i-lucide-arrow-left"
              class="h-5 w-5 text-black dark:text-white group-hover/button:rotate-12 transition-transform duration-300"
            />
          </button>
          <button
            @click="handleNext"
            class="h-7 w-7 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center group/button hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
          >
            <UIcon
              name="i-lucide-arrow-right"
              class="h-5 w-5 text-black dark:text-white group-hover/button:-rotate-12 transition-transform duration-300"
            />
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
