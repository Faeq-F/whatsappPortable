<script setup lang="ts">
import navbar from "~/components/layoutSections/navbar.vue";
import { VueLenis } from "lenis/vue";
import { ref } from "vue";
const LenisWrapper = ref();
const LenisContent = ref();
</script>
<template>
  <navbar />
  <VueLenis
    root
    :options="{
      autoRaf: true,
      lerp: 0.1,
      anchors: true,
      content: LenisContent,
      wrapper: LenisWrapper,
    }"
  />
  <slot />
</template>
<style scoped lang="css"></style>
