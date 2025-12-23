<script setup lang="ts">
import type { IndexCollectionItem } from '@nuxt/content'

defineProps<{
  page: IndexCollectionItem
}>()
</script>

<template>
  <UPageSection
    :ui="{
      container: 'px-0 !pt-0'
    }"
  >
    <UPageCTA
      :title="page.cta.title"
      :description="page.cta.description"
      :ui="{
        container: 'sm:py-12 lg:py-16 sm:gap-8',
        title: 'text-2xl sm:text-3xl lg:text-4xl',
        description: 'text-base sm:text-lg'
      }"
    >
      <template #links>
        <div class="flex flex-col sm:flex-row gap-4 justify-center items-center">
          <UButton
            v-for="(link, index) in page.cta.links"
            :key="index"
            v-bind="link"
            size="lg"
            class="w-full sm:w-auto"
          />
        </div>
      </template>
    </UPageCTA>
  </UPageSection>
</template>

