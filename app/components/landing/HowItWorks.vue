<script setup lang="ts">
import type { IndexCollectionItem } from '@nuxt/content'

defineProps<{
  page: IndexCollectionItem
}>()
</script>

<template>
  <UPageSection
    :title="page.howItWorks.title"
    :description="page.howItWorks.description"
    :ui="{
      container: '!pt-0 gap-8 sm:gap-12',
      title: 'text-left text-xl sm:text-xl lg:text-2xl font-medium',
      description: 'text-left mt-2 text-sm sm:text-md lg:text-sm text-muted'
    }"
  >
    <UPageGrid>
      <UPageFeature
        v-for="(step, index) in page.howItWorks.steps"
        :key="index"
        :title="step.title"
        :description="step.description"
        :icon="step.icon"
        orientation="vertical"
        :ui="{
          root: 'text-center',
          title: 'text-center',
          description: 'text-center'
        }"
      />
    </UPageGrid>
  </UPageSection>
</template>
