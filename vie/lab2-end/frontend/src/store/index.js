import { createStore } from 'vuex'
import axios from 'axios'

const API_BASE_URL = 'http://localhost:8080/api'

export default createStore({
  state: {
    resumes: [],
    loading: false,
    error: null
  },
  
  getters: {
    resumesByStatus: (state) => {
      const statuses = ['Новый', 'Назначено собеседование', 'Принят', 'Отказ']
      const grouped = {}
      
      statuses.forEach(status => {
        grouped[status] = state.resumes.filter(r => r.status === status)
      })
      
      return grouped
    },
    
    resumeCounts: (state) => {
      const statuses = ['Новый', 'Назначено собеседование', 'Принят', 'Отказ']
      const counts = {}
      
      statuses.forEach(status => {
        counts[status] = state.resumes.filter(r => r.status === status).length
      })
      
      return counts
    },
    
    getResumeById: (state) => (id) => {
      return state.resumes.find(r => r.id === id)
    }
  },
  
  mutations: {
    SET_RESUMES(state, resumes) {
      state.resumes = resumes
    },
    
    ADD_RESUME(state, resume) {
      state.resumes.push(resume)
    },
    
    UPDATE_RESUME(state, updatedResume) {
      const index = state.resumes.findIndex(r => r.id === updatedResume.id)
      if (index !== -1) {
        state.resumes[index] = updatedResume
      }
    },
    
    UPDATE_RESUME_STATUS(state, { id, status }) {
      const resume = state.resumes.find(r => r.id === id)
      if (resume) {
        resume.status = status
      }
    },
    
    SET_LOADING(state, loading) {
      state.loading = loading
    },
    
    SET_ERROR(state, error) {
      state.error = error
    }
  },
  
  actions: {
    async fetchResumes({ commit }) {
      commit('SET_LOADING', true)
      commit('SET_ERROR', null)
      
      try {
        const response = await axios.get(`${API_BASE_URL}/cv`)
        commit('SET_RESUMES', response.data)
      } catch (error) {
        commit('SET_ERROR', error.message)
        console.error('Error fetching resumes:', error)
      } finally {
        commit('SET_LOADING', false)
      }
    },
    
    async fetchResumeById({ commit }, id) {
      commit('SET_LOADING', true)
      commit('SET_ERROR', null)
      
      try {
        const response = await axios.get(`${API_BASE_URL}/cv/${id}`)
        return response.data
      } catch (error) {
        commit('SET_ERROR', error.message)
        throw error
      } finally {
        commit('SET_LOADING', false)
      }
    },
    
    async addResume({ commit, dispatch }, resumeData) {
      commit('SET_LOADING', true)
      commit('SET_ERROR', null)
      
      try {
        await axios.post(`${API_BASE_URL}/cv/0/add`, resumeData)
        await dispatch('fetchResumes')
      } catch (error) {
        commit('SET_ERROR', error.message)
        throw error
      } finally {
        commit('SET_LOADING', false)
      }
    },
    
    async updateResume({ commit, dispatch }, { id, resumeData }) {
      commit('SET_LOADING', true)
      commit('SET_ERROR', null)
      
      try {
        await axios.post(`${API_BASE_URL}/cv/${id}/edit`, resumeData)
        await dispatch('fetchResumes')
      } catch (error) {
        commit('SET_ERROR', error.message)
        throw error
      } finally {
        commit('SET_LOADING', false)
      }
    },
    
    async updateResumeStatus({ commit }, { id, status }) {
      try {
        await axios.post(`${API_BASE_URL}/cv/${id}/status/update`, { status })
        commit('UPDATE_RESUME_STATUS', { id, status })
      } catch (error) {
        commit('SET_ERROR', error.message)
        throw error
      }
    }
  }
})

