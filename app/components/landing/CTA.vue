<script setup lang="ts">
import { Motion } from 'motion-v'
import type { IndexCollectionItem } from '@nuxt/content'

defineProps<{
  page: IndexCollectionItem
}>()
</script>

<template>
  <section
    data-testid="cta"
    class="relative py-20 lg:py-32 overflow-hidden"
  >
    <div class="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
      <div class="flex flex-col items-center text-center">
        <Motion
          :initial="{ opacity: 0, y: 20 }"
          :in-view="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.5, ease: 'easeOut' }"
          :in-view-options="{ once: true, amount: 0.5 }"
        >
          <h2
          data-testid="cta-title"
          class="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4"
        >
            {{ page.cta.title }}
          </h2>
        </Motion>
        <Motion
          :initial="{ opacity: 0, y: 20 }"
          :in-view="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.5, ease: 'easeOut', delay: 0.1 }"
          :in-view-options="{ once: true, amount: 0.5 }"
        >
          <p class="text-lg text-[#CCCCCC] max-w-2xl mb-8">
            {{ page.cta.description }}
          </p>
        </Motion>

        <Motion
          :initial="{ opacity: 0, y: 20 }"
          :in-view="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.5, ease: 'easeOut', delay: 0.2 }"
          :in-view-options="{ once: true, amount: 0.5 }"
          class="flex flex-col sm:flex-row gap-4 justify-center items-center w-full sm:w-auto"
        >
          <UButton
            v-for="(link, index) in page.cta.links"
            :key="index"
            :data-testid="`cta-${link.label.toLowerCase().replace(/\s/g, '-')}`"
            v-bind="link"
            size="xl"
            class="w-full sm:w-auto px-8 py-3"
          />
        </Motion>
      </div>
    </div>
  </section>
</template>
