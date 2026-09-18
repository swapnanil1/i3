# The prompt style is picked by $prompt_style; run `prompt-style` for a menu
# with previews. Each style is a function _prompt_<style> in functions/; the
# segment styles are thin wrappers around __pl_render.
function fish_prompt
    set -g _prompt_status $status
    set -g _prompt_duration $CMD_DURATION

    set -l style _prompt_$prompt_style
    functions -q $style; or set style _prompt_plain
    $style $argv
end
