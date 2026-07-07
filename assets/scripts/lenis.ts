import { useLenis } from "lenis/vue";
let resizeTimeout: NodeJS.Timeout;

export default function refreshLenis() {
  useLenis((lenis) => {
    clearTimeout(resizeTimeout); // Cancel previous resize calls
    resizeTimeout = setTimeout(() => {
      requestAnimationFrame(() => {
        lenis.resize(); // Recalculate dimensions inside requestAnimationFrame for smoother transitions
      });
    }, 300);
  });
}