echo_red() {
    tput setaf 1
    echo "$*"
    tput sgr0
}
echo_barrier() { for _ in $(seq $1); do echo -n -; done; }
echo_title() {
    echo ""
    echo_red $(echo_barrier $((${#*} + 10)))
    echo_red "---- $* ----"
    echo_red $(echo_barrier $((${#*} + 10)))
}
echo_and_run() {
    echo_red "\$ $*"
    "$@"
}

echo_red "Step1: Essential utils, NVIDIA Driver"
echo_red "Step2: my-linux-setting, Miniconda"
echo_red "Step3: Python packages, Neovim, Etc..."
echo_red "Step4: Libinput-gestures (for laptop)"
echo_red "Step5: clangd, clang-format"
echo_red "Step6: node"
read -p "$(echo_red "Which step?")" STEP

if [ "$STEP" = "1" ]; then

    echo_title "Basic Update"
    echo_and_run sudo apt update
    echo_and_run sudo apt upgrade

    echo_title "Essential Utils"
    echo_and_run sudo apt install build-essential git openssh-server tmux

    echo_title "Google Chrome"
    echo_and_run wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    echo_and_run sudo apt install ./google-chrome-stable_current_amd64.deb
    echo_and_run rm ./google-chrome-stable_current_amd64.deb

    read -p "$(echo_red "Install Nvidia Driver (y/n)?")" CONT
    if [ "$CONT" = "y" ]; then
        echo_title "Install Nvidia Driver"
        echo_and_run sudo add-apt-repository ppa:graphics-drivers/ppa
        echo_and_run sudo apt update
        echo_and_run ubuntu-drivers devices
        echo_and_run sudo ubuntu-drivers autoinstall
        echo_red "System Reboot Recommended"
    fi

elif [ "$STEP" = "2" ]; then

    echo_title "Make Utils Folder"
    echo_and_run mkdir Utils

    echo_title "Install my-linux-setting"
    echo_and_run git clone https://github.com/jaehyuck0103/my-linux-setting.git ~/Utils/my-linux-setting
    echo_and_run cd ~/Utils/my-linux-setting
    echo_and_run sh install.sh
    echo_and_run cd -

    echo_title "Miniconda"
    echo_and_run wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    echo_and_run bash Miniconda3-latest-Linux-x86_64.sh
    echo_and_run rm Miniconda3-latest-Linux-x86_64.sh
    echo_red "Reopen Terminal Required"

elif [ "$STEP" = "3" ]; then

    echo_title "Install Python Packages"
    echo_and_run conda update --all
    echo_and_run pip install setuptools wheel
    echo_and_run pip install flake8 jedi pylint black isort
    echo_and_run pip install numpy scipy matplotlib
    echo_and_run pip install pandas scikit-learn scikit-image
    echo_and_run pip install opencv-python
    echo_and_run pip install torch torchvision
    echo_and_run pip install cmakelang
    # pip xarray requests bs4 seaborn xgboost imbalanced-learn albumentations tqdm

    echo_title "Neovim (from PPA)" # https://github.com/neovim/neovim/wiki/Installing-Neovim
    echo_and_run sudo add-apt-repository ppa:neovim-ppa/unstable
    echo_and_run sudo apt-get update
    echo_and_run sudo apt-get install neovim
    echo_and_run pip install neovim

    echo_title "Dropbox"
    echo_and_run sudo apt install dropbox python3-gpg

elif [ "$STEP" = "4" ]; then

    echo_title "Libinput-gestures (for laptop)"
    echo_and_run sudo gpasswd -a $USER input
    echo_and_run sudo apt install xdotool wmctrl libinput-tools
    echo_and_run git clone https://github.com/bulletmark/libinput-gestures.git ~/Utils/libinput-gestures
    echo_and_run cd ~/Utils/libinput-gestures
    echo_and_run sudo make install
    echo_and_run libinput-gestures-setup autostart
    # echo_and_run libinput-gestures-setup start   # Is necessary?
    echo_and_run cd -
    echo_red "Logout and Login Required"

elif [ "$STEP" = "5" ]; then # https://apt.llvm.org/

    echo_title "Install clangd, clang-format"

    UBUNTU_CODENAME=$(grep "UBUNTU_CODENAME=" /etc/os-release | cut -d "=" -f2)
    echo_red "UBUNTU_CODENAME: ${UBUNTU_CODENAME}"

    REPO_NAME="deb http://apt.llvm.org/${UBUNTU_CODENAME}/   llvm-toolchain-${UBUNTU_CODENAME}  main"
    echo_and_run sudo add-apt-repository "${REPO_NAME}"
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add - # echo_and_run 붙이면 안되서 제외.
    echo_and_run sudo apt update
    echo_and_run sudo apt install clangd clang-format

elif [ "$STEP" = "6" ]; then # https://github.com/nodesource/distributions/blob/master/README.md
    echo_title "Install node"
    curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    echo_and_run sudo apt-get install -y nodejs
fi
