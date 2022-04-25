if ! command -v brew info &> /dev/null
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
then
    brew update
fi