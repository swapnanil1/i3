status is-interactive; or return

# Abbreviations expand in place as you type, so history and copy-paste show the
# real command. `abbr` alone lists them.

# pacman
abbr -a pi  sudo pacman -S
abbr -a pr  sudo pacman -R
abbr -a prr sudo pacman -Rns
abbr -a pu  sudo pacman -Syu
abbr -a pq  pacman -Qs

# git
abbr -a g   git
abbr -a gs  git status -sb
abbr -a ga  git add
abbr -a gc  git commit
abbr -a gca git commit --amend
abbr -a gd  git diff
abbr -a gds git diff --staged
abbr -a gl  git log --oneline --graph -20
abbr -a gp  git push
abbr -a gpl git pull --rebase
abbr -a gco git checkout
abbr -a gsw git switch
abbr -a gb  git branch

# moving around
abbr -a ..   cd ..
abbr -a ...  cd ../..
abbr -a .... cd ../../..

if type -q eza
    alias ls 'eza -al --color=always --group-directories-first'
    abbr -a lt eza -T --level=2 --group-directories-first
end
if type -q nvim
    alias vim nvim
end
