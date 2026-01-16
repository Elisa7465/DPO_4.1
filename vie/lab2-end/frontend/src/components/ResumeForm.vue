<template>
  <div class="resume-form">
    <h2 class="mb-4">Заполните данные для резюме</h2>
    <form @submit.prevent>
      <div class="row">
        <div class="col-md-6 mb-3">
          <label for="profession" class="form-label">Профессия</label>
          <input
            type="text"
            class="form-control"
            id="profession"
            v-model="formData.profession"
            placeholder="Например: Frontend разработчик"
          />
        </div>
        <div class="col-md-6 mb-3">
          <label for="city" class="form-label">Город</label>
          <input
            type="text"
            class="form-control"
            id="city"
            v-model="formData.city"
            placeholder="Например: Москва"
          />
        </div>
      </div>

      <div class="row">
        <div class="col-md-6 mb-3">
          <label for="photoUrl" class="form-label">Ссылка на фото</label>
          <input
            type="url"
            class="form-control"
            id="photoUrl"
            v-model="formData.photoUrl"
            placeholder="https://example.com/photo.jpg"
          />
        </div>
        <div class="col-md-6 mb-3">
          <label for="fullName" class="form-label">ФИО</label>
          <input
            type="text"
            class="form-control"
            id="fullName"
            v-model="formData.fullName"
            placeholder="Иванов Иван Иванович"
          />
        </div>
      </div>

      <div class="row">
        <div class="col-md-6 mb-3">
          <label for="phone" class="form-label">Телефон</label>
          <input
            type="tel"
            class="form-control"
            :class="{ 'is-invalid': phoneError }"
            id="phone"
            v-model="formData.phone"
            @input="validatePhone"
            placeholder="Только цифры, 6-10 символов"
          />
          <div v-if="phoneError" class="invalid-feedback">
            {{ phoneError }}
          </div>
        </div>
        <div class="col-md-6 mb-3">
          <label for="email" class="form-label">Email</label>
          <input
            type="email"
            class="form-control"
            id="email"
            v-model="formData.email"
            placeholder="example@mail.com"
          />
        </div>
      </div>

      <div class="row">
        <div class="col-md-6 mb-3">
          <label for="birthDate" class="form-label">Дата рождения</label>
          <input
            type="date"
            class="form-control"
            id="birthDate"
            v-model="formData.birthDate"
          />
        </div>
        <div class="col-md-6 mb-3">
          <label for="status" class="form-label">Статус</label>
          <select
            class="form-select"
            id="status"
            v-model="formData.status"
          >
            <option value="Новый">Новый</option>
            <option value="Назначено собеседование">Назначено собеседование</option>
            <option value="Принят">Принят</option>
            <option value="Отказ">Отказ</option>
          </select>
        </div>
      </div>

      <div class="row">
        <div class="col-md-6 mb-3">
          <label for="educationLevel" class="form-label">Уровень образования</label>
          <select
            class="form-select"
            id="educationLevel"
            v-model="formData.educationLevel"
          >
            <option value="">Выберите уровень</option>
            <option value="Среднее">Среднее</option>
            <option value="Среднее специальное">Среднее специальное</option>
            <option value="Неоконченное высшее">Неоконченное высшее</option>
            <option value="Высшее">Высшее</option>
          </select>
        </div>
      </div>

      <!-- Дополнительные поля образования -->
      <div v-if="showEducationFields" class="education-section mb-3">
        <EducationFields
          v-for="(education, index) in formData.educations"
          :key="education.id"
          :id="education.id"
          :model-value="education"
          :show-delete="formData.educations.length > 1"
          @update:model-value="updateEducation(index, $event)"
          @delete="removeEducation(index)"
        />
        <div class="mt-2">
          <a
            href="#"
            class="add-education-link"
            @click.prevent="addEducation"
          >
            Указать еще одно место обучения
          </a>
        </div>
      </div>

      <div class="row">
        <div class="col-md-6 mb-3">
          <label for="desiredSalary" class="form-label">Желаемая зарплата</label>
          <input
            type="text"
            class="form-control"
            id="desiredSalary"
            v-model="formData.desiredSalary"
            placeholder="Например: 100 000 руб."
          />
        </div>
        <div class="col-md-6 mb-3">
          <label for="skills" class="form-label">Ключевые навыки</label>
          <input
            type="text"
            class="form-control"
            id="skills"
            v-model="formData.skills"
            placeholder="Например: JavaScript, Vue.js, HTML, CSS"
          />
        </div>
      </div>

      <div class="mb-3">
        <label for="about" class="form-label">О себе</label>
        <textarea
          class="form-control"
          id="about"
          rows="4"
          v-model="formData.about"
          placeholder="Расскажите о себе..."
        ></textarea>
      </div>

      <div class="text-center mt-4">
        <button
          type="button"
          class="btn btn-primary btn-lg"
          @click="applyChanges"
          :disabled="loading"
        >
          <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
          Применить
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { reactive, computed, ref, watch, onMounted } from 'vue'
import EducationFields from './EducationFields.vue'

const props = defineProps({
  initialData: {
    type: Object,
    default: () => null
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['apply'])

const phoneError = ref('')
const currentYear = new Date().getFullYear()
let educationIdCounter = 0

// Инициализация массива образований
const initEducations = (data) => {
  if (!data) return []
  
  const educationLevel = data.educationLevel || ''
  
  // Если уровень "Среднее", не показываем дополнительные поля
  if (educationLevel === 'Среднее') {
    return []
  }
  
  if (data.educations && Array.isArray(data.educations) && data.educations.length > 0) {
    return data.educations.map(edu => ({
      ...edu,
      id: edu.id || `edu-${educationIdCounter++}`
    }))
  }
  
  // Если уровень требует дополнительных полей, но их нет, возвращаем пустой массив
  // (они будут добавлены через watch)
  return []
}

// Инициализация данных формы
const initFormData = () => {
  if (props.initialData) {
    return {
      profession: props.initialData.profession || '',
      city: props.initialData.city || '',
      photoUrl: props.initialData.photoUrl || '',
      fullName: props.initialData.fullName || '',
      phone: props.initialData.phone || '',
      email: props.initialData.email || '',
      birthDate: props.initialData.birthDate || '',
      status: props.initialData.status || 'Новый',
      educationLevel: props.initialData.educationLevel || '',
      educations: props.initialData.educations && props.initialData.educations.length > 0
        ? props.initialData.educations.map(edu => ({
            id: edu.id || `edu-${educationIdCounter++}`,
            institution: edu.institution || '',
            faculty: edu.faculty || '',
            specialization: edu.specialization || '',
            graduationYear: edu.graduationYear || ''
          }))
        : initEducations(props.initialData),
      desiredSalary: props.initialData.desiredSalary || '',
      skills: props.initialData.skills || '',
      about: props.initialData.about || ''
    }
  }
  return {
    profession: '',
    city: '',
    photoUrl: '',
    fullName: '',
    phone: '',
    email: '',
    birthDate: '',
    status: 'Новый',
    educationLevel: '',
    educations: [],
    desiredSalary: '',
    skills: '',
    about: ''
  }
}

const formData = reactive(initFormData())

// Показывать ли дополнительные поля образования
const showEducationFields = computed(() => {
  return formData.educationLevel === 'Среднее специальное' ||
         formData.educationLevel === 'Неоконченное высшее' ||
         formData.educationLevel === 'Высшее'
})

// Обновляем форму при изменении initialData
watch(() => props.initialData, (newData) => {
  if (newData) {
    Object.assign(formData, initFormData())
  }
}, { deep: true })

// Добавить новое образование
const addEducation = () => {
  formData.educations.push({
    id: `edu-${educationIdCounter++}`,
    institution: '',
    faculty: '',
    specialization: '',
    graduationYear: ''
  })
}

// Обновить образование по индексу
const updateEducation = (index, data) => {
  formData.educations[index] = { ...formData.educations[index], ...data }
}

// Удалить образование по индексу
const removeEducation = (index) => {
  formData.educations.splice(index, 1)
  // Если удалили все и уровень требует дополнительных полей, добавляем одно пустое
  if (formData.educations.length === 0 && showEducationFields.value) {
    addEducation()
  }
}

// Следим за изменением уровня образования
watch(() => formData.educationLevel, (newLevel) => {
  if (newLevel === 'Среднее') {
    // Для среднего образования очищаем массив
    formData.educations = []
  } else if (newLevel && (newLevel === 'Среднее специальное' || 
                          newLevel === 'Неоконченное высшее' || 
                          newLevel === 'Высшее')) {
    // Для других уровней добавляем одно образование, если массив пуст
    if (formData.educations.length === 0) {
      addEducation()
    }
  }
}, { immediate: true })

// Валидация телефона
const formatRuPhone = (digits) => {
  // digits = только цифры, без +, скобок и т.п.

  // если ввели 8/7 в начале — нормализуем к 7
  if (digits.startsWith('8')) digits = '7' + digits.slice(1)

  // если номер начинается с 7 — убираем её (будет +7 в формате)
  if (digits.startsWith('7')) digits = digits.slice(1)

  // теперь digits — это "национальная" часть (обычно 10 цифр)
  const d = digits.slice(0, 10)

  let out = '+7'
  if (d.length === 0) return out

  out += ' ' + '(' + d.slice(0, 3)
  if (d.length >= 3) out += ')'
  if (d.length > 3) out += ' ' + d.slice(3, 6)
  if (d.length > 6) out += '-' + d.slice(6, 8)
  if (d.length > 8) out += '-' + d.slice(8, 10)

  return out
}

const validatePhone = () => {
  const raw = String(formData.phone ?? '')
  const digitsAll = raw.replace(/\D/g, '') // только цифры

  // пусто — ок
  if (digitsAll.length === 0) {
    phoneError.value = ''
    formData.phone = ''
    return true
  }

  // берём только "национальную" часть после 7/8 (если есть)
  let national = digitsAll
  if (national.startsWith('8')) national = '7' + national.slice(1)
  if (national.startsWith('7')) national = national.slice(1)

  // ограничим максимумом 10
  national = national.slice(0, 10)

  // валидация по твоим правилам: 6..10 цифр (после +7)
  if (national.length < 6 || national.length > 10) {
    phoneError.value = 'Телефон должен содержать от 6 до 10 цифр'
    formData.phone = formatRuPhone(national)
    return false
  }

  phoneError.value = ''
  formData.phone = formatRuPhone(national)
  return true
}

// Применить изменения
const applyChanges = () => {
  // Валидируем телефон перед применением
  if (formData.phone && !validatePhone()) {
    return
  }
  
  // Подготавливаем данные для отправки
  const dataToSend = {
    ...formData,
    educations: formData.educations.filter(edu => 
      edu.institution || edu.faculty || edu.specialization || edu.graduationYear
    )
  }
  
  emit('apply', dataToSend)
}
</script>

<style scoped>
.resume-form {
  background: #f8f9fa;
  padding: 2rem;
  border-radius: 8px;
  margin-bottom: 2rem;
}

.form-label {
  font-weight: 500;
  color: #333;
}

.education-section {
  margin-top: 1rem;
}

.add-education-link {
  color: #007bff;
  text-decoration: none;
  font-size: 0.95rem;
  cursor: pointer;
}

.add-education-link:hover {
  text-decoration: underline;
  color: #0056b3;
}
</style>

