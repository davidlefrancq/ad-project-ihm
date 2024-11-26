<template>
  <div class="api-status">
    <div class="card">
      <h2 class="title">Prediction</h2>

      <div class="status-container">
        <div v-if="apiResponse" class="status-info" :class="{ 'status-ok': apiResponse.status === 'ok' }">
          <div class="status-indicator"></div>
          <div class="message">{{ apiResponse.message }}</div>
        </div>

        <div v-if="error" class="error-message">
          {{ error }}
        </div>
      </div>

      <button
        @click="checkApiStatus"
        class="check-button"
        :disabled="isLoading"
      >
        <span v-if="isLoading">Vérification...</span>
        <span v-else>Vérifier le statut</span>
      </button>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue'

interface ApiResponse {
  status: string
  message: string
}

export default defineComponent({
  name: 'ApiStatus',
  setup() {
    const apiResponse = ref<ApiResponse | null>(null)
    const error = ref<string | null>(null)
    const isLoading = ref(false)

    const checkApiStatus = async () => {
      isLoading.value = true
      error.value = null

      try {
        const response = await fetch('http://57.128.24.53:8394')

        if (!response.ok) {
          throw new Error('Erreur lors de la communication avec l\'API')
        }

        const data = await response.json()
        apiResponse.value = data
      } catch (e) {
        error.value = e instanceof Error ? e.message : 'Une erreur est survenue'
      } finally {
        isLoading.value = false
      }
    }

    return {
      apiResponse,
      error,
      isLoading,
      checkApiStatus
    }
  }
})
</script>

<style scoped>
.api-status {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 50vh;
  padding: 1rem;
}

.card {
  background: #1a1a1a; /* Fond sombre */
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.5);
  width: 100%;
  max-width: 500px;
  border: 1px solid #333; /* Bordure subtile */
}

.title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #e5e7eb; /* Texte clair */
  margin-bottom: 1.5rem;
  text-align: center;
}

.status-container {
  margin-bottom: 1.5rem;
  min-height: 60px;
}

.status-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  background-color: #27272a; /* Fond légèrement plus clair */
  border-radius: 8px;
  border: 1px solid #333;
}

.message {
  color: #e5e7eb; /* Texte clair */
  font-size: 1rem;
}

.status-indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background-color: #4b5563; /* Gris plus foncé */
}

.status-ok .status-indicator {
  background-color: #059669; /* Vert plus foncé */
}

.error-message {
  color: #ef4444; /* Rouge plus vif */
  padding: 1rem;
  background-color: rgba(239, 68, 68, 0.1); /* Rouge très transparent */
  border-radius: 8px;
  border: 1px solid #ef4444;
}

.check-button {
  width: 100%;
  padding: 0.75rem 1.5rem;
  background-color: #2563eb; /* Bleu plus foncé */
  color: #e5e7eb;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.check-button:hover {
  background-color: #1d4ed8; /* Bleu encore plus foncé au hover */
  transform: translateY(-1px);
}

.check-button:disabled {
  background-color: #4b5563; /* Gris foncé */
  cursor: not-allowed;
  transform: none;
}
</style>
