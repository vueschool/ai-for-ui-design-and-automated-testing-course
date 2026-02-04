<script setup lang="ts">
import type { IndexCollectionItem } from '@nuxt/content'

defineProps<{
  page: IndexCollectionItem
}>()
</script>

<template>
  <section class="relative py-20 lg:py-32 overflow-hidden">
    <div class="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
      <div class="flex flex-col items-center text-center">
        <h2 class="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4">
          {{ page.cta.title }}
        </h2>
        <p class="text-lg text-[#CCCCCC] max-w-2xl mb-8">
          {{ page.cta.description }}
        </p>

        <div class="flex flex-col sm:flex-row gap-4 justify-center items-center w-full sm:w-auto">
          <UButton
            v-for="(link, index) in page.cta.links"
            :key="index"
            v-bind="link"
            size="xl"
            class="w-full sm:w-auto px-8 py-3"
          />
        </div>
      </div>
    </div>
  </section>
</template>
