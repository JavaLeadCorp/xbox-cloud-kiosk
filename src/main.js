const { app, BrowserWindow, session } = require('electron');
const path = require('path');

// Prevent multiple instances of the app running at once
const gotLock = app.requestSingleInstanceLock();
if (!gotLock) { app.quit(); }

let splashWindow = null;
let mainWindow   = null;

// Domains that navigation is allowed to (covers login + gameplay)
const ALLOWED_DOMAINS = [
  'xbox.com',
  'microsoft.com',
  'live.com',
  'microsoftonline.com',
  'xboxlive.com',
];

function isAllowed(url) {
  return ALLOWED_DOMAINS.some(domain => url.includes(domain));
}

// ---------------------------------------------------------------------------
// Splash window — shown while the main page loads
// ---------------------------------------------------------------------------
function createSplash() {
  splashWindow = new BrowserWindow({
    fullscreen: true,
    frame: false,
    alwaysOnTop: true,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });
  splashWindow.loadFile(path.join(__dirname, 'splash.html'));
}

// ---------------------------------------------------------------------------
// Main kiosk window
// ---------------------------------------------------------------------------
function createMain() {
  mainWindow = new BrowserWindow({
    fullscreen: true,
    frame: false,
    show: false,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      webgl: true,
    },
  });

  // Spoof user agent to Windows Chrome — Xbox Cloud Gaming requires this on Linux
  mainWindow.webContents.setUserAgent(
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' +
    'AppleWebKit/537.36 (KHTML, like Gecko) ' +
    'Chrome/122.0.0.0 Safari/537.36'
  );

  // Block navigation to anything outside Xbox/Microsoft
  mainWindow.webContents.on('will-navigate', (event, url) => {
    if (!isAllowed(url)) event.preventDefault();
  });

  // Block any popups outside Xbox/Microsoft (e.g. OAuth redirects are fine)
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    if (isAllowed(url)) mainWindow.loadURL(url);
    return { action: 'deny' };
  });

  mainWindow.loadURL('https://www.xbox.com/en-US/play');

  // Once page loads, fade out splash and show main window
  mainWindow.webContents.on('did-finish-load', () => {
    setTimeout(() => {
      if (splashWindow && !splashWindow.isDestroyed()) {
        splashWindow.close();
        splashWindow = null;
      }
      mainWindow.show();
    }, 800);
  });
}

// ---------------------------------------------------------------------------
// App lifecycle
// ---------------------------------------------------------------------------
app.whenReady().then(() => {
  // Auto-grant permissions needed for cloud gaming
  session.defaultSession.setPermissionRequestHandler((_wc, permission, callback) => {
    const allowed = ['fullscreen', 'media', 'gamepad', 'pointerLock'];
    callback(allowed.includes(permission));
  });

  createSplash();
  setTimeout(createMain, 400); // small delay so splash renders before network starts
});

app.on('window-all-closed', () => app.quit());

// If user tries to open a second instance, just focus the existing window
app.on('second-instance', () => {
  if (mainWindow) mainWindow.focus();
});
