<script setup lang="ts">
defineProps<{ flooded?: boolean; arrived?: boolean }>()
</script>

<template>
  <svg class="neighborhood-map" viewBox="0 0 560 380" role="img" aria-label="Illustrative map with a school, library, park and home">
    <rect width="560" height="380" rx="24" fill="#e9efdc" />
    <path d="M416 -20 C365 80 484 139 427 223 S414 337 490 410" fill="none" stroke="#b0dfe5" stroke-width="45" />
    <g fill="#d9e5ca"><rect x="34" y="27" width="137" height="76" rx="15" /><rect x="208" y="26" width="125" height="75" rx="15" /><rect x="202" y="165" width="128" height="81" rx="15" /><rect x="33" y="271" width="138" height="81" rx="15" /></g>
    <g fill="none" stroke="#fbfaf1" stroke-width="28" stroke-linecap="round"><path d="M-10 133 H570 M-10 257 H570 M185 -10 V390 M352 -10 V390" /></g>
    <path d="M0 133 H560 M0 257 H560 M185 0 V380 M352 0 V380" fill="none" stroke="#dbddcd" stroke-width="1.5" stroke-dasharray="5 7" />
    <path d="M86 257 H185 V133 H352 V74" fill="none" stroke="#2b7560" stroke-width="7" stroke-linecap="round" stroke-dasharray="2 13" />
    <path v-if="flooded" d="M185 257 H435" fill="none" stroke="#eea756" stroke-width="9" stroke-linecap="round" stroke-dasharray="8 10" />
    <g v-if="flooded"><ellipse cx="429" cy="257" rx="47" ry="32" fill="#84c8d7" /><path d="M400 247 q8 -9 16 0 t16 0 t16 0 M400 262 q8 -9 16 0 t16 0 t16 0" fill="none" stroke="white" stroke-width="3" /><circle cx="387" cy="257" r="14" fill="#d87654" /><path d="m381 251 12 12 m0 -12 -12 12" stroke="white" stroke-width="3" /></g>
    <g transform="translate(70 195)"><rect width="68" height="44" rx="5" fill="#f0c579" /><path d="M-7 0 34 -24 75 0" fill="#cd7c55" /><path d="M13 12 h10 v12 H13z M45 12 h10 v12 H45z" fill="#fff9e9" /><rect x="28" y="21" width="13" height="23" fill="#ad7656" /><text x="34" y="-35" class="map-label">SCHOOL</text></g>
    <g transform="translate(237 51)"><rect width="66" height="43" rx="4" fill="#b5bfdf" /><path d="M-5 0 33 -19 71 0" fill="#7b89b8" /><path d="M14 8 v27 M32 8 v27 M50 8 v27" stroke="#eff1fa" stroke-width="7" /><text x="33" y="-27" class="map-label">LIBRARY</text></g>
    <g transform="translate(339 40)"><rect width="46" height="38" rx="4" fill="#f4c396" /><path d="M-7 1 23 -21 53 1" fill="#2b7560" /><rect x="17" y="18" width="13" height="20" fill="#805e4e" /><rect x="5" y="9" width="10" height="10" fill="#fff8e9" /><text x="23" y="-27" class="map-label">HOME</text></g>
    <g transform="translate(259 197)"><path d="M0 24 V-6 M43 24 V-6" stroke="#8a9675" stroke-width="7" /><circle cy="-7" r="22" fill="#86ad76" /><circle cx="43" cy="-7" r="19" fill="#a0bd7a" /><text x="22" y="39" class="map-label">PARK</text></g>
    <g :transform="arrived ? 'translate(352 96)' : 'translate(185 211)'"><circle r="25" fill="#2b7560" opacity=".12" /><circle r="17" fill="#2b7560" stroke="white" stroke-width="4" /><path d="m0 -8 7 13 -7 -3 -7 3z" fill="white" /></g>
    <g transform="translate(451 25)"><rect width="87" height="31" rx="15" fill="#fffdf5" /><text x="44" y="20" class="map-label">↑ NORTH</text></g>
    <rect x="315" y="305" width="218" height="45" rx="14" fill="#fffdf5" /><circle cx="333" cy="328" r="5" fill="#2b7560" /><text x="347" y="332" font-size="12" fill="#536357">{{ flooded ? 'New route via the library' : 'Your route back to base' }}</text>
  </svg>
</template>

<style scoped>
.neighborhood-map { width: 100%; height: 100%; }
.map-label { font: 700 10px Arial, sans-serif; fill: #536357; text-anchor: middle; letter-spacing: .7px; }
.neighborhood-map text:not(.map-label) { font: 400 12px Arial, sans-serif; }
</style>
