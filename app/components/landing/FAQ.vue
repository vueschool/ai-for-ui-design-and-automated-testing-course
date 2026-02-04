<script setup lang="ts">
import type { IndexCollectionItem } from '@nuxt/content'

const props = defineProps<{
  page: IndexCollectionItem
}>()

const items = computed(() => {
  return props.page.faq?.categories.map((faq) => {
    return {
      label: faq.title,
      key: faq.title.toLowerCase(),
      questions: faq.questions
    }
  })
})

const ui = {
  root: 'flex items-center gap-4 w-full',
  list: 'relative flex bg-transparent dark:bg-transparent gap-2 px-0',
  indicator: 'absolute top-[4px] duration-200 ease-out focus:outline-none rounded-lg bg-elevated/60',
  trigger: 'px-3 py-2 rounded-lg hover:bg-muted/50 data-[state=active]:text-highlighted data-[state=inactive]:text-muted',
  label: 'truncate'
}
</script>

<template>
  <section class="relative py-20 lg:py-32 overflow-hidden">
    <div class="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
      <div class="mb-12">
        <h2 class="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4">
          {{ page.faq.title }}
        </h2>
        <p class="text-lg text-[#CCCCCC]">
          {{ page.faq.description }}
        </p>
      </div>

      <UTabs
        :items
        orientation="horizontal"
        :ui
      >
        <template #content="{ item }">
          <UAccordion
            trailing-icon="lucide:plus"
            :items="item.questions"
            :unmount-on-hide="false"
            :ui="{
              item: 'border-none',
              trigger: 'mb-2 border-0 group px-4 transform-gpu rounded-lg bg-elevated/60 will-change-transform hover:bg-muted/50 text-base',
              trailingIcon: 'group-data-[state=closed]:rotate-0 group-data-[state=open]:rotate-135 text-base text-muted'
            }"
          >
            <template #body="{ item: _item }">
              <MDC
                :value="_item.content"
                unwrap="p"
                class="px-4"
              />
            </template>
          </UAccordion>
        </template>
      </UTabs>
    </div>
  </section>
</template>
