<template>
  <div class="edit-resume">
    <div class="container py-4">
      <div v-if="error && error === 'not-found'" class="alert alert-danger">
        Резюме с указанным ID не найдено.
      </div>

      <div v-else>
        <div class="d-flex justify-content-between align-items-center mb-4">
          <h1>Редактирование резюме</h1>
          <router-link to="/" class="btn btn-secondary">
            Назад к списку
          </router-link>
        </div>

        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border" role="status">
            <span class="visually-hidden">Загрузка...</span>
          </div>
        </div>

        <ResumeForm
          v-else-if="resumeData"
          :initial-data="resumeData"
          @apply="handleApply"
          :loading="saving"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useStore } from 'vuex'
import ResumeForm from '../components/ResumeForm.vue'

const router = useRouter()
const route = useRoute()
const store = useStore()

const resumeData = ref(null)
const loading = ref(true)
const saving = ref(false)
const error = ref(null)

onMounted(async () => {
  const id = parseInt(route.params.id)
  
  try {
    const data = await store.dispatch('fetchResumeById', id)
    resumeData.value = data
  } catch (err) {
    if (err.response && err.response.status === 404) {
      error.value = 'not-found'
    } else {
      error.value = 'Ошибка загрузки резюме'
    }
  } finally {
    loading.value = false
  }
})

const handleApply = async (formData) => {
  const id = parseInt(route.params.id)
  saving.value = true
  
  try {
    await store.dispatch('updateResume', { id, resumeData: formData })
    router.push('/')
  } catch (err) {
    alert('Ошибка при сохранении резюме: ' + err.message)
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.edit-resume {
  min-height: 100vh;
  background: #f5f5f5;
  padding: 2rem 0;
}
</style>

