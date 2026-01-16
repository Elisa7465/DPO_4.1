<template>
  <div class="home">
    <div class="container py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="mb-0">База данных резюме</h1>
        <router-link to="/add" class="btn btn-primary btn-lg">
          Новое резюме
        </router-link>
      </div>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Загрузка...</span>
        </div>
      </div>

      <div v-else class="resumes-board">
        <div class="row g-3">
          <div
            v-for="status in statuses"
            :key="status"
            class="col-md-3"
          >
            <div class="status-column">
              <div class="status-header">
                <h3>{{ status }} ({{ resumeCounts[status] }})</h3>
              </div>
              <draggable
                :list="resumesByStatus[status]"
                :group="{ name: 'resumes', pull: true, put: true }"
                item-key="id"
                @end="onDragEnd"
                class="resumes-list"
              >
                <template #item="{ element }">
                  <div
                    class="resume-card"
                    @click="goToEdit(element.id)"
                  >
                    <div class="resume-photo-container">
                      <img
                        v-if="element.photoUrl"
                        :src="element.photoUrl"
                        alt="Фото"
                        class="resume-photo-small"
                        @error="handleImageError"
                      />
                      <div v-else class="resume-photo-placeholder">
                        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                          <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                          <circle cx="12" cy="7" r="4"></circle>
                        </svg>
                      </div>
                    </div>
                    <div class="resume-info">
                      <div class="resume-profession">{{ element.profession || 'Не указано' }}</div>
                      <div class="resume-name">{{ element.fullName || 'Не указано' }}</div>
                      <div v-if="element.age" class="resume-age">Возраст: {{ element.age }}</div>
                    </div>
                  </div>
                </template>
              </draggable>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useStore } from 'vuex'
import draggable from 'vuedraggable'

const router = useRouter()
const store = useStore()

const statuses = ['Новый', 'Назначено собеседование', 'Принят', 'Отказ']

const resumesByStatus = computed(() => store.getters.resumesByStatus)
const resumeCounts = computed(() => store.getters.resumeCounts)
const loading = computed(() => store.state.loading)

onMounted(() => {
  store.dispatch('fetchResumes')
})

const onDragEnd = async (event) => {
  const resume = event.item.__draggable_context__.element
  const newStatus = event.to.closest('.status-column').querySelector('.status-header h3').textContent.split(' (')[0]
  
  if (resume.status !== newStatus) {
    try {
      await store.dispatch('updateResumeStatus', {
        id: resume.id,
        status: newStatus
      })
    } catch (error) {
      console.error('Error updating status:', error)
      // Откатываем изменения в UI
      store.dispatch('fetchResumes')
    }
  }
}

const goToEdit = (id) => {
  router.push(`/edit/${id}`)
}

const handleImageError = (event) => {
  event.target.style.display = 'none'
}
</script>

<style scoped>
.home {
  min-height: 100vh;
  background: #f5f5f5;
  padding: 2rem 0;
}

.resumes-board {
  margin-top: 2rem;
}

.status-column {
  background: white;
  border-radius: 8px;
  padding: 1rem;
  min-height: 400px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.status-header {
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #e9ecef;
}

.status-header h3 {
  font-size: 1.1rem;
  font-weight: 600;
  color: #212529;
  margin: 0;
}

.resumes-list {
  min-height: 300px;
}

.resume-card {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  padding: 1rem;
  margin-bottom: 0.75rem;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  gap: 1rem;
}

.resume-card:hover {
  background: #e9ecef;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  transform: translateY(-2px);
}

.resume-photo-container {
  flex-shrink: 0;
}

.resume-photo-small {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #dee2e6;
}

.resume-photo-placeholder {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #adb5bd;
  border: 2px solid #dee2e6;
}

.resume-info {
  flex: 1;
  min-width: 0;
}

.resume-profession {
  font-weight: 600;
  color: #212529;
  margin-bottom: 0.25rem;
  font-size: 0.95rem;
}

.resume-name {
  color: #495057;
  margin-bottom: 0.25rem;
  font-size: 0.9rem;
}

.resume-age {
  color: #6c757d;
  font-size: 0.85rem;
}
</style>

