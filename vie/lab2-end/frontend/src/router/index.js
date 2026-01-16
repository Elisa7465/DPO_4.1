import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import AddResume from '../views/AddResume.vue'
import EditResume from '../views/EditResume.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/add',
    name: 'AddResume',
    component: AddResume
  },
  {
    path: '/edit/:id',
    name: 'EditResume',
    component: EditResume,
    props: true
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router

