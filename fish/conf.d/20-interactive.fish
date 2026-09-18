status is-interactive; or return

set -g fish_greeting
set -g fish_key_bindings fish_default_key_bindings

# Prompt style: run `prompt-style` to pick one (functions/_prompt_<style>.fish)
set -q prompt_style; or set -g prompt_style lean
set -g fish_prompt_pwd_dir_length 6
set -g fish_transient_prompt 1

# Git in the prompt. Dirty state and ahead/behind are cheap; counting untracked
# files is what makes prompts slow in big repos, so it stays off.
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showupstream informative
set -g __fish_git_prompt_char_dirtystate '*'
set -g __fish_git_prompt_char_stagedstate '+'
set -g __fish_git_prompt_char_upstream_ahead ' ↑'
set -g __fish_git_prompt_char_upstream_behind ' ↓'
set -g __fish_git_prompt_char_upstream_diverged ' ↕'
set -g __fish_git_prompt_char_upstream_equal ''
set -g __fish_git_prompt_char_stateseparator ''

# Syntax colours. Since fish 4.3 these are plain globals set from config, not
# universal variables. Named colours only, so they follow the terminal theme.
set -g fish_color_command blue
set -g fish_color_keyword magenta
set -g fish_color_param normal
set -g fish_color_option cyan
set -g fish_color_quote yellow
set -g fish_color_redirection cyan
set -g fish_color_operator cyan
set -g fish_color_end magenta
set -g fish_color_error red
set -g fish_color_comment brblack
set -g fish_color_autosuggestion brblack
set -g fish_color_valid_path --underline
set -g fish_color_escape brcyan
set -g fish_color_selection --background=brblack
set -g fish_color_search_match --background=brblack
set -g fish_pager_color_prefix normal --bold --underline
set -g fish_pager_color_completion normal
set -g fish_pager_color_description yellow --italics
set -g fish_pager_color_progress brwhite --background=cyan
set -g fish_pager_color_selected_background --background=brblack
