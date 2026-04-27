<div align="center">

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:0f0f1a,30:00D9FF,70:FF6B35,100:0f0f1a&height=210&section=header&text=Social%20Downloader&fontSize=42&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=Download%20social%20videos%20directly%20into%20DaVinci%20Resolve&descAlignY=60&descSize=16" />

[![Typing SVG](https://readme-typing-svg.demolab.com?font=Inter&weight=600&size=21&pause=1000&color=00D9FF&center=true&vCenter=true&width=980&lines=Download+from+YouTube%2C+Instagram%2C+TikTok+and+more;Auto-detect+platforms+and+import+into+Media+Pool;Available+for+macOS+and+Windows;Powered+by+Lua%2C+yt-dlp+and+ffmpeg)](https://git.io/typing-svg)

# 📥 Social Downloader for DaVinci Resolve

**A modern DaVinci Resolve utility script to download videos from major social platforms and import them directly into your Media Pool.**

<p>
  <img src="https://img.shields.io/badge/version-5.1-00D9FF?style=for-the-badge" />
  <img src="https://img.shields.io/badge/macOS-supported-1a1a2e?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Windows-supported-0078D6?style=for-the-badge&logo=windows&logoColor=white" />
  <img src="https://img.shields.io/badge/DaVinci%20Resolve-17%2B-FF6B35?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Lua-Script-2C2D72?style=for-the-badge&logo=lua&logoColor=white" />
  <img src="https://img.shields.io/badge/yt--dlp-powered-FF0000?style=for-the-badge" />
  <img src="https://img.shields.io/badge/ffmpeg-required-10B981?style=for-the-badge" />
</p>

<p>
  <img src="https://img.shields.io/badge/YouTube-FF0000?style=flat-square&logo=youtube&logoColor=white" />
  <img src="https://img.shields.io/badge/Instagram-E4405F?style=flat-square&logo=instagram&logoColor=white" />
  <img src="https://img.shields.io/badge/TikTok-000000?style=flat-square&logo=tiktok&logoColor=white" />
  <img src="https://img.shields.io/badge/Pinterest-BD081C?style=flat-square&logo=pinterest&logoColor=white" />
  <img src="https://img.shields.io/badge/Twitter%2FX-1DA1F2?style=flat-square" />
  <img src="https://img.shields.io/badge/Facebook-1877F2?style=flat-square&logo=facebook&logoColor=white" />
  <img src="https://img.shields.io/badge/Vimeo-1AB7EA?style=flat-square&logo=vimeo&logoColor=white" />
  <img src="https://img.shields.io/badge/Reddit-FF4500?style=flat-square&logo=reddit&logoColor=white" />
</p>

</div>

---

## ✨ Overview

**Social Downloader** is a utility script for **DaVinci Resolve** available on both **macOS and Windows**.

It allows you to download media from popular social media platforms and optionally import the downloaded file directly into the **Resolve Media Pool**.

No browser-heavy workflow. No manual file hunting. Just a fast editor-friendly pipeline inside Resolve.

### Simple Workflow
**Paste URL → Get Info → Download → Import into Resolve**

---

## 🚀 Features

- **Auto platform detection**
- **Fusion UI inside DaVinci Resolve**
- **Download video in Best / 4K / 1080p / 720p**
- **Audio-only mode in WAV**
- **Subtitle download support**
- **Thumbnail saving**
- **Playlist support**
- **Automatic Resolve Media Pool import**
- **Download history**
- **Platform-based folder organization**
- **Improved video + audio merging**
- **MP4-focused output for better Resolve compatibility**

---

## 🧩 Supported Platforms

| Platform | Support |
|---|---|
| YouTube | ✅ Supported |
| Instagram | ✅ Supported |
| Pinterest | ✅ Supported |
| Twitter / X | ✅ Supported |
| TikTok | ✅ Supported |
| Facebook | ✅ Supported |
| Vimeo | ✅ Supported |
| Reddit | ✅ Supported |
| Auto-detect | ✅ Supported |

---

## 🖼️ Preview

<div align="center">

<table>
  <tr>
    <td align="center" style="padding: 0;">
      <img src="assets/demo.gif" alt="Social Downloader Demo" width="100%" style="border-radius: 14px; display: block;" />
    </td>
  </tr>
  <tr>
    <td align="center">
      <sub>
        <img src="https://img.shields.io/badge/Social%20Downloader-v5.1-00D9FF?style=flat-square" />
        &nbsp;
        <img src="https://img.shields.io/badge/DaVinci%20Resolve-Ready-FF6B35?style=flat-square" />
        &nbsp;
        <img src="https://img.shields.io/badge/macOS%20%2B%20Windows-1a1a2e?style=flat-square" />
      </sub>
    </td>
  </tr>
</table>

</div>

---

## ⚙️ Requirements

### macOS ![macOS](https://img.shields.io/badge/macOS-1a1a2e?style=flat-square&logo=apple&logoColor=white)

- **macOS** (Intel or Apple Silicon)
- **DaVinci Resolve** 17 / 18 / 19 / 20 / 21
- **Homebrew**
- **yt-dlp**
- **ffmpeg**

### Windows ![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat-square&logo=windows&logoColor=white)

- **Windows** 10 / 11
- **DaVinci Resolve** 17 / 18 / 19 / 20 / 21
- **yt-dlp**
- **ffmpeg**

> **Important:** `ffmpeg` is required for proper video/audio merging on several platforms.

---

## 📦 Installation

### macOS ![macOS](https://img.shields.io/badge/macOS-1a1a2e?style=flat-square&logo=apple&logoColor=white)

#### Option 1 — Installer Script

```bash
git clone https://github.com/praveensinghlko/Resolve-Social-Downloader.git
cd Resolve-Social-Downloader/macOS
chmod +x install.sh
./install.sh
```

The macOS installer will:
- copy the script to the correct DaVinci Resolve script folder
- check whether `yt-dlp` and `ffmpeg` are installed
- offer to install missing dependencies via Homebrew

#### Option 2 — Manual Install

```bash
cp macOS/Resolve-Social-Downloader.lua "$HOME/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Utility/"
brew install yt-dlp
brew install ffmpeg
```

---

### Windows ![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat-square&logo=windows&logoColor=white)

#### Option 1 — Installer Script

1. Download or clone this repository  
2. Open the **Windows** folder  
3. Double-click **install.bat**  
4. If needed, right-click and **Run as Administrator**

The Windows installer will:
- copy the script to the correct DaVinci Resolve script folder
- check whether `yt-dlp` and `ffmpeg` are installed
- offer to install missing dependencies via `winget`

#### Option 2 — Manual Install

Copy `Windows/Resolve-Social-Downloader-Win.lua` to:

```text
C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Utility\
```

Install dependencies:

```text
winget install yt-dlp
winget install ffmpeg
```

---

## ▶️ Launch the Script

### macOS
```text
Workspace → Scripts → Utility → Resolve-Social-Downloader
```

### Windows
```text
Workspace → Scripts → Utility → Resolve-Social-Downloader-Win
```

---

## 🛠️ Usage

1. Paste a video URL into the input field  
2. Click **GET INFO**  
3. Select the platform or leave it on **Auto-detect**  
4. Choose the quality you want  
5. Enable optional features like subtitles, thumbnails, or audio-only mode  
6. Click **DOWNLOAD NOW**  
7. Choose whether to import the result into Resolve  

---

## 📁 Output Structure

### macOS
```text
~/Downloads/SocialDownloader/
```

### Windows
```text
C:\Users\YourName\Downloads\SocialDownloader\
```

Both platforms organize downloads like this:

```text
SocialDownloader/
├── YouTube/
│   └── thumbnails/
├── Instagram/
│   └── thumbnails/
├── Pinterest/
│   └── thumbnails/
├── Twitter/
│   └── thumbnails/
├── TikTok/
│   └── thumbnails/
├── Facebook/
│   └── thumbnails/
├── Vimeo/
│   └── thumbnails/
├── Reddit/
│   └── thumbnails/
├── Other/
│   └── thumbnails/
└── history.json
```

---

## 🔧 How It Works

This script combines a few powerful tools:

- **Lua** for the DaVinci Resolve / Fusion UI and logic
- **yt-dlp** for metadata extraction and downloading
- **ffmpeg** for merging, conversion, and post-processing
- **DaVinci Resolve API** for importing media directly into the Media Pool

---

## ✅ Version 5.1 Highlights

- Fixed **Instagram / Pinterest video + audio merge issues**
- Improved **YouTube WebM → MP4 conversion**
- Forced **MP4 output** for DaVinci Resolve compatibility
- Improved **ffmpeg auto-detection**
- Improved **downloaded file detection**
- Added **video track verification using ffprobe**
- Added **Windows support with dedicated installer**

---

## 🧪 Troubleshooting

### `yt-dlp not found`

**macOS**
```bash
brew install yt-dlp
brew upgrade yt-dlp
```

**Windows**
```text
winget install yt-dlp
```

### `ffmpeg not found`

**macOS**
```bash
brew install ffmpeg
```

**Windows**
```text
winget install ffmpeg
```

### Downloaded video has no audio

Make sure `ffmpeg` is installed and accessible in your Terminal or Command Prompt.

### Instagram, Pinterest, or YouTube download fails

Update `yt-dlp`:

**macOS**
```bash
brew upgrade yt-dlp
```

**Windows**
```text
winget upgrade yt-dlp
```

### “Run this script from within DaVinci Resolve”

This script must be launched **inside DaVinci Resolve**, not from Terminal or Command Prompt.

### Import to Media Pool fails

- Make sure a Resolve project is currently open
- Check that the file was downloaded successfully
- Try importing the file manually from the output folder

### Windows installer needs permission

If `install.bat` cannot copy files into the Resolve scripts folder, run it as **Administrator**.

---

## 🗂️ Project Structure

```text
Resolve-Social-Downloader/
├── assets/
│   └── demo.gif
├── macOS/
│   ├── Resolve-Social-Downloader.lua
│   └── install.sh
├── Windows/
│   ├── Resolve-Social-Downloader-Win.lua
│   └── install.bat
└── README.md
```

---

## 🗺️ Roadmap

- [x] Windows support
- [ ] Batch URL download support
- [ ] Real-time progress bar
- [ ] Custom output folder selector
- [ ] More supported platforms
- [ ] Better thumbnail preview rendering
- [ ] Persistent user settings

---

## 🤝 Contributing

Contributions are welcome.

```bash
git checkout -b feature/your-feature-name
git commit -m "feat: describe your change"
git push origin feature/your-feature-name
```

You can help with:

- bug fixes
- UI improvements
- metadata parsing improvements
- platform support expansion
- Resolve workflow enhancements

---

## 📜 Changelog

### v5.1
- Fixed merge issues for Instagram and Pinterest
- Improved MP4 output compatibility
- Improved file detection after download
- Improved ffmpeg integration
- Added media verification checks
- Added Windows support with installer files

### v5.0
- Complete UI redesign
- Added download history
- Added preview section
- Added platform-specific format handling

### v4.x
- Core downloading functionality
- Resolve Media Pool import support

---

## ⚠️ Disclaimer

This project is intended for **personal and educational use only**.

Please:

- respect each platform's Terms of Service
- avoid downloading copyrighted content without permission
- support original creators whenever possible

---

## 📄 License

This project is licensed under the **MIT License**.

```text
Copyright (c) 2024 Praveen Singh
```

---

## 👨‍💻 Author

**Praveen Singh**  
🌐 [praveensingh.pro](https://praveensingh.pro/)

If this project helps you, consider giving it a **star** on GitHub.

---

<div align="center">

### ⭐ Built for editors who want speed inside DaVinci Resolve

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:0f0f1a,30:00D9FF,70:FF6B35,100:0f0f1a&height=120&section=footer" />

</div>
