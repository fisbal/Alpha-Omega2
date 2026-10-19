# Alpha & Omega — New Testament Study

A deep, bilingual (EN/FR) New Testament study app — KJV/WEB and Louis Segond/Darby,
verse-by-verse commentary, and an honest investigation into the historical Jesus.

The app itself (`app/index.html`) is unchanged from the version published as a
Claude Artifact. This repository only adds the pattern used for NavalOS,
MillionOS, and ProDFOS: every push to `main` automatically rebuilds and
republishes a Windows installer, an Android APK, and a web link — no manual
packaging step.

## Get the app — three ways

**1. Any phone, tablet, or computer (no install needed, works everywhere):**
Open **https://fisbal.github.io/alpha-omega/** in a browser. On Android/Chrome
and most modern browsers you can also tap "Install app" / "Add to Home
Screen" to get an app icon and offline access.

**2. Windows:**
Go to the [latest release](../../releases/tag/latest), download
`AlphaOmega-windows-setup.exe`, and run it. It installs like any normal
Windows program (Start Menu + desktop shortcut).

**3. Android:**
Go to the [latest release](../../releases/tag/latest), download
`AlphaOmega-android.apk` on your phone, and open it to install. Android may
ask you to allow "install from unknown sources" the first time — that's
expected for an app installed outside the Play Store.

## How the automatic rebuild works

Every time something changes on `main`, GitHub Actions (`.github/workflows/build.yml`) runs four jobs:

- `android` — generates a fresh native Android project with Capacitor
  (wrapping `app/`, nothing duplicated) and builds the APK.
- `windows` — packages `app/` into a Windows installer with Electron +
  electron-builder.
- `web` — copies `app/` as-is to the `gh-pages` branch, which GitHub Pages
  serves at the link above.
- `release` — collects the APK and the EXE and republishes them under a
  single rolling release tagged `latest`, so the download links above never
  change even though the files behind them do.

## Repository layout

```
app/          the actual Alpha & Omega app (index.html, manifest, service
              worker, icons) — the only folder with real content
electron/     Windows desktop wrapper around app/ (no app content here)
capacitor/    Android wrapper config around app/ (no app content here;
              the native android/ project is generated fresh by CI)
.github/      the build-and-release pipeline
```

To change the app itself, edit `app/index.html` and push — the next build
picks it up everywhere automatically. Nothing else in this repo needs to
change for a content update.
