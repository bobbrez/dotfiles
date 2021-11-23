git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

[ -f ~/.vimrc ] && echo "Backing up existing .vimrc"  && cp ~/.vimrc ~/.vimrc.bkup && rm ~/.vimrc
ln -s ~/.dotfiles/terminal/vimrc ~/.vimrc

vim +PluginInstall +qall