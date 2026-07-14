<script setup lang="ts">
import type { NavigationMenuItem } from "@nuxt/ui";
import { ref } from "vue";
// import { useFetch } from "nuxt/app";

//let githubStars;
let rightItems;

// useFetch("https://api.github.com/repos/faeq-f/whatsappPortable/stargazers")
//   .then((data) => {
//     githubStars = Intl.NumberFormat("en-US", {
//       notation: "compact",
//       maximumFractionDigits: 1,
//     })
//       .format([...data.data.value].length)
//       .toString();
//   })
//   .catch(() => {
//     githubStars = "";
//   });
rightItems = ref<NavigationMenuItem[][]>([
  [
    {
      label: "GitHub",
      icon: "i-lucide-github",
      // badge: githubStars,
      to: "https://github.com/faeq-f/whatsappPortable/",
      target: "_blank",
    },
  ],
]);

import { useTheme } from "@maz-ui/themes";

const { setColorMode } = useTheme();

function toggleTheme(theme) {
  if (theme == 1) {
    setColorMode("light");
  } else if (theme == 0) {
    setColorMode("dark");
  } else {
    setColorMode("auto");
  }
}

const themeItems = ref<NavigationMenuItem[][]>([
  [
    {
      icon: "i-lucide-sun-moon",
      label: "",
      children: [
        {
          label: "Light",
          icon: "i-lucide-sun",
          onSelect: () => toggleTheme(1),
        },
        {
          label: "Dark",
          icon: "i-lucide-moon",
          onSelect: () => toggleTheme(0),
        },
        {
          label: "System",
          icon: "i-lucide-laptop-minimal",
          onSelect: () => toggleTheme(-1),
        },
      ],
    },
  ],
]);

const device = useDevice();
</script>

<template>
  <MazAnimatedElement
    direction="down"
    :duration="700"
    class="sticky top-0 z-10 outfit"
    id="navbar"
  >
    <div
      class="flex items-center gap-3 data-[orientation=horizontal]:border-b border-default data-[orientation=horizontal]:w-full data-[orientation=vertical]:w-48 border-b-2 border-accent sticky top-0 bg-[var(--ui-bg)] z-10 pl-4"
    >
      <MazAnimatedElement direction="right" :delay="300" :duration="700">
        <!-- <nuxt-link to="/" class="whitespace-nowrap">
          <span style="color: #25d366">WhatsApp</span> Portable
        </nuxt-link> -->
      </MazAnimatedElement>
      <MazAnimatedElement
        direction="down"
        :delay="300"
        :duration="700"
        class="w-full justify-center flex"
      >
        <div class="flex items-center gap-2"></div>
      </MazAnimatedElement>
      <USeparator orientation="vertical" class="h-8 self-center ml-4" />
      <MazAnimatedElement
        direction="down"
        :delay="300"
        :duration="700"
        class="relative flex w-auto justify-end"
      >
        <UNavigationMenu
          highlight
          highlight-color="neutral"
          color="neutral"
          orientation="horizontal"
          v-if="rightItems"
          :items="rightItems"
        />

        <!-- Theme Switch -->
        <USeparator orientation="vertical" class="h-8 self-center ml-4" />
        <UNavigationMenu
          content-orientation="vertical"
          color="neutral"
          :items="themeItems"
          variant="link"
          trailing-icon=" "
          :ui="{
            viewport: 'mt-2 pr-27 bg-white dark:bg-black',
            content: 'w-auto',
            childList: 'w-auto',
            childLabel: 'w-full',
            childLinkDescription: 'line-clamp-1',
          }"
          class="relative flex w-auto justify-end"
        >
          <template #item="{ item }">
            <UIcon :name="item.icon!" class="mx-4" />
          </template>
        </UNavigationMenu>
      </MazAnimatedElement>
    </div>
  </MazAnimatedElement>
</template>
