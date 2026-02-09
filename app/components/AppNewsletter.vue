<script setup lang="ts">
</script>

<template>
  <section class="pb-16 relative overflow-hidden">
    <div class="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
      <div class="relative rounded-xl bg-linear-to-br from-white/10 via-white/5 to-transparent backdrop-blur-3xl border border-white/10 shadow-[0_8px_32px_0_rgba(0,0,0,0.36)] ring-1 ring-white/10 overflow-hidden p-8 md:p-12 mx-auto">
        <!-- Inner Highlight -->
        <div class="absolute inset-0 bg-linear-to-br from-white/10 to-transparent opacity-50 pointer-events-none" />

        <div class="relative z-10 grid md:grid-cols-2 gap-8 md:gap-16 items-center">
          <!-- Text Side -->
          <div class="text-center md:text-left">
            <div class="flex items-center justify-center md:justify-start gap-4 mb-4">
              <div class="p-3 rounded-full bg-primary-500/10 border border-primary-500/20 hidden md:flex">
                <UIcon
                  name="i-heroicons-envelope-open"
                  class="w-6 h-6 text-primary-400"
                />
              </div>
              <h2 class="text-3xl font-bold font-serif text-white">
                Stay in the Loop
              </h2>
            </div>
            <p class="text-lg text-gray-300">
              Get the latest study tips, exam strategies, and educational insights delivered straight to your inbox.
            </p>
          </div>

          <!-- Form Side -->
          <div>
            <form
              class="flex flex-col sm:flex-row gap-3"
              @submit.prevent
            >
              <UInput
                placeholder="Enter your email"
                size="xl"
                class="flex-1 rounded-full"
                :ui="{ leading: 'pointer-events-none' }"
              >
                <template #leading>
                  <UIcon
                    name="i-heroicons-envelope"
                    class="text-gray-500"
                  />
                </template>
              </UInput>
              <UButton
                type="submit"
                size="xl"
                label="Subscribe"
              />
            </form>
            <p class="text-xs text-gray-500 mt-3 text-center md:text-left ml-1">
              No spam, unsubscribe at any time.
            </p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
