function fish_prompt
    set -l full_path (pwd)
    set -l path_to_process (string replace -- "$HOME" "~" $full_path)
    set -l path_parts (string split / $path_to_process)
    set -l truncated_parts

    if test (count $path_parts) -gt 0
        set -l first_part $path_parts[1]
        if test "$first_part" = "~"
            set -a truncated_parts "~"
        else if test "$first_part" = ""
            set -a truncated_parts ""
        else
            set -a truncated_parts (string sub --length 6 $first_part)
        end
    end

    if test (count $path_parts) -gt 1
        for i in (seq 2 (count $path_parts))
            set part $path_parts[$i]
            if test -n "$part"
                set -a truncated_parts (string sub --length 6 $part)
            end
        end
    end

    set -l display_path "?"
    if test (count $truncated_parts) -gt 0
        set display_path (string join / $truncated_parts)
        if test "$display_path" = ""; and test "$full_path" = "/"
            set display_path "/"
        end
    else
        if test "$full_path" = "/"
           set display_path "/"
        end
    end

    set_color bb9af7
    echo -n $display_path
    set_color normal
    echo -n ' > '
    set_color normal
end
