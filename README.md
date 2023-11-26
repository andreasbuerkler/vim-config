### Installation

```
wget https://github.com/neovim/neovim-releases/releases/download/nightly/nvim-linux64.deb
sudo apt install ./nvim-linux64.deb
mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/init.lua
```

### required packages

- build-essential
- nodejs
- npm
- unzip


### install language server for Makefiles

```
pip install autotools-language-server
pip install --upgrade jsonschema
```
