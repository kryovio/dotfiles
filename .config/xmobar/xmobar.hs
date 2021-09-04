Config { font    = "xft:Mononoki:weight=bold:pixelsize=12:antialias=true:hinting=true"
       , additionalFonts = [ "xft:Mononoki Nerd Font:pixelsize=12:antialias=true:hinting=true"
                           , "xft:Font Awesome 5 Free Solid:pixelsize=12"
                           , "xft:Font Awesome 5 Brands:pixelsize=12"
                           ]
       , bgColor = "#10100E"
       , fgColor = "#C6C6C4"
       , position = Static { xpos = 0 , ypos = 0, width = 1920, height = 24 }
       , lowerOnStart = True
       , hideOnStart = False
       , allDesktops = True
       , persistent = True
       , iconRoot = "/home/crispy/.xmonad/xpm/"  -- default: "."
       , commands = [
                    -- Time and date
                      Run Date "<fn=2>\xf017</fn> %H:%M <fn=2>\xf073</fn> %d %b %Y" "date" 50
                      -- Ethernet up and down
                    , Run Network "enp0s3" ["-t", "<fn=2>\xf6ff</fn> <dev> <fn=2>\xf0ab</fn> <rx>kb <fn=2>\xf0aa</fn> <tx>kb"] 20
                      -- Wireless %<[wirelessadaptername]wi>
                    --, Run Wireless "wlan0" ["-t", "<fn=2>\xf1eb</fn> <essid> <fn=2>\xf0ab</fn> <rx>kb <fn=2>\xf0aa</fn> <tx>kb"] 20
                      -- Cpu usage percent
                    , Run Cpu
                    [ "-t", "<fn=2>\xf2db</fn> (<total>%)"
                    , "-H", "50"
                    , "--high", "red"
                    ] 20
                      -- Ram used percent
                    , Run Memory ["-t", "<fn=2>\xf538</fn> (<usedratio>%)"] 20
                      -- Disk space free
                    , Run DiskU [("/", "<fn=2>\xf0c7</fn> <free> free")] [] 60
                      -- Runs a standard shell command 'uname -r' to get kernel version
                    , Run Com "uname" ["-r"] "" 3600
                      -- Volume
                    , Run Volume "default" "Master"
                    [ "-t", "<fn=2>\xf028</fn> <volume>% <status>"
                    , "-L", "0"
                    , "-l", "red"
                    ] 3
                    , Run Battery
                    [ "-t", "<fn=2>\xf240</fn> <acstatus> <left>%"
                    , "--"
                    , "-i", "charged"
                    , "-O", "charging"
                    , "-o", "<left>% (<timeleft>)"
                    , "-h", "green"
                    , "-l", "red"
                    ] 10
                    , Run StdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       --, template = " <icon=haskell_20.xpm/> <fc=#666666>|</fc> %StdinReader% }{ <fc=#41a7e0><fn=3></fn> %uname%</fc> <fc=#666666>|</fc> <fc=#ebcb8b>%cpu%</fc> <fc=#666666>|</fc> <fc=#bf616a>%memory%</fc> <fc=#666666>|</fc> <fc=#81a1c1>%disku%</fc> <fc=#666666>|</fc> <fc=#d08770>%enp0s3%</fc> <fc=#666666>|</fc> <fc=#a3be8c>%default:Master%</fc><fc=#666666>|</fc> <fc=#b48ead>%battery%</fc> <fc=#666666>|</fc> <fc=#d8dee9>%date%</fc> "
       , template = " <fc=#dea062>%cpu%</fc> <fc=#666666>|</fc> <fc=#de7462>%memory%</fc> <fc=#666666>|</fc> %StdinReader%}{ %enp0s3% <fc=#666666>|</fc> %default:Master%<fc=#666666>|</fc> %battery% <fc=#666666>|</fc> <fc=#678abf>%date%</fc> "
       }
