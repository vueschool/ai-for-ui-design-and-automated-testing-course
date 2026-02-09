<script setup lang="ts">
defineProps<{
  post: any
}>()
</script>

<template>
  <section class="relative py-12 overflow-hidden">
    <div class="max-w-7xl mx-auto px-6 lg:px-8">
      <div class="relative z-10 bg-white/5 backdrop-blur-2xl border border-white/10 rounded-3xl p-8 md:p-12 overflow-hidden">
        <!-- Badge -->
        <div class="absolute top-6 right-6">
          <UBadge
            color="primary"
            variant="solid"
            size="lg"
            class="px-4 py-2 rounded-full shadow-lg shadow-primary-500/20"
          >
            <UIcon
              name="i-heroicons-sparkles-solid"
              class="mr-2"
            />
            Featured Post
          </UBadge>
        </div>

        <div class="grid md:grid-cols-2 gap-12 items-center">
          <!-- Image Side -->
          <div class="relative group">
            <div class="absolute inset-0 bg-linear-to-tr from-primary-500/20 to-primary-500/20 rounded-2xl blur-2xl transform rotate-3 transition-transform duration-500 group-hover:rotate-6" />
            <NuxtLink :to="post.path">
              <NuxtImg
                :src="post.path + '-og.png'"
                :alt="post.title"
                class="relative z-10 w-full aspect-video object-cover rounded-2xl shadow-2xl ring-1 ring-white/10 transition-transform duration-500 group-hover:scale-[1.02]"
                width="535"
                height="300"
              />
            </NuxtLink>
          </div>

          <!-- Content Side -->
          <div>
            <div class="flex items-center gap-3 text-sm text-primary-400 mb-4 font-medium">
              <time :datetime="post.date">{{ new Date(post.date).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }) }}</time>
              <span class="w-1 h-1 rounded-full bg-primary-400" />
              <span>{{ post.author?.name || 'Mentora Team' }}</span>
            </div>

            <h2 class="text-3xl md:text-4xl font-bold font-serif text-white mb-4 leading-tight">
              <NuxtLink :to="post.path">
                {{ post.title }}
              </NuxtLink>
            </h2>
            <p
              v-if="post.subtitle"
              class="text-xl text-gray-300 font-medium mb-4"
            >
              {{ post.subtitle }}
            </p>

            <p class="text-lg text-gray-400 leading-relaxed mb-8 line-clamp-3">
              {{ post.description }}
            </p>

            <div class="flex flex-wrap gap-3 mb-8">
              <UBadge
                v-for="tag in post.tags"
                :key="tag"
                color="neutral"
                variant="outline"
                size="md"
              >
                {{ tag }}
              </UBadge>
            </div>

            <div class="flex gap-4">
              <UButton
                :to="post.path"
                size="xl"
                color="primary"
                variant="solid"
                label="Read Article"
                icon="i-heroicons-arrow-right"
                trailing
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
