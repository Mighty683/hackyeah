<script setup lang="ts">
withDefaults(defineProps<{
  number: string
  label?: string
  dark?: boolean
}>(), { label: 'Safe Path', dark: false })
</script>

<template>
  <section class="pitch-slide" :class="{ 'pitch-dark': dark }">
    <header class="pitch-header">
      <span>{{ label }}</span>
      <span>HackYeah 2026 · Defence</span>
    </header>
    <main class="pitch-content"><slot /></main>
    <footer class="pitch-footer">
      <span><slot name="footer">Child-focused safety training</slot></span>
      <span>{{ number }} / 10</span>
    </footer>
  </section>
</template>
