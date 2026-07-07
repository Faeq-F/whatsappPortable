//import { defineAppConfig } from "nuxt/app";

export default defineAppConfig({
  ui: {
    carousel: {
      variants: {
        active: {
          true: {
            dot: '!bg-gray-300 dark:!bg-gray-700'
          }
        }
      }
    }
  }
})