[ -f ~/.gitignore ] && echo "Backing up existing .gitignore" && cp ~/.gitignore ~/.gitignore.bkup && rm ~/.gitignore
ln -s ~/.dotfiles/git/gitignore ~/.gitignore

[ -f ~/.gitconfig ] && echo "Backing up existing .gitconfig"  && cp ~/.gitconfig ~/.gitconfig.bkup && rm ~/.gitconfig
ln -s ~/.dotfiles/git/gitconfig ~/.gitconfig

cd ~/.dotfiles
git remote rm origin
git remote add origin git@github.com:bobbrez/dotfiles.git

cd ~