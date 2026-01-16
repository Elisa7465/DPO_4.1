<script setup>
import Convertor from "./components/Convertor.vue"
import { ref } from 'vue'
import { feetToMeters, metersToFeet } from './utils/FeetMeters.js'
import { nauticalMilesToKm,kmToNauticalMiles } from './utils/MilesKilometer.js'
import { decimetersToFootballFields, footballFieldsToDecimeters } from './utils/DecemetryFootball.js'
import { celsiusToFahrenheit, fahrenheitToCelsius } from './utils/CelsiusFahrenheit.js'


const feet = ref('')
const metrs = ref('')

const miles = ref('')
const kilometer = ref('')

const celsius = ref('')
const fahrenheit = ref('')

const decemeter = ref('')
const football = ref('')
</script>

<template>
  <Convertor
    title="Перевод из футов в метры"
    label1="фут"
    label2="метр"
    :modelValue="feet"
    @update:modelValue="feet = $event"
    :modelValue2="metrs"
    @update:modelValue2="metrs = $event"
    :convertForward="feetToMeters"
    :convertBackward="metersToFeet"
  />

  <Convertor
    title="Перевод из морских миль в километры"
    label1="морские мили"
    label2="километры"
    :modelValue="miles"
    @update:modelValue="miles = $event"
    :modelValue2="kilometer"
    @update:modelValue2="kilometer = $event"
    :convertForward="nauticalMilesToKm"
    :convertBackward="kmToNauticalMiles"
  />

  <Convertor
    title="температуру по Цельсию в температуру по Фаренгейту"
    label1="температура по Цельсию"
    label2="температура по Фаренгейту"
    :modelValue="celsius"
    @update:modelValue="celsius = $event"
    :modelValue2="fahrenheit"
    @update:modelValue2="fahrenheit = $event"
    :convertForward="celsiusToFahrenheit"
    :convertBackward="fahrenheitToCelsius"
  />

  <Convertor
    title="перевод из децеметров в футбольные поля"
    label1="децеметры"
    label2="футбольные поля"
    :modelValue="decemeter"
    @update:modelValue="decemeter = $event"
    :modelValue2="football"
    @update:modelValue2="football = $event"
    :convertForward="decimetersToFootballFields"
    :convertBackward="footballFieldsToDecimeters"
  />
</template>

<style scoped></style>
