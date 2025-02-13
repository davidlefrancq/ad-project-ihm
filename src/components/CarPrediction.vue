<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { CarIcon, SearchIcon } from 'lucide-vue-next'
import CarFormStepper from './CarFormStepper.vue'
import CarColorPicker from './CarColorPicker.vue'
import type { IDatasetEncodersValues } from '@/interfaces/IDatasetEncodersValues'

const API_URL = `${import.meta.env.VITE_API_URL}/predict`

const colorList = [
  { name: 'noir', hex: '#111111' },
  { name: 'blanc', hex: '#F5F5F5' },
  { name: 'gris', hex: '#A0A0A0' },
  { name: 'bleu', hex: '#82B1FF' },
  { name: 'rouge', hex: '#FF8A8A' },
  { name: 'vert', hex: '#81C784' },
  { name: 'jaune', hex: '#FFE57F' },
  { name: 'marron', hex: '#8D6E63' },
  { name: 'orange', hex: '#FFB74D' },
  { name: 'violet', hex: '#B39DDB' },
]

const energyList = [
  { name: 'gpl', icon: '🔄' },
  { name: 'hybride', icon: '⚡️' },
  // { name: 'hydrogène', icon: '💧' },
  { name: 'bioéthanol', icon: '🌱' },
  { name: 'electrique', icon: '⚡️' },
  { name: 'essence', icon: '⛽️' },
  { name: 'diesel', icon: '🛢️' },
]

const doorOptions = [2, 3, 4, 5]

interface ErrorNotification {
  id: number
  message: string
}

const isLoading = ref(false)
const modelSearch = ref('')
const carModels = ref<string[]>([])
const selectedModel = ref<string | null>(null)
const selectedColor = ref('')
const selectedEnergy = ref('')
const selectedTransmission = ref<boolean | null>(null)
const selectedFirstHand = ref<boolean | null>(false)
const hasSearched = ref(false)
const selectedDoors = ref<number | null>(null)
const mileage = ref('')
const year = ref('')
const horsepower = ref('')
const isMetallicColor = ref(false)
const estimatedPrice = ref<number | null>(null)
const isEstimating = ref(false)
const showEstimation = ref(false)
const errors = ref<ErrorNotification[]>([])
let nextErrorId = 0

const addError = (message: string) => {
  errors.value.push({
    id: nextErrorId++,
    message
  })
}

const removeError = (id: number) => {
  errors.value = errors.value.filter(error => error.id !== id)
}

const clearData = () => {
  modelSearch.value = ''
  selectedModel.value = null
  selectedColor.value = ''
  selectedEnergy.value = ''
  selectedTransmission.value = null
  selectedFirstHand.value = null
  selectedDoors.value = null
  mileage.value = ''
  year.value = ''
  horsepower.value = ''
  isMetallicColor.value = false
  estimatedPrice.value = null
  showEstimation.value = false
  errors.value = []
  nextErrorId = 0
}

const estimatePrice = async () => {
  isEstimating.value = true
  showEstimation.value = false

  const data = {
    carmodel: selectedModel.value?.trim().replace(/[\r\n]+/g, ''),
    year: year.value,
    color: selectedColor.value,
    metallic_color: isMetallicColor.value,
    energy: selectedEnergy.value,
    gearbox: selectedTransmission.value ? 'mécanique' : 'automatique',
    first_hand: selectedFirstHand.value,
    doors: selectedDoors.value,
    mileage: parseInt(mileage.value),
    power: parseInt(horsepower.value)
  }

  console.log('Estimation data:', data)

  try {
    fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    })
      .then(response => response.json())
      .then((data) => {
        console.log('Estimation:', data)
        if (data && data.detail) {
          console.error(data.detail)
          addError('Erreur lors de l\'estimation.')
          return
        }
        estimatedPrice.value = data.price
        showEstimation.value = true
      })
      .catch((error: Error) => console.error('Erreur estimation:', error))
  } catch (error) {
    console.error('Erreur estimation:', error as Error)
  } finally {
    isEstimating.value = false
  }
}

const validateNumber = (value: string) => {
  const num = parseInt(value)
  return !isNaN(num) && num >= 0 ? value : ''
}

const matchingModels = computed(() => {
  if (!modelSearch.value.trim() || isLoading.value) return []
  const searchTerms = modelSearch.value.toLowerCase().split(' ').filter(term => term.length > 0)
  return carModels.value.filter(model =>
    searchTerms.every(term => model.toLowerCase().includes(term))
  ).slice(0, 10)
})

// Sélection d'un modèle
const selectModel = (model: string) => {
  selectedModel.value = model
  modelSearch.value = model
  hasSearched.value = false
}

// Chargement du fichier JSON
const loadModels = async () => {
  try {
    isLoading.value = true
    const response = await fetch('/dataset_encoders_values.json')
    const data = await response.json() as IDatasetEncodersValues
    carModels.value = data.carmodel
  } catch (e) {
    console.error('Erreur lors du chargement des modèles:', e)
  } finally {
    isLoading.value = false
  }
}

const selectColor = (color: string) => {
  selectedColor.value = color === selectedColor.value ? '' : color
}

const selectEnergy = (energy: string) => {
  selectedEnergy.value = energy === selectedEnergy.value ? '' : energy
}

onMounted(() => {
  loadModels()
})
</script>

<template>
  <div class="w-full max-w-2xl mx-auto p-4">
    <div class="rounded-xl border border-zinc-800 bg-zinc-900 shadow-lg backdrop-blur-xl">
      <div class="p-6">
        <h3 class="flex items-center gap-2 text-2xl font-medium text-zinc-100 mb-8">
          <CarIcon class="w-6 h-6 text-emerald-500" />Estimation de prix
        </h3>

        <div class="space-y-6">
          <!-- Recherche -->
          <div v-if="!selectedModel" class="relative transition-all duration-200 hover:scale-[1.01]">
            <SearchIcon class="absolute left-3 top-3 h-5 w-5 text-zinc-500" />
            <input v-model="modelSearch"
                  type="text"
                  class="uppercase w-full h-12 pl-10 pr-4 rounded-xl bg-zinc-800/50 border border-zinc-700 text-zinc-100 placeholder-zinc-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 focus:border-emerald-500 transition-all duration-200"
                  placeholder="Rechercher un modèle..."
                  @input="hasSearched = true">

            <!-- Résultats de recherche -->
            <div v-if="hasSearched && matchingModels.length > 0"
                class="absolute z-10 w-full mt-1 border border-zinc-800 rounded-xl bg-zinc-900/95 backdrop-blur-xl shadow-xl">
              <div class="max-h-[300px] overflow-y-auto">
                <button v-for="model in matchingModels"
                        :key="model"
                        @click="selectModel(model)"
                        class="w-full flex items-center space-x-4 p-4 text-left border-b border-zinc-800 hover:bg-zinc-800/50 transition-all duration-200 last:border-b-0">
                  <CarIcon class="h-5 w-5 text-emerald-500" />
                  <span class="uppercase text-zinc-100">{{ model }}</span>
                </button>
              </div>
            </div>
          </div>

          <div v-if="selectedModel" class="space-y-6">
          <!-- Erreurs -->
          <TransitionGroup
            tag="div"
            enter-active-class="transition duration-300 ease-out"
            enter-from-class="transform -translate-y-2 opacity-0"
            enter-to-class="transform translate-y-0 opacity-100"
            leave-active-class="transition duration-200 ease-in"
            leave-from-class="transform translate-y-0 opacity-100"
            leave-to-class="transform -translate-y-2 opacity-0"
            class="space-y-2 mb-6"
          >
            <div v-for="error in errors"
                :key="error.id"
                class="group flex items-center justify-between gap-4 px-4 py-3 rounded-xl bg-zinc-800 border border-red-500/50 shadow-lg backdrop-blur-sm transition-all duration-300 hover:bg-zinc-800/80">
              <div class="flex items-center gap-3">
                <div class="flex-shrink-0 w-8 h-8 rounded-full bg-red-500/10 flex items-center justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-red-500" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                  </svg>
                </div>
                <p class="text-red-500/90 font-medium">{{ error.message }}</p>
              </div>
              <button @click="removeError(error.id)"
                      class="flex-shrink-0 p-2 rounded-lg hover:bg-zinc-700 text-zinc-400 hover:text-zinc-300 opacity-0 group-hover:opacity-100 transition-all duration-200">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>
                </svg>
              </button>
            </div>
          </TransitionGroup>

            <!-- Récapitulatif -->
            <div v-if="selectedModel" class="p-4 rounded-xl border border-zinc-700 bg-zinc-800/30 backdrop-blur-xl space-y-2">
              <h4 class="uppercase text-lg font-medium text-emerald-500">{{ selectedModel }}</h4>
              <div class="space-y-2">
                <div class="flex flex-wrap gap-2">
                  <span v-if="selectedColor"
                        class="inline-flex items-center px-3 py-1 rounded-lg bg-zinc-800 text-zinc-300 text-sm">
                    <span class="w-2 h-2 rounded-full mr-2"
                          :style="{ backgroundColor: colorList.find(c => c.name === selectedColor)?.hex }">
                    </span>
                    <span class="capitalize">{{ selectedColor }}</span>
                    <span v-if="isMetallicColor" class="lowercase ml-1">métallisé</span>
                  </span>
                  <span v-if="selectedEnergy"
                        class="inline-flex items-center px-3 py-1 rounded-lg bg-zinc-800 text-zinc-300 text-sm">
                    {{ energyList.find(e => e.name === selectedEnergy)?.icon }}
                    <span class="capitalize ml-2">{{ selectedEnergy }}</span>
                  </span>
                  <span v-if="selectedTransmission !== null"
                        class="inline-flex items-center px-3 py-1 rounded-lg bg-zinc-800 text-zinc-300 text-sm">
                    {{ selectedTransmission ? '🔧 Manuelle' : '⚙️ Automatique' }}
                  </span>
                  <span v-if="selectedFirstHand !== null && selectedFirstHand !== false"
                        class="capitalize inline-flex items-center px-3 py-1 rounded-lg bg-zinc-800 text-zinc-300 text-sm">
                    {{ selectedFirstHand ? '🆕 1ère main' : null }}
                  </span>
                  <span v-if="selectedDoors"
                        class="capitalize inline-flex items-center px-3 py-1 rounded-lg bg-zinc-800 text-zinc-300 text-sm">
                    🚪 {{ selectedDoors }} Portes
                  </span>
                </div>
              </div>
            </div>

            <!-- Kilométrage, puissance et année (visible si nombre de portes sélectionné) -->
            <div v-if="selectedModel" class="space-y-2">
              <div class="flex gap-3">
                <div class="flex-[2] relative">
                  <input v-model="mileage"
                        @input="(e: Event) => mileage = validateNumber((e.target as HTMLInputElement).value)"
                        type="number"
                        min="0"
                        class="w-full h-12 px-4 rounded-xl bg-zinc-800/50 border border-zinc-700 text-zinc-100 placeholder-zinc-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 focus:border-emerald-500"
                        placeholder="Kilométrage">
                  <span class="absolute right-4 top-3 text-zinc-500">km</span>
                </div>

                <div class="flex-1 relative">
                  <input v-model="horsepower"
                        @input="(e: Event) => horsepower = validateNumber((e.target as HTMLInputElement).value)"
                        type="number"
                        min="0"
                        class="w-full h-12 px-4 rounded-xl bg-zinc-800/50 border border-zinc-700 text-zinc-100 placeholder-zinc-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 focus:border-emerald-500"
                        placeholder="CV Fiscaux">
                  <span class="absolute right-4 top-3 text-zinc-500">CV</span>
                </div>

                <div class="flex-1 relative">
                  <input v-model="year"
                        type="number"
                        min="1900"
                        :max="new Date().getFullYear()"
                        class="w-full h-12 px-4 rounded-xl bg-zinc-800/50 border border-zinc-700 text-zinc-100 placeholder-zinc-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 focus:border-emerald-500"
                        placeholder="Année">
                </div>
              </div>
            </div>
          </div>

          <div v-if="selectedModel && !showEstimation" class="space-y-6">
            <CarFormStepper v-if="selectedModel">
              <!-- Couleur et option métallisé -->
              <template #color>
                <CarColorPicker
                  v-model="isMetallicColor"
                  :color-list="colorList"
                  :selected-color="selectedColor"
                  @select:color="selectColor"
                />
              </template>

              <!-- Carburant (visible si couleur sélectionnée) -->
              <template #energy>
                <div class="space-y-2">
                  <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                    <button v-for="energy in energyList"
                            :key="energy.name"
                            @click="selectEnergy(energy.name)"
                            class="px-2 py-2 rounded-xl border text-sm text-left transition-all duration-200 hover:scale-[1.02] focus:outline-none"
                            :class="selectedEnergy === energy.name
                              ? 'border-emerald-500 bg-emerald-500/10 text-emerald-500'
                              : 'border-zinc-700 hover:border-zinc-600 text-zinc-300'">
                      <span class="flex items-center gap-2">
                        <span class="text-lg">{{ energy.icon }}</span>
                        <span class="capitalize">{{ energy.name }}</span>
                      </span>
                    </button>
                  </div>
                </div>
              </template>

              <!-- Boîte (visible si carburant sélectionné) -->
              <template #transmission>
                <div class="space-y-2">
                  <div class="flex gap-3">
                    <button @click="selectedTransmission = true"
                            class="flex-1 px-2 py-2 rounded-xl border transition-all duration-200 hover:scale-[1.02] focus:outline-none"
                            :class="selectedTransmission === true
                              ? 'border-emerald-500 bg-emerald-500/10 text-emerald-500'
                              : 'border-zinc-700 hover:border-zinc-600 text-zinc-300'">
                      <span class="flex items-center justify-center gap-2">
                        <span>🔧</span>
                        <span>Manuelle</span>
                      </span>
                    </button>
                    <button @click="selectedTransmission = false"
                            class="flex-1 px-2 py-2 rounded-xl border transition-all duration-200 hover:scale-[1.02] focus:outline-none"
                            :class="selectedTransmission === false
                              ? 'border-emerald-500 bg-emerald-500/10 text-emerald-500'
                              : 'border-zinc-700 hover:border-zinc-600 text-zinc-300'">
                      <span class="flex items-center justify-center gap-2">
                        <span>⚙️</span>
                        <span>Automatique</span>
                      </span>
                    </button>
                  </div>
                </div>
              </template>

              <!-- Première main -->
              <template #firstHand>
              <div class="space-y-2">
                <div class="flex gap-3">
                  <button @click="selectedFirstHand = !selectedFirstHand"
                          class="flex-1 px-2 py-2 rounded-xl border transition-all duration-200 hover:scale-[1.02] focus:outline-none"
                          :class="selectedFirstHand === true
                            ? 'border-emerald-500 bg-emerald-500/10 text-emerald-500'
                            : 'border-zinc-700 hover:border-zinc-600 text-zinc-300'">
                    <span class="flex items-center justify-center gap-2">
                      <span>🆕</span>
                      <span>Première main</span>
                    </span>
                  </button>
                  <button @click="selectedFirstHand = !selectedFirstHand"
                          class="flex-1 px-2 py-2 rounded-xl border transition-all duration-200 hover:scale-[1.02] focus:outline-none"
                          :class="selectedFirstHand === false
                            ? 'border-emerald-500 bg-emerald-500/10 text-emerald-500'
                            : 'border-zinc-700 hover:border-zinc-600 text-zinc-300'">
                    <span class="flex items-center justify-center gap-2">
                      <span>🔄</span>
                      <span>Occasion</span>
                    </span>
                  </button>
                </div>
              </div>
              </template>

              <!-- Nombre de portes -->
              <template #doors>
              <div class="space-y-2">
                <div class="flex gap-3">
                  <button v-for="doors in doorOptions"
                          :key="doors"
                          @click="selectedDoors = doors === selectedDoors ? null : doors"
                          class="flex-1 px-2 py-2 rounded-xl border transition-all duration-200 hover:scale-[1.02] focus:outline-none"
                          :class="selectedDoors === doors
                            ? 'border-emerald-500 bg-emerald-500/10 text-emerald-500'
                            : 'border-zinc-700 hover:border-zinc-600 text-zinc-300'">
                    <span class="flex items-center justify-center gap-2">
                      <span>{{ doors }}</span>
                    </span>
                  </button>
                </div>
              </div>
              </template>
            </CarFormStepper>
          </div>

          <div v-if="selectedModel" class="space-y-6">

            <!-- Résultat estimation -->
            <div v-if="showEstimation"
                class="p-6 rounded-xl border border-emerald-500 bg-emerald-500/10"
                :class="{'animate-fade-in': showEstimation}">
              <div class="flex items-center relative">
                <h4 class="text-lg font-medium text-emerald-500 absolute left-0">Estimation</h4>
                <div class="flex-1 text-center">
                  <span class="text-3xl font-bold text-white">
                    {{ estimatedPrice ? Math.round(estimatedPrice)?.toLocaleString() : 0 }} €
                  </span>
                </div>
              </div>
            </div>

            <!-- Bouton estimer -->
            <button @click="estimatePrice"
                    :disabled="!mileage || !horsepower || !selectedDoors || selectedTransmission===null || !selectedEnergy || !selectedColor || !year"
                    class="w-full px-4 py-3 rounded-xl text-white font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                    :class="isEstimating ? 'bg-zinc-600' : 'bg-emerald-500 hover:bg-emerald-600'">
                <span v-if="isEstimating" class="flex items-center justify-center gap-2">
                  <svg class="animate-spin h-5 w-5" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"/>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
                  </svg>
                  Estimation en cours...
                </span>
                <span v-else>
                  Estimer le prix
                </span>
            </button>

            <!-- Clear data button aligned end-end -->
            <div class="flex justify-center">
              <button @click="clearData"
                class="text-emerald-500 hover:text-emerald-600 focus:outline-none">
                Reset
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
