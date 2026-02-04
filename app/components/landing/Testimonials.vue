<script setup lang="ts">
import type { IndexCollectionItem } from '@nuxt/content'

defineProps<{
  page: IndexCollectionItem
}>()
</script>

<template>
  <section class="relative py-20 lg:py-32 overflow-hidden">
    <div class="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
      <UCarousel
        v-slot="{ item }"
        :items="page.testimonials"
        :autoplay="{ delay: 4000 }"
        loop
        dots
        :ui="{
          viewport: 'bg-elevated/50 rounded-2xl'
        }"
      >
        <UPageCTA
          :description="item.quote"
          variant="naked"
          class="rounded-none"
          :ui="{
            container: 'sm:py-12 lg:py-12 sm:gap-8',
            description: '!text-base text-balance before:content-[open-quote] before:text-5xl lg:before:text-7xl before:inline-block before:text-dimmed before:absolute before:-ml-6 lg:before:-ml-10 before:-mt-2 lg:before:-mt-4 after:content-[close-quote] after:text-5xl lg:after:text-7xl after:inline-block after:text-dimmed after:absolute after:mt-1 lg:after:mt-0 after:ml-1 lg:after:ml-2'
          }"
        >
          <UUser
            v-bind="item.author"
            size="xl"
            class="justify-center"
          />
        </UPageCTA>
      </UCarousel>
    </div>
  </section>
</template>
