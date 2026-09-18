# Environment, for every fish (login, interactive or script)

if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
end

fish_add_path -g ~/.local/bin
