<template>
  <div class="add-resume">
    <div class="container py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>Добавление резюме</h1>
        <router-link to="/" class="btn btn-secondary">
          Назад к списку
        </router-link>
      </div>

      <ResumeForm
        @apply="handleApply"
        :loading="loading"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useStore } from 'vuex'
import ResumeForm from '../components/ResumeForm.vue'

const router = useRouter()
const store = useStore()
const loading = ref(false)

const handleApply = async (formData) => {
  loading.value = true
  try {
    await store.dispatch('addResume', formData)
    router.push('/')
  } catch (error) {
    alert('Ошибка при добавлении резюме: ' + error.message)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.add-resume {
  min-height: 100vh;
  background: #f5f5f5;
  padding: 2rem 0;
}
</style>

