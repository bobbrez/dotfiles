# Replace the generated zshrc with the custom one here, the backup should be discared aferwards
mv ~/.zshrc ~/.zshrc.bkup
ln -s ~/.dotfiles/terminal/zshrc ~/.zshrc

# Install Powerlevel
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
ln -s ~/.dotfiles/terminal/p10k.zsh ~/.p10k.zsh

# Install Zsh Nodenv
git clone https://github.com/mattberther/zsh-nodenv ~/.oh-my-zsh/custom/plugins/zsh-nodenv
