<script setup lang="ts">
defineProps<{
  src: string
  alt: string
}>()
</script>

<template>
  <div class="relative image-fade-container">
    <NuxtImg
      :src="src"
      :alt="alt"
      width="2400"
      height="900"
      format="webp"
      class="rounded-lg w-full h-[250px] md:h-[450px] object-cover object-center md:my-5"
    />
    <!-- Edge gradients -->
    <div class="fade-left" />
    <div class="fade-right" />
    <div class="fade-top" />
    <div class="fade-bottom" />
  </div>
</template>

<style scoped>
.image-fade-container {
  position: relative;
  --fade-size: 40px;
  --fade-radius: 0.5rem;
  --fade-color-solid: var(--ui-bg);
  --fade-color-mid: color-mix(in srgb, var(--ui-bg) 70%, transparent);
}

/* Base styles for all fade overlays */
.fade-left,
.fade-right,
.fade-top,
.fade-bottom {
  position: absolute;
  pointer-events: none;
  z-index: 1;
}

/* Horizontal fades */
.fade-left,
.fade-right {
  top: 0;
  bottom: 0;
  width: var(--fade-size);
}

/* Vertical fades */
.fade-top,
.fade-bottom {
  left: 0;
  right: 0;
  height: var(--fade-size);
}

/* Left edge */
.fade-left {
  left: 0;
  border-top-left-radius: var(--fade-radius);
  border-bottom-left-radius: var(--fade-radius);
  background: linear-gradient(to right, var(--fade-color-solid) 0%, var(--fade-color-mid) 40%, transparent 100%);
}

/* Right edge */
.fade-right {
  right: 0;
  border-top-right-radius: var(--fade-radius);
  border-bottom-right-radius: var(--fade-radius);
  background: linear-gradient(to left, var(--fade-color-solid) 0%, var(--fade-color-mid) 40%, transparent 100%);
}

/* Top edge */
.fade-top {
  top: 0;
  border-top-left-radius: var(--fade-radius);
  border-top-right-radius: var(--fade-radius);
  background: linear-gradient(to bottom, var(--fade-color-solid) 0%, var(--fade-color-mid) 40%, transparent 100%);
}

/* Bottom edge */
.fade-bottom {
  bottom: 0;
  border-bottom-left-radius: var(--fade-radius);
  border-bottom-right-radius: var(--fade-radius);
  background: linear-gradient(to top, var(--fade-color-solid) 0%, var(--fade-color-mid) 40%, transparent 100%);
}
</style>
