import { useRef, useEffect } from 'react'
import './App.css'

function App() {
  const videoRef = useRef<HTMLVideoElement>(null)

  useEffect(() => {
    videoRef.current?.play().catch(() => {})
  }, [])

  return (
    <>
      <section className="hero">
        <video
          ref={videoRef}
          className="hero-video"
          src={import.meta.env.BASE_URL + 'hero-video.mp4'}
          autoPlay
          loop
          muted
          playsInline
        />
        <div className="hero-overlay" />
        <div className="hero-content">
          <p className="hero-eyebrow">Software Engineer & Speaker</p>
          <h1 className="hero-title">Andrey Napannich</h1>
          <p className="hero-subtitle">
            Building intelligent systems at the intersection of AI and real-world applications
          </p>
          <a href="#workspace" className="hero-cta">
            Explore My Work
          </a>
        </div>
      </section>

      <div id="workspace" className="app-shell">
        <div className="topbar panel">
          <div className="topbar-copy">
            <p className="eyebrow">Command Center</p>
            <h1>Mail Command Center</h1>
            <p className="muted-copy">
              A responsive email workspace with a queue-first inbox, opened
              thread view and task panel — designed for focus and speed.
            </p>
          </div>
          <div className="topbar-actions">
            <span className="status-chip">● Online</span>
            <button className="secondary-button" type="button">
              Compose
            </button>
          </div>
        </div>

        <div className="overview-grid">
          {[
            { label: 'Inbox', value: '24', note: '3 unread, 5 starred' },
            { label: 'Queue', value: '8', note: 'Next review in 2h' },
            { label: 'Sent', value: '142', note: 'This month' },
            { label: 'Tasks', value: '6', note: '2 due today' },
          ].map((m) => (
            <div className="metric-card panel" key={m.label}>
              <p className="metric-label">{m.label}</p>
              <span className="metric-value">{m.value}</span>
              <p className="metric-note">{m.note}</p>
            </div>
          ))}
        </div>
      </div>
    </>
  )
}

export default App
