#!/usr/bin/env sh
# Handlers de hyprevents. Sobrescriben las funciones vacias de
# /usr/share/hyprevents/event_handler

event_monitorremoved() {
    # MONITORNAME
    [ "$MONITORNAME" = "DP-2" ] || return 0
    # Dock fuera: probablemente en bateria. Perfil de ahorro y sin blur.
    powerprofilesctl set power-saver 2>/dev/null
    hyprctl keyword decoration:blur:enabled false >/dev/null 2>&1
    notify-send -a hyprevents "Dock desconectado" "Perfil: power-saver, blur off" 2>/dev/null
}

event_monitoradded() {
    # MONITORNAME
    [ "$MONITORNAME" = "DP-2" ] || return 0
    powerprofilesctl set balanced 2>/dev/null
    hyprctl keyword decoration:blur:enabled true >/dev/null 2>&1
    notify-send -a hyprevents "Dock conectado" "Perfil: balanced, blur on" 2>/dev/null
}
