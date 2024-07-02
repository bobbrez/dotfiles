# Install OhMyZsh
sh -c "export RUNZSH=no && $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Replace the generated zshrc with the custom one here, the backup should be discared aferwards
mv ~/.zshrc ~/.zshrc.bkup
ln -s ~/.dotfiles/terminal/zshrc ~/.zshrc

# Install Powerlevel
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
ln -s ~/.dotfiles/terminal/p10k.zsh ~/.p10k.zsh

# Install Zsh Nodenv
# git clone https://github.com/mattberther/zsh-nodenv ~/.oh-my-zsh/custom/plugins/zsh-nodenv

# Install Zsh Syntax Highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

# Setup Brew
eval $(/opt/homebrew/bin/brew shellenv)

# Install Python Virtual
brew install pyenv-virtualenv

exec zsh -l