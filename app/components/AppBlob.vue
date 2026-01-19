<script setup lang="ts">
const props = defineProps<{
  name: string
}>()

const blobMatrix = [
  // Row 1
  ["orb_perfect", "bean_tilted", "star_puffy", "slug_floating"],
  
  // Row 2
  ["kidney_curved", "peanut_smooth", "globule_heavy", "gourd_stretch"],
  
  // Row 3
  ["boomerang_soft", "jellybean_fat", "macaroni_arch", "worm_crawling"],
  
  // Row 4
  ["amoeba_cross", "cloud_lump", "tri_lobe", "puddle_melt"]
]

const blobPosition = computed(() => {
  let rowIndex = -1
  let colIndex = -1

  for (let r = 0; r < blobMatrix.length; r++) {
    const c = blobMatrix[r].indexOf(props.name)
    if (c !== -1) {
      rowIndex = r
      colIndex = c
      break
    }
  }

  if (rowIndex === -1 || colIndex === -1) {
    return { x: 0, y: 0 }
  }

  // 4x4 grid
  const cols = 4
  const rows = 4
  
  const x = (colIndex / (cols - 1)) * 100
  const y = (rowIndex / (rows - 1)) * 100
  
  return { x, y }
})
</script>

<template>
  <div 
    class="blob-sprite"
    :style="{
      backgroundPosition: `${blobPosition.x}% ${blobPosition.y}%`
    }"
    :aria-label="name"
    role="img"
  />
</template>

<style scoped>
.blob-sprite {
  width: 100%;
  height: 100%;
  background-image: url('/blob-sprite.png');
  background-size: 400% 400%;
  background-repeat: no-repeat;
  display: inline-block;
}
</style>
