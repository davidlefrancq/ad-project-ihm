<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { CarIcon, SearchIcon, CheckIcon } from 'lucide-vue-next'
import Papa from 'papaparse'

const API_URL = `${import.meta.env.VITE_API_URL}/predict`

interface CarData {
  id: number
  carmodel: string
  price: string
  year: string
  energy: string
  gearbox: string
  color: string
  doors: string
  firsthand: string
  power: string
}

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
  { name: 'hydrogène', icon: '💧' },
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
const searchQuery = ref('')
const selectedColor = ref('')
const selectedEnergy = ref('')
const selectedTransmission = ref<boolean | null>(null)
const selectedFirstHand = ref<boolean | null>(null)
const carsData = ref<CarData[]>([])
const hasSearched = ref(false)
const selectedCar = ref<CarData | null>(null)
const selectedDoors = ref<number | null>(null)
const mileage = ref('')
const horsepower = ref('')
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



const estimatePrice = async () => {
  isEstimating.value = true
  showEstimation.value = false

  const data = {
    carmodel: selectedCar.value?.carmodel.trim().replace(/[\r\n]+/g, ''),
    year: selectedCar.value?.year,
    color: selectedColor.value,
    metallic_color: false,
    energy: selectedEnergy.value,
    gearbox: selectedTransmission.value ? 'mécanique' : 'automatique',
    first_hand: selectedFirstHand.value,
    doors: selectedDoors.value,
    mileage: parseInt(mileage.value),
    power: parseInt(horsepower.value)
  }

  console.log('Estimation data:', data)

  try {
    // // Simulation API call
    // await new Promise(resolve => setTimeout(resolve, 1500))
    // estimatedPrice.value = Math.floor(Math.random() * 30000) + 10000 // À remplacer par votre vrai appel API
    // showEstimation.value = true
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
      .catch((error) => console.error('Erreur estimation:', error))
  } catch (error) {
    console.error('Erreur estimation:', error)
  } finally {
    isEstimating.value = false
  }
}

const validateNumber = (value: string) => {
  const num = parseInt(value)
  return !isNaN(num) && num >= 0 ? value : ''
}

const uniqueMatchingCars = computed(() => {
  if (!searchQuery.value.trim() || isLoading.value) return []
  const searchTerms = searchQuery.value.toLowerCase().split(' ').filter(term => term.length > 0)
  const matches = carsData.value.filter(car =>
    searchTerms.every(term => car.carmodel.toLowerCase().includes(term))
  )
  return Array.from(new Map(matches.map(car => [car.carmodel, car])).values())
})

const loadCarsData = async () => {
  try {
    isLoading.value = true
    const response = await fetch('/src/dataset/dataset.csv')
    const csvText = await response.text()
    Papa.parse<CarData>(csvText, {
      header: true,
      complete: (results) => {
        carsData.value = results.data.filter((car) => car.carmodel) as CarData[]
      },
      error: (error) => console.error('Erreur lors du parsing CSV:', error)
    })
  } catch (e) {
    console.error('Erreur lors du chargement du CSV:', e)
  } finally {
    isLoading.value = false
  }
}

const selectCar = (car: CarData) => {
  selectedCar.value = car
  searchQuery.value = car.carmodel
  hasSearched.value = false
}

const selectColor = (color: string) => {
  selectedColor.value = color === selectedColor.value ? '' : color
}

const selectEnergy = (energy: string) => {
  selectedEnergy.value = energy === selectedEnergy.value ? '' : energy
}

onMounted(loadCarsData)
</script>

<template>
  <div class="w-full max-w-2xl mx-auto p-4">
    <div class="rounded-xl border border-zinc-800 bg-zinc-900 shadow-lg backdrop-blur-xl">
      <div class="p-6">
        <h3 class="flex items-center gap-2 text-2xl font-medium text-zinc-100 mb-8">
          <CarIcon class="w-6 h-6 text-emerald-500" />Recherche de voiture
        </h3>

        <div class="space-y-8">
          <!-- Recherche -->
          <div class="relative transition-all duration-200 hover:scale-[1.01]">
            <SearchIcon class="absolute left-3 top-3 h-5 w-5 text-zinc-500" />
            <input v-model="searchQuery"
                   type="text"
                   class="w-full h-12 pl-10 pr-4 rounded-xl bg-zinc-800/50 border border-zinc-700 text-zinc-100 placeholder-zinc-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 focus:border-emerald-500 transition-all duration-200"
                   placeholder="Rechercher un modèle..."
                   @input="hasSearched = true">

            <!-- Résultats de recherche -->
            <div v-if="hasSearched && uniqueMatchingCars.length > 0"
                 class="absolute z-10 w-full mt-1 border border-zinc-800 rounded-xl bg-zinc-900/95 backdrop-blur-xl shadow-xl">
              <div class="max-h-[300px] overflow-y-auto">
                <button v-for="car in uniqueMatchingCars"
                        :key="car.id"
                        @click="selectCar(car)"
                        class="w-full flex items-center space-x-4 p-4 text-left border-b border-zinc-800 hover:bg-zinc-800/50 transition-all duration-200 last:border-b-0">
                  <CarIcon class="h-5 w-5 text-emerald-500" />
                  <span class="text-zinc-100">{{ car.carmodel }}</span>
                </button>
              </div>
            </div>
          </div>

          <div v-if="selectedCar" class="space-y-6">
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
            <div v-if="selectedCar" class="p-4 rounded-xl border border-zinc-700 bg-zinc-800/30 backdrop-blur-xl space-y-2">
              <h4 class="text-lg font-medium text-emerald-500">Sélection</h4>
              <div class="space-y-2">
                <p class="text-zinc-100">{{ selectedCar.carmodel }}</p>
                <div class="flex flex-wrap gap-2">
                  <span v-if="selectedColor"
                        class="inline-flex items-center px-3 py-1 rounded-lg bg-zinc-800 text-zinc-300 text-sm">
                    <span class="w-2 h-2 rounded-full mr-2"
                          :style="{ backgroundColor: colorList.find(c => c.name === selectedColor)?.hex }">
                    </span>
                    <span class="capitalize">{{ selectedColor }}</span>
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
                  <span v-if="selectedFirstHand !== null"
                        class="capitalize inline-flex items-center px-3 py-1 rounded-lg bg-zinc-800 text-zinc-300 text-sm">
                    {{ selectedFirstHand ? '🆕 1ère main' : '🔄 Occasion' }}
                  </span>
                  <span v-if="selectedDoors"
                        class="capitalize inline-flex items-center px-3 py-1 rounded-lg bg-zinc-800 text-zinc-300 text-sm">
                    🚪 {{ selectedDoors }} Portes
                  </span>
                </div>
              </div>
            </div>

            <!-- Kilométrage et puissance (visible si nombre de portes sélectionné) -->
            <div v-if="searchQuery" class="space-y-2">
              <div class="flex gap-3">
                <div class="flex-[2] relative">
                  <input v-model="mileage"
                        @input="mileage = validateNumber($event?.target?.value)"
                        type="number"
                        min="0"
                        class="w-full h-12 px-4 rounded-xl bg-zinc-800/50 border border-zinc-700 text-zinc-100 placeholder-zinc-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 focus:border-emerald-500"
                        placeholder="Kilométrage">
                  <span class="absolute right-4 top-3 text-zinc-500">km</span>
                </div>

                <div class="flex-1 relative">
                  <input v-model="horsepower"
                        @input="horsepower = validateNumber($event?.target?.value)"
                        type="number"
                        min="0"
                        class="w-full h-12 px-4 rounded-xl bg-zinc-800/50 border border-zinc-700 text-zinc-100 placeholder-zinc-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 focus:border-emerald-500"
                        placeholder="CV Fiscaux">
                  <span class="absolute right-4 top-3 text-zinc-500">CV</span>
                </div>
              </div>
            </div>

            <!-- Bouton estimer -->
            <button @click="estimatePrice"
                    :disabled="!mileage || !horsepower || !selectedDoors || !selectedFirstHand || !selectedTransmission || !selectedEnergy || !selectedColor"
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

            <!-- Résultat estimation -->
            <div v-if="showEstimation"
                class="p-6 rounded-xl border border-emerald-500 bg-emerald-500/10 space-y-4"
                :class="{'animate-fade-in': showEstimation}">
              <h4 class="text-lg font-medium text-emerald-500">Estimation</h4>
              <div class="text-center">
                <span class="text-3xl font-bold text-white">
                  {{ estimatedPrice?.toLocaleString() }} €
                </span>
              </div>
            </div>

          </div>

          <!-- Couleur (visible si voiture sélectionnée) -->
          <div v-if="selectedCar" class="space-y-2">
            <h4 class="text-sm font-medium text-zinc-400">Couleur</h4>
            <div class="flex flex-wrap gap-3">
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
          </div>

          <!-- Carburant (visible si couleur sélectionnée) -->
          <div v-if="selectedColor" class="space-y-2">
            <h4 class="text-sm font-medium text-zinc-400">Type de carburant</h4>
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

          <!-- Boîte (visible si carburant sélectionné) -->
          <div v-if="selectedEnergy" class="space-y-2">
            <h4 class="text-sm font-medium text-zinc-400">Type de boîte</h4>
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

          <!-- Première main (visible si boîte sélectionnée) -->
          <div v-if="selectedTransmission !== null" class="space-y-2">
            <h4 class="text-sm font-medium text-zinc-400">État du véhicule</h4>
            <div class="flex gap-3">
              <button @click="selectedFirstHand = true"
                      class="flex-1 px-2 py-2 rounded-xl border transition-all duration-200 hover:scale-[1.02] focus:outline-none"
                      :class="selectedFirstHand === true
                        ? 'border-emerald-500 bg-emerald-500/10 text-emerald-500'
                        : 'border-zinc-700 hover:border-zinc-600 text-zinc-300'">
                <span class="flex items-center justify-center gap-2">
                  <span>🆕</span>
                  <span>Première main</span>
                </span>
              </button>
              <button @click="selectedFirstHand = false"
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

          <!-- Nombre de portes (visible si première main sélectionnée) -->
          <div v-if="selectedFirstHand !== null" class="space-y-2">
            <h4 class="text-sm font-medium text-zinc-400">Nombre de portes</h4>
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

        </div>
      </div>
    </div>
  </div>
</template>
