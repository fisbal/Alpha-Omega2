// Alpha & Omega — Windows desktop shell.
// Loads the unmodified app/index.html as a packaged resource. No changes to
// the app's content, theology, or features happen here — this file only
// opens a window and points it at the existing HTML file.
const { app, BrowserWindow } = require("electron");
const path = require("path");

function resolveAppFile() {
  // In a packaged build, electron-builder's extraResources copies the
  // sibling "app" folder into resources/app alongside this executable.
  // In dev (unpackaged), it's one directory up at ../app.
  const packaged = path.join(process.resourcesPath, "app", "index.html");
  const dev = path.join(__dirname, "..", "app", "index.html");
  const fs = require("fs");
  return fs.existsSync(packaged) ? packaged : dev;
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1280,
    height: 860,
    minWidth: 820,
    minHeight: 560,
    backgroundColor: "#14151D",
    title: "Alpha & Omega",
    icon: path.join(__dirname, "..", "app", "icon.ico"),
    autoHideMenuBar: true,
    webPreferences: {
      sandbox: true,
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  win.loadFile(resolveAppFile());
}

app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});

app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
