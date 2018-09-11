#!/usr/bin/env bash
set -euo pipefail

init() {
    sudo apt update
    sudo apt upgrade --yes
    sudo apt install --yes \
         build-essential \
         shellcheck

    git config --global user.name 'Masayuki Takeda'
    git config --global user.email 'mtakeda.enigsol@gmail.com'
    git config --global credential.helper store

    ln -s "$PWD"/conf/.tmux.conf ~/.tmux.conf
}

setup_spacemacs() {
    sudo apt install --yes emacs
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

    ln -s "$PWD"/conf/.spacemacs ~/.spacemacs

    FONT_HOME=~/.local/share/fonts
    echo "installing fonts at $PWD to $FONT_HOME"
    mkdir -p "$FONT_HOME/adobe-fonts/source-han-code-jp"
    (git clone \
        --branch release \
        --depth 1 \
        'https://github.com/adobe-fonts/source-han-code-jp.git' \
        "$FONT_HOME/adobe-fonts/source-han-code-jp" && \
     fc-cache -f -v "$FONT_HOME/adobe-fonts/source-han-code-jp")
}

setup_ocaml() {
    if ! type 'opam' > /dev/null; then
        sudo apt install --yes \
            aspcud \
            m4 \
            unzip
        curl -sS https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh |
            sh -s /usr/local/bin
    fi

    eval "$(opam config env)"
    echo '. /home/ubuntu/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true' >> ~/.profile
    cat <<EOF > .ocamlinit
let () =
  try Topdirs.dir_directory (Sys.getenv "OCAML_TOPLEVEL_PATH")
  with Not_found -> ()
;;
#use "topfind";;
#thread;;
#require "core.top";;
#require "core.syntax";;
open Core
EOF
    opam switch 4.07.0
    opam install --yes \
         dune \
         merlin \
         ocp-indent \
         ocamlformat \
         utop \
         core \
         async
}

setup_haskell() {
    if ! type 'stack' > /dev/null; then
        curl -sSL https://get.haskellstack.org/ |
            sh
    fi
    stack setup
}

setup_rust() {
    exit 1 # TODO
    # curl https://sh.rustup.rs -sSf | sh
}

setup_javascript() {
    if ! type 'node' > /dev/null; then
        git clone https://github.com/riywo/ndenv ~/.ndenv
        echo 'export PATH="$HOME/.ndenv/bin:$PATH"' >> ~/.profile
        echo 'eval "$(ndenv init -)"' >> ~/.profile
        source ~/.profile

        git clone https://github.com/riywo/node-build.git "$(ndenv root)"/plugins/node-build
        ndenv install "v8.11.4"
        ndenv rehash
    fi
}

init
setup_spacemacs
#setup_ocaml
#setup_haskell
#setup_rust
setup_javascript
