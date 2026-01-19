<script setup lang="ts">
import type { IndexCollectionItem } from '@nuxt/content'

const props = defineProps<{
  page: IndexCollectionItem
}>()

const steps = computed(() => {
  return props.page.howItWorks.steps.map((step, index) => ({
    title: step.title,
    description: step.description,
    icon: step.icon,
    value: index
  }))
})
</script>

<template>
  <section class="relative py-20 lg:py-32 overflow-hidden bg-[#1A1A1A]">
    <div class="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
      <div class="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
        <!-- Left Column - Teacher Image -->
        <div class="relative order-1 lg:order-1">
          <!-- Teacher Image Container -->
          <div class="relative w-full overflow-hidden pb-20">
            <NuxtImg
              src="/how-it-works-teacher.png"
              alt="Expert Teacher"
              width="600"
              class="w-full h-auto object-contain"
            />

            <!-- Verified Tutors Card Overlay - Full Width -->
            <UCard
              class="absolute bottom-0 left-0 right-0 z-20 bg-[#1A1A1A]/95 backdrop-blur-md border-t border-l border-r border-white/10 rounded-t-xl shadow-xl p-2"
            >
              <div class="flex items-center gap-3">
                <div class="flex-shrink-0 w-12 h-12 rounded-full bg-[#4CAF50] flex items-center justify-center shadow-lg">
                  <UIcon
                    name="i-lucide-check"
                    class="w-6 h-6 text-white"
                  />
                </div>
                <div>
                  <h3 class="font-bold text-white text-base">
                    Verified Tutors
                  </h3>
                  <p class="text-sm text-[#CCCCCC] mt-0.5">
                    Every tutor is vetted for quality
                  </p>
                </div>
              </div>
            </UCard>
          </div>
        </div>

        <!-- Right Column - Text Content -->
        <div class="relative z-10 order-2 lg:order-2">
          <!-- Heading -->
          <h2 class="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4">
            {{ page.howItWorks.title }}
          </h2>

          <!-- Subtitle -->
          <p class="text-lg text-[#CCCCCC] mb-12">
            {{ page.howItWorks.description }}
          </p>

          <!-- Steps using UStepper -->
          <div class="mb-10">
            <UStepper
              :items="steps"
              orientation="vertical"
              color="primary"
              :disabled="true"
              :ui="{
                item: 'last:mb-0',
                indicator: 'w-12 h-12',
                icon: 'w-6 h-6',
                title: 'text-xl font-bold text-white mb-2',
                description: 'text-[#CCCCCC] leading-relaxed text-base'
              }"
            />
          </div>

          <!-- CTA Button -->
          <UButton
            size="xl"
            color="primary"
            variant="solid"
            trailing-icon="i-lucide-arrow-right"
            class="px-8 py-4 text-lg font-medium rounded-lg gradient-primary-glow hover:shadow-[0_0_25px_rgba(246,81,47,0.5)] transition-all"
          >
            Start Learning Today
          </UButton>
        </div>
      </div>
    </div>
  </section>
</template>
