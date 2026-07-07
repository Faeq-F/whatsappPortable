import type { RouterConfig } from '@nuxt/schema';
import { navigateTo } from 'nuxt/app';

// https://router.vuejs.org/api/#routeroptions
export default <RouterConfig>{
  scrollBehavior: (to, from, savedPosition) => {

    if (to.hash) {
      return new Promise((resolve) => {
        setTimeout(async () => {
          await navigateTo(to.path)
          resolve({
            el: to.hash,
            behavior: 'smooth',
          });
        }, 500);
      });
    }

    if (to.path == from.path) {
      return {
        left: 0,
        top: 0,
        behavior: 'smooth',
      };
    }

    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({
          left: savedPosition?.left || 0,
          top: savedPosition?.top || 0,
        });
      }, 500);
    });
  },
};
