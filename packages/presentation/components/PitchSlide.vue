<script setup lang="ts">
import { computed } from 'vue'
import content from '../content.json'

const props = defineProps<{
  slide: keyof typeof content.slides
  dark?: boolean
}>()
const copy = computed(() => content.slides[props.slide])
const slideIds = Object.keys(content.slides)
const number = computed(() => String(slideIds.indexOf(props.slide) + 1).padStart(2, '0'))
</script>

<template>
  <section class="pitch-slide" :class="{ 'pitch-dark': dark }">
    <header class="pitch-header">
      <span>{{ copy.label }}</span>
      <span>{{ content.shared.event }}</span>
    </header>
    <main class="pitch-content"><slot :copy="copy" /></main>
    <footer class="pitch-footer">
      <span>{{ copy.footer }}</span>
      <span>{{ number }} / {{ slideIds.length }}</span>
    </footer>
  </section>
</template>
