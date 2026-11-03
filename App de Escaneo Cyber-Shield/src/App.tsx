import { FormEvent, ReactNode, useState } from 'react'

type Screen = 'home' | 'history' | 'stats' | 'profile'
type IconName =
  | 'arrow'
  | 'chart'
  | 'check'
  | 'chevron'
  | 'clock'
  | 'eye'
  | 'fingerprint'
  | 'home'
  | 'link'
  | 'lock'
  | 'mail'
  | 'message'
  | 'scan'
  | 'shield'
  | 'sparkles'
  | 'user'
  | 'warning'

const scanHistory = [
  { type: 'URL', value: 'secure-bbva-access.xyz', time: 'Hace 8 min', risk: 'Crítico', score: 92 },
  { type: 'SMS', value: 'Tu paquete está en espera...', time: 'Hoy, 09:42', risk: 'Medio', score: 38 },
  { type: 'URL', value: 'spotify.com/account', time: 'Ayer, 18:12', risk: 'Seguro', score: 4 },
  { type: 'SMS', value: 'Código de acceso: 483921', time: '12 jun, 11:20', risk: 'Seguro', score: 2 },
]

function Icon({ name, size = 20, strokeWidth = 1.8 }: { name: IconName; size?: number; strokeWidth?: number }) {
  const paths: Record<IconName, ReactNode> = {
    arrow: <path d="m9 18 6-6-6-6" />,
    chart: <><path d="M4 19V9" /><path d="M10 19V5" /><path d="M16 19v-7" /><path d="M22 19H2" /></>,
    check: <path d="m5 12 4 4L19 6" />,
    chevron: <path d="m9 18 6-6-6-6" />,
    clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
    eye: <><path d="M2.5 12s3.5-6 9.5-6 9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6Z" /><circle cx="12" cy="12" r="2.5" /></>,
    fingerprint: <><path d="M8.2 10.8a4 4 0 0 1 7.7 1.4c0 3-.5 5.4-1.5 7.3" /><path d="M5.5 15.5c.3-1.2.4-2.2.4-3.3a6.1 6.1 0 0 1 12.2 0c0 2.2-.2 4.3-.8 6.3" /><path d="M3.5 11.5a8.5 8.5 0 0 1 16.9.8c0 1.5-.1 2.8-.3 4" /><path d="M9.5 14.2c0 2.3-.5 4.3-1.4 5.8" /><path d="M12.5 11.5c.4 3.7-.2 7-1.4 9.1" /></>,
    home: <><path d="m3 11 9-8 9 8" /><path d="M5 10v10h14V10M9 20v-6h6v6" /></>,
    link: <><path d="M10 13a5 5 0 0 0 7.1.1l2-2a5 5 0 0 0-7.1-7.1l-1.1 1.1" /><path d="M14 11a5 5 0 0 0-7.1-.1l-2 2A5 5 0 0 0 12 20l1.1-1.1" /></>,
    lock: <><rect x="4" y="10" width="16" height="11" rx="3" /><path d="M8 10V7a4 4 0 0 1 8 0v3" /><path d="M12 14v3" /></>,
    mail: <><rect x="3" y="5" width="18" height="14" rx="3" /><path d="m4 7 8 6 8-6" /></>,
    message: <><path d="M20 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h9a4 4 0 0 1 4 4Z" /><path d="M7 9h10M7 13h6" /></>,
    scan: <><path d="M8 3H5a2 2 0 0 0-2 2v3M16 3h3a2 2 0 0 1 2 2v3M21 16v3a2 2 0 0 1-2 2h-3M8 21H5a2 2 0 0 1-2-2v-3" /><path d="M7 12h10M12 7v10" /></>,
    shield: <><path d="M12 22s8-3.8 8-10V5l-8-3-8 3v7c0 6.2 8 10 8 10Z" /><path d="m8.5 12 2.2 2.2 4.8-5" /></>,
    sparkles: <><path d="m12 3 1.1 3.2L16 7.5l-2.9 1.3L12 12l-1.1-3.2L8 7.5l2.9-1.3L12 3Z" /><path d="m5 13 .8 2.2L8 16l-2.2.8L5 19l-.8-2.2L2 16l2.2-.8L5 13ZM19 12l.7 1.8 1.8.7-1.8.7L19 17l-.7-1.8-1.8-.7 1.8-.7L19 12Z" /></>,
    user: <><circle cx="12" cy="8" r="4" /><path d="M4 21a8 8 0 0 1 16 0" /></>,
    warning: <><path d="M10.3 3.7 2.5 17.2A2 2 0 0 0 4.2 20h15.6a2 2 0 0 0 1.7-2.8L13.7 3.7a2 2 0 0 0-3.4 0Z" /><path d="M12 8v5M12 17h.01" /></>,
  }

  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      {paths[name]}
    </svg>
  )
}

function Brand({ compact = false }: { compact?: boolean }) {
  return (
    <div className="brand">
      <div className={`brand-mark ${compact ? 'brand-mark-small' : ''}`}>
        <Icon name="shield" size={compact ? 21 : 29} />
        <span className="brand-glint" />
      </div>
      <div>
        <strong>AntFish</strong>
        {!compact && <span>Cyber shield</span>}
      </div>
    </div>
  )
}

function AuthScreen({ onEnter }: { onEnter: () => void }) {
  const [mode, setMode] = useState<'login' | 'register'>('login')
  const [showPassword, setShowPassword] = useState(false)

  function submit(event: FormEvent) {
    event.preventDefault()
    onEnter()
  }

  return (
    <main className="auth-page">
      <div className="ambient ambient-one" />
      <div className="ambient ambient-two" />
      <section className="auth-shell">
        <div className="auth-visual">
          <Brand />
          <div className="shield-orbit" aria-hidden="true">
            <div className="orbit orbit-one" />
            <div className="orbit orbit-two" />
            <div className="shield-core"><Icon name="fingerprint" size={58} /></div>
          </div>
          <div>
            <p className="eyebrow">PROTECCIÓN INTELIGENTE</p>
            <h1>Tu mundo digital,<br /><em>bajo control.</em></h1>
            <p className="auth-copy">Detecta enlaces maliciosos y mensajes fraudulentos antes de que sea demasiado tarde.</p>
          </div>
          <div className="trust-row">
            <span><Icon name="lock" size={14} /> Cifrado privado</span>
            <span><Icon name="sparkles" size={14} /> Análisis en segundos</span>
          </div>
        </div>

        <div className="auth-panel glass-panel" style={{ paddingBottom: 0 }}>
          <div className="mobile-brand"><Brand compact /></div>
          <p className="eyebrow">{mode === 'login' ? 'BIENVENIDO DE NUEVO' : 'CREA TU ESCUDO'}</p>
          <h2>{mode === 'login' ? 'Accede a tu espacio seguro' : 'Comienza a navegar seguro'}</h2>
          <p className="muted">{mode === 'login' ? 'Tu protección continúa donde la dejaste.' : 'Configura tu cuenta en menos de un minuto.'}</p>

          <div className="auth-tabs" role="tablist">
            <button className={mode === 'login' ? 'active' : ''} onClick={() => setMode('login')}>Ingresar</button>
            <button className={mode === 'register' ? 'active' : ''} onClick={() => setMode('register')}>Registrarme</button>
          </div>

          <form onSubmit={submit}>
            {mode === 'register' && (
              <label className="field">
                <span>Nombre</span>
                <div><Icon name="user" size={18} /><input required placeholder="¿Cómo te llamas?" /></div>
              </label>
            )}
            <label className="field">
              <span>Correo electrónico</span>
              <div><Icon name="mail" size={18} /><input required type="email" placeholder="nombre@correo.com" /></div>
            </label>
            <label className="field">
              <span>Contraseña</span>
              <div>
                <Icon name="lock" size={18} />
                <input required type={showPassword ? 'text' : 'password'} placeholder="Mínimo 8 caracteres" minLength={8} />
                <button type="button" className="field-action" onClick={() => setShowPassword(!showPassword)} aria-label="Mostrar contraseña"><Icon name="eye" size={18} /></button>
              </div>
            </label>
            {mode === 'login' && <button type="button" className="forgot">¿Olvidaste tu contraseña?</button>}
            <button className="primary-button" type="submit">
              {mode === 'login' ? 'Entrar de forma segura' : 'Crear cuenta segura'}
              <Icon name="arrow" size={18} />
            </button>
          </form>

          <div className="divider"><span>o continúa con</span></div>
          <button className="google-button" onClick={onEnter}>
            <span className="google-g">G</span> Continuar con Google
          </button>
          <p className="legal">Al continuar, aceptas nuestros <button>Términos</button> y <button>Privacidad</button>.</p>
        </div>
      </section>
    </main>
  )
}

function SecurityRing({ score = 94, label = 'Protección activa' }: { score?: number; label?: string }) {
  return (
    <div className="security-ring" style={{ '--score': `${score * 3.6}deg` } as React.CSSProperties}>
      <div className="ring-inner">
        <Icon name="shield" size={28} />
        <strong>{score}%</strong>
        <span>{label}</span>
      </div>
    </div>
  )
}

function HomeScreen() {
  const [inputType, setInputType] = useState<'url' | 'sms'>('url')
  const [value, setValue] = useState('')
  const [scanning, setScanning] = useState(false)
  const [result, setResult] = useState(false)

  function analyze() {
    if (!value.trim()) return
    setScanning(true)
    setResult(false)
    window.setTimeout(() => {
      setScanning(false)
      setResult(true)
    }, 900)
  }

  return (
    <div className="screen-content home-screen">
      <header className="app-header">
        <Brand compact />
        <button className="avatar" aria-label="Abrir perfil">AM<span className="online-dot" /></button>
      </header>

      <section className="hello-row">
        <div>
          <p>Buenas tardes, Alex</p>
          <h1>Tu espacio está <em>protegido.</em></h1>
        </div>
        <SecurityRing />
      </section>

      <section className="scanner-card glass-panel">
        <div className="scanner-topline">
          <div>
            <span className="live-dot" /> ESCÁNER INTELIGENTE
          </div>
          <span>Motor activo</span>
        </div>
        <h2>¿Qué quieres analizar?</h2>
        <p>Pega un enlace o mensaje sospechoso. Nosotros hacemos el resto.</p>

        <div className="type-switch">
          <button className={inputType === 'url' ? 'active' : ''} onClick={() => { setInputType('url'); setResult(false) }}><Icon name="link" size={17} /> Enlace URL</button>
          <button className={inputType === 'sms' ? 'active' : ''} onClick={() => { setInputType('sms'); setResult(false) }}><Icon name="message" size={17} /> Mensaje SMS</button>
        </div>

        <div className="scan-input-wrap">
          {inputType === 'url' ? <Icon name="link" size={20} /> : <Icon name="message" size={20} />}
          <textarea
            value={value}
            onChange={(event) => setValue(event.target.value)}
            placeholder={inputType === 'url' ? 'https://sitio-que-quieres-verificar.com' : 'Pega aquí el contenido del mensaje sospechoso...'}
            rows={inputType === 'url' ? 1 : 3}
          />
          {value && <button onClick={() => setValue('')} aria-label="Limpiar">×</button>}
        </div>
        <p className="privacy-note"><Icon name="lock" size={13} /> Tu contenido se analiza de forma privada y nunca se almacena.</p>

        <button className="scan-button" onClick={analyze} disabled={!value.trim() || scanning}>
          <span><Icon name="scan" size={21} /></span>
          {scanning ? 'Analizando señales...' : 'Analizar ahora'}
          {!scanning && <Icon name="arrow" size={18} />}
        </button>
      </section>

      {result ? <ResultCard /> : <RiskTrafficLight />}

      <section className="recent-section">
        <div className="section-heading">
          <div><p className="eyebrow">ACTIVIDAD</p><h2>Análisis recientes</h2></div>
          <button>Ver todos <Icon name="arrow" size={15} /></button>
        </div>
        <div className="history-list compact-list">
          {scanHistory.slice(0, 3).map((item) => <HistoryRow key={item.value} item={item} />)}
        </div>
      </section>
    </div>
  )
}

function RiskTrafficLight() {
  return (
    <section className="traffic-card glass-panel">
      <div className="traffic-visual">
        <span className="traffic-dot green" />
        <span className="traffic-dot yellow" />
        <span className="traffic-dot orange" />
        <span className="traffic-dot red" />
      </div>
      <div>
        <p className="eyebrow">SEMÁFORO DE RIESGO</p>
        <h3>Una respuesta clara, no solo datos.</h3>
        <p>Traducimos cientos de señales en un nivel de riesgo fácil de entender.</p>
      </div>
    </section>
  )
}

function ResultCard() {
  return (
    <section className="result-card glass-panel">
      <div className="result-score">
        <div><span>92</span><small>/100</small></div>
        <p>RIESGO CRÍTICO</p>
      </div>
      <div className="result-copy">
        <p className="eyebrow">ANÁLISIS COMPLETADO</p>
        <h3>No abras este enlace</h3>
        <p>Detectamos una posible suplantación de identidad y reputación negativa.</p>
        <div className="finding-tags"><span><Icon name="warning" size={13} /> Dominio engañoso</span><span>Lista negra</span></div>
      </div>
    </section>
  )
}

function HistoryRow({ item }: { item: typeof scanHistory[number] }) {
  const tone = item.score >= 80 ? 'critical' : item.score >= 20 ? 'medium' : 'safe'
  return (
    <button className="history-row">
      <span className={`history-icon ${tone}`}><Icon name={item.type === 'URL' ? 'link' : 'message'} size={19} /></span>
      <span className="history-main"><strong>{item.value}</strong><small>{item.type} · {item.time}</small></span>
      <span className={`risk-pill ${tone}`}>{item.risk}</span>
      <Icon name="chevron" size={16} />
    </button>
  )
}

function HistoryScreen() {
  return (
    <div className="screen-content inner-screen">
      <PageHeader eyebrow="REGISTRO SEGURO" title="Tu historial" copy="Consulta tus análisis anteriores y vuelve a revisar los resultados." />
      <div className="filter-row"><button className="active">Todos</button><button>Enlaces</button><button>Mensajes</button></div>
      <div className="history-list">{scanHistory.concat(scanHistory.slice(0, 2)).map((item, index) => <HistoryRow key={`${item.value}-${index}`} item={item} />)}</div>
    </div>
  )
}

function PageHeader({ eyebrow, title, copy }: { eyebrow: string; title: string; copy: string }) {
  return (
    <header className="page-header">
      <Brand compact />
      <p className="eyebrow">{eyebrow}</p>
      <h1>{title}</h1>
      <p>{copy}</p>
    </header>
  )
}

function StatsScreen() {
  return (
    <div className="screen-content inner-screen stats-screen">
      <PageHeader eyebrow="TU IMPACTO" title="Métricas de protección" copy="Cada análisis suma una capa más de tranquilidad digital." />
      <section className="stats-hero glass-panel">
        <SecurityRing score={86} label="nivel seguro" />
        <div>
          <p className="eyebrow">ESTE MES</p>
          <h2>Tu protección creció <em>12%</em></h2>
          <p>Has evitado interactuar con 7 amenazas potenciales.</p>
        </div>
      </section>
      <section className="metric-grid">
        <article className="metric-card glass-panel"><span><Icon name="scan" /></span><strong>148</strong><p>Escaneos totales</p><small>+18 este mes</small></article>
        <article className="metric-card glass-panel"><span><Icon name="shield" /></span><strong>23</strong><p>Amenazas bloqueadas</p><small>15.5% del total</small></article>
        <article className="metric-card glass-panel"><span><Icon name="link" /></span><strong>91</strong><p>Enlaces analizados</p><small>61% de actividad</small></article>
        <article className="metric-card glass-panel"><span><Icon name="message" /></span><strong>57</strong><p>SMS analizados</p><small>39% de actividad</small></article>
      </section>
      <section className="threat-breakdown glass-panel">
        <div className="section-heading"><div><p className="eyebrow">DESGLOSE</p><h2>Nivel de riesgo</h2></div><span>Últimos 30 días</span></div>
        {[['Seguro', 71, 'safe'], ['Riesgo medio', 19, 'medium'], ['Riesgo alto', 7, 'high'], ['Crítico', 3, 'critical']].map(([label, value, tone]) => (
          <div className="bar-row" key={label}>
            <span>{label}</span><div><i className={String(tone)} style={{ width: `${value}%` }} /></div><strong>{value}%</strong>
          </div>
        ))}
      </section>
      <section className="insight-card">
        <Icon name="sparkles" size={22} />
        <div><strong>Tu hábito más seguro</strong><p>Analizas el 84% de los enlaces antes de abrirlos.</p></div>
      </section>
    </div>
  )
}

function ProfileScreen({ onExit }: { onExit: () => void }) {
  return (
    <div className="screen-content inner-screen profile-screen">
      <PageHeader eyebrow="CUENTA PROTEGIDA" title="Tu perfil" copy="Administra tu espacio, privacidad y preferencias." />
      <section className="profile-card glass-panel">
        <div className="profile-avatar">AM</div>
        <div><h2>Alex Morgan</h2><p>alex@correo.com</p><span><Icon name="check" size={12} /> Correo verificado</span></div>
      </section>
      <section className="settings-list glass-panel">
        <button><span><Icon name="shield" /></span><div><strong>Centro de seguridad</strong><small>Contraseña y sesiones activas</small></div><Icon name="chevron" /></button>
        <button><span><Icon name="fingerprint" /></span><div><strong>Privacidad</strong><small>Datos y permisos de análisis</small></div><Icon name="chevron" /></button>
        <button><span><Icon name="sparkles" /></span><div><strong>Preferencias</strong><small>Alertas y notificaciones</small></div><Icon name="chevron" /></button>
      </section>
      <button className="logout-button" onClick={onExit}>Cerrar sesión</button>
      <p className="version">AntFish 1.0 · Tu escudo digital</p>
    </div>
  )
}

function BottomNav({ screen, setScreen }: { screen: Screen; setScreen: (screen: Screen) => void }) {
  const navItems: { key: Screen; label: string; icon: IconName }[] = [
    { key: 'home', label: 'Inicio', icon: 'home' },
    { key: 'history', label: 'Historial', icon: 'clock' },
    { key: 'stats', label: 'Métricas', icon: 'chart' },
    { key: 'profile', label: 'Perfil', icon: 'user' },
  ]

  return (
    <nav className="bottom-nav">
      {navItems.slice(0, 2).map((item) => <NavButton key={item.key} item={item} screen={screen} setScreen={setScreen} />)}
      <button className="central-scan" onClick={() => setScreen('home')} aria-label="Escanear ahora"><span><Icon name="scan" size={25} /></span><small>Escanear</small></button>
      {navItems.slice(2).map((item) => <NavButton key={item.key} item={item} screen={screen} setScreen={setScreen} />)}
    </nav>
  )
}

function NavButton({ item, screen, setScreen }: { item: { key: Screen; label: string; icon: IconName }; screen: Screen; setScreen: (screen: Screen) => void }) {
  return <button className={screen === item.key ? 'active' : ''} onClick={() => setScreen(item.key)}><Icon name={item.icon} size={20} /><span>{item.label}</span></button>
}

function AppShell({ onExit }: { onExit: () => void }) {
  const [screen, setScreen] = useState<Screen>('home')
  return (
    <main className="app-page">
      <div className="ambient app-ambient-one" />
      <div className="ambient app-ambient-two" />
      <div className="mobile-app">
        {screen === 'home' && <HomeScreen />}
        {screen === 'history' && <HistoryScreen />}
        {screen === 'stats' && <StatsScreen />}
        {screen === 'profile' && <ProfileScreen onExit={onExit} />}
        <BottomNav screen={screen} setScreen={setScreen} />
      </div>
    </main>
  )
}

export default function App() {
  const [authenticated, setAuthenticated] = useState(false)
  return authenticated ? <AppShell onExit={() => setAuthenticated(false)} /> : <AuthScreen onEnter={() => setAuthenticated(true)} />
}
