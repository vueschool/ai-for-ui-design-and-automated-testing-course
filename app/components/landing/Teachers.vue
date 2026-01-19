<script setup lang="ts">
import type { IndexCollectionItem } from '@nuxt/content'

defineProps<{
  page: IndexCollectionItem
}>()

// Assign specific blobs to match the creative vibe
const teacherBlobs = [
  'amoeba_cross',  // Sarah - More organic/complex
  'tri_lobe',      // James - Distinctive but organic
  'star_puffy',    // Aisha
  'slug_floating'  // Michael
]

const getBlobForTeacher = (index: number) => {
  return teacherBlobs[index % teacherBlobs.length]
}
</script>

<template>
  <UPageSection
    :title="page.teachers.title"
    :description="page.teachers.description"
    :ui="{
      container: '!pt-0 gap-8 sm:gap-12',
      title: 'text-left text-xl sm:text-xl lg:text-2xl font-medium font-heading',
      description: 'text-left mt-2 text-sm sm:text-md lg:text-sm text-muted font-sans'
    }"
  >
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div
        v-for="(mentor, index) in page.teachers.mentors"
        :key="index"
        class="group relative flex flex-col items-center p-6 rounded-3xl glass transition-all duration-300 hover:-translate-y-1 hover:bg-white/[0.02]"
      >
        <!-- Gradient Border via pseudo-element -->
        <div class="absolute inset-0 rounded-3xl border border-white/5 group-hover:border-primary-500/30 transition-colors duration-300 pointer-events-none" />

        <!-- Avatar & Blob Container -->
        <div class="relative mb-6 mt-2 flex items-center justify-center">
          <!-- Animated Blob Background -->
          <div class="absolute w-56 h-56 flex items-center justify-center pointer-events-none">
             <AppBlob
              :name="getBlobForTeacher(index)"
              class="w-full h-full opacity-100 group-hover:scale-110 group-hover:rotate-12 transition-all duration-700 ease-in-out"
            />
          </div>
          
          <!-- Avatar Image with Glassmorphism Ring -->
          <div class="relative z-10 w-32 h-32 rounded-full p-1 bg-white/10 backdrop-blur-sm ring-1 ring-white/20 group-hover:ring-primary-500/40 group-hover:bg-white/20 transition-all duration-300">
             <div class="w-full h-full rounded-full overflow-hidden border-2 border-white/10 group-hover:border-transparent transition-colors duration-300 shadow-2xl bg-gray-900">
              <img
                :src="mentor.avatar.src"
                :alt="mentor.name"
                class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
              />
            </div>
          </div>
        </div>

        <!-- Info -->
        <div class="relative z-10 text-center w-full">
          <h3 class="text-xl font-bold text-white mb-1 font-heading">
            {{ mentor.name }}
          </h3>
          <p class="text-primary-400 text-sm font-medium mb-3 font-sans">
            {{ mentor.role }}
          </p>
          <p class="text-gray-400 text-sm leading-relaxed mb-6 line-clamp-3 font-sans">
            {{ mentor.description }}
          </p>

          <!-- Specialties Tags -->
          <div class="flex flex-wrap justify-center gap-2">
            <span
              v-for="(specialty, idx) in mentor.specialties.slice(0, 3)"
              :key="idx"
              class="px-3 py-1 text-xs font-medium rounded-full bg-white/5 text-gray-300 border border-white/5 group-hover:bg-primary-500/10 group-hover:text-primary-200 group-hover:border-primary-500/20 transition-all duration-300"
            >
              {{ specialty }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </UPageSection>
</template>
