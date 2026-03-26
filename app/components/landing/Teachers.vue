<script setup lang="ts">
import { Motion } from 'motion-v'
import type { IndexCollectionItem } from '@nuxt/content'

defineProps<{
  page: IndexCollectionItem
}>()

const MAX_TEACHERS_SHOWN = 4

// Assign specific blobs to match the creative vibe
const teacherBlobs = [
  'amoeba_cross', // Sarah - More organic/complex
  'tri_lobe', // James - Distinctive but organic
  'star_puffy', // Aisha
  'slug_floating' // Michael
] as const

const getBlobForTeacher = (index: number): (typeof teacherBlobs)[number] => {
  const i = index % teacherBlobs.length
  return teacherBlobs[i]!
}
</script>

<template>
  <section
    data-testid="teachers"
    class="relative py-20 lg:py-32 overflow-hidden"
  >
    <div class="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
      <div class="mb-12">
        <Motion
          :initial="{ opacity: 0, y: 20 }"
          :in-view="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.5, ease: 'easeOut' }"
          :in-view-options="{ once: true, amount: 0.5 }"
        >
          <h2
            data-testid="teachers-title"
            class="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4"
          >
            {{ page.teachers.title }}
          </h2>
        </Motion>
        <Motion
          :initial="{ opacity: 0, y: 20 }"
          :in-view="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.5, ease: 'easeOut', delay: 0.1 }"
          :in-view-options="{ once: true, amount: 0.5 }"
        >
          <p class="text-lg text-[#CCCCCC]">
            {{ page.teachers.description }}
          </p>
        </Motion>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <TeacherCard
          v-for="(mentor, index) in page.teachers.mentors.slice(0, MAX_TEACHERS_SHOWN)"
          :key="index"
          :mentor
          :blob-name="getBlobForTeacher(index)"
          :index
          :test-id="`teacher-card-${index}`"
        />
      </div>
    </div>
  </section>
</template>
