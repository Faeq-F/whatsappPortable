<script setup lang="ts">
import { useThemesStore } from "~/stores/themes";
const themes = useThemesStore();

import { ref } from "vue";
import MazAnimatedElement from "maz-ui/components/MazAnimatedElement";
import { vFullscreenImg } from "maz-ui/directives/vFullscreenImg";

const carouselRef = ref();
const next = () => {
  const container = carouselRef.value?.$el?.querySelector(".m-carousel__items");
  if (container) {
    const isAtEnd =
      container.scrollLeft + container.clientWidth >=
      container.scrollWidth - 20;
    container.scrollTo({
      left: isAtEnd ? 0 : container.scrollLeft + container.clientWidth,
      behavior: "smooth",
    });
  }
};
const prev = () => {
  const container = carouselRef.value?.$el?.querySelector(".m-carousel__items");
  if (container) {
    const isAtStart = container.scrollLeft <= 20;
    container.scrollTo({
      left: isAtStart
        ? container.scrollWidth
        : container.scrollLeft - container.clientWidth,
      behavior: "smooth",
    });
  }
};
</script>

<template>
  <div class="w-screen h-[calc(100vh-10rem)]">
    <div class="sm:relative sm:top-1/2 sm:-translate-y-1/2">
      <div class="pt-12 sm:px-16">
        <MazAnimatedElement direction="up" :delay="600" :duration="700">
          <div
            class="font-bold sm:text-6xl text-3xl varela text-center sm:text-left"
          >
            <span style="color: #25d366">WhatsApp</span> Portable
          </div>
        </MazAnimatedElement>
        <MazAnimatedElement direction="up" :delay="800" :duration="700">
          <div class="sm:text-sm text-md mt-2 varela text-center sm:text-left">
            Not endorsed or affiliated with WhatsApp
          </div>
        </MazAnimatedElement>
        <MazAnimatedElement direction="up" :delay="900" :duration="700">
          <div class="my-4 flex justify-center sm:justify-start">
            <a
              href="https://github.com/Faeq-F/whatsappPortable/releases/download/Version2.4.0/WhatsApp.zip"
              target="_blank"
              class="inline-flex items-center gap-2.5 border border-black cursor-pointer! px-6 py-3 bg-[#25d366] active:bg-[#1ca34d] text-[#111B21] rounded-full transition-all duration-300 shadow-md hover:shadow-lg hover:-translate-y-0.5"
            >
              <span class="text-sm">Download</span>
              <UIcon name="i-lucide-download" class="w-5 h-5" />
            </a>
          </div>
        </MazAnimatedElement>
      </div>
      <div
        class="flex flex-col-reverse items-center sm:items-start sm:flex-row sm:px-16"
      >
        <div class="sm:inline sm:w-1/3 w-fit pt-12 px-8 sm:px-0 pb-12 sm:pb-0">
          <MazAnimatedElement direction="right" :delay="1000" :duration="700">
            <div class="">
              <h3 class="text-md font-bold mb-3 outfit">Features</h3>
              <ul class="space-y-3 outfit text-sm">
                <li class="flex items-start gap-2.5">
                  <UIcon
                    name="i-lucide-circle"
                    class="w-5 h-5 text-[#25d366] shrink-0 mt-0.5"
                  />
                  <span>No installation required</span>
                </li>
                <li class="flex items-start gap-2.5">
                  <UIcon
                    name="i-lucide-circle"
                    class="w-5 h-5 text-[#25d366] shrink-0 mt-0.5"
                  />
                  <span
                    >All data stored in the relocatable app folder (making it
                    truly portable)</span
                  >
                </li>
                <li class="flex items-start gap-2.5">
                  <UIcon
                    name="i-lucide-circle"
                    class="w-5 h-5 text-[#25d366] shrink-0 mt-0.5"
                  />
                  <span>Use multiple WhatsApp accounts simultaneously</span>
                </li>
                <li class="flex items-start gap-2.5">
                  <UIcon
                    name="i-lucide-circle"
                    class="w-5 h-5 text-[#25d366] shrink-0 mt-0.5"
                  />
                  <span>
                    Support for multiple languages & translation (via the
                    <a
                      href="https://docs.cloud.google.com/translate/docs/reference/rest"
                      target="_blank"
                      class="underline hover:text-[#25d366] transition-colors"
                      >Google Translate API</a
                    >)
                  </span>
                </li>
                <li class="flex items-start gap-2.5">
                  <UIcon
                    name="i-lucide-circle"
                    class="w-5 h-5 text-[#25d366] shrink-0 mt-0.5"
                  />
                  <span>OS native notifications</span>
                </li>
                <li class="flex items-start gap-2.5">
                  <UIcon
                    name="i-lucide-circle"
                    class="w-5 h-5 text-[#25d366] shrink-0 mt-0.5"
                  />
                  <span>Themes: Light / Dark / System modes</span>
                </li>
                <li class="flex items-start gap-2.5">
                  <UIcon
                    name="i-lucide-circle"
                    class="w-5 h-5 text-[#25d366] shrink-0 mt-0.5"
                  />
                  <span>DevTools access</span>
                </li>
              </ul>
            </div>
          </MazAnimatedElement>
        </div>

        <div
          class="flex-2 sm:w-2/3 w-17/18 flex flex-col items-start sm:pl-4 rounded-lg"
        >
          <MazAnimatedElement
            direction="left"
            :delay="1000"
            :duration="2000"
            class="justify-center w-full"
          >
            <div class="relative w-full">
              <MazCarousel
                ref="carouselRef"
                hide-scrollbar
                hide-scroll-buttons
                class="rounded-lg mx-auto my-0"
              >
                <div
                  v-for="(item, index) in themes.themes"
                  :key="index"
                  class="flex flex-col items-center p-2 w-full min-w-full"
                >
                  <img
                    :src="item.image"
                    :alt="item.name"
                    class="rounded-lg object-contain w-full max-h-[350px] select-none"
                    v-fullscreen-img
                  />
                  <div class="mt-2 text-xs opacity-75 outfit text-center">
                    {{ item.name }}
                  </div>
                </div>
              </MazCarousel>

              <UButton
                icon="i-lucide-chevron-left"
                color="neutral"
                variant="ghost"
                class="absolute left-7 top-1/2 -translate-y-1/2 ring-1 ring-[#1f8fff33] rounded-full p-2 bg-black/10 dark:bg-white/10 backdrop-blur-md z-10 hover:bg-black/20 dark:hover:bg-white/20"
                @click="prev"
              />
              <UButton
                icon="i-lucide-chevron-right"
                color="neutral"
                variant="ghost"
                class="absolute right-4 top-1/2 -translate-y-1/2 ring-1 ring-[#1f8fff33] rounded-full p-2 bg-black/10 dark:bg-white/10 backdrop-blur-md z-10 hover:bg-black/20 dark:hover:bg-white/20"
                @click="next"
              />
            </div>
          </MazAnimatedElement>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="css">
.m-carousel__items {
  padding-top: 0 !important;
  padding-bottom: 0 !important;
}
</style>
