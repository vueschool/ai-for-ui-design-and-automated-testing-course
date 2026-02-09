<script setup lang="ts">
const { data: page } = await useAsyncData('blog-page', () => {
  return queryCollection('pages').path('/blog').first()
})
if (!page.value) {
  throw createError({
    statusCode: 404,
    statusMessage: 'Page not found',
    fatal: true
  })
}
const { data: posts } = await useAsyncData('blogs', () =>
  queryCollection('blog').order('date', 'DESC').all()
)
if (!posts.value) {
  throw createError({
    statusCode: 404,
    statusMessage: 'blogs posts not found',
    fatal: true
  })
}

// Search & Filter
const search = ref('')
const selectedTag = ref('All')

const tags = computed(() => {
  if (!posts.value) return ['All']
  const allTags = posts.value.flatMap(p => p.tags || [])
  return ['All', ...new Set(allTags)]
})

const isFiltering = computed(() => search.value || selectedTag.value !== 'All')

const filteredPosts = computed(() => {
  if (!posts.value) return []

  // If not filtering, return remaining posts (excluding featured)
  if (!isFiltering.value) {
    return posts.value.slice(1)
  }

  // If filtering, search through ALL posts
  let result = posts.value

  if (search.value) {
    const q = search.value.toLowerCase()
    result = result.filter(p =>
      p.title.toLowerCase().includes(q)
      || p.description.toLowerCase().includes(q)
    )
  }

  if (selectedTag.value !== 'All') {
    result = result.filter(p => p.tags?.includes(selectedTag.value))
  }

  return result
})

const featuredPost = computed(() => posts.value?.[0])

useSeoMeta({
  title: page.value?.seo?.title || page.value?.title,
  ogTitle: page.value?.seo?.title || page.value?.title,
  description: page.value?.seo?.description || page.value?.description,
  ogDescription: page.value?.seo?.description || page.value?.description
})
</script>

<template>
  <div class="min-h-screen">
    <!-- Header -->
    <div class="pt-32 pb-12 text-center">
      <h1 class="text-4xl md:text-6xl font-bold font-serif text-white mb-6">
        Latest Articles
      </h1>
      <p class="text-xl text-gray-400 max-w-2xl mx-auto">
        {{ page?.description }}
      </p>
    </div>

    <!-- Featured Section (Only show if not filtering) -->
    <div v-if="!isFiltering && featuredPost">
      <BlogFeatured :post="featuredPost" />
    </div>

    <div class="py-12 max-w-7xl mx-auto px-6 lg:px-8">
      <!-- Search & Filter Bar -->
      <div class="mb-12 flex flex-col md:flex-row gap-6 items-center justify-between">
        <!-- Search -->
        <div class="w-full md:w-96">
          <UInput
            v-model="search"
            icon="i-heroicons-magnifying-glass"
            placeholder="Search articles..."
            size="lg"
            color="neutral"
            variant="outline"
            class="rounded-full"
            :ui="{ trailing: 'pointer-events-auto' }"
          >
            <template
              v-if="search"
              #trailing
            >
              <UButton
                color="neutral"
                variant="link"
                icon="i-heroicons-x-mark"
                :padded="false"
                @click="search = ''"
              />
            </template>
          </UInput>
        </div>

        <!-- Tags -->
        <div class="flex gap-2 overflow-x-auto max-w-full pb-2 no-scrollbar">
          <button
            v-for="tag in tags"
            :key="tag"
            class="px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all duration-200"
            :class="selectedTag === tag
              ? 'bg-primary-500 text-white shadow-lg shadow-primary-500/25'
              : 'bg-white/5 text-gray-400 hover:bg-white/10 hover:text-white'"
            @click="selectedTag = tag"
          >
            {{ tag }}
          </button>
        </div>
      </div>

      <!-- Grid -->
      <div
        v-if="filteredPosts.length > 0"
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
      >
        <BlogCard
          v-for="(post, index) in filteredPosts"
          :key="post.path"
          :post="post"
          :index="index"
        />
      </div>

      <!-- Empty State -->
      <div
        v-else
        class="py-24 text-center"
      >
        <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white/5 mb-6">
          <UIcon
            name="i-heroicons-magnifying-glass"
            class="w-8 h-8 text-gray-500"
          />
        </div>
        <h3 class="text-xl font-bold text-white mb-2">
          No articles found
        </h3>
        <p class="text-gray-400">
          Try adjusting your search or filters
        </p>
        <UButton
          label="Clear Filters"
          color="neutral"
          variant="outline"
          class="mt-6"
          @click="{ search = ''; selectedTag = 'All' }"
        />
      </div>
    </div>

    <!-- Newsletter Section -->
    <AppNewsletter />
  </div>
</template>
