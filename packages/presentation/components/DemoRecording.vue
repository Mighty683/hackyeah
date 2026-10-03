<script setup lang="ts">
import { ref, watch } from 'vue'
import content from '../content.json'

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
      :aria-label="content.recording.videoLabel"
      @error="failed = true"
      @click.stop
      @keydown.stop
    />
    <div v-else class="recording-placeholder" role="img" :aria-label="content.recording.placeholderLabel">
      <span class="recording-duration">{{ content.recording.duration }}</span>
      <strong>{{ failed ? content.recording.unavailable : content.recording.placeholderTitle }}</strong>
      <span>{{ content.recording.description }}</span>
    </div>
  </div>
</template>
