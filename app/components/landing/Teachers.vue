<script setup lang="ts">
import type { IndexCollectionItem } from '@nuxt/content'

defineProps<{
  page: IndexCollectionItem
}>()
</script>

<template>
  <UPageSection
    :title="page.teachers.title"
    :description="page.teachers.description"
    :ui="{
      container: '!pt-0 gap-8 sm:gap-12',
      title: 'text-left text-xl sm:text-xl lg:text-2xl font-medium',
      description: 'text-left mt-2 text-sm sm:text-md lg:text-sm text-muted'
    }"
  >
    <UPageGrid>
      <UCard
        v-for="(mentor, index) in page.teachers.mentors"
        :key="index"
        :ui="{
          body: 'p-6',
          header: 'p-0',
          footer: 'p-0'
        }"
      >
        <template #header>
          <UUser
            :name="mentor.name"
            :description="mentor.role"
            :avatar="mentor.avatar"
            size="lg"
            class="mb-4"
          />
        </template>

        <p class="text-sm text-muted mb-4">
          {{ mentor.description }}
        </p>

        <div class="flex flex-wrap gap-2">
          <UBadge
            v-for="(specialty, idx) in mentor.specialties"
            :key="idx"
            color="primary"
            variant="soft"
            size="sm"
          >
            {{ specialty }}
          </UBadge>
        </div>
      </UCard>
    </UPageGrid>
  </UPageSection>
</template>

