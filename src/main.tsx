import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import { initTheme } from './theme'
import { registerSW } from 'virtual:pwa-register'

const updateSW = registerSW({
  immediate: true,
  onNeedRefresh() {
    // تنزيل النسخة الجديدة فورًا بدل إبقاء التطبيق على bundle قديم.
    void updateSW(true)
  },
  onRegisteredSW(_swUrl, registration) {
    // فحص تحديثات النشر دوريًا، خصوصًا للتطبيق المثبت كـ PWA.
    if (registration) {
      window.setInterval(() => void registration.update(), 5 * 60 * 1000)
    }
  },
})

// عند نشر نسخة جديدة قد يحاول متصفحٌ آخر تحميل chunk انتهت إزالته من CDN.
// إعادة تحميل واحدة فقط تستعيد index.html وService Worker الجديدين دون loop.
window.addEventListener('vite:preloadError', (event) => {
  event.preventDefault()
  const reloadKey = 'mido-market-preload-recovery'
  if (!sessionStorage.getItem(reloadKey)) {
    sessionStorage.setItem(reloadKey, '1')
    window.location.reload()
  } else {
    sessionStorage.removeItem(reloadKey)
  }
})

// تزامن الثيم بين التابات ومع إعداد الجهاز — مرة واحدة لكل صفحة.
initTheme()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
