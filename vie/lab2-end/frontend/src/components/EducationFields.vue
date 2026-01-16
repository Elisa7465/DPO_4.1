<template>
  <div class="education-fields-block">
    <div class="education-fields-header">
      <h6 class="mb-0">Дополнительная информация об образовании</h6>
      <button
        v-if="showDelete"
        type="button"
        class="btn-close"
        @click="$emit('delete')"
        aria-label="Удалить"
      ></button>
    </div>
    <div class="row mt-3">
      <div class="col-md-6 mb-3">
        <label :for="`institution-${id}`" class="form-label">Учебное заведение</label>
        <input
          type="text"
          class="form-control"
          :id="`institution-${id}`"
          :value="modelValue.institution"
          @input="updateField('institution', $event.target.value)"
          placeholder="Название учебного заведения"
        />
      </div>
      <div class="col-md-6 mb-3">
        <label :for="`faculty-${id}`" class="form-label">Факультет</label>
        <input
          type="text"
          class="form-control"
          :id="`faculty-${id}`"
          :value="modelValue.faculty"
          @input="updateField('faculty', $event.target.value)"
          placeholder="Название факультета"
        />
      </div>
    </div>
    <div class="row">
      <div class="col-md-6 mb-3">
        <label :for="`specialization-${id}`" class="form-label">Специализация</label>
        <input
          type="text"
          class="form-control"
          :id="`specialization-${id}`"
          :value="modelValue.specialization"
          @input="updateField('specialization', $event.target.value)"
          placeholder="Специализация"
        />
      </div>
      <div class="col-md-6 mb-3">
        <label :for="`graduationYear-${id}`" class="form-label">Год окончания</label>
        <input
          type="number"
          class="form-control"
          :id="`graduationYear-${id}`"
          :value="modelValue.graduationYear"
          @input="updateField('graduationYear', $event.target.value)"
          placeholder="Год"
          min="1950"
          :max="currentYear"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineEmits, defineProps } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true,
    default: () => ({
      institution: '',
      faculty: '',
      specialization: '',
      graduationYear: ''
    })
  },
  id: {
    type: [String, Number],
    required: true
  },
  showDelete: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue', 'delete'])

const currentYear = new Date().getFullYear()

const updateField = (field, value) => {
  emit('update:modelValue', {
    ...props.modelValue,
    [field]: value
  })
}
</script>

<style scoped>
.education-fields-block {
  background: #ffffff;
  padding: 1.5rem;
  border-radius: 6px;
  border: 1px solid #dee2e6;
  margin-top: 1rem;
  position: relative;
}

.education-fields-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.education-fields-header h6 {
  color: #495057;
  font-weight: 600;
  margin: 0;
}

.btn-close {
  background: transparent;
  border: none;
  font-size: 1.5rem;
  line-height: 1;
  color: #6c757d;
  opacity: 0.5;
  cursor: pointer;
  padding: 0;
  width: 1.5rem;
  height: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-close:hover {
  opacity: 1;
  color: #dc3545;
}

.btn-close::before {
  content: '×';
  font-size: 1.5rem;
  line-height: 1;
}
</style>

