update_system() {
    sudo apt update && sudo apt upgrade -y
}

setup_dev_tools() {
    # deps
    sudo apt install -y git curl wget unzip build-essential

    # starship
    curl -sS https://starship.rs/install.sh | sh

    # eza (ls alternative)
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza

    # bat
    sudo apt install -y bat
    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat

    # mise
    curl https://mise.run | sh
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
    ~/.local/bin/mise use --global node@22
	~/.local/bin/mise settings add idiomatic_version_file_enable_tools node

    # github cli
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
	git config --global user.name "Davi Oliveira"
	git config --global user.email "davioliveira.java@gmail.com"
	git config --global pull.rebase true
	git config --global push.autoSetupRemote true

	# docker
	# Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"

	# lazydocker
	curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

    # fish
    sudo apt-add-repository ppa:fish-shell/release-4
    sudo apt update
    sudo apt install -y fish

    # dotfiles
    setup_dotfiles
}

setup_dotfiles() {
    # Authenticate with GitHub CLI
    gh auth login
    # Clone dotfiles using gh cli
    gh repo clone daviziks/dotfiles ~/.dotfiles
    # Moves the content of the dotfiles folder to the home directory
    cp -r ~/.dotfiles/. ~/
    # Removes the dotfiles folder
    rm -rf ~/.dotfiles
    rm -rf ~/.git
    rm -rf ~/.config/hypr
    rm -rf ~/.config/Cursor
}

cleanup() {
    sudo apt autoremove -y
}

auto() {
    echo 'Updating system'
    update_system
    echo 'Installing dev tools'
    setup_dev_tools
    echo 'Cleaning up'
    cleanup
}

auto
