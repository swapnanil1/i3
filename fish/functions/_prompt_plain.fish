# ~/repos/swapna/i3 overhaul* ↑1 [2m 5s] [127] >
#
#   path         parents cut to $fish_prompt_pwd_dir_length characters
#   branch       * = uncommitted changes, ↑N ↓N = ahead/behind upstream
#   [2m 5s]      only when the last command took longer than 5 seconds
#   [127]        only when the last command failed; the > turns red too
#   user@host    only over SSH
#
# Once a command runs, the line collapses to "path >" (transient prompt), so
# scrollback stays readable. Colours are the terminal's named colours, so the
# prompt follows ~/.config/i3/scripts/theme.
function _prompt_plain
    set -l last_status $_prompt_status
    set -l duration $_prompt_duration

    if set -q SSH_TTY
        set_color brblack
        echo -n $USER@(prompt_hostname)' '
    end

    set_color magenta
    echo -n (prompt_pwd)

    # --final-rendering: fish is redrawing the prompt of a line being executed
    if not contains -- --final-rendering $argv
        set_color brblack
        echo -n (fish_git_prompt ' %s')

        if test "$duration" -gt 5000
            set -l secs (math -s0 $duration / 1000)
            set_color yellow
            if test $secs -ge 60
                echo -n ' ['(math -s0 $secs / 60)'m '(math $secs % 60)'s]'
            else
                echo -n " [$secs"s]
            end
        end

        if test $last_status -ne 0
            set_color red
            echo -n " [$last_status]"
        end
    end

    if test $last_status -eq 0
        set_color normal
    else
        set_color red
    end
    echo -n ' > '
    set_color normal
end
