mkdir -p ~/.ssh

[ -f ~/.ssh/config ] && echo "Backing up existing .ssh/config"  && cp ~/.ssh/config ~/.ssh/config.bkup && rm ~/.ssh/config

ln -s ~/.dotfiles/ssh/config ~/.ssh/config

ssh-keygen -t rsa -b 4096 -C "bob@brez.com"
ssh-add --apple-use-keychain ~/.ssh/id_rsa