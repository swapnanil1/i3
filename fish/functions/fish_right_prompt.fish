# Right side for every style except plain: exit code, how long the command took,
# and the clock. Empty while a line is being executed.
function fish_right_prompt
    test "$prompt_style" = plain; and return
    contains -- --final-rendering $argv; and return

    if test "$_prompt_duration" -gt 5000
        set -l secs (math -s0 $_prompt_duration / 1000)
        set_color yellow
        if test $secs -ge 60
            echo -n (math -s0 $secs / 60)'m '(math $secs % 60)'s '
        else
            echo -n $secs's '
        end
    end
    if test "$_prompt_status" -ne 0
        set_color red
        echo -n "✘ $_prompt_status "
    end
    set_color brblack
    echo -n (date +%H:%M)
    set_color normal
end
