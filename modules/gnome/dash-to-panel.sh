#!/usr/bin/env bash
set -x

dconf write /org/gnome/shell/extensions/dash-to-panel/panel-size 40
dconf write /org/gnome/shell/extensions/dash-to-panel/group-apps false
dconf write /org/gnome/shell/extensions/dash-to-panel/isolate-workspaces true
dconf write /org/gnome/shell/extensions/dash-to-panel/show-window-previews false
