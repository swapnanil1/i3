# Shared renderer for the segment prompt styles.
#   __pl_render <shape> [framed] -- <fish_prompt args>
# shapes: arrows gapped pills slanted blocks thin
# "framed" draws the segments on line 1 and the input arrow on line 2.
#
# Segments: host (SSH only), path (red + lock when not writable), git (green
# clean, yellow with changes). Exit code, duration and clock are in
# fish_right_prompt. Named terminal colours only, so it follows the i3 theme.
function __pl_render
    set -l shape $argv[1]
    set -l framed 0
    contains -- framed $argv; and set framed 1

    set -l arrow_color green
    test $_prompt_status -ne 0; and set arrow_color red

    # transient: the line being executed collapses to a single arrow
    if contains -- --final-rendering $argv
        set_color $arrow_color; echo -n '❯ '; set_color normal
        return
    end

    # --- collect segments as "background|foreground|text"
    set -l segs
    set -q SSH_TTY; and set -a segs "brblack|white|$USER@"(prompt_hostname)
    if test -w .
        set -a segs "blue|black|"(prompt_pwd)
    else
        set -a segs "red|black| "(prompt_pwd)
    end
    set -l git (fish_git_prompt '%s')
    if test -n "$git"
        if string match -qr '[*+]' -- $git
            set -a segs "yellow|black| $git"
        else
            set -a segs "green|black| $git"
        end
    end

    test $framed -eq 1; and begin; echo; set_color brblack; echo -n '╭─'; end

    # --- draw
    set -l prev
    for seg in $segs
        set -l p (string split -m 2 '|' -- $seg)
        set -l bg $p[1]; set -l fg $p[2]; set -l text $p[3]
        switch $shape
            case arrows
                test -n "$prev"; and begin; set_color --background $bg $prev; echo -n ''; end
                set_color --background $bg $fg; echo -n " $text "
            case slanted
                test -n "$prev"; and begin; set_color --background $bg $prev; echo -n ' '; end
                set_color --background $bg $fg; echo -n " $text "
            case gapped
                test -n "$prev"; and echo -n ' '
                set_color --background $bg $fg; echo -n " $text "
                set_color normal; set_color $bg; echo -n ''
            case pills
                test -n "$prev"; and echo -n ' '
                set_color normal; set_color $bg; echo -n ''
                set_color --background $bg $fg; echo -n "$text"
                set_color normal; set_color $bg; echo -n ''
            case blocks
                test -n "$prev"; and begin; set_color normal; echo -n ' '; end
                set_color --background $bg $fg; echo -n " $text "
            case thin
                test -n "$prev"; and begin; set_color --background brblack black; echo -n ''; end
                set_color --background brblack black; echo -n " $text "
        end
        set prev $bg
    end

    # --- close the last segment
    set_color normal
    switch $shape
        case arrows
            set_color $prev; echo -n ''
        case slanted
            set_color $prev; echo -n ''
        case thin
            set_color brblack; echo -n ''
    end
    set_color normal

    if test $framed -eq 1
        echo
        set_color brblack; echo -n '╰─'
        set_color $arrow_color; echo -n '❯ '
    else
        echo -n ' '
    end
    set_color normal
end
