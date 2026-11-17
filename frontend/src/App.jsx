import { useCallback, useEffect, useState } from 'react'
import { createIdea, getIdeas } from './api/ideas.js'

const MAX_IDEA_LENGTH = 1000

function formatTimestamp(value) {
  return new Intl.DateTimeFormat(undefined, {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value))
}

function App() {
  const [ideas, setIdeas] = useState([])
  const [content, setContent] = useState('')
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [loadError, setLoadError] = useState('')
  const [formMessage, setFormMessage] = useState(null)

  const loadIdeas = useCallback(async () => {
    setLoading(true)
    setLoadError('')
    try {
      setIdeas(await getIdeas())
    } catch (error) {
      setLoadError(error.message)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    loadIdeas()
  }, [loadIdeas])

  async function handleSubmit(event) {
    event.preventDefault()
    const trimmedContent = content.trim()
    if (!trimmedContent || trimmedContent.length > MAX_IDEA_LENGTH || submitting) {
      return
    }

    setSubmitting(true)
    setFormMessage(null)
    try {
      const newIdea = await createIdea(trimmedContent)
      setIdeas((currentIdeas) => [newIdea, ...currentIdeas])
      setContent('')
      setFormMessage({ type: 'success', text: 'Your idea is on the board.' })
    } catch (error) {
      setFormMessage({ type: 'error', text: error.message })
    } finally {
      setSubmitting(false)
    }
  }

  const trimmedLength = content.trim().length

  return (
    <main className="min-h-screen bg-canvas px-4 py-10 text-ink sm:px-6 sm:py-14">
      <div className="mx-auto max-w-3xl">
        <header className="mb-9 text-center sm:mb-12">
          <div className="mx-auto mb-4 grid h-12 w-12 place-items-center rounded-2xl bg-violet text-xl font-bold text-white shadow-card" aria-hidden="true">
            i
          </div>
          <p className="mb-2 text-xs font-bold uppercase tracking-[0.2em] text-violet">A place to think out loud</p>
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">IdeaBoard</h1>
          <p className="mx-auto mt-3 max-w-lg text-base leading-7 text-muted sm:text-lg">
            Good ideas grow when they&apos;re shared. Add yours to the board.
          </p>
        </header>

        <section className="rounded-2xl border border-slate-100 bg-white p-5 shadow-card sm:p-7" aria-labelledby="share-heading">
          <div className="mb-5">
            <h2 id="share-heading" className="text-lg font-semibold">Share an idea</h2>
            <p className="mt-1 text-sm text-muted">Keep it simple. You can always build on it later.</p>
          </div>
          <form onSubmit={handleSubmit}>
            <label htmlFor="idea-content" className="sr-only">Your idea</label>
            <textarea
              id="idea-content"
              name="content"
              rows="3"
              maxLength={MAX_IDEA_LENGTH}
              value={content}
              onChange={(event) => {
                setContent(event.target.value)
                setFormMessage(null)
              }}
              placeholder="What have you been thinking about?"
              className="w-full resize-y rounded-xl border border-slate-200 bg-slate-50/70 px-4 py-3 text-base leading-6 text-ink outline-none transition placeholder:text-slate-400 focus:border-violet focus:ring-4 focus:ring-violet/10"
              aria-describedby="idea-count"
              required
            />
            <div className="mt-3 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <span id="idea-count" className="text-xs text-muted">{trimmedLength} / {MAX_IDEA_LENGTH}</span>
              <button
                type="submit"
                disabled={submitting || trimmedLength === 0 || trimmedLength > MAX_IDEA_LENGTH}
                className="inline-flex min-h-11 items-center justify-center rounded-xl bg-violet px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-violet/90 focus:outline-none focus:ring-4 focus:ring-violet/20 disabled:cursor-not-allowed disabled:opacity-50"
              >
                {submitting ? 'Adding idea…' : 'Add to the board'}
              </button>
            </div>
            {formMessage && (
              <p className={`mt-4 text-sm ${formMessage.type === 'success' ? 'text-emerald-700' : 'text-red-700'}`} role="status">
                {formMessage.text}
              </p>
            )}
          </form>
        </section>

        <section className="mt-10 sm:mt-12" aria-labelledby="ideas-heading">
          <div className="mb-5 flex items-center justify-between gap-4">
            <div>
              <h2 id="ideas-heading" className="text-xl font-bold">Ideas from the board</h2>
              {!loading && !loadError && <p className="mt-1 text-sm text-muted">{ideas.length} {ideas.length === 1 ? 'idea' : 'ideas'} shared</p>}
            </div>
            {!loading && (
              <button
                type="button"
                onClick={loadIdeas}
                className="rounded-lg px-3 py-2 text-sm font-semibold text-violet hover:bg-violet/5 focus:outline-none focus:ring-2 focus:ring-violet/30"
              >
                Refresh
              </button>
            )}
          </div>

          {loading ? (
            <div className="flex items-center justify-center gap-3 rounded-2xl border border-slate-100 bg-white px-5 py-12 text-sm text-muted shadow-card" role="status">
              <span className="h-5 w-5 animate-spin rounded-full border-2 border-violet/20 border-t-violet" aria-hidden="true" />
              Loading ideas…
            </div>
          ) : loadError ? (
            <div className="rounded-2xl border border-red-100 bg-red-50 px-5 py-6 text-sm text-red-800" role="alert">
              <p className="font-semibold">We couldn&apos;t load the board.</p>
              <p className="mt-1">{loadError}</p>
              <button type="button" onClick={loadIdeas} className="mt-3 font-semibold underline underline-offset-2">Try again</button>
            </div>
          ) : ideas.length === 0 ? (
            <div className="rounded-2xl border border-dashed border-slate-300 bg-white/70 px-5 py-12 text-center">
              <div className="mx-auto grid h-11 w-11 place-items-center rounded-full bg-violet/10 text-lg text-violet" aria-hidden="true">✦</div>
              <h3 className="mt-4 font-semibold">A fresh page</h3>
              <p className="mt-1 text-sm text-muted">There are no ideas yet. Be the first to share one.</p>
            </div>
          ) : (
            <ul className="space-y-3">
              {ideas.map((idea) => (
                <li key={idea.id} className="rounded-2xl border border-slate-100 bg-white p-5 shadow-card sm:p-6">
                  <p className="whitespace-pre-wrap break-words leading-7 text-ink">{idea.content}</p>
                  <time className="mt-4 block text-xs text-muted" dateTime={idea.created_at}>
                    {formatTimestamp(idea.created_at)}
                  </time>
                </li>
              ))}
            </ul>
          )}
        </section>
        <footer className="mt-12 text-center text-xs text-muted">Every great project starts with an idea.</footer>
      </div>
    </main>
  )
}

export default App
