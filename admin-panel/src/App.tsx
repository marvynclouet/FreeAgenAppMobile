import { useState } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate, Link, useLocation } from 'react-router-dom'
import Dashboard from './pages/Dashboard'
import UsersManagement from './pages/UsersManagement'
import Opportunities from './pages/Opportunities'
import Messages from './pages/Messages'
import './App.css'

// Composant de navigation
const Navigation: React.FC = () => {
  const location = useLocation();
  
  const navItems = [
    { path: '/', label: 'Accueil', icon: '🏠' },
    { path: '/users', label: 'Utilisateurs', icon: '👥' },
    { path: '/opportunities', label: 'Annonces', icon: '📢' },
    { path: '/messages', label: 'Messages', icon: '💬' }
  ];

  return (
    <nav className="admin-navbar">
      <div className="nav-brand">
        <h2>FreeAgent Admin</h2>
      </div>
      <div className="nav-menu">
        {navItems.map(item => (
          <Link
            key={item.path}
            to={item.path}
            className={`nav-link ${location.pathname === item.path ? 'active' : ''}`}
          >
            <span className="nav-icon">{item.icon}</span>
            {item.label}
          </Link>
        ))}
      </div>
    </nav>
  );
};

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    if (password === 'admin123') {
      setIsAuthenticated(true)
      setError('')
    } else {
      setError('Mot de passe incorrect')
    }
  }

  const handleLogout = () => {
    setIsAuthenticated(false)
    setPassword('')
  }

  if (!isAuthenticated) {
    return (
      <div className="login-container">
        <div className="login-card">
          <div>
            <h2 className="login-title">
              FreeAgent Administration
            </h2>
            <p className="login-subtitle">
              Panneau d'administration
            </p>
          </div>
          
          <form onSubmit={handleLogin}>
            <div className="form-group">
              <label htmlFor="password" className="form-label">
                Mot de passe administrateur
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="form-input"
                placeholder="Entrez le mot de passe"
              />
            </div>

            {error && (
              <div className="error-message">
                {error}
              </div>
            )}

            <button
              type="submit"
              className="login-button"
            >
              Se connecter
            </button>
          </form>
        </div>
      </div>
    )
  }

  return (
    <Router>
      <div className="admin-layout">
        <Navigation />
        
        <div className="admin-header">
          <div className="header-content">
            <h1>Panneau d'Administration</h1>
            <button onClick={handleLogout} className="logout-button">
              Déconnexion
            </button>
          </div>
        </div>

        <main className="admin-main">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/users" element={<UsersManagement />} />
            <Route path="/opportunities" element={<Opportunities />} />
            <Route path="/messages" element={<Messages />} />
          </Routes>
        </main>
      </div>
    </Router>
  )
}

export default App
