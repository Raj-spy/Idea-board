const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL ?? '').replace(/\/$/, '')

async function request(path, options) {
  let response
  try {
    response = await fetch(`${API_BASE_URL}${path}`, {
      headers: { 'Content-Type': 'application/json' },
      ...options,
    })
  } catch {
    throw new Error('Unable to reach the IdeaBoard API. Check that the backend is running.')
  }

  if (!response.ok) {
    if (response.status === 422) {
      throw new Error('Please enter an idea with up to 1000 characters.')
    }
    if (response.status >= 500) {
      throw new Error('The service is temporarily unavailable. Please try again.')
    }
    throw new Error('The request could not be completed. Please try again.')
  }
  return response.json()
}

export function getIdeas() {
  return request('/api/ideas')
}

export function createIdea(content) {
  return request('/api/ideas', {
    method: 'POST',
    body: JSON.stringify({ content }),
  })
}
