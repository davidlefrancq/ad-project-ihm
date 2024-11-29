<script setup lang="ts">
import { ref } from 'vue'

interface Props {
  modelValue: boolean
  colorList?: Array<{name: string, hex: string}>
  selectedColor?: string
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: false
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'select:color': [value: string]
}>()

const selectColor = (color: string) => {
  emit('select:color', color)
}
</script>

<template>
  <div class="space-y-4">
    <h4 class="text-sm font-medium text-zinc-400">Couleur</h4>
    <div class="flex items-center gap-4">
      <!-- Couleurs - 50% -->
      <div class="w-1/2 flex flex-wrap gap-3">
        <button v-for="color in colorList"
                :key="color.name"
                @click="selectColor(color.name)"
                :title="color.name"
                class="relative w-8 h-8 rounded-full border-2 transition-all duration-200 hover:scale-110 focus:outline-none"
                :class="selectedColor === color.name ? 'border-emerald-500 scale-110' : 'border-zinc-600'"
                :style="{ backgroundColor: color.hex }">
          <CheckIcon v-if="selectedColor === color.name"
                    class="absolute inset-0 m-auto w-5 h-5"
                    :class="color.name === 'blanc' ? 'text-black' : 'text-white'" />
        </button>
      </div>

      <!-- Animated Checkbox - 50% -->
      <div class="w-1/2 flex items-center justify-center gap-3">
        <button
          @click="emit('update:modelValue', !modelValue)"
          class="group relative w-8 h-8 rounded-md overflow-hidden focus:outline-none"
          role="checkbox"
          :aria-checked="modelValue"
        >
          <!-- Fond du bouton -->
          <div
            class="absolute inset-0 transition-colors duration-300"
            :class="modelValue ? 'bg-emerald-500' : 'bg-zinc-700'"
          />

          <!-- Checkmark SVG -->
          <svg
            class="absolute inset-0 w-6 h-6 m-auto stroke-[3] stroke-white transition-all duration-300"
            :class="modelValue ? 'opacity-100 scale-100' : 'opacity-0 scale-50'"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
          >
            <path
              d="M20 6L9 17L4 12"
              :class="modelValue ? 'animate-draw' : ''"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>

          <!-- Border avec animation -->
          <div
            class="absolute inset-0 border-2 rounded-md transition-colors duration-300"
            :class="modelValue ? 'border-emerald-500' : 'border-zinc-600 group-hover:border-zinc-500'"
          />
        </button>

        <span
          @click="emit('update:modelValue', !modelValue)"
          class="text-zinc-300 select-none cursor-pointer text-sm"
        >
          ✨ Peinture métallisée
        </span>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes draw {
  0% {
    stroke-dasharray: 60;
    stroke-dashoffset: 60;
  }
  100% {
    stroke-dasharray: 60;
    stroke-dashoffset: 0;
  }
}

.animate-draw {
  animation: draw 0.3s ease forwards;
}
</style>
