#!/usr/bin/env sh
# Handlers de hyprevents. Sobrescriben las funciones vacias de
# /usr/share/hyprevents/event_handler

event_monitorremoved() {
    # MONITORNAME
    # Salidas externas del A18: HDMI-A-1 y DP-9 (las dos en la GB206).
    case "$MONITORNAME" in HDMI-A-1|DP-9) ;; *) return 0 ;; esac
    # Monitor fuera: probablemente en bateria. Perfil de ahorro y sin blur.
    powerprofilesctl set power-saver 2>/dev/null
    hyprctl keyword decoration:blur:enabled false >/dev/null 2>&1
    notify-send -a hyprevents "Monitor externo desconectado" "Perfil: power-saver, blur off" 2>/dev/null
}

event_monitoradded() {
    # MONITORNAME
    case "$MONITORNAME" in HDMI-A-1|DP-9) ;; *) return 0 ;; esac
    powerprofilesctl set balanced 2>/dev/null
    hyprctl keyword decoration:blur:enabled true >/dev/null 2>&1
    notify-send -a hyprevents "Monitor externo conectado" "Perfil: balanced, blur on" 2>/dev/null
}
