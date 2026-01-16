<template>
  <div class="resume-view">
    <div class="resume-container">
      <!-- Заголовок резюме -->
      <div class="resume-header mb-4">
        <div class="row align-items-center">
          <div class="col-md-3 text-center">
            <div class="photo-container">
              <img
                v-if="displayPhotoUrl && !imageError"
                :src="displayPhotoUrl"
                alt="Фото"
                class="resume-photo"
                @error="handleImageError"
                @load="imageError = false"
              />
              <div v-else class="photo-placeholder">
                <svg width="100" height="100" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                  <circle cx="12" cy="7" r="4"></circle>
                </svg>
              </div>
            </div>
          </div>
          <div class="col-md-9">
            <h1 class="resume-name">{{ displayName }}</h1>
            <p class="resume-profession text-muted">{{ displayProfession }}</p>
            <div class="resume-location">
              <span v-if="displayCity">{{ displayCity }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Контактная информация -->
      <div class="resume-section mb-4" v-if="hasContactInfo">
        <h3 class="section-title">Контактная информация</h3>
        <div class="row">
          <div class="col-md-6" v-if="displayPhone">
            <p><strong>Телефон:</strong> {{ displayPhone }}</p>
          </div>
          <div class="col-md-6" v-if="displayEmail">
            <p><strong>Email:</strong> {{ displayEmail }}</p>
          </div>
        </div>
      </div>

      <!-- Личная информация -->
      <div class="resume-section mb-4" v-if="hasPersonalInfo">
        <h3 class="section-title">Личная информация</h3>
        <div class="row">
          <div class="col-md-6" v-if="displayBirthDate">
            <p><strong>Дата рождения:</strong> {{ displayBirthDate }}</p>
          </div>
        </div>
      </div>

      <!-- Статус -->
      <div class="resume-section mb-4" v-if="displayStatus">
        <h3 class="section-title">Статус</h3>
        <p>
          <span :class="statusBadgeClass">{{ displayStatus }}</span>
        </p>
      </div>

      <!-- Образование -->
      <div class="resume-section mb-4" v-if="hasEducation">
        <h3 class="section-title">Образование</h3>
        <div class="education-info">
          <p class="education-level"><strong>{{ displayEducationLevel }}</strong></p>
          
          <!-- Отображение нескольких образований -->
          <div v-if="educationsList.length > 0" class="educations-list">
            <div
              v-for="(education, index) in educationsList"
              :key="index"
              class="education-item"
            >
              <div v-if="hasEducationDetails(education)" class="education-details">
                <p v-if="education.institution"><strong>Учебное заведение:</strong> {{ education.institution }}</p>
                <p v-if="education.faculty"><strong>Факультет:</strong> {{ education.faculty }}</p>
                <p v-if="education.specialization"><strong>Специализация:</strong> {{ education.specialization }}</p>
                <p v-if="education.graduationYear"><strong>Год окончания:</strong> {{ education.graduationYear }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Желаемая зарплата -->
      <div class="resume-section mb-4" v-if="displayDesiredSalary">
        <h3 class="section-title">Желаемая зарплата</h3>
        <p>{{ displayDesiredSalary }}</p>
      </div>

      <!-- Ключевые навыки -->
      <div class="resume-section mb-4" v-if="displaySkills">
        <h3 class="section-title">Ключевые навыки</h3>
        <div class="skills-list">
          <span
            v-for="(skill, index) in skillsArray"
            :key="index"
            class="skill-badge"
          >
            {{ skill }}
          </span>
        </div>
      </div>

      <!-- О себе -->
      <div class="resume-section mb-4" v-if="displayAbout">
        <h3 class="section-title">О себе</h3>
        <p class="about-text">{{ displayAbout }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  resumeData: {
    type: Object,
    default: () => ({})
  }
})

// Computed properties для всех полей
const displayName = computed(() => {
  return props.resumeData.fullName || 'Не указано'
})

const displayProfession = computed(() => {
  return props.resumeData.profession || 'Не указано'
})

const displayCity = computed(() => {
  return props.resumeData.city || ''
})

const displayPhotoUrl = computed(() => {
  const url = props.resumeData?.photoUrl
  if (!url) return ''
  const trimmed = String(url).trim()
  return trimmed !== '' ? trimmed : ''
})

const displayPhone = computed(() => {
  return props.resumeData.phone || ''
})

const displayEmail = computed(() => {
  return props.resumeData.email || ''
})

const displayBirthDate = computed(() => {
  if (!props.resumeData.birthDate) return ''
  const date = new Date(props.resumeData.birthDate)
  return date.toLocaleDateString('ru-RU', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
})

const displayStatus = computed(() => {
  return props.resumeData.status || ''
})

const statusBadgeClass = computed(() => {
  const status = displayStatus.value
  if (status === 'Новый') return 'status-badge status-new'
  if (status === 'Назначено собеседование') return 'status-badge status-interview'
  if (status === 'Принят') return 'status-badge status-accepted'
  if (status === 'Отказ') return 'status-badge status-rejected'
  return 'status-badge'
})

const displayEducationLevel = computed(() => {
  return props.resumeData.educationLevel || ''
})

const educationsList = computed(() => {
  if (props.resumeData.educations && Array.isArray(props.resumeData.educations)) {
    return props.resumeData.educations
  }
  // Поддержка старого формата для обратной совместимости
  if (props.resumeData.institution || props.resumeData.faculty || 
      props.resumeData.specialization || props.resumeData.graduationYear) {
    return [{
      institution: props.resumeData.institution || '',
      faculty: props.resumeData.faculty || '',
      specialization: props.resumeData.specialization || '',
      graduationYear: props.resumeData.graduationYear || ''
    }]
  }
  return []
})

const hasEducation = computed(() => {
  return !!displayEducationLevel.value
})

const hasEducationDetails = (education) => {
  return !!(education.institution || education.faculty || 
           education.specialization || education.graduationYear)
}

const displayDesiredSalary = computed(() => {
  return props.resumeData.desiredSalary || ''
})

const displaySkills = computed(() => {
  return props.resumeData.skills || ''
})

const skillsArray = computed(() => {
  if (!props.resumeData.skills) return []
  return props.resumeData.skills
    .split(',')
    .map(skill => skill.trim())
    .filter(skill => skill.length > 0)
})

const displayAbout = computed(() => {
  return props.resumeData.about || ''
})

const hasContactInfo = computed(() => {
  return displayPhone.value || displayEmail.value
})

const hasPersonalInfo = computed(() => {
  return displayBirthDate.value
})

const imageError = ref(false)

const handleImageError = (event) => {
  imageError.value = true
  event.target.style.display = 'none'
}

// Сбрасываем флаг ошибки при изменении URL
watch(() => props.resumeData.photoUrl, () => {
  imageError.value = false
})
</script>

<style scoped>
.resume-view {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.resume-container {
  max-width: 900px;
  margin: 0 auto;
}

.resume-header {
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 1.5rem;
}

.photo-container {
  margin-bottom: 1rem;
}

.resume-photo {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #dee2e6;
}

.photo-placeholder {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  background: #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  color: #adb5bd;
}

.resume-name {
  font-size: 2rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #212529;
}

.resume-profession {
  font-size: 1.25rem;
  margin-bottom: 0.5rem;
}

.resume-location {
  color: #6c757d;
  font-size: 1rem;
}

.resume-section {
  border-bottom: 1px solid #e9ecef;
  padding-bottom: 1rem;
}

.section-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #212529;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #007bff;
}

.skills-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.skill-badge {
  display: inline-block;
  padding: 0.5rem 1rem;
  background: #e7f3ff;
  color: #0066cc;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 500;
}

.about-text {
  line-height: 1.6;
  color: #495057;
  white-space: pre-wrap;
}

p {
  margin-bottom: 0.5rem;
  color: #495057;
}

.education-info {
  margin-top: 0.5rem;
}

.education-level {
  font-size: 1.1rem;
  margin-bottom: 1rem;
  color: #212529;
}

.education-details {
  margin-left: 1rem;
  padding-left: 1rem;
  border-left: 3px solid #e9ecef;
}

.educations-list {
  margin-top: 0.5rem;
}

.education-item {
  margin-bottom: 1.5rem;
}

.education-item:not(:last-child) {
  padding-bottom: 1.5rem;
  border-bottom: 1px solid #e9ecef;
}

.status-badge {
  display: inline-block;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 500;
  font-size: 0.9rem;
}

.status-new {
  background: #e7f3ff;
  color: #0066cc;
}

.status-interview {
  background: #fff3cd;
  color: #856404;
}

.status-accepted {
  background: #d4edda;
  color: #155724;
}

.status-rejected {
  background: #f8d7da;
  color: #721c24;
}
</style>

