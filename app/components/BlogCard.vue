<script setup lang="ts">
defineProps<{
  post: any
  index?: number
}>()
</script>

<template>
  <Motion
    class="group relative h-full"
    :initial="{ opacity: 0, y: 20 }"
    :in-view="{ opacity: 1, y: 0 }"
    :transition="{ duration: 0.5, delay: (index || 0) * 0.1 }"
    :viewport="{ once: true }"
  >
    <NuxtLink
      :to="post.path"
      class="block h-full"
    >
      <div
        class="h-full rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10 overflow-hidden hover:border-primary-500/30 transition-all duration-300 hover:-translate-y-1 flex flex-col"
      >
        <!-- Image -->
        <div class="relative aspect-video overflow-hidden">
          <div
            class="absolute inset-0 bg-linear-to-tr from-primary-500/20 to-primary-500/20 mix-blend-overlay z-10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
          />
          <NuxtImg
            :src="post.path + '-og.png'"
            :alt="post.title"
            class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
            width="382"
            height="215"
          />
        </div>

        <!-- Content -->
        <div class="p-6 flex-1 flex flex-col">
          <!-- Meta -->
          <div class="flex items-center gap-3 text-xs font-medium text-primary-400 mb-3">
            <time :datetime="post.date">{{
              new Date(post.date).toLocaleDateString("en-US", {
                month: "short",
                day: "numeric",
                year: "numeric"
              })
            }}</time>
            <span class="w-1 h-1 rounded-full bg-primary-400" />
            <span>{{ post.author?.name || "Mentora Team" }}</span>
          </div>

          <h3
            class="text-xl font-bold font-serif text-white mb-3 line-clamp-2 group-hover:text-primary-400 transition-colors"
          >
            {{ post.title }}
          </h3>

          <p class="text-gray-400 text-sm leading-relaxed mb-6 line-clamp-3 flex-1">
            {{ post.description }}
          </p>

          <!-- Tags -->
          <div class="flex flex-wrap gap-2 mt-auto">
            <UBadge
              v-for="tag in post.tags?.slice(0, 3)"
              :key="tag"
              color="neutral"
              variant="subtle"
              size="xs"
            >{{ tag
            }}</UBadge>
          </div>
        </div>
      </div>
    </NuxtLink>
  </Motion>
</template>
