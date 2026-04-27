--[[
================================================================================
    📥 Social Downloader for DaVinci Resolve
    
    💻 Developed by: Praveen Singh
    📱 Platform: macOS Only
    📦 Version: 5.1 - FIXED Audio/Video Merge Issues
    
    Supported Platforms:
    🟢 Auto-detect | 🔴 YouTube | 🟣 Instagram | 🔴 Pinterest
    ⚫ Twitter/X | ⬛ TikTok | 🔵 Facebook | 🔵 Vimeo | 🟠 Reddit
================================================================================
]]

if not fu or not bmd then
    print("ERROR: Run this script from within DaVinci Resolve")
    return
end

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

-- Window Size
local width, height = 1200, 750

-- Config
local config = {
    basePath = "/Users/praveen/Downloads/SocialDownloader/",
    ytdlpPath = nil,
    ffmpegPath = nil,
    ffmpegDir = nil,
    rememberImport = false,
    autoImport = true,
}

-- Platform Colors & Info
local platforms = {
    {id = "auto", name = "🟢 Auto-detect", color = "#10B981", folder = "Other"},
    {id = "youtube", name = "🔴 YouTube", color = "#FF0000", folder = "YouTube"},
    {id = "instagram", name = "🟣 Instagram", color = "#E1306C", folder = "Instagram"},
    {id = "pinterest", name = "🔴 Pinterest", color = "#E60023", folder = "Pinterest"},
    {id = "twitter", name = "⚫ Twitter/X", color = "#1DA1F2", folder = "Twitter"},
    {id = "tiktok", name = "⬛ TikTok", color = "#010101", folder = "TikTok"},
    {id = "facebook", name = "🔵 Facebook", color = "#1877F2", folder = "Facebook"},
    {id = "vimeo", name = "🔵 Vimeo", color = "#1AB7EA", folder = "Vimeo"},
    {id = "reddit", name = "🟠 Reddit", color = "#FF4500", folder = "Reddit"},
}

-- Download History
local downloadHistory = {}

-- Video Info
local videoInfo = {
    title = '',
    duration = '',
    channel = '',
    platform = '',
    thumbnail = '',
    url = '',
    quality = '',
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function findExecutable(name)
    local handle = io.popen('which ' .. name .. ' 2>/dev/null')
    if handle then
        local result = handle:read('*l')
        handle:close()
        if result and result ~= '' then return result end
    end
    local paths = {'/opt/homebrew/bin/'..name, '/usr/local/bin/'..name}
    for _, p in ipairs(paths) do
        local f = io.open(p, 'r')
        if f then f:close() return p end
    end
    return nil
end

local function createDirectory(path)
    os.execute('mkdir -p "' .. path .. '"')
end

local function formatDuration(sec)
    if not sec or sec == '' then return '--:--' end
    local s = tonumber(sec) or 0
    local h, m, ss = math.floor(s/3600), math.floor((s%3600)/60), math.floor(s%60)
    if h > 0 then return string.format('%d:%02d:%02d', h, m, ss)
    else return string.format('%d:%02d', m, ss) end
end

local function detectPlatform(url)
    if not url then return "auto" end
    url = url:lower()
    if url:match("youtube") or url:match("youtu.be") then return "youtube"
    elseif url:match("instagram") then return "instagram"
    elseif url:match("pinterest") or url:match("pin.it") then return "pinterest"
    elseif url:match("twitter") or url:match("x.com") then return "twitter"
    elseif url:match("tiktok") then return "tiktok"
    elseif url:match("facebook") or url:match("fb.watch") then return "facebook"
    elseif url:match("vimeo") then return "vimeo"
    elseif url:match("reddit") or url:match("redd.it") then return "reddit"
    else return "auto" end
end

local function getPlatformInfo(id)
    for _, p in ipairs(platforms) do
        if p.id == id then return p end
    end
    return platforms[1]
end

local function getPlatformIndex(id)
    for i, p in ipairs(platforms) do
        if p.id == id then return i - 1 end
    end
    return 0
end

local function sanitizeFilename(name)
    if not name then return "video" end
    -- Remove problematic characters
    name = name:gsub('[\\/:*?"<>|]', '_')
    name = name:gsub('%s+', ' ')
    name = name:sub(1, 100)  -- Limit length
    return name
end

local function saveHistory()
    local historyFile = config.basePath .. "history.json"
    local f = io.open(historyFile, "w")
    if f then
        f:write("[\n")
        for i, h in ipairs(downloadHistory) do
            f:write(string.format('  {"title":"%s","platform":"%s","date":"%s","file":"%s","status":"%s"}',
                h.title or "", h.platform or "", h.date or "", h.file or "", h.status or ""))
            if i < #downloadHistory then f:write(",") end
            f:write("\n")
        end
        f:write("]\n")
        f:close()
    end
end

local function loadHistory()
    local historyFile = config.basePath .. "history.json"
    local f = io.open(historyFile, "r")
    if f then
        local content = f:read("*a")
        f:close()
        downloadHistory = {}
        for title, platform, date, file, status in content:gmatch('"title":"([^"]*)","platform":"([^"]*)","date":"([^"]*)","file":"([^"]*)","status":"([^"]*)"') do
            table.insert(downloadHistory, {title=title, platform=platform, date=date, file=file, status=status})
        end
    end
end

-- ============================================================================
-- MAIN WINDOW
-- ============================================================================

local win = disp:AddWindow({
    ID = 'SocialDownloader',
    WindowTitle = '📥 Social Downloader | by Praveen Singh',
    Geometry = {50, 50, width, height},
    Spacing = 8,
    Margin = 12,
    
    ui:VGroup{
        ID = 'root',
        
        -- HEADER
        ui:HGroup{
            Weight = 0,
            MinimumSize = {0, 50},
            
            ui:Label{
                Text = '📥 Social Downloader',
                StyleSheet = [[QLabel{
                    color: #00D9FF;
                    font-size: 26px;
                    font-weight: bold;
                    padding: 10px;
                }]],
                MinimumSize = {300, 45},
            },
            
            ui:HGap(0, 1),
            
            ui:Label{
                Text = 'v5.1 🔧 Fixed',
                StyleSheet = [[QLabel{color:#10B981;font-size:11px;padding:5px;}]],
            },
            
            ui:Label{
                Text = '💻 Developed by Praveen Singh',
                StyleSheet = [[QLabel{
                    color: #FF6B35;
                    font-size: 13px;
                    font-weight: bold;
                    padding: 10px;
                }]],
                MinimumSize = {250, 45},
                Alignment = {AlignRight = true},
            },
        },
        
        -- URL INPUT ROW
        ui:HGroup{
            Weight = 0,
            MinimumSize = {0, 45},
            
            ui:Label{
                Text = '🔗 URL:',
                StyleSheet = [[QLabel{color:#AAAAAA;font-size:13px;font-weight:bold;}]],
                MinimumSize = {50, 40},
            },
            
            ui:LineEdit{
                ID = 'urlInput',
                PlaceholderText = 'Paste video URL here (YouTube, Instagram, Pinterest, Twitter, TikTok, etc.)...',
                MinimumSize = {600, 38},
                StyleSheet = [[QLineEdit{
                    background:#1a1a2e;
                    border:2px solid #00D9FF;
                    border-radius:8px;
                    color:#fff;
                    padding:8px 12px;
                    font-size:13px;
                }
                QLineEdit:focus{border-color:#FF6B35;}]],
            },
            
            ui:Button{
                ID = 'btnGetInfo',
                Text = '🔍 GET INFO',
                MinimumSize = {120, 38},
                StyleSheet = [[QPushButton{
                    background:#00D9FF;
                    border:none;
                    border-radius:8px;
                    color:#000;
                    font-weight:bold;
                    font-size:13px;
                    padding:8px 15px;
                }
                QPushButton:hover{background:#00B4D8;}]],
            },
        },
        
        -- PLATFORM & IMPORT ROW
        ui:HGroup{
            Weight = 0,
            MinimumSize = {0, 40},
            
            ui:Label{
                Text = '📱 Platform:',
                StyleSheet = [[QLabel{color:#AAAAAA;font-size:12px;font-weight:bold;}]],
                MinimumSize = {80, 35},
            },
            
            ui:ComboBox{
                ID = 'cmbPlatform',
                MinimumSize = {200, 32},
                StyleSheet = [[QComboBox{
                    background:#1a1a2e;
                    border:2px solid #10B981;
                    border-radius:6px;
                    color:#fff;
                    padding:6px 12px;
                    font-size:12px;
                }
                QComboBox::drop-down{border:none;width:30px;}
                QComboBox QAbstractItemView{
                    background:#1a1a2e;
                    color:#fff;
                    selection-background-color:#10B981;
                }]],
            },
            
            ui:HGap(30),
            
            ui:CheckBox{
                ID = 'chkAutoImport',
                Text = '  📥 Auto-import to Media Pool',
                Checked = true,
                MinimumSize = {220, 32},
                StyleSheet = [[QCheckBox{
                    color:#FFFFFF;
                    font-size:12px;
                    font-weight:bold;
                }
                QCheckBox::indicator{
                    width:18px;
                    height:18px;
                    border-radius:4px;
                    border:2px solid #10B981;
                }
                QCheckBox::indicator:checked{background:#10B981;}]],
            },
            
            ui:HGap(0, 1),
            
            ui:Button{
                ID = 'btnHistory',
                Text = '📜 HISTORY',
                MinimumSize = {110, 32},
                StyleSheet = [[QPushButton{
                    background:#252536;
                    border:2px solid #A855F7;
                    border-radius:6px;
                    color:#A855F7;
                    font-weight:bold;
                    font-size:11px;
                    padding:6px 12px;
                }
                QPushButton:hover{background:#A855F7;color:#fff;}]],
            },
        },
        
        ui:VGap(5),
        
        -- MAIN CONTENT: PREVIEW + OPTIONS
        ui:HGroup{
            Weight = 0.5,
            MinimumSize = {0, 280},
            
            -- LEFT: VIDEO PREVIEW
            ui:VGroup{
                Weight = 0.55,
                MinimumSize = {500, 270},
                StyleSheet = [[QFrame{
                    background:#1a1a2e;
                    border:2px solid #00D9FF;
                    border-radius:10px;
                    padding:10px;
                }]],
                
                ui:Label{
                    Text = '📺 VIDEO PREVIEW',
                    StyleSheet = [[QLabel{color:#00D9FF;font-size:14px;font-weight:bold;padding:5px;}]],
                    MinimumSize = {0, 25},
                },
                
                -- Thumbnail Placeholder
                ui:VGroup{
                    Weight = 1,
                    MinimumSize = {0, 150},
                    StyleSheet = [[QFrame{
                        background:#0a0a14;
                        border:1px solid #333;
                        border-radius:8px;
                    }]],
                    
                    ui:Label{
                        ID = 'lblThumbnail',
                        Text = '🖼️ Thumbnail will appear here\n\nPaste URL and click GET INFO',
                        Alignment = {AlignHCenter = true, AlignVCenter = true},
                        StyleSheet = [[QLabel{color:#666;font-size:14px;padding:20px;}]],
                    },
                },
                
                ui:VGap(8),
                
                -- Video Info
                ui:HGroup{
                    Weight = 0,
                    MinimumSize = {0, 25},
                    ui:Label{Text = '📺 Title:', StyleSheet = [[QLabel{color:#888;font-size:11px;min-width:60px;}]]},
                    ui:Label{ID = 'infoTitle', Text = 'No video loaded', StyleSheet = [[QLabel{color:#fff;font-size:11px;}]]},
                },
                
                ui:HGroup{
                    Weight = 0,
                    MinimumSize = {0, 22},
                    ui:Label{Text = '⏱️ Duration:', StyleSheet = [[QLabel{color:#888;font-size:11px;min-width:60px;}]]},
                    ui:Label{ID = 'infoDuration', Text = '--:--', StyleSheet = [[QLabel{color:#10B981;font-size:11px;font-weight:bold;min-width:60px;}]]},
                    ui:Label{Text = '👤 Channel:', StyleSheet = [[QLabel{color:#888;font-size:11px;min-width:60px;}]]},
                    ui:Label{ID = 'infoChannel', Text = '-', StyleSheet = [[QLabel{color:#00D9FF;font-size:11px;}]]},
                },
                
                ui:HGroup{
                    Weight = 0,
                    MinimumSize = {0, 22},
                    ui:Label{Text = '📱 Platform:', StyleSheet = [[QLabel{color:#888;font-size:11px;min-width:60px;}]]},
                    ui:Label{ID = 'infoPlatform', Text = '-', StyleSheet = [[QLabel{color:#FF6B35;font-size:11px;font-weight:bold;min-width:80px;}]]},
                    ui:Label{Text = '📊 Quality:', StyleSheet = [[QLabel{color:#888;font-size:11px;min-width:60px;}]]},
                    ui:Label{ID = 'infoQuality', Text = '-', StyleSheet = [[QLabel{color:#FBBF24;font-size:11px;}]]},
                },
            },
            
            ui:HGap(10),
            
            -- RIGHT: OPTIONS
            ui:VGroup{
                Weight = 0.45,
                MinimumSize = {400, 270},
                
                -- VIDEO OPTIONS
                ui:VGroup{
                    Weight = 0,
                    MinimumSize = {0, 75},
                    StyleSheet = [[QFrame{background:#1a1a2e;border:2px solid #FF0000;border-radius:8px;padding:8px;}]],
                    
                    ui:Label{
                        Text = '🔴 VIDEO OPTIONS',
                        StyleSheet = [[QLabel{color:#FF0000;font-size:12px;font-weight:bold;}]],
                        MinimumSize = {0, 20},
                    },
                    ui:HGroup{
                        Weight = 0,
                        ui:CheckBox{
                            ID = 'chkVideo',
                            Text = ' Download Video',
                            Checked = true,
                            StyleSheet = [[QCheckBox{color:#fff;font-size:11px;}
                            QCheckBox::indicator{width:16px;height:16px;border-radius:4px;border:2px solid #FF0000;}
                            QCheckBox::indicator:checked{background:#FF0000;}]],
                        },
                        ui:HGap(20),
                        ui:Label{Text = 'Quality:', StyleSheet = [[QLabel{color:#888;font-size:11px;}]]},
                        ui:ComboBox{
                            ID = 'cmbQuality',
                            MinimumSize = {130, 26},
                            StyleSheet = [[QComboBox{background:#252536;border:1px solid #FF0000;border-radius:4px;color:#fff;padding:4px;font-size:10px;}]],
                        },
                    },
                },
                
                ui:VGap(6),
                
                -- AUDIO OPTIONS
                ui:VGroup{
                    Weight = 0,
                    MinimumSize = {0, 55},
                    StyleSheet = [[QFrame{background:#1a1a2e;border:2px solid #10B981;border-radius:8px;padding:8px;}]],
                    
                    ui:Label{
                        Text = '🟢 AUDIO OPTIONS',
                        StyleSheet = [[QLabel{color:#10B981;font-size:12px;font-weight:bold;}]],
                        MinimumSize = {0, 18},
                    },
                    ui:HGroup{
                        Weight = 0,
                        ui:CheckBox{
                            ID = 'chkAudio',
                            Text = ' Audio Only (WAV - Best Quality)',
                            Checked = false,
                            StyleSheet = [[QCheckBox{color:#fff;font-size:11px;}
                            QCheckBox::indicator{width:16px;height:16px;border-radius:4px;border:2px solid #10B981;}
                            QCheckBox::indicator:checked{background:#10B981;}]],
                        },
                    },
                },
                
                ui:VGap(6),
                
                -- SUBTITLES
                ui:VGroup{
                    Weight = 0,
                    MinimumSize = {0, 55},
                    StyleSheet = [[QFrame{background:#1a1a2e;border:2px solid #FBBF24;border-radius:8px;padding:8px;}]],
                    
                    ui:Label{
                        Text = '🟡 SUBTITLES',
                        StyleSheet = [[QLabel{color:#FBBF24;font-size:12px;font-weight:bold;}]],
                        MinimumSize = {0, 18},
                    },
                    ui:HGroup{
                        Weight = 0,
                        ui:CheckBox{
                            ID = 'chkSubs',
                            Text = ' Download Subtitles',
                            Checked = false,
                            StyleSheet = [[QCheckBox{color:#fff;font-size:11px;}
                            QCheckBox::indicator{width:16px;height:16px;border-radius:4px;border:2px solid #FBBF24;}
                            QCheckBox::indicator:checked{background:#FBBF24;}]],
                        },
                        ui:HGap(15),
                        ui:ComboBox{
                            ID = 'cmbLang',
                            MinimumSize = {110, 24},
                            StyleSheet = [[QComboBox{background:#252536;border:1px solid #FBBF24;border-radius:4px;color:#fff;padding:3px;font-size:10px;}]],
                        },
                    },
                },
                
                ui:VGap(6),
                
                -- EXTRAS (Playlist + Thumbnail)
                ui:HGroup{
                    Weight = 0,
                    MinimumSize = {0, 55},
                    
                    -- Playlist
                    ui:VGroup{
                        Weight = 1,
                        StyleSheet = [[QFrame{background:#1a1a2e;border:2px solid #A855F7;border-radius:8px;padding:8px;}]],
                        
                        ui:Label{
                            Text = '🟣 PLAYLIST',
                            StyleSheet = [[QLabel{color:#A855F7;font-size:11px;font-weight:bold;}]],
                            MinimumSize = {0, 16},
                        },
                        ui:CheckBox{
                            ID = 'chkPlaylist',
                            Text = ' Download All',
                            Checked = false,
                            StyleSheet = [[QCheckBox{color:#fff;font-size:10px;}
                            QCheckBox::indicator{width:14px;height:14px;border-radius:3px;border:2px solid #A855F7;}
                            QCheckBox::indicator:checked{background:#A855F7;}]],
                        },
                    },
                    
                    ui:HGap(6),
                    
                    -- Thumbnail
                    ui:VGroup{
                        Weight = 1,
                        StyleSheet = [[QFrame{background:#1a1a2e;border:2px solid #E1306C;border-radius:8px;padding:8px;}]],
                        
                        ui:Label{
                            Text = '🖼️ THUMBNAIL',
                            StyleSheet = [[QLabel{color:#E1306C;font-size:11px;font-weight:bold;}]],
                            MinimumSize = {0, 16},
                        },
                        ui:CheckBox{
                            ID = 'chkThumbnail',
                            Text = ' Save Image',
                            Checked = true,
                            StyleSheet = [[QCheckBox{color:#fff;font-size:10px;}
                            QCheckBox::indicator{width:14px;height:14px;border-radius:3px;border:2px solid #E1306C;}
                            QCheckBox::indicator:checked{background:#E1306C;}]],
                        },
                    },
                },
            },
        },
        
        ui:VGap(10),
        
        -- DOWNLOAD BUTTON
        ui:HGroup{
            Weight = 0,
            MinimumSize = {0, 55},
            
            ui:HGap(0, 1),
            
            ui:Button{
                ID = 'btnDownload',
                Text = '⬇️  DOWNLOAD NOW',
                MinimumSize = {300, 50},
                StyleSheet = [[QPushButton{
                    background:qlineargradient(x1:0,y1:0,x2:1,y2:0,stop:0 #FF6B35,stop:0.5 #FF8C42,stop:1 #FF6B35);
                    border:none;
                    border-radius:12px;
                    color:#fff;
                    font-size:18px;
                    font-weight:bold;
                    padding:12px 40px;
                }
                QPushButton:hover{background:qlineargradient(x1:0,y1:0,x2:1,y2:0,stop:0 #E55A2B,stop:0.5 #FF6B35,stop:1 #E55A2B);}
                QPushButton:disabled{background:#555;color:#888;}]],
            },
            
            ui:HGap(0, 1),
        },
        
        ui:VGap(8),
        
        -- LOG SECTION
        ui:VGroup{
            Weight = 0.4,
            MinimumSize = {0, 180},
            
            ui:HGroup{
                Weight = 0,
                MinimumSize = {0, 28},
                
                ui:Label{
                    Text = '📋 LOG',
                    StyleSheet = [[QLabel{color:#00D9FF;font-size:12px;font-weight:bold;}]],
                },
                ui:HGap(0, 1),
                ui:Button{
                    ID = 'btnClear',
                    Text = '🗑️ Clear',
                    MinimumSize = {70, 24},
                    StyleSheet = [[QPushButton{background:#252536;border:1px solid #555;border-radius:5px;color:#aaa;font-size:10px;padding:4px 10px;}
                    QPushButton:hover{background:#353546;color:#fff;}]],
                },
                ui:Button{
                    ID = 'btnSetup',
                    Text = '⚙️ Setup',
                    MinimumSize = {70, 24},
                    StyleSheet = [[QPushButton{background:#252536;border:1px solid #555;border-radius:5px;color:#aaa;font-size:10px;padding:4px 10px;}
                    QPushButton:hover{background:#353546;color:#fff;}]],
                },
            },
            
            ui:TextEdit{
                ID = 'logArea',
                Text = '',
                ReadOnly = true,
                MinimumSize = {0, 140},
                StyleSheet = [[QTextEdit{
                    background:#0a0a14;
                    border:1px solid #333;
                    border-radius:8px;
                    color:#ccc;
                    font-family:'Menlo','Monaco',monospace;
                    font-size:11px;
                    padding:10px;
                }]],
            },
        },
        
        -- STATUS BAR
        ui:HGroup{
            Weight = 0,
            MinimumSize = {0, 30},
            
            ui:Label{
                ID = 'status',
                Text = '✅ Ready',
                StyleSheet = [[QLabel{color:#10B981;font-size:11px;font-weight:bold;padding:5px;}]],
            },
            ui:HGap(0, 1),
            ui:Label{
                ID = 'lblPath',
                Text = '📁 /Users/praveen/Downloads/SocialDownloader/',
                StyleSheet = [[QLabel{color:#666;font-size:10px;padding:5px;}]],
            },
        },
    },
})

win.StyleSheet = [[QWidget#SocialDownloader{background-color:#0f0f1a;}]]

local itm = win:GetItems()

-- ============================================================================
-- POPULATE COMBO BOXES
-- ============================================================================

-- Platforms
for _, p in ipairs(platforms) do
    itm.cmbPlatform:AddItem(p.name)
end
itm.cmbPlatform.CurrentIndex = 0

-- Quality
itm.cmbQuality:AddItem('🏆 Max Best')
itm.cmbQuality:AddItem('📺 4K (2160p)')
itm.cmbQuality:AddItem('🎬 1080p')
itm.cmbQuality:AddItem('📱 720p')
itm.cmbQuality.CurrentIndex = 0

-- Languages
itm.cmbLang:AddItem('🌐 Both (EN+HI)')
itm.cmbLang:AddItem('🇬🇧 English')
itm.cmbLang:AddItem('🇮🇳 Hindi')
itm.cmbLang.CurrentIndex = 0

-- ============================================================================
-- LOGGING & STATUS
-- ============================================================================

local function log(msg)
    local ts = os.date('[%H:%M:%S] ')
    itm.logArea.PlainText = (itm.logArea.PlainText or '') .. ts .. tostring(msg) .. '\n'
    itm.logArea:MoveCursor('End', 'MoveAnchor')
    print(msg)
end

local function setStatus(msg, isError)
    if isError then
        itm.status.Text = '❌ ' .. msg
        itm.status.StyleSheet = [[QLabel{color:#EF4444;font-size:11px;font-weight:bold;padding:5px;}]]
    else
        itm.status.Text = '✅ ' .. msg
        itm.status.StyleSheet = [[QLabel{color:#10B981;font-size:11px;font-weight:bold;padding:5px;}]]
    end
end

local function setWorking(msg)
    itm.status.Text = '⏳ ' .. msg
    itm.status.StyleSheet = [[QLabel{color:#FBBF24;font-size:11px;font-weight:bold;padding:5px;}]]
end

-- ============================================================================
-- INITIALIZE
-- ============================================================================

local function init()
    log('═══════════════════════════════════════════════════════════════')
    log('  📥 Social Downloader v5.1 (FIXED)')
    log('  💻 Developed by Praveen Singh')
    log('═══════════════════════════════════════════════════════════════')
    log('')
    log('  🔧 FIXES in v5.1:')
    log('  ✅ Video+Audio merge for Instagram/Pinterest')
    log('  ✅ MP4 output for DaVinci Resolve compatibility')
    log('  ✅ YouTube WebM → MP4 conversion')
    log('')
    
    -- Create folders
    createDirectory(config.basePath)
    for _, p in ipairs(platforms) do
        if p.folder ~= "Other" then
            createDirectory(config.basePath .. p.folder)
            createDirectory(config.basePath .. p.folder .. "/thumbnails")
        end
    end
    createDirectory(config.basePath .. "Other")
    createDirectory(config.basePath .. "Other/thumbnails")
    
    log('📁 Folders created: ' .. config.basePath)
    
    config.ytdlpPath = findExecutable('yt-dlp')
    config.ffmpegPath = findExecutable('ffmpeg')
    
    -- Get ffmpeg directory for yt-dlp
    if config.ffmpegPath then
        config.ffmpegDir = config.ffmpegPath:match("(.*/)")
    end
    
    if config.ytdlpPath then 
        log('✅ yt-dlp: ' .. config.ytdlpPath)
    else 
        log('❌ yt-dlp NOT FOUND! Run: brew install yt-dlp')
    end
    
    if config.ffmpegPath then 
        log('✅ ffmpeg: ' .. config.ffmpegPath)
    else 
        log('⚠️ ffmpeg not found. Run: brew install ffmpeg')
        log('   ⚠️ Without ffmpeg, video+audio cannot be merged!')
    end
    
    loadHistory()
    log('')
    log('🎯 Paste URL → Click GET INFO → Click DOWNLOAD')
    log('')
    
    setStatus('Ready')
end

-- ============================================================================
-- HISTORY WINDOW
-- ============================================================================

local function showHistoryWindow()
    local histWin = disp:AddWindow({
        ID = 'HistoryWin',
        WindowTitle = '📜 Download History',
        Geometry = {150, 100, 800, 500},
        Spacing = 10,
        Margin = 15,
        
        ui:VGroup{
            ui:HGroup{
                Weight = 0,
                MinimumSize = {0, 40},
                
                ui:Label{
                    Text = '📜 Download History',
                    StyleSheet = [[QLabel{color:#A855F7;font-size:20px;font-weight:bold;}]],
                },
                ui:HGap(0, 1),
                ui:Button{
                    ID = 'btnClearHistory',
                    Text = '🗑️ Clear All',
                    MinimumSize = {100, 32},
                    StyleSheet = [[QPushButton{background:#EF4444;border:none;border-radius:6px;color:#fff;font-weight:bold;padding:8px 15px;}
                    QPushButton:hover{background:#DC2626;}]],
                },
            },
            
            ui:Tree{
                ID = 'historyTree',
                MinimumSize = {0, 350},
                StyleSheet = [[QTreeWidget{
                    background:#1a1a2e;
                    border:1px solid #333;
                    border-radius:8px;
                    color:#fff;
                    font-size:11px;
                }
                QTreeWidget::item{padding:8px;}
                QTreeWidget::item:selected{background:#A855F7;}
                QHeaderView::section{background:#252536;color:#fff;padding:8px;border:none;}]],
            },
            
            ui:HGroup{
                Weight = 0,
                MinimumSize = {0, 40},
                
                ui:Label{
                    ID = 'lblHistoryCount',
                    Text = 'Total: 0 downloads',
                    StyleSheet = [[QLabel{color:#888;font-size:11px;}]],
                },
                ui:HGap(0, 1),
                ui:Button{
                    ID = 'btnOpenFolder',
                    Text = '📂 Open Folder',
                    MinimumSize = {120, 32},
                    StyleSheet = [[QPushButton{background:#10B981;border:none;border-radius:6px;color:#fff;font-weight:bold;padding:8px 15px;}
                    QPushButton:hover{background:#059669;}]],
                },
                ui:Button{
                    ID = 'btnCloseHistory',
                    Text = '❌ Close',
                    MinimumSize = {100, 32},
                    StyleSheet = [[QPushButton{background:#555;border:none;border-radius:6px;color:#fff;font-weight:bold;padding:8px 15px;}
                    QPushButton:hover{background:#666;}]],
                },
            },
        },
    })
    
    histWin.StyleSheet = [[QWidget#HistoryWin{background-color:#0f0f1a;}]]
    
    local histItm = histWin:GetItems()
    
    local tree = histItm.historyTree
    tree:SetHeaderLabels({'#', 'Title', 'Platform', 'Date', 'Status'})
    tree:SetColumnWidth(0, 40)
    tree:SetColumnWidth(1, 350)
    tree:SetColumnWidth(2, 120)
    tree:SetColumnWidth(3, 150)
    tree:SetColumnWidth(4, 80)
    
    for i, h in ipairs(downloadHistory) do
        local item = tree:NewItem()
        item.Text[0] = tostring(i)
        item.Text[1] = h.title or 'Unknown'
        item.Text[2] = h.platform or 'Unknown'
        item.Text[3] = h.date or ''
        item.Text[4] = h.status or '✅'
        tree:AddTopLevelItem(item)
    end
    
    histItm.lblHistoryCount.Text = 'Total: ' .. #downloadHistory .. ' downloads'
    
    function histWin.On.btnCloseHistory.Clicked(ev)
        disp:ExitLoop()
    end
    
    function histWin.On.btnClearHistory.Clicked(ev)
        downloadHistory = {}
        saveHistory()
        tree:Clear()
        histItm.lblHistoryCount.Text = 'Total: 0 downloads'
    end
    
    function histWin.On.btnOpenFolder.Clicked(ev)
        os.execute('open "' .. config.basePath .. '"')
    end
    
    function histWin.On.HistoryWin.Close(ev)
        disp:ExitLoop()
    end
    
    histWin:Show()
    disp:RunLoop()
    histWin:Hide()
end

-- ============================================================================
-- IMPORT DIALOG
-- ============================================================================

local function showImportDialog(filename, platform)
    local dlg = disp:AddWindow({
        ID = 'ImportDlg',
        WindowTitle = '📥 Import to Media Pool',
        Geometry = {300, 200, 500, 280},
        Spacing = 0,
        Margin = 0,
        
        ui:VGroup{
            Spacing = 12,
            Margin = 25,
            
            ui:Label{
                Text = '✅ Download Complete!',
                Alignment = {AlignHCenter = true},
                MinimumSize = {450, 45},
                StyleSheet = [[QLabel{color:#10B981;font-size:22px;font-weight:bold;padding:10px;}]],
            },
            
            ui:Label{
                ID = 'dlgFile',
                Text = '📁 ' .. (filename or 'video.mp4'),
                Alignment = {AlignHCenter = true},
                MinimumSize = {450, 30},
                StyleSheet = [[QLabel{color:#00D9FF;font-size:13px;padding:5px;}]],
            },
            
            ui:Label{
                ID = 'dlgPlatform',
                Text = '📱 Platform: ' .. (platform or 'Unknown'),
                Alignment = {AlignHCenter = true},
                MinimumSize = {450, 25},
                StyleSheet = [[QLabel{color:#FF6B35;font-size:12px;padding:5px;}]],
            },
            
            ui:Label{
                Text = 'Do you want to import to DaVinci Resolve?',
                Alignment = {AlignHCenter = true},
                MinimumSize = {450, 30},
                StyleSheet = [[QLabel{color:#FFFFFF;font-size:14px;padding:10px;}]],
            },
            
            ui:HGroup{
                Weight = 0,
                MinimumSize = {450, 55},
                Spacing = 20,
                
                ui:HGap(0, 0.3),
                
                ui:Button{
                    ID = 'btnImportYes',
                    Text = '✅ YES - Import',
                    MinimumSize = {160, 50},
                    StyleSheet = [[QPushButton{
                        background:#10B981;
                        border:none;
                        border-radius:10px;
                        color:#fff;
                        font-size:15px;
                        font-weight:bold;
                        padding:12px 25px;
                    }
                    QPushButton:hover{background:#059669;}]],
                },
                
                ui:Button{
                    ID = 'btnImportNo',
                    Text = '❌ NO - Skip',
                    MinimumSize = {160, 50},
                    StyleSheet = [[QPushButton{
                        background:#EF4444;
                        border:none;
                        border-radius:10px;
                        color:#fff;
                        font-size:15px;
                        font-weight:bold;
                        padding:12px 25px;
                    }
                    QPushButton:hover{background:#DC2626;}]],
                },
                
                ui:HGap(0, 0.3),
            },
            
            ui:CheckBox{
                ID = 'chkRemember',
                Text = "  Don't ask again (remember my choice)",
                Checked = false,
                MinimumSize = {450, 30},
                StyleSheet = [[QCheckBox{color:#888;font-size:11px;}
                QCheckBox::indicator{width:16px;height:16px;border-radius:4px;border:2px solid #666;}
                QCheckBox::indicator:checked{background:#A855F7;border-color:#A855F7;}]],
            },
        },
    })
    
    dlg.StyleSheet = [[QWidget#ImportDlg{background-color:#1E1E2E;border:2px solid #10B981;border-radius:15px;}]]
    
    local result = false
    local remember = false
    local dlgItm = dlg:GetItems()
    
    function dlg.On.btnImportYes.Clicked(ev)
        result = true
        remember = dlgItm.chkRemember.Checked
        disp:ExitLoop()
    end
    
    function dlg.On.btnImportNo.Clicked(ev)
        result = false
        remember = dlgItm.chkRemember.Checked
        disp:ExitLoop()
    end
    
    function dlg.On.ImportDlg.Close(ev)
        result = false
        disp:ExitLoop()
    end
    
    dlg:Show()
    disp:RunLoop()
    dlg:Hide()
    
    return result, remember
end

-- ============================================================================
-- IMPORT TO RESOLVE
-- ============================================================================

local function importToResolve(file)
    local resolve = Resolve()
    if not resolve then return false end
    
    local ms = resolve:GetMediaStorage()
    if ms then
        local r = ms:AddItemListToMediaPool(file)
        if r and #r > 0 then return true end
    end
    
    local pm = resolve:GetProjectManager()
    if pm then
        local proj = pm:GetCurrentProject()
        if proj then
            local mp = proj:GetMediaPool()
            if mp then
                local r = mp:ImportMedia({file})
                if r and #r > 0 then return true end
            end
        end
    end
    return false
end

-- ============================================================================
-- GET FORMAT STRING - FIXED FOR EACH PLATFORM
-- ============================================================================

local function getFormatString(platform, qualityIdx)
    -- Platform-specific format strings that ensure video+audio together
    
    if platform == "youtube" then
        -- YouTube: prefer mp4, merge if needed, recode webm to mp4
        if qualityIdx == 0 then -- Best
            return 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best'
        elseif qualityIdx == 1 then -- 4K
            return 'bestvideo[height<=2160][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=2160]+bestaudio/best[height<=2160]'
        elseif qualityIdx == 2 then -- 1080p
            return 'bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=1080]+bestaudio/best[height<=1080]'
        else -- 720p
            return 'bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=720]+bestaudio/best[height<=720]'
        end
        
    elseif platform == "instagram" then
        -- Instagram: DASH streams need proper merging
        -- Use best combined format first, then try merging
        return 'best[ext=mp4]/bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best'
        
    elseif platform == "pinterest" then
        -- Pinterest: prefer combined formats
        return 'best[ext=mp4]/bestvideo+bestaudio/best'
        
    elseif platform == "tiktok" then
        -- TikTok: usually has combined formats
        return 'best[ext=mp4]/best'
        
    elseif platform == "twitter" then
        -- Twitter/X: prefer mp4
        return 'best[ext=mp4]/bestvideo+bestaudio/best'
        
    elseif platform == "facebook" then
        -- Facebook
        if qualityIdx == 0 then
            return 'best[ext=mp4]/bestvideo+bestaudio/best'
        else
            return 'best[height<=1080][ext=mp4]/bestvideo[height<=1080]+bestaudio/best[height<=1080]'
        end
        
    elseif platform == "vimeo" then
        -- Vimeo: prefer mp4
        if qualityIdx == 0 then
            return 'bestvideo[ext=mp4]+bestaudio/best[ext=mp4]/bestvideo+bestaudio/best'
        elseif qualityIdx == 1 then
            return 'bestvideo[height<=2160][ext=mp4]+bestaudio/best[height<=2160]'
        elseif qualityIdx == 2 then
            return 'bestvideo[height<=1080][ext=mp4]+bestaudio/best[height<=1080]'
        else
            return 'bestvideo[height<=720][ext=mp4]+bestaudio/best[height<=720]'
        end
        
    elseif platform == "reddit" then
        -- Reddit: needs merging often
        return 'bestvideo+bestaudio/best'
        
    else
        -- Auto/Other: general best approach
        return 'best[ext=mp4]/bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best'
    end
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

function win.On.btnClear.Clicked(ev)
    itm.logArea.PlainText = ''
end

function win.On.btnSetup.Clicked(ev)
    log('')
    log('⚙️ CHECKING SETUP...')
    
    config.ytdlpPath = findExecutable('yt-dlp')
    config.ffmpegPath = findExecutable('ffmpeg')
    
    if config.ffmpegPath then
        config.ffmpegDir = config.ffmpegPath:match("(.*/)")
    end
    
    if config.ytdlpPath then
        local h = io.popen(config.ytdlpPath .. ' --version 2>/dev/null')
        local v = h and h:read('*l') or 'unknown'
        if h then h:close() end
        log('✅ yt-dlp: v' .. v)
    else
        log('❌ yt-dlp: NOT FOUND')
        log('   Install: brew install yt-dlp')
    end
    
    if config.ffmpegPath then 
        log('✅ ffmpeg: ' .. config.ffmpegPath)
        log('   (Required for merging video+audio)')
    else 
        log('❌ ffmpeg: NOT FOUND')
        log('   Install: brew install ffmpeg')
        log('   ⚠️ Without ffmpeg, downloads may fail!')
    end
    
    local resolve = Resolve()
    if resolve then
        log('✅ DaVinci Resolve: Connected')
        local pm = resolve:GetProjectManager()
        if pm then
            local proj = pm:GetCurrentProject()
            if proj then log('   Project: ' .. proj:GetName()) end
        end
    else
        log('⚠️ DaVinci Resolve: Not connected')
    end
    
    log('')
end

function win.On.btnHistory.Clicked(ev)
    showHistoryWindow()
end

function win.On.chkAudio.Clicked(ev)
    if itm.chkAudio.Checked then
        itm.chkVideo.Checked = false
        itm.cmbQuality.Enabled = false
    else
        itm.cmbQuality.Enabled = true
    end
end

function win.On.chkVideo.Clicked(ev)
    if itm.chkVideo.Checked then
        itm.chkAudio.Checked = false
        itm.cmbQuality.Enabled = true
    end
end

function win.On.urlInput.TextChanged(ev)
    local url = itm.urlInput.Text
    if url and url ~= '' then
        local detected = detectPlatform(url)
        itm.cmbPlatform.CurrentIndex = getPlatformIndex(detected)
    end
end

function win.On.btnGetInfo.Clicked(ev)
    local url = itm.urlInput.Text
    
    if not url or url == '' then
        log('❌ Please enter a URL')
        setStatus('Enter URL', true)
        return
    end
    
    if not config.ytdlpPath then
        log('❌ yt-dlp not found!')
        setStatus('Install yt-dlp', true)
        return
    end
    
    setWorking('Fetching info...')
    
    local detected = detectPlatform(url)
    local platformInfo = getPlatformInfo(detected)
    
    log('')
    log('🔍 Fetching from ' .. platformInfo.name .. '...')
    log('   URL: ' .. url)
    
    local cmd = config.ytdlpPath .. ' --dump-single-json --no-download --no-warnings "' .. url .. '" 2>/dev/null'
    local h = io.popen(cmd)
    if not h then
        log('❌ Failed to run yt-dlp')
        setStatus('Error', true)
        return
    end
    
    local json = h:read('*a')
    h:close()
    
    if not json or json == '' then
        log('❌ Could not fetch info - Check URL')
        setStatus('Invalid URL', true)
        return
    end
    
    local title = json:match('"title"%s*:%s*"([^"]*)"') or 'Unknown'
    local duration = json:match('"duration"%s*:%s*([%d%.]+)') or ''
    local channel = json:match('"channel"%s*:%s*"([^"]*)"') or json:match('"uploader"%s*:%s*"([^"]*)"') or 'Unknown'
    local thumbnail = json:match('"thumbnail"%s*:%s*"([^"]*)"') or ''
    
    title = title:gsub('\\u0026', '&'):gsub('\\/', '/'):gsub('\\"', '"')
    
    videoInfo.title = title
    videoInfo.duration = duration
    videoInfo.channel = channel
    videoInfo.platform = detected
    videoInfo.thumbnail = thumbnail
    videoInfo.url = url
    
    -- Update UI
    local shortTitle = #title > 60 and title:sub(1, 57) .. '...' or title
    itm.infoTitle.Text = shortTitle
    itm.infoDuration.Text = formatDuration(duration)
    itm.infoChannel.Text = channel
    itm.infoPlatform.Text = platformInfo.name
    itm.infoQuality.Text = 'Best available'
    
    itm.lblThumbnail.Text = '🖼️ ' .. shortTitle .. '\n\n⏱️ ' .. formatDuration(duration) .. ' | 👤 ' .. channel
    
    itm.cmbPlatform.CurrentIndex = getPlatformIndex(detected)
    
    log('✅ Video found!')
    log('   📺 ' .. title)
    log('   ⏱️ ' .. formatDuration(duration) .. ' | 👤 ' .. channel)
    log('')
    
    setStatus('Ready to download')
end

function win.On.btnDownload.Clicked(ev)
    local url = itm.urlInput.Text
    
    if not url or url == '' then
        log('❌ Enter URL first')
        setStatus('No URL', true)
        return
    end
    
    if not config.ytdlpPath then
        log('❌ yt-dlp not found')
        setStatus('Install yt-dlp', true)
        return
    end
    
    -- Check ffmpeg
    if not config.ffmpegPath then
        log('⚠️ WARNING: ffmpeg not found - video+audio may not merge!')
    end
    
    local platformIdx = itm.cmbPlatform.CurrentIndex + 1
    local platformInfo = platforms[platformIdx] or platforms[1]
    local detected = detectPlatform(url)
    if platformIdx == 1 then -- Auto-detect
        platformInfo = getPlatformInfo(detected)
        detected = platformInfo.id
    else
        detected = platformInfo.id
    end
    
    local downloadFolder = config.basePath .. platformInfo.folder .. "/"
    
    log('')
    log('═══════════════════════════════════════════════════════════════')
    log('  ⬇️ STARTING DOWNLOAD')
    log('═══════════════════════════════════════════════════════════════')
    log('  📱 Platform: ' .. platformInfo.name)
    log('  📁 Folder: ' .. downloadFolder)
    
    -- Build command
    local cmd = config.ytdlpPath
    
    -- Output template - clean filename without format ID
    cmd = cmd .. ' -o "' .. downloadFolder .. '%(title)s.%(ext)s"'
    
    -- CRITICAL: Set ffmpeg location for merging
    if config.ffmpegDir then
        cmd = cmd .. ' --ffmpeg-location "' .. config.ffmpegDir .. '"'
        log('  🔧 Using ffmpeg: ' .. config.ffmpegDir)
    end
    
    -- Quality & Format
    local q = itm.cmbQuality.CurrentIndex
    
    if itm.chkAudio.Checked then
        log('  🎵 Mode: Audio Only (WAV)')
        cmd = cmd .. ' -x --audio-format wav --audio-quality 0'
    else
        -- Get platform-specific format string
        local formatStr = getFormatString(detected, q)
        
        if q == 0 then
            log('  📺 Quality: Max Best')
        elseif q == 1 then
            log('  📺 Quality: 4K')
        elseif q == 2 then
            log('  📺 Quality: 1080p')
        else
            log('  📺 Quality: 720p')
        end
        
        cmd = cmd .. ' -f "' .. formatStr .. '"'
        
        -- Force MP4 output for DaVinci Resolve compatibility
        cmd = cmd .. ' --merge-output-format mp4'
        
        -- For YouTube/Vimeo, recode webm to mp4 if needed
        if detected == "youtube" or detected == "vimeo" then
            cmd = cmd .. ' --recode-video mp4'
            log('  🔄 Recoding to MP4 if needed')
        end
        
        -- Post-processor for proper merging
        cmd = cmd .. ' --embed-metadata'
    end
    
    -- Subtitles
    if itm.chkSubs.Checked then
        log('  📝 Subtitles: ON')
        cmd = cmd .. ' --write-subs --write-auto-subs --convert-subs srt'
        local lang = itm.cmbLang.CurrentIndex
        if lang == 0 then cmd = cmd .. ' --sub-langs "en.*,hi.*"'
        elseif lang == 1 then cmd = cmd .. ' --sub-langs "en.*"'
        else cmd = cmd .. ' --sub-langs "hi.*"' end
    end
    
    -- Thumbnail
    if itm.chkThumbnail.Checked then
        log('  🖼️ Thumbnail: ON')
        cmd = cmd .. ' --write-thumbnail --convert-thumbnails jpg'
    end
    
    -- Playlist
    if not itm.chkPlaylist.Checked then
        cmd = cmd .. ' --no-playlist'
    end
    
    -- Additional options for reliability
    cmd = cmd .. ' --no-warnings'
    cmd = cmd .. ' --no-mtime'  -- Don't set file modification time
    
    cmd = cmd .. ' "' .. url .. '"'
    
    log('')
    log('🚀 Downloading...')
    log('   (This may take a moment for merging/conversion)')
    setWorking('Downloading...')
    
    itm.btnDownload.Enabled = false
    itm.btnDownload.Text = '⏳ Downloading...'
    
    local tmpErr = '/tmp/social_dl_' .. os.time() .. '.txt'
    local tmpOut = '/tmp/social_dl_out_' .. os.time() .. '.txt'
    local ok = os.execute(cmd .. ' >"' .. tmpOut .. '" 2>"' .. tmpErr .. '"')
    
    local errH = io.open(tmpErr, 'r')
    local errMsg = errH and errH:read('*a') or ''
    if errH then errH:close() os.remove(tmpErr) end
    
    local outH = io.open(tmpOut, 'r')
    local outMsg = outH and outH:read('*a') or ''
    if outH then outH:close() os.remove(tmpOut) end
    
    itm.btnDownload.Enabled = true
    itm.btnDownload.Text = '⬇️  DOWNLOAD NOW'
    
    local success = (type(ok) == 'boolean' and ok) or (type(ok) == 'number' and ok == 0) or (ok ~= nil)
    
    if success then
        log('')
        log('✅ Download Complete!')
        setStatus('Complete!')
        
        -- Find downloaded file - look for mp4 first, then other formats
        local file = nil
        local extensions = {'mp4', 'mkv', 'webm', 'wav', 'mp3'}
        
        for _, ext in ipairs(extensions) do
            local lsCmd = 'ls -t "' .. downloadFolder .. '"*.' .. ext .. ' 2>/dev/null | head -1'
            local lsH = io.popen(lsCmd)
            local found = lsH and lsH:read('*l')
            if lsH then lsH:close() end
            if found and found ~= '' then
                file = found
                break
            end
        end
        
        if file and file ~= '' then
            local filename = file:match("([^/]+)$") or file
            log('📁 ' .. filename)
            
            -- Verify it's a proper video file (not audio-only)
            if not itm.chkAudio.Checked then
                local probeCmd = config.ffmpegPath and (config.ffmpegPath:gsub('ffmpeg$', 'ffprobe') .. ' -v error -select_streams v -show_entries stream=codec_type -of csv=p=0 "' .. file .. '" 2>/dev/null') or nil
                if probeCmd then
                    local probeH = io.popen(probeCmd)
                    local hasVideo = probeH and probeH:read('*a') or ''
                    if probeH then probeH:close() end
                    if hasVideo:match('video') then
                        log('✅ Video track verified')
                    else
                        log('⚠️ Warning: No video track detected')
                    end
                end
            end
            
            -- Add to history
            table.insert(downloadHistory, 1, {
                title = videoInfo.title ~= '' and videoInfo.title or filename,
                platform = platformInfo.name,
                date = os.date('%Y-%m-%d %H:%M'),
                file = file,
                status = '✅'
            })
            if #downloadHistory > 50 then table.remove(downloadHistory) end
            saveHistory()
            
            -- Import handling
            local autoImport = itm.chkAutoImport.Checked
            
            if config.rememberImport then
                if config.autoImport then
                    log('📥 Auto-importing...')
                    if importToResolve(file) then
                        log('✅ Imported to Media Pool!')
                        setStatus('Imported!')
                    else
                        log('⚠️ Import failed - file may not be compatible')
                        setStatus('Import failed')
                    end
                else
                    log('ℹ️ Import skipped (remembered)')
                end
            elseif autoImport then
                local shouldImport, remember = showImportDialog(filename, platformInfo.name)
                
                if remember then
                    config.rememberImport = true
                    config.autoImport = shouldImport
                end
                
                if shouldImport then
                    log('📥 Importing to Media Pool...')
                    if importToResolve(file) then
                        log('✅ Imported successfully!')
                        setStatus('Imported!')
                    else
                        log('⚠️ Import failed - try opening file manually')
                        setStatus('Import failed')
                    end
                else
                    log('ℹ️ Import skipped')
                    setStatus('Download complete')
                end
            else
                log('ℹ️ Auto-import disabled')
                setStatus('Download complete')
            end
        else
            log('⚠️ Could not locate downloaded file')
            log('   Check folder: ' .. downloadFolder)
        end
    else
        log('')
        log('❌ Download Failed!')
        if errMsg ~= '' then 
            log('Error details:')
            for line in errMsg:gmatch('[^\n]+') do
                log('   ' .. line:sub(1, 100))
            end
        end
        log('')
        log('💡 Troubleshooting:')
        log('   1. Run: brew upgrade yt-dlp')
        log('   2. Ensure ffmpeg is installed: brew install ffmpeg')
        log('   3. Check if the URL is valid and accessible')
        setStatus('Failed', true)
    end
    log('')
end

function win.On.SocialDownloader.Close(ev)
    saveHistory()
    disp:ExitLoop()
end

-- ============================================================================
-- RUN
-- ============================================================================

init()
win:Show()
disp:RunLoop()
win:Hide()