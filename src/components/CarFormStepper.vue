<!-- CarFormStepper.vue -->
<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { ChevronLeftIcon, ChevronRightIcon } from 'lucide-vue-next'

const currentStep = ref(0)

const steps = [
  { title: 'Couleur', icon: '🎨', key: 'color' },
  { title: 'Carburant', icon: '⛽', key: 'energy' },
  { title: 'Boîte de vitesses', icon: '⚙️', key: 'transmission' },
  { title: 'État du véhicule', icon: '🚗', key: 'firstHand' },
  { title: 'Nombre de portes', icon: '🚪', key: 'doors' }
]

const canGoNext = computed(() => currentStep.value < steps.length - 1)
const canGoPrevious = computed(() => currentStep.value > 0)

const goToNextStep = () => {
  if (canGoNext.value) {
    currentStep.value++
  }
}

const goToPreviousStep = () => {
  if (canGoPrevious.value) {
    currentStep.value--
  }
}

const goToStep = (index: number) => {
  currentStep.value = index
}

const emit = defineEmits(['update:step'])

watch(currentStep, (newStep) => {
  emit('update:step', steps[newStep].key)
})
</script>

<template>
  <div class="w-full space-y-5">
    <!-- Progress bar -->
    <div class="flex items-center justify-between mb-4">
      <template v-for="(step, index) in steps" :key="step.title">
        <div class="flex items-center"
             :class="[
               index === steps.length - 1 ? 'flex-initial' : 'flex-1'
             ]">
          <button
            @click="goToStep(index)"
            :class="[
              'w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium shrink-0',
              'transition-all duration-200 hover:scale-110',
              index === currentStep ? 'bg-emerald-500 text-white' :
              index < currentStep ? 'bg-emerald-500/20 text-emerald-500' :
              'bg-zinc-800 text-zinc-500 hover:bg-zinc-700 hover:text-zinc-300'
            ]"
          >
            {{ step.icon }}
          </button>
          <div v-if="index < steps.length - 1"
               :class="[
                 'h-1 mx-2 flex-1 rounded',
                 index < currentStep ? 'bg-emerald-500' : 'bg-zinc-800'
               ]" />
        </div>
      </template>
    </div>

    <!-- Navigation -->
    <div class="flex items-center justify-between">
      <button @click="goToPreviousStep"
              :disabled="!canGoPrevious"
              class="p-2 rounded-lg border border-zinc-700 text-zinc-400 disabled:opacity-50
                     disabled:cursor-not-allowed hover:bg-zinc-800 transition-colors">
        <ChevronLeftIcon class="w-5 h-5" />
      </button>

      <span class="text-zinc-400 font-medium">
        {{ steps[currentStep].title }}
      </span>

      <button @click="goToNextStep"
              :disabled="!canGoNext"
              class="p-2 rounded-lg border border-zinc-700 text-zinc-400 disabled:opacity-50
                     disabled:cursor-not-allowed hover:bg-zinc-800 transition-colors">
        <ChevronRightIcon class="w-5 h-5" />
      </button>
    </div>

    <!-- Content -->
    <div class="relative min-h-[120px]">
      <TransitionGroup
        name="slide"
        tag="div"
        class="absolute w-full">
        <div v-for="(step, index) in steps"
             :key="step.key"
             v-show="currentStep === index"
             class="w-full">
          <slot :name="step.key" />
        </div>
      </TransitionGroup>
    </div>
  </div>
</template>

<style scoped>
.slide-enter-active {
  transition: all 0.3s ease-out;
}
.slide-leave-active {
  transition: all 0s ease-out;
}

.slide-enter-from {
  opacity: 0;
  transform: translateX(20px);
}

.slide-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}

.slide-enter-to,
.slide-leave-from {
  opacity: 1;
  transform: translateX(0);
}
</style>
