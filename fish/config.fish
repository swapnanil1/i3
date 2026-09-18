# Settings live in conf.d/ (loaded in name order before this file); functions in
# functions/ (autoloaded by name). This file only holds what must run last.
#
# Machine-specific tweaks: put them in conf.d/99-local.fish, which is not part
# of the dotfiles.

status is-interactive; or return

# System summary once per terminal: not in nested shells or editor terminals
if not set -q FETCH_SHOWN; and not set -q TERM_PROGRAM; and type -q fastfetch
    set -gx FETCH_SHOWN 1
    fastfetch
end
