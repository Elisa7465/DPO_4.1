<script>
export default {
  props: {
    title: String,
    label1: String,
    label2: String,
    modelValue: String,
    modelValue2: String,
    convertForward: Function,
    convertBackward: Function,
  },
  emits: ["update:modelValue", "update:modelValue2"],
  methods: {
    onFirstInput(v) {
      this.$emit("update:modelValue", v);
      this.$emit("update:modelValue2", this.convertForward(v));
    },
    onSecondInput(v) {
      this.$emit("update:modelValue2", v);
      this.$emit("update:modelValue", this.convertBackward(v));
    },
  },
};
</script>

<template>
  <div class="container"> 
    <p class="title">{{ title }}</p>
    
    <div class="input-wrapper">
      <label>
        <span>{{ label1 }}</span>
        <input type="number" :value="modelValue" @input="onFirstInput($event.target.value.replace(/[^0-9.]/g, ''))" />
      </label>
      
      <label>
        <span>{{ label2 }}</span>
        <input type="number" :value="modelValue2" @input="onSecondInput($event.target.value.replace(/[^0-9.]/g, ''))" />
      </label>
    </div>
  </div>
</template>

<style scoped>
  .container {
  display: flex;
  flex-direction: column;
  align-items: center; 
  justify-content: center; 
}
.title {
  display: flex; 
  justify-content: center;
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 16px;
  color: #333;
}

.input-wrapper {
  display: flex; 
  justify-content: center;
  flex-direction: column;
  width: 400px;
  gap: 18px;
  padding: 20px;
  background: #f7f9fc;
  border-radius: 12px;
  border: 1px solid #dce3ee;
  align-items: center;
}

label {
  display: flex;
  flex-direction: column;
  font-size: 14px;
  color: #555;
  width: 100%; 
  max-width: 300px;
}

input {
  padding: 10px 14px;
  border: 1px solid #aab7cf;
  border-radius: 8px;
  font-size: 16px;
  transition: 0.2s;
  width: 100%; 
  box-sizing: border-box;
}

input:focus {
  border-color: #4a90e2;
  box-shadow: 0 0 4px rgba(74, 144, 226, 0.4);
  outline: none;
}
</style>
