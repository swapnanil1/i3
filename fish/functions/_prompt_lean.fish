# ~/repos/swapna/daily-plan  BRANCH main *                    (right: ✘ 1  1m 5s)
# ❯
#
# Two lines, coloured text, no background blocks. Line 1 is information, line 2
# is where you type, so a long path never pushes the command off screen.
# The arrow is green, or red after a failed command. Once a command runs the
# two lines collapse to the arrow alone (transient prompt).
# Named terminal colours only, so it follows ~/.config/i3/scripts/theme.
function _prompt_lean
    set -l arrow_color green
    test $_prompt_status -ne 0; and set arrow_color red

    if not contains -- --final-rendering $argv
        echo                                   # breathing room between commands

        if set -q SSH_TTY
            set_color brblack
            echo -n $USER@(prompt_hostname)' '
        end

        if test -w .
            set_color --bold blue
        else
            set_color --bold red
        end
        echo -n (prompt_pwd)
        set_color normal

        set -l git (fish_git_prompt '%s')
        if test -n "$git"
            if string match -qr '[*+]' -- $git
                set_color yellow
            else
                set_color brblack
            end
            echo -n "   $git"
        end
        echo
    end

    set_color $arrow_color
    echo -n '❯ '
    set_color normal
end
