[ -f ~/.gitignore ] && echo "Backing up existing .gitignore" && cp ~/.gitignore ~/.gitignore.bkup && rm ~/.gitignore
ln -s ~/.dotfiles/terminal/gitignore ~/.gitignore

[ -f ~/.gitconfig ] && echo "Backing up existing .gitconfig"  && cp ~/.gitconfig ~/.gitconfig.bkup && rm ~/.gitconfig
ln -s ~/.dotfiles/terminal/gitconfig ~/.gitconfig