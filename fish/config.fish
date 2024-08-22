if status is-interactive
    set -U fish_greeting ""
    # Commands to run in interactive sessions can go here
    alias ls='eza -al --color=always --group-directories-first'
    alias pi='sudo pacman -S'
    alias pr='sudo pacman -R'
    alias prr='sudo pacman -Rns'
    alias vim='nvim'
end
