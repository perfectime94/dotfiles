-- Paleta oficial del port catppuccin/hyprland (26 colores de Mocha).
-- dofile con ruta absoluta: Hyprland no expone package.path al config,
-- asi que un require() normal no encontraria el modulo.
local ctp = dofile(os.getenv("HOME") .. "/.config/hypr/catppuccin-mocha.lua")

------------------
---- MONITORS ----
------------------
-- ASUS TUF A18: el panel interno lo dibuja la 780M (card0 -> eDP-1). Las
-- salidas externas HDMI-A-1 y DP-9 cuelgan de la GB206 (card1), no de la
-- iGPU: llegan al escritorio por reverse-PRIME.
-- "HDM-A-1" del portatil anterior era una errata, ese output no existe.
-- El conector del panel es eDP-2, NO eDP-1: el panel esta cableado a las dos
-- GPU (hay MUX) y aquamarine numera los eDP a lo largo de las dos tarjetas.
-- Verificado con `hyprctl monitors`: eDP-2 = AU Optronics B180UAN01.2.
hl.monitor({output = "eDP-2",    mode = "preferred", position = "auto-center-right", scale = 1})
-- BenQ EL2870U, 28" 4K. A escala 1 la interfaz sale minuscula.
-- 1.333333 = 4/3 exacto: 3840/(4/3) = 2880 y 2160/(4/3) = 1620, sin pixeles
-- fraccionarios, que es lo que Hyprland exige para no avisar y reajustar.
hl.monitor({output = "HDMI-A-1", mode = "preferred", position = "auto-center-left",  scale = 1.333333})
-- Cualquier otra salida (DP-9 por USB-C/Thunderbolt) con valores por defecto
hl.monitor({output = "", mode = "preferred", position = "auto", scale = 1})



---------------------:
---- MY PROGRAMS ----
---------------------
-- Set programs that you use
local terminal    = "alacritty"
local fileManager = "pcmanfm"
local menu        = "hyprlauncher"

-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function() hl.exec_cmd("gentoo-pipewire-launcher") end)
hl.on("hyprland.start", function() hl.exec_cmd("ashell") end)
hl.on("hyprland.start", function() hl.exec_cmd("/usr/libexec/hyprpolkitagent") end)
-- Fondo de pantalla
hl.on("hyprland.start", function() hl.exec_cmd("hyprpaper") end)
-- Inactividad: atenuar, bloquear, apagar pantalla, suspender
hl.on("hyprland.start", function() hl.exec_cmd("hypridle") end)
-- Filtro de luz azul a 4000K
hl.on("hyprland.start", function() hl.exec_cmd("hyprsunset -t 4000") end)
-- Reacciona a eventos del compositor (ver events.sh)
hl.on("hyprland.start", function() hl.exec_cmd("hyprevents -f " .. os.getenv("HOME") .. "/.config/hypr/events.sh") end)
-- asusd-user: demonio de sesion de asusctl. asusd (root) lleva ventiladores,
-- perfiles y bateria; los efectos de Aura por usuario los lleva este.
hl.on("hyprland.start", function() hl.exec_cmd("asusd-user") end)
-- cliphist: guarda el historial del portapapeles. wl-paste --watch se queda
-- escuchando y mete cada copia en la base de datos.
hl.on("hyprland.start", function() hl.exec_cmd("wl-paste --type text --watch cliphist store") end)
hl.on("hyprland.start", function() hl.exec_cmd("wl-paste --type image --watch cliphist store") end)
-- GUI de asusctl en la bandeja de ashell. --background la deja cerrada,
-- solo el icono. Si no la quieres, borra esta linea.
hl.on("hyprland.start", function() hl.exec_cmd("rog-control-center --background --autostart") end)

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function () 
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- Requeridas por el wiki de Gentoo: los portales XDG las usan para elegir
-- que implementacion cargar. Sin XDG_CURRENT_DESKTOP el portal de Hyprland
-- no se selecciona.
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- hyprqt6engine sustituye a qt6ct: da tema nativo de Hyprland a las apps Qt6.
-- El nombre lo registra /usr/lib64/qt6/plugins/platformthemes/libhyprqt6engine.so
-- Sin esto, hyprpolkitagent y demas apps Qt6 usan el estilo por defecto.
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
-- Graficos hibridos: Hyprland debe dibujar en la 780M, no en la NVIDIA.
-- La numeracion de /dev/dri/cardN no es estable: al cambiar de kernel la 780M
-- paso de card0 a card2 y card0 desaparecio.
-- OJO: aqui NO valen las rutas de /dev/dri/by-path/. AQ_DRM_DEVICES separa la
-- lista por ':' y esos nombres llevan ':' dentro (pci-0000:66:00.0-card), asi
-- que aquamarine parte la ruta en trozos y no arranca. Los alias gpu-amd y
-- gpu-nvidia los crea /etc/udev/rules.d/70-gpu-alias.rules: estables y sin ':'.
-- La NVIDIA va la segunda para que HDMI-A-1 y DP-9 sigan estando disponibles.
hl.env("AQ_DRM_DEVICES", "/dev/dri/gpu-amd:/dev/dri/gpu-nvidia")
-- Decodificacion de video por hardware en la 780M (VCN 4.0.2)
hl.env("LIBVA_DRIVER_NAME", "radeonsi")

hl.env("XCURSOR_SIZE", "24")
-- Los temas de nordzy-cursors estan SEPARADOS por formato: Nordzy-hyprcursors
-- solo tiene hyprcursors/ y Nordzy-cursors solo cursors/. Poner el mismo
-- nombre en ambas variables deja una de las dos apuntando a un tema sin el
-- formato que necesita, y el cursor desaparece en esas aplicaciones.
--   hyprcursor -> SVG, escala sin pixelar (Hyprland y Wayland nativo)
--   XCursor    -> mapas de bits (XWayland: Boosteroid)
hl.env("HYPRCURSOR_THEME", "Nordzy-hyprcursors-catppuccin-mocha-mauve")
hl.env("XCURSOR_THEME",    "Nordzy-catppuccin-mocha-mauve")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    -- Boosteroid es la unica app XWayland del sistema (Chrome y Alacritty son
    -- Wayland nativas), asi que este ajuste global solo le afecta a ella.
    -- Sin esto, en DP-2 (4K, scale 1.3333) Hyprland renderiza XWayland a
    -- escala 1 y amplia el bufer un 1.33x por interpolacion: texto borroso.
    -- Con force_zero_scaling renderiza a pixeles nativos y sale nitido.
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in  = 5,
        gaps_out = 20,

        border_size = 2,

        col = {
            -- Catppuccin Mocha: mauve -> pink en el activo, surface1 en el inactivo
            active_border   = { colors = {"rgba(" .. ctp.mauveAlpha .. "ee)",
                                          "rgba(" .. ctp.pinkAlpha  .. "ee)"}, angle = 45 },
            inactive_border = "rgba(" .. ctp.surface1Alpha .. "aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    -- Deja que una ventana a pantalla completa se envie directamente al
    -- escaner de la pantalla, sin pasar por el compositor: menos latencia y
    -- menos trabajo de la iGPU. Justo lo que interesa con Boosteroid.
    render = {
        direct_scanout = 1,
    },

    cursor = {
        -- Oculta el puntero tras 3s quieto: molesta menos viendo un stream.
        inactive_timeout = 3,
    },

    binds = {
        -- Pulsar la tecla del escritorio actual vuelve al anterior.
        workspace_back_and_forth = true,
    },

    ecosystem = {
        -- Sin ventanas emergentes de novedades ni de donaciones.
        no_update_news  = true,
        no_donation_nag = true,
    },

    misc = {
        -- Fuente de interfaz de Hyprland (groupbar, splash).
        font_family = "Cantarell",
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout  = "es",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))

-- Herramientas del ecosistema Hyprland
-- hyprprop: "xprop para Hyprland". Clic en una ventana y te da class/title,
-- que es justo lo que hace falta para escribir window_rule.
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprprop"))
-- Centro de volumen y panel de informacion del sistema
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("hyprpwcenter"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("hyprsysteminfo"))
-- Alterna el filtro de luz azul
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/hyprsunset-toggle"))
-- hyprpicker: cuentagotas de color. -a copia el valor al portapapeles.
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
-- Historial del portapapeles. hyprlauncher --dmenu lee la lista por stdin,
-- asi que no hace falta rofi/wofi para el selector.
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd(
    "sh -c 'cliphist list | hyprlauncher --dmenu | cliphist decode | wl-copy'"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Boosteroid: cliente de cloud gaming. Clase de ventana verificada con
-- `hyprctl clients -j`: "Boosteroid" (app XCB/X11 vía XWayland).
hl.window_rule({
    name  = "boosteroid-floating",
    match = { class = "^Boosteroid$" },
    float             = true,
    size              = "1600 900",
    center            = true,
    -- Evita que se apague la pantalla mientras hay stream en marcha.
    idle_inhibit      = "focus",
    -- El stream tiene relacion de aspecto fija: al redimensionar, respetarla.
    keep_aspect_ratio = true,
})

-- Bandeja propia de Wine. Cuando no encuentra un systray XEmbed (en Wayland
-- no hay), explorer.exe dibuja el suyo: una ventana flotante de 160x20 sin
-- titulo. Verificado con `hyprctl clients -j`.
-- No se puede desactivar desde Wine, asi que se fija discreta en la esquina
-- inferior derecha y se ancla para tenerla a mano al minimizar Battle.net.
hl.window_rule({
    name  = "wine-systray",
    match = { class = "^explorer\\.exe$", title = "^$", xwayland = true },

    float       = true,
    pin         = true,
    move        = "100%-180 100%-40",
    border_size = 0,
    no_shadow   = true,
    no_focus    = true,
})
