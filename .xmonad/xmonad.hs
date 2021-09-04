    -- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

    -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
-- import XMonad.Util.Spotify

    -- Variables
myFont :: String
myFont = "xft:Mononoki:size=12:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask                    -- Set to Windows key

myTerminal :: String
myTerminal = "alacritty"                -- Set terminal to Alacritty

myBrowser :: String
myBrowser = "firefox"                   -- Set browser to Firefox

myBorderWidth :: Dimension
myBorderWidth = 2                       -- Sets width of window border

myNormColor :: String
myNormColor = "#232a38"                 -- Border colour for unfocused window

myFocusColor :: String
myFocusColor = "#247ec7"                -- Border colour for focused window

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

    -- Startup Hook
myStartupHook :: X ()
myStartupHook = do
    --spawnOnce "lxappearance &"
    spawnOnce "nitrogen --restore &"
    spawnOnce "picom &"
    --spawnOnce "nm-applet &"
    --spawnOnce "volumeicon &"
    --spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 0 --transparent true --alpha 0 --tint 0x10100E --height 24 &"
    setWMName "LG3D"

    -- Scratchpad
myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm ]

  where
    classTerm     = "terminal-dropdown"
    titleTerm     = "dropdown"
    spawnTerm     = myTerminal ++ " -t " ++ titleTerm
    findTerm      = title =? titleTerm
    manageTerm    = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w

    -- Layouts
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

tall =
  renamed [Replace "tall"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 12 $
              mySpacing 8 $
                ResizableTall 1 (3 / 100) (1 / 2) []

floats =
  renamed [Replace "floats"] $
    limitWindows 20 simplestFloat

grid =
  renamed [Replace "grid"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          limitWindows 12 $
            mySpacing 8 $
              mkToggle (single MIRROR) $
                Grid (16 / 10)

spirals =
  renamed [Replace "spirals"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          mySpacing 8 $
            spiral (6 / 7)

threeCol =
  renamed [Replace "threeCol"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 7 $
              ThreeCol 1 (3 / 100) (1 / 2)

threeRow =
  renamed [Replace "threeRow"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 7
            -- Mirror takes a layout and rotates it by 90 degrees.
            -- So we are applying Mirror to the ThreeCol layout.
            $
              Mirror $
                ThreeCol 1 (3 / 100) (1 / 2)

myTabTheme =
  def
    { fontName = myFont,
      activeColor = "#46d9ff",
      inactiveColor = "#313846",
      activeBorderColor = "#232a38",
      inactiveBorderColor = "#247ec7",
      activeTextColor = "#282c34",
      inactiveTextColor = "#d0d0d0"
    }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme =
  def
    { swn_font = "xft:Mononoki:bold:size=32",
      swn_fade = 1.0,
      swn_bgcolor = "#1c1f24",
      swn_color = "#ffffff"
    }

-- Log hook
myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
  where
    fadeAmount = 1.0

-- The layout hook
myLayoutHook =
  avoidStruts $
    mouseResize $
      windowArrange $
        T.toggleLayouts floats $
          mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout =
      withBorder myBorderWidth tall
        ||| floats
        ||| grid
        ||| spirals
        ||| threeCol
        ||| threeRow


    -- Workspaces
myWorkspaces =
  [ "<fn=2>\xf015</fn>"           -- home
  , "<fn=2>\xf0ac</fn>"           -- web
  , "<fn=2>\xf121 \xf0d8</fn>"    -- coding 1
  , "<fn=2>\xf121 \xf0d7</fn>"    -- coding 2
  , "<fn=2>\xf121 \xf0d9</fn>"    -- coding 3
  , "<fn=2>\xf121 \xf0da</fn>"    -- coding 4
  , "<fn=2>\xf108</fn>"           -- system
  , "<fn=2>\xf001</fn>"           -- music
  , "<fn=2>\xf1b3</fn>"           -- anything else / dump
  ]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1 ..] -- (,) == \x y -> (x,y)

    -- Manage hook
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
  [ className =? "confirm"         --> doFloat
  , className =? "file_progress"   --> doFloat
  , className =? "dialog"          --> doFloat
  , className =? "download"        --> doFloat
  , className =? "error"           --> doFloat
  , className =? "Gimp"            --> doFloat
  , className =? "notification"    --> doFloat
  , className =? "pinentry-gtk-2"  --> doFloat
  , className =? "splash"          --> doFloat
  , className =? "toolbar"         --> doFloat
  , className =? "Yad"             --> doCenterFloat
  --, title =? "dropdown"                      --> doFloat
  , title =? "Oracle VM VirtualBox Manager"  --> doFloat
  , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
  , isFullscreen -->  doFullFloat
  ] <+> namedScratchpadManageHook myScratchPads

    -- Keybinds
myKeys :: [(String, X ())]
myKeys =

    -- XMonad bindings
  [ ("M-C-r", spawn "xmonad --recompile; killall xmobar")
  , ("M-S-r", spawn "xmonad --restart; xmobar $HOME/.config/xmobar/xmobar.hs")
  , ("M-S-q", spawn "xmonad --recompile; killall xmobar; xmonad --restart; xmobar $HOME/.config/xmobar/xmobar.hs")

    -- Screen locking
  , ("M-S-l", spawn "slock")

    -- dmenu
  , ("M-p", spawn "dmenu_run -p Run:")

    -- Useful
  , ("M-<Return>", spawn myTerminal)
  , ("M-b", spawn myBrowser)
  , ("M-C-S-p", spawn "scrot")

    -- Kill
  , ("M-S-c", kill1)
  , ("M-S-a", killAll)

    -- Window Navigation
  , ("M-m", windows W.focusMaster)  -- Move focus to the master window
  , ("M-j", windows W.focusDown)    -- Move focus to the next window
  , ("M-k", windows W.focusUp)      -- Move focus to the prev window
  , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
  , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
  , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
  , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
  , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
  , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

    -- Window Layouts
  , ("M-<Tab>", sendMessage NextLayout)
  , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)

    -- Floating Windows
  , ("M-f", sendMessage (T.Toggle "floats"))
  , ("M-t", withFocused $ windows . W.sink)

    -- Scratchpads
  , ("M-S-s", namedScratchpadAction myScratchPads "terminal")

    -- Multimedia Keys
  -- , ("<XF86AudioPlay>", audioPlayPause)
  -- , ("<XF86AudioPrev>", audioPrev)
  -- , ("<XF86AudioNext>", audioNext)
  , ("M-S-\\", spawn "amixer set Master toggle")
  , ("M-S-[", spawn "amixer set Master 5%- unmute")
  , ("M-S-]", spawn "amixer set Master 5%+ unmute")

  ]

    where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
          nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

    -- End Keybinds

    -- Main
main :: IO ()
main = do
  xmproc <- spawnPipe "xmobar $HOME/.config/xmobar/xmobar.hs"
  xmonad $ ewmh def
    { manageHook          = myManageHook <+> manageDocks
    , handleEventHook     = docksEventHook
    , modMask             = myModMask
    , terminal            = myTerminal
    , startupHook         = myStartupHook
    , layoutHook          = myLayoutHook
    , workspaces          = myWorkspaces
    , borderWidth         = myBorderWidth
    , normalBorderColor   = myNormColor
    , focusedBorderColor  = myFocusColor
    , logHook = workspaceHistoryHook <+> myLogHook <+> dynamicLogWithPP xmobarPP
      { ppOutput = hPutStrLn xmproc
      , ppCurrent = xmobarColor "#93bf67" "" . wrap "[" "]"   -- Current workspace in xmobar
      --, ppVisible = xmobarColor "#cb4b16" ""                -- Visible but not current workspace
      , ppHidden = xmobarColor "#678abf" "" . wrap "*" ""     -- Hidden workspaces in xmobar
      , ppHiddenNoWindows = xmobarColor "#9472ad" ""          -- Hidden workspaces (no windows) #cf5757
      , ppTitle = xmobarColor "#84a0c6" "" . shorten 60       -- Title of active window in xmobar
      , ppSep =  " <fc=#666666>|</fc> "                       -- Separators in xmobar
      , ppUrgent = xmobarColor "#dc322f" "" . wrap "!" "!"    -- Urgent workspace
      , ppExtras  = [windowCount]                             -- # of windows current workspace
      , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
      }
    } `additionalKeysP` myKeys
