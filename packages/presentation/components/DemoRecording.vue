<script setup lang="ts">
import { ref, watch } from 'vue'

// Leave src empty until the local app recording is ready for the pitch.
const props = withDefaults(defineProps<{ src?: string }>(), { src: '' })
const failed = ref(false)
watch(() => props.src, () => { failed.value = false })
</script>

<template>
  <div class="demo-recording">
    <video
      v-if="src && !failed"
      :key="src"
      :src="src"
      controls
      playsinline
      preload="metadata"
      aria-label="Safe Path Android app demonstration"
      @error="failed = true"
      @click.stop
      @keydown.stop
    />
    <div v-else class="recording-placeholder" role="img" aria-label="Demo recording placeholder. A 45-second Android walkthrough will be added here.">
      <span class="recording-duration">45 seconds · Android app</span>
      <strong>{{ failed ? 'Recording unavailable' : 'App recording goes here' }}</strong>
      <span>One situation. One choice. A chance to try again.</span>
    </div>
  </div>
</template>
