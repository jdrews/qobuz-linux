const { app, BrowserWindow, Menu, Tray, nativeImage } = require('electron')
var path = require('path');

let appIcon = null
let win = null

const qobuz_url = "https://play.qobuz.com/"

const createWindow = () => {
    win = new BrowserWindow({
      width: 1200,
      height: 800,
      icon: path.join(__dirname, "../resources/icons/clearicon.png"),
      useContentSize: true,
      frame: true,
      titleBarStyle: 'default',
    })
    win.removeMenu()
    win.loadURL(qobuz_url)

    win.webContents.on('did-finish-load', () => {
        const css = `
            body, html, #app, #app > div {
                min-width: 0 !important;
            }
            .mobileOverlay {
                /* Qobuz enforces a 1024px minimum width and shows this overlay when narrower.
                   Since Electron lets us render at any size, hide it so the app stays usable. */
                display: none !important;
            }
        `;
        win.webContents.insertCSS(css);

        // Open DevTools for debugging after page load if DEVTOOLS env var is set
        if (process.env.DEVTOOLS) {
            win.webContents.openDevTools();
        }
    });

    win.on('close', (e) => {
            e.preventDefault()
            win.hide()
        })
}


const gotTheLock = app.requestSingleInstanceLock({});
if (!gotTheLock) {
  app.quit();
  process.exit(0);
}

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit()
})

app.on("second-instance", () => {
  win.show();
});

app.whenReady().then(() => {
  createWindow()

  const iconPath = path.join(__dirname, "../resources/icons/clearicon.png");
  const trayIcon = nativeImage.createFromPath(iconPath);
  appIcon = new Tray(trayIcon)
  const contextMenu = Menu.buildFromTemplate([
    { label: `Version ${app.getVersion()}`, enabled: false },
    { type: 'separator' },
    { label: 'Hide', click() { win.hide() }},
    { label: 'Show', click() { win.show() }},
    { label: 'Quit', click() { win.destroy() }},
  ])


  // Call this again for Linux because we modified the context menu
  appIcon.setContextMenu(contextMenu)


  app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})