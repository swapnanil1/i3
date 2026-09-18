function prompt-style --description 'Pick the prompt style: menu with no arguments, or prompt-style <name> [--save]'
    set -l styles (functions --all | string match -r '^_prompt_\K.+')

    if test (count $argv) -gt 0
        if not contains -- $argv[1] $styles
            echo "unknown style: $argv[1] (available: $styles)" >&2
            return 1
        end
        set -g prompt_style $argv[1]
        contains -- --save $argv; and __promptstyle_save $argv[1]
        return 0
    end

    # --- menu. fish's `read` keeps the arrow keys for its own line editing, so the
    # menu uses j/k and the number keys instead.
    set -l pos (contains -i -- "$prompt_style" $styles; or echo 1)
    set -l drawn 0
    set -g _prompt_status 0
    set -g _prompt_duration 0
    printf '\e[?25l'                                   # hide the cursor

    while true
        test $drawn -gt 0; and printf '\e[%dA\e[J' $drawn   # back to the top, clear

        set -l lines "Prompt style   j/k or 1-9 move   enter use   s save as default   q quit" ""
        for i in (seq (count $styles))
            if test $i -eq $pos
                set -a lines (set_color --reverse)(printf " ❯%2d %s " $i $styles[$i])(set_color normal)
            else
                set -a lines (printf "  %2d %s" $i $styles[$i])
            end
        end
        set -a lines "" (set_color brblack)"preview:"(set_color normal)
        set -a lines (_prompt_$styles[$pos])
        printf '%s\n' $lines
        set drawn (count $lines)

        read -n 1 -s -P '' key
        switch "$key"
            case k
                set pos (math "($pos - 2 + "(count $styles)") % "(count $styles)" + 1")
            case j
                set pos (math "$pos % "(count $styles)" + 1")
            case 1 2 3 4 5 6 7 8 9
                test $key -le (count $styles); and set pos $key
            case '' s
                set -g prompt_style $styles[$pos]
                printf '\e[?25h'
                test "$key" = s; and __promptstyle_save $styles[$pos]
                return 0
            case q
                printf '\e[?25h'
                return 0
        end
    end
end

function __promptstyle_save
    # 99-local.fish is this machine's own file, not part of the dotfiles
    set -l file $__fish_config_dir/conf.d/99-local.fish
    touch $file
    string match -v -r '^set -g prompt_style ' <$file >$file.tmp
    echo "set -g prompt_style $argv[1]" >>$file.tmp
    mv $file.tmp $file
    echo "saved: $argv[1] is the default on this machine"
end
