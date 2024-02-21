#!/bin/bash

mkdir ~/{.config,Downloads,Docker,Workdir,Scripts,Screenshots}
sudo mkdir /root/.config

echo "LC_ALL=en_US.UTF-8" | sudo tee -a /etc/environment
echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
sudo locale-gen en_US.UTF-8


## Install pacman packages

echo "[+] Installing packages..."

sudo pacman -Syu --noconfirm
sudo pacman -S adwaita-cursors adwaita-icon-theme alsa-lib alsa-plugins alsa-tools alsa-utils apr-util autoconf automake base base-devel bat bspwm bzip2 clang cmake curl devtools dpkg exploitdb feh firefox flameshot fuse fzf gc gcc gdb git gnu-netcat go gzip hashcat hydra inetutils iputils john kitty lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings lightdm-webkit2-greeter lsd lua mesa mesa-utils metasploit net-tools networkmanager nmap perl picom pocl polybar psmisc pulseaudio python qt5ct rofi ruby sqlite samba sqlmap starship sxhkd systemd tar thunar tree unzip util-linux webkit2gtk wget wireshark-qt wmname xclip xdg-utils xdotool xf86-input-libinput xorg-server-common xterm zip zsh zsh-autosuggestions zsh-syntax-highlighting --noconfirm

sudo pacman -S --needed base-devel --noconfirm
sudo pacman -S wget git --noconfirm
sudo systemctl enable lightdm.service


## Install git packages

echo "[+] Installing Git packages..."

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay
git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si && cd .. && rm -rf 
wget "https://github.com/neovim/neovim/releases/download/v0.9.5/nvim.appimage" && chmod u+x nvim.appimage && sudo mv nvim.appimage /usr/bin/nvim
git clone https://github.com/xmendez/wfuzz.git && cd wfuzz && makepkg -si && cd .. && rm -rf wfuzz
git clone https://aur.archlinux.org/burpsuite.git && cd gobuster && makepkg -si && cd .. && rm -rf gobuster
git clone https://github.com/longld/peda.git ~/peda && echo "source ~/peda/peda.py" >> ~/.gdbinit 
sudo git clone https://github.com/longld/peda.git /root/peda && echo "source /root/peda/peda.py" >> /root/.gdbinit
git clone https://github.com/helixarch/debtap.git && cd debtap && sudo mv debtap /usr/bin/debtap && cd .. && rm -rf debtap
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim


## Create config directories and clone configs

echo "[+] Creating config files..."

sudo rm README.md

sudo chmod +x {sxhkd/sxhkdrc,bspwm/bspwmrc,polybar/launch.sh,polybar/scripts/*.sh,bin/*.sh}

tar -xzvf assets/fonts.tar.gz
sudo chown -R root:root fonts
sudo cp -r fonts /usr/share/fonts
sudo rm -rf fonts

sudo mkdir /usr/share/backgrounds
sudo cp assets/background.png /usr/share/backgrounds
sudo rm -rf assets

cp zsh/.zshrc ~
sudo cp zsh/.zshrc /root/
sudo rm zsh/.zshrc
sudo cp -r zsh/* /usr/share/
sudo rm -rf zsh 

cd lightdm
sudo mkdir -p /usr/share/lightdm-webkit/themes/
sudo mkdir -p /etc/lightdm/
sudo cp -r lightdm/light-wlock /usr/share/lightdm-webkit/themes/
sudo cp lightdm/lightdm.conf /etc/lightdm/
sudo cp lightdm/lightdm-webkit2-greeter /etc/lightdm/
sudo rm -rf lightdm

echo 'QT_STYLE_OVERRIDE=Adwaita-Dark' | sudo tee -a /etc/environment
echo 'QT_QPA_PLATFORMTHEME=qt5ct' | sudo tee -a /etc/environment

sudo cp pam/lightdm /etc/pam.d/
sudo cp pam/system-auth /etc/pam.d/
echo "deny = 3" | sudo tee -a /etc/security/faillock.conf
echo "unlock_time = 15" | sudo tee -a /etc/security/faillock.conf
echo "nodelay" | sudo tee -a /etc/security/faillock.conf
sudo rm -rf pam

sudo mkdir /usr/share/wordlists
wget -c https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip && unzip SecList.zip && rm -f SecList.zip
sudo mv SecList /usr/share/wordlists/
wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt && sudo mv rockyou.txt /usr/share/wordlists/

sudo cp -r * /root/.config/
sudo rm /root/.config/starship.toml && sudo mv /root/.config/root_starship.toml /root/.config/starship.toml
cp -r * ~/.config

sudo chsh -s $(which zsh)
sudo chsh -s $(which zsh) $USER


## Install VMware Tools

read -p "[?] Do you want to install VMware Tools? [y/n]: " resp

if [ "$resp" == "y" ]; then
  
  until sudo blkid | grep "VMware Tools"; do
      echo "Please install the VMware Tools CD"
      read
  done

  if sudo blkid | grep "VMware Tools"; then

    echo "[+] Installing VMware Tools..."

    for x in {0..6}
    do
      sudo mkdir -p /etc/init.d/rc${x}.d 
    done
    sudo mount /dev/cdrom /mnt
    tar xf /mnt/VMwareTools*.tar.gz -C /root
    perl /root/vmware-tools-distrib/vmware-install.pl
    
    git clone https://gitlab.archlinux.org/archlinux/packaging/packages/open-vm-tools.git
    cd open-vm-tools
    makepkg -s --asdeps
    sudo cp vm* /usr/lib/systemd/system
    cd .. && rm -rf open-vm-tools

    sudo systemctl enable vmware-vmblock-fuse.service
    sudo systemctl enable vmtoolsd.service
    
    echo "[Unit]
    Description=VMWare Tools daemon
    
    [Service]
    ExecStart=/etc/init.d/vmware-tools start
    ExecStop=/etc/init.d/vmware-tools stop
    PIDFile=/var/lock/subsys/vmware
    TimeoutSec=0
    RemainAfterExit=yes
     
    [Install]
    WantedBy=multi-user.target" | sudo tee /etc/systemd/system/vmwaretools.service
    sudo systemctl enable vmwaretools.service
    sudo pacman -S xf86-input-vmmouse xf86-video-vmware mesa --noconfirm
    
    git clone https://github.com/rasa/vmware-tools-patches.git
    cd vmware-tools-patches
    sudo ./patched-open-vm-tools.sh
    cd .. && sudo rm -rf vmware-tools-patches

    echo "[i] Reboot and run this to start VMware Tools: sudo /etc/init.d/rc6.d/K99vmware-tools start"
  fi
fi

echo "[+] Removing installation files..."
cd .. && sudo rm -rf dotfiles

echo "[*] Done!"
