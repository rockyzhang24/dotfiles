#!/bin/bash

# sketchybar-app-font is required (https://github.com/kvndrsslr/sketchybar-app-font)
# Install it by `brew install font-sketchybar-app-font`
#
# All supported icons can be found here: https://github.com/kvndrsslr/sketchybar-app-font/tree/main/svgs

function icon_map() {
    case "$1" in
    "Activity Monitor")
        icon_result=":activity_monitor:"
        ;;
    "Acrobat")
        icon_result=":acrobat:"
        ;;
    "Adobe InDesign"* | "InDesign")
        icon_result=":indesign:"
        ;;
    "Adobe Illustrator"* | "Illustrator")
        icon_result=":illustrator:"
        ;;
    "Adobe Lightroom")
        icon_result=":lightroom:"
        ;;
    "Adobe Photoshop"*)
        icon_result=":photoshop:"
        ;;
    "Adobe Premiere" | "Premiere" | "Adobe Premiere Pro 2024")
        icon_result="premiere"
        ;;
    "Affinity Designer")
        icon_result=":affinity_designer:"
        ;;
    "Affinity Designer 2")
        icon_result=":affinity_designer_2:"
        ;;
    "Affinity Photo")
        icon_result=":affinity_photo:"
        ;;
    "Affinity Photo 2")
        icon_result=":affinity_photo_2:"
        ;;
    "Affinity Publisher")
        icon_result=":affinity_publisher:"
        ;;
    "Affinity Publisher 2")
        icon_result=":affinity_publisher_2:"
        ;;
    "Airmail")
        icon_result=":airmail:"
        ;;
    "AirPort Utility")
        icon_result=":airport_utility:"
        ;;
    "Alacritty")
        icon_result=":alacritty:"
        ;;
    "Alfred")
        icon_result=":alfred:"
        ;;
    "Android Messages")
        icon_result=":android_messages:"
        ;;
    "Android Studio")
        icon_result=":android_studio:"
        ;;
    "Anki")
        icon_result=":anki:"
        ;;
    "Anytype")
        icon_result=":anytype:"
        ;;
    "App Store")
        icon_result=":app_store:"
        ;;
    "Arc")
        icon_result=":arc:"
        ;;
    "Audacity")
        icon_result=":audacity:"
        ;;
    "Automator")
        icon_result="automator:"
        ;;
    "Bear")
        icon_result=":bear:"
        ;;
    "BetterTouchTool")
        icon_result=":bettertouchtool:"
        ;;
    "Bitwarden")
        icon_result=":bit_warden:"
        ;;
    "Blender")
        icon_result=":blender:"
        ;;
    "Books" | "Apple Books")
        icon_result=":apple_books:"
        ;;
    "Brave Browser")
        icon_result=":brave_browser:"
        ;;
    "BusyCal")
        icon_result=":busycal:"
        ;;
    "Calculator" | "Calculette" | "Rechner")
        icon_result=":calculator:"
        ;;
    "Calendar" | "Fantastical" | "Cron" | "Amie")
        icon_result=":calendar:"
        ;;
    "Calibre")
        icon_result=":book:"
        ;;
    "Caprine")
        icon_result=":caprine:"
        ;;
    "ChatGPT")
        icon_result=":openai:"
        ;;
    "Citrix Workspace" | "Citrix Viewer")
        icon_result=":citrix:"
        ;;
    "CleanMyMac X")
        icon_result=":desktop:"
        ;;
    "ClickUp")
        icon_result=":click_up:"
        ;;
    "Clock")
        icon_result=":clock:"
        ;;
    "coconutBattery")
        icon_result=":coconut_battery:"
        ;;
    "Code" | "Code - Insiders")
        icon_result=":code:"
        ;;
    "Color Picker")
        icon_result=":color_picker:"
        ;;
    "Cursor")
        icon_result=":cursor:"
        ;;
    "Cypress")
        icon_result=":cypress:"
        ;;
    "Default")
        icon_result=":default:"
        ;;
    "DEVONthink 3")
        icon_result=":devonthink3:"
        ;;
    "DingTalk")
        icon_result=":dingtalk:"
        ;;
    "Discord" | "Discord Canary" | "Discord PTB")
        icon_result=":discord:"
        ;;
    "Docker" | "Docker Desktop")
        icon_result=":docker:"
        ;;
    "Drafts")
        icon_result=":drafts:"
        ;;
    "draw.io")
        icon_result=":draw_io:"
        ;;
    "Dropbox")
        icon_result=":dropbox:"
        ;;
    "Element")
        icon_result=":element:"
        ;;
    "Emacs")
        icon_result=":emacs:"
        ;;
    "Evernote Legacy")
        icon_result=":evernote_legacy:"
        ;;
    "FaceTime")
        icon_result=":face_time:"
        ;;
    "Feishu")
        icon_result=":feishu:"
        ;;
    "Figma")
        icon_result=":figma:"
        ;;
    "Final Cut Pro")
        icon_result=":final_cut_pro:"
        ;;
    "Finder")
        icon_result=":finder:"
        ;;
    "Firefox")
        icon_result=":firefox:"
        ;;
    "Firefox Developer Edition" | "Firefox Nightly")
        icon_result=":firefox_developer_edition:"
        ;;
    "Folx")
        icon_result=":folx:"
        ;;
    "Fork")
        icon_result=":fork:"
        ;;
    "Games")
        icon_result=":games:"
        ;;
    "Gemini" | "Google Gemini")
        icon_result=":gemini:"
        ;;
    "Ghostty")
        icon_result=":ghostty:"
        ;;
    "GIMP")
        icon_result=":gimp:"
        ;;
    "GitHub Desktop")
        icon_result=":git_hub:"
        ;;
    "Godot")
        icon_result=":godot:"
        ;;
    "GoLand")
        icon_result=":goland:"
        ;;
    "Goodnotes")
        icon_result=":goodnotes:"
        ;;
    "Google Chat")
        icon_result=":google_chat:"
        ;;
    "Google Chrome" | "Chromium" | "Google Chrome Canary")
        icon_result=":google_chrome:"
        ;;
    "Google Meet")
        icon_result=":meet:"
        ;;
    "Grammarly Editor")
        icon_result=":grammarly:"
        ;;
    "GrandTotal" | "Receipts")
        icon_result=":dollar:"
        ;;
    "Hyper")
        icon_result=":hyper:"
        ;;
    "IINA")
        icon_result=":iina:"
        ;;
    "Infuse")
        icon_result=":infuse:"
        ;;
    "Inkdrop")
        icon_result=":inkdrop:"
        ;;
    "Insomnia")
        icon_result=":insomnia:"
        ;;
    "IntelliJ IDEA")
        icon_result=":idea:"
        ;;
    "iPhone Mirroring")
        icon_result=":iphone_mirroring:"
        ;;
    "iTerm2")
        icon_result=":iterm:"
        ;;
    "Iris")
        icon_result=":iris:"
        ;;
    "Jellyfin Media Player")
        icon_result=":jellyfin:"
        ;;
    "JetBrains Gateway")
        icon_result=":jetbrains_gateway:"
        ;;
    "JetBrains Toolbox")
        icon_result=":jetbrains_toolbox:"
        ;;
    "Joplin")
        icon_result=":joplin:"
        ;;
    "Journal")
        icon_result=":journal:"
        ;;
    "Kakoune")
        icon_result=":kakoune:"
        ;;
    "KeePassXC")
        icon_result=":kee_pass_x_c:"
        ;;
    "Keyboard Maestro")
        icon_result=":keyboard_maestro:"
        ;;
    "Keynote")
        icon_result=":keynote:"
        ;;
    "kitty")
        icon_result=":kitty:"
        ;;
    "LaunchBar")
        icon_result=""
        ;;
    "League of Legends")
        icon_result=":league_of_legends:"
        ;;
    "LibreWolf")
        icon_result=":libre_wolf:"
        ;;
    "LibreOffice")
        icon_result=":libreoffice:"
        ;;
    "Lightroom Classic")
        icon_result=":lightroomclassic:"
        ;;
    "LINE")
        icon_result=":line:"
        ;;
    "Linear")
        icon_result=":linear:"
        ;;
    "Live")
        icon_result=":ableton:"
        ;;
    "LocalSend")
        icon_result=":localsend:"
        ;;
    "Logseq")
        icon_result=":logseq:"
        ;;
    "MacVim" | "Vim" | "VimR")
        icon_result=":vim:"
        ;;
    "Mail" | "Canary Mail" | "HEY" | "Mailspring" | "MailMate")
        icon_result=":mail:"
        ;;
    "MAMP" | "MAMP PRO")
        icon_result=":mamp:"
        ;;
    "Maps" | "Google Maps" | "マップ" | "Karten")
        icon_result="maps"
        ;;
    "Matlab")
        icon_result=":matlab:"
        ;;
    "Mattermost")
        icon_result=":mattermost:"
        ;;
    "Messages")
        icon_result=":messages:"
        ;;
    "Messenger")
        icon_result=":messenger:"
        ;;
    "Microsoft Edge")
        icon_result=":microsoft_edge:"
        ;;
    "Microsoft Excel")
        icon_result=":microsoft_excel:"
        ;;
    "Microsoft Outlook")
        icon_result=":microsoft_outlook:"
        ;;
    "Microsoft PowerPoint")
        icon_result=":microsoft_power_point:"
        ;;
    "Microsoft Remote Desktop")
        icon_result=":microsoft_remote_desktop:"
        ;;
    "Microsoft Teams")
        icon_result=":microsoft_teams:"
        ;;
    "Microsoft To Do" | "Things")
        icon_result=":things:"
        ;;
    "Microsoft Word")
        icon_result=":microsoft_word:"
        ;;
    "Mimestream")
        icon_result=":mimestream:"
        ;;
    "Min")
        icon_result=":min_browser:"
        ;;
    "Miro")
        icon_result=":miro:"
        ;;
    "MoneyMoney")
        icon_result=":bank:"
        ;;
    "MongoDB Compass"*)
        icon_result=":mongodb:"
        ;;
    "mpv")
        icon_result=":mpv:"
        ;;
    "Music")
        icon_result=":music:"
        ;;
    "Navicat Premium")
        icon_result=":navicat:"
        ;;
    "Neovide" | "neovide")
        icon_result=":neovide:"
        ;;
    "Neovim" | "neovim" | "nvim")
        icon_result=":neovim:"
        ;;
    "NetNewsWire")
        icon_result=":netnewswire:"
        ;;
    "News")
        icon_result=":news:"
        ;;
    "NordVPN")
        icon_result=":nord_vpn:"
        ;;
    "Notability")
        icon_result=":notability:"
        ;;
    "Notes")
        icon_result=":notes:"
        ;;
    "Notion")
        icon_result=":notion:"
        ;;
    "Notion Mail")
        icon_result=":notion_mail:"
        ;;
    "Nova")
        icon_result=":nova:"
        ;;
    "Numbers")
        icon_result=":numbers:"
        ;;
    "OBS Studio")
        icon_result=":obsstudio:"
        ;;
    "Obsidian")
        icon_result=":obsidian:"
        ;;
    "OmniFocus")
        icon_result=":omni_focus:"
        ;;
    "OpenAI Translator")
        icon_result=":openai_translator:"
        ;;
    "Opera")
        icon_result=":opera:"
        ;;
    "OrbStack")
        icon_result=":orbstack:"
        ;;
    "Orion" | "Orion RC")
        icon_result=":orion:"
        ;;
    "Overcast")
        icon_result=":overcast:"
        ;;
    "Pages")
        icon_result=":pages:"
        ;;
    "Parallels Desktop")
        icon_result=":parallels:"
        ;;
    "Passwords")
        icon_result=":passwords:"
        ;;
    "PDF Expert")
        icon_result=":pdf_expert:"
        ;;
    "Pearcleaner")
        icon_result=":pearcleaner:"
        ;;
    "Perplexity" | "Perplexity AI")
        icon_result=":perplexity:"
        ;;
    "Phone")
        icon_result=":phone:"
        ;;
    "Photos")
        icon_result=":photos:"
        ;;
    "PhpStorm")
        icon_result="php_storm"
        ;;
    "Pi-hole Remote")
        icon_result=":pihole:"
        ;;
    "Pine")
        icon_result=":pine:"
        ;;
    "Pixelmator Pro")
        icon_result=":pixelmator_pro:"
        ;;
    "Plex")
        icon_result=":plex:"
        ;;
    "Podcasts")
        icon_result=":podcasts:"
        ;;
    "PomoDone App")
        icon_result=":pomodone:"
        ;;
    "Postman")
        icon_result=":postman:"
        ;;
    "Preview")
        icon_result=":preview:"
        ;;
    "Proton Mail" | "Proton Mail Bridge")
        icon_result=":proton_mail:"
        ;;
    "Proton VPN" | "ProtonVPN")
        icon_result=":proton_vpn:"
        ;;
    "PyCharm")
        icon_result=":pycharm:"
        ;;
    "qBittorrent")
        icon_result=":qbittorrent:"
        ;;
    "QQ")
        icon_result=":qq:"
        ;;
    "QuickTime Player")
        icon_result=":quicktime:"
        ;;
    "Quip")
        icon_result=":quip:"
        ;;
    "qutebrowser")
        icon_result=":qute_browser:"
        ;;
    "Raindrop.io")
        icon_result=":raindrop_io:"
        ;;
    "Raspberry Pi Imager" | "Raspberry Pi Connect")
        icon_result=":raspberry_pi:"
        ;;
    "Raycast")
        icon_result=":raycast:"
        ;;
    "Reeder")
        icon_result=":reeder5:"
        ;;
    "Reminders")
        icon_result=":reminders:"
        ;;
    "Replit")
        icon_result=":replit:"
        ;;
    "Rider" | "JetBrains Rider")
        icon_result=":rider:"
        ;;
    "Safari" | "Safari Technology Preview")
        icon_result=":safari:"
        ;;
    "Sequel Ace")
        icon_result=":sequel_ace:"
        ;;
    "Sequel Pro")
        icon_result=":sequel_pro:"
        ;;
    "Setapp")
        icon_result=":setapp:"
        ;;
    "Shortcuts")
        icon_result=":shortcuts:"
        ;;
    "Signal")
        icon_result=":signal:"
        ;;
    "Sketch")
        icon_result=":sketch:"
        ;;
    "Skim" | "zathura")
        icon_result=":pdf:"
        ;;
    "Slack")
        icon_result=":slack:"
        ;;
    "Spark Desktop")
        icon_result=":spark:"
        ;;
    "Spotify")
        icon_result=":spotify:"
        ;;
    "Spotlight")
        icon_result=":spotlight:"
        ;;
    "Steam" | "Steam Helper")
        icon_result=":steam:"
        ;;
    "Sublime Text")
        icon_result=":sublime_text:"
        ;;
    "Surfshark")
        icon_result=":surfshark:"
        ;;
    "Swift Playground")
        icon_result=":swift_playground:"
        ;;
    "System Preferences" | "System Settings")
        icon_result=":gear:"
        ;;
    "Tana")
        icon_result=":tana:"
        ;;
    "TeamSpeak 3")
        icon_result=":team_speak:"
        ;;
    "Telegram")
        icon_result=":telegram:"
        ;;
    "Terminal")
        icon_result=":terminal:"
        ;;
    "Termius")
        icon_result=":termius:"
        ;;
    "Thunderbird")
        icon_result=":thunderbird:"
        ;;
    "TickTick")
        icon_result=":tick_tick:"
        ;;
    "TIDAL")
        icon_result=":tidal:"
        ;;
    "Todoist")
        icon_result=":todoist:"
        ;;
    "Toggl Track")
        icon_result=":toggl_track:"
        ;;
    "Tor Browser")
        icon_result=":tor_browser:"
        ;;
    "Tower")
        icon_result=":tower:"
        ;;
    "Transmit")
        icon_result=":transmit:"
        ;;
    "Trello")
        icon_result=":trello:"
        ;;
    "TV")
        icon_result=":tv:"
        ;;
    "Twitter" | "Tweetbot" | "X" )
        icon_result=":twitter:"
        ;;
    "Typora")
        icon_result=":text:"
        ;;
    "Vivaldi")
        icon_result=":vivaldi:"
        ;;
    "VMware Fusion")
        icon_result=":vmware_fusion:"
        ;;
    "VLC")
        icon_result=":vlc:"
        ;;
    "VSCodium")
        icon_result=":vscodium:"
        ;;
    "Warp")
        icon_result=":warp:"
        ;;
    "Weather")
        icon_result=":weather:"
        ;;
    "WebStorm")
        icon_result=":web_storm:"
        ;;
    "WeChat")
        icon_result=":wechat:"
        ;;
    "WezTerm")
        icon_result=":wezterm:"
        ;;
    "‎WhatsApp")
        icon_result=":whats_app:"
        ;;
    "Xcode")
        icon_result=":xcode:"
        ;;
    "Yuque")
        icon_result=":yuque:"
        ;;
    "Zed")
        icon_result=":zed:"
        ;;
    "Zen" | "Zen Browser")
        icon_result=":zen_browser:"
        ;;
    "Zeplin")
        icon_result=":zeplin:"
        ;;
    "zoom.us")
        icon_result=":zoom:"
        ;;
    "Zotero")
        icon_result=":zotero:"
        ;;
    "Zulip")
        icon_result=":zulip:"
        ;;
    "1Password")
        icon_result=":one_password:"
        ;;
    *)
        icon_result=":default:"
        ;;
    esac
}

icon_map "$1"
echo "$icon_result"
