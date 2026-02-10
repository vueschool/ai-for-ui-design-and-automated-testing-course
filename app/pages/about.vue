<script setup lang="ts">
const { data: page } = await useAsyncData('about', () => {
  return queryCollection('about').first()
})
if (!page.value) {
  throw createError({
    statusCode: 404,
    statusMessage: 'Page not found',
    fatal: true
  })
}

const { global } = useAppConfig()

useSeoMeta({
  title: page.value?.seo?.title ?? page.value?.title,
  ogTitle: page.value?.seo?.title ?? page.value?.title,
  description: page.value?.seo?.description ?? page.value?.description,
  ogDescription: page.value?.seo?.description ?? page.value?.description
})

const hasStructuredContent = computed(() => Boolean(page.value?.hero && page.value?.mission))
</script>

<template>
  <div class="min-h-screen bg-[#1A1A1A]">
    <!-- Mentora About page (Figma design) when structured content exists -->
    <template v-if="page && hasStructuredContent">
      <!-- Hero -->
      <section class="pt-28 sm:pt-32 pb-16 sm:pb-20 px-6">
        <div class="max-w-4xl mx-auto text-center">
          <h1 class="font-heading text-4xl sm:text-5xl lg:text-6xl font-bold text-white">
            {{ page.hero!.title }}
          </h1>
          <p class="mt-4 text-lg sm:text-xl text-[#D0D0D0] max-w-3xl mx-auto">
            {{ page.hero!.description }}
          </p>
        </div>
      </section>

      <!-- Our Mission -->
      <section class="py-16 sm:py-24 px-6 bg-[#252525]/80">
        <div class="max-w-7xl mx-auto">
          <div class="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
            <div class="relative overflow-hidden rounded-xl ring-2 ring-primary/40 ring-offset-2 ring-offset-[#1A1A1A] shadow-lg">
              <NuxtImg
                :src="page.mission!.image.src"
                :alt="page.mission!.image.alt"
                class="w-full h-auto object-cover aspect-4/3"
                width="600"
              />
            </div>
            <div>
              <p class="inline-flex items-center gap-1.5 text-primary font-semibold text-sm uppercase tracking-wide">
                <UIcon name="i-lucide-sparkles" class="size-4" />
                {{ page.mission!.label }}
              </p>
              <h2 class="mt-3 font-heading text-3xl sm:text-4xl lg:text-5xl font-bold text-white">
                {{ page.mission!.heading }}
              </h2>
              <p class="mt-4 text-[#D0D0D0] text-base sm:text-lg leading-relaxed">
                {{ page.mission!.body }}
              </p>
              <!-- Stats grid -->
              <div class="mt-10 grid grid-cols-2 border border-primary/30 rounded-lg overflow-hidden bg-[#1A1A1A]/60">
                <div
                  v-for="(stat, index) in page.mission!.stats"
                  :key="stat.label"
                  class="text-center p-6 border-primary/30"
                  :class="{
                    'border-r': index % 2 === 0,
                    'border-b': index < 2
                  }"
                >
                  <p class="text-2xl sm:text-3xl font-bold text-white">
                    {{ stat.value }}
                  </p>
                  <p class="mt-1 text-xs sm:text-sm text-[#A0A0A0] uppercase tracking-wider">
                    {{ stat.label }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Our Core Values -->
      <section v-if="page.coreValues" class="py-16 sm:py-24 px-6">
        <div class="max-w-7xl mx-auto">
          <div class="text-center mb-12 sm:mb-16">
            <h2 class="font-heading text-3xl sm:text-4xl lg:text-5xl font-bold text-white">
              {{ page.coreValues!.title }}
            </h2>
            <p class="mt-3 text-[#D0D0D0] text-base sm:text-lg max-w-2xl mx-auto">
              {{ page.coreValues!.subtitle }}
            </p>
          </div>
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6 lg:gap-8">
            <UCard
              v-for="value in page.coreValues!.values"
              :key="value.title"
              class="bg-[#252525]/80 border border-white/10 rounded-xl p-6 h-full flex flex-col"
            >
              <div class="flex flex-col flex-1">
                <div class="w-12 h-12 rounded-lg bg-primary/20 flex items-center justify-center text-primary mb-4">
                  <UIcon :name="value.icon" class="size-6" />
                </div>
                <h3 class="font-heading text-lg font-bold text-white">
                  {{ value.title }}
                </h3>
                <p class="mt-2 text-sm text-[#B0B0B0] leading-relaxed flex-1">
                  {{ value.description }}
                </p>
              </div>
            </UCard>
          </div>
        </div>
      </section>

      <!-- Our Story -->
      <section v-if="page.story" class="py-16 sm:py-24 px-6 bg-[#252525]/50">
        <div class="max-w-3xl mx-auto text-center">
          <h2 class="font-heading text-3xl sm:text-4xl font-bold text-white inline-block border-b-2 border-primary pb-2">
            {{ page.story!.title }}
          </h2>
          <div class="mt-10 space-y-6 text-[#D0D0D0] text-base sm:text-lg leading-relaxed">
            <p v-for="(paragraph, i) in page.story!.paragraphs" :key="i">
              {{ paragraph }}
            </p>
          </div>
        </div>
      </section>

      <!-- Gallery -->
      <section v-if="page.gallery?.images?.length" class="py-16 sm:py-24 px-6">
        <div class="max-w-7xl mx-auto">
          <div class="grid sm:grid-cols-2 gap-6 lg:gap-8">
            <div
              v-for="(image, index) in page.gallery!.images"
              :key="index"
              class="overflow-hidden rounded-xl border border-white/10 shadow-lg"
            >
              <NuxtImg
                :src="image.src"
                :alt="image.alt"
                class="w-full h-auto object-cover aspect-16/10"
                width="800"
              />
            </div>
          </div>
        </div>
      </section>
    </template>

    <!-- Fallback: legacy about layout when no structured content -->
    <UPage v-else-if="page">
      <UPageHero
        :title="page.title"
        :description="page.description"
        orientation="horizontal"
        :ui="{
          container: 'lg:flex sm:flex-row items-center',
          title: '!mx-0 text-left',
          description: '!mx-0 text-left',
          links: 'justify-start'
        }"
      >
        <UColorModeAvatar
          class="sm:rotate-4 size-36 rounded-lg ring ring-default ring-offset-3 ring-offset-(--ui-bg)"
          :light="global.picture?.light!"
          :dark="global.picture?.dark!"
          :alt="global.picture?.alt!"
        />
      </UPageHero>
      <UPageSection :ui="{ container: '!pt-0' }">
        <MDC :value="page.content" unwrap="p" />
        <div class="flex flex-row justify-center items-center py-10 space-x-[-2rem]">
          <PolaroidItem
            v-for="(image, index) in page.images"
            :key="index"
            :image="image"
            :index="index"
          />
        </div>
      </UPageSection>
    </UPage>
  </div>
</template>
