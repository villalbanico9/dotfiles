#!/usr/bin/env bash

# Setup

echo "[+] Setting up..."
mkdir ~/{.config,Desktop,Downloads,Docker,Workdir,Scripts,Screenshots}
sudo mkdir /root/.config

echo "LC_ALL=en_US.UTF-8" | sudo tee -a /etc/environment
echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
sudo locale-gen en_US.UTF-8


## Install pacman packages

echo "[+] Installing packages..."
curl -O https://blackarch.org/strap.sh && chmod +x strap.sh && sudo ./strap.sh
sudo pacman -Syu --noconfirm --needed
sudo pacman -S adwaita-cursors alsa-lib alsa-plugins alsa-tools alsa-utils apr-util arp-scan autoconf automake base base-devel bat bspwm burpsuite bzip2 cewl clang cmake crackmapexec curl devtools docker dpkg exploitdb feh firefox flameshot fuse fzf gc gcc gdb ghidra git gnu-netcat go gobuster gzip hashcat hash-identifier hydra inetutils impacket iputils john kitty kvantum less lib32-gcc-libs lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings lightdm-webkit2-greeter locate lsd ltrace lua lxappearance macchanger man-db mariadb mesa mesa-utils metasploit net-tools networkmanager nm-connection-editor nmap openvpn papirus-icon-theme paru perl picom pocl polybar proxychains psmisc pulseaudio python python2 qt6ct responder rlwrap rofi ruby sqlite samba sqlmap starship strace sxhkd systemd tar tcpdump thunar tree unzip util-linux webkit2gtk wfuzz wget wireshark-qt wmname xclip xdg-utils xdotool xf86-input-libinput xorg-server-common xorg-xrandr xterm yay zip zsh zsh-autosuggestions zsh-syntax-highlighting --noconfirm --needed


## Install git packages

echo "[+] Installing additional packages..."

sudo find / -name "EXTERNALLY-MANAGED" 2>/dev/null -exec mv {} {}.old \;
sudo python3 -m ensurepip --upgrade
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && sudo python2 get-pip.py
yay -S rofi-file-browser-extended-git bsp-layout --noconfirm
gem install wpscan
wget "https://github.com/neovim/neovim/releases/download/v0.9.5/nvim.appimage" && chmod u+x nvim.appimage && sudo mv nvim.appimage /usr/bin/nvim
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
sudo cp -r fonts /usr/share/
sudo rm -rf fonts && sudo rm -rf assets/fonts.tar.gz

sudo mkdir /usr/share/backgrounds
sudo cp assets/background.png /usr/share/backgrounds
sudo rm -rf assets

sudo touch /usr/share/target.txt && sudo chmod 777 /usr/share/target.txt

cp zsh/.zshrc ~
sudo cp zsh/.zshrc /root/
sudo rm zsh/.zshrc
sudo cp -r zsh/* /usr/share/
sudo rm -rf zsh 

sudo systemctl enable lightdm
sudo mkdir -p /usr/share/lightdm-webkit/themes/
sudo mkdir -p /etc/lightdm/
sudo cp -r lightdm/light-wlock /usr/share/lightdm-webkit/themes/
sudo cp lightdm/lightdm.conf /etc/lightdm/
sudo cp lightdm/lightdm-webkit2-greeter.conf /etc/lightdm/
sudo rm -rf lightdm

echo 'QT_STYLE_OVERRIDE=Kvantum' | sudo tee -a /etc/environment
echo 'QT_QPA_PLATFORMTHEME=qt6ct' | sudo tee -a /etc/environment

sudo cp pam/lightdm /etc/pam.d/
sudo cp pam/system-auth /etc/pam.d/
echo "deny = 3" | sudo tee -a /etc/security/faillock.conf
echo "unlock_time = 15" | sudo tee -a /etc/security/faillock.conf
echo "nodelay" | sudo tee -a /etc/security/faillock.conf
sudo rm -rf pam

sudo cp -r * /root/.config/
sudo mv /root/.config/root_starship.toml /root/.config/starship.toml
cp -r * ~/.config

sed -i "s/\$USER/$USER/g" ~/.zshrc
sudo sed -i "s/\$USER/$USER/g" /root/.zshrc

sudo mkdir /usr/share/wordlists
wget -c https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip && unzip SecList.zip && rm -f SecList.zip
sudo mv SecLists-master /usr/share/wordlists/SecLists
tar -zxvf /usr/share/wordlists/SecLists/Passwords/Leaked-Databases/rockyou.txt.tar.gz -C /usr/share/wordlists

sudo updatedb

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
    sudo tar xf /mnt/VMwareTools*.tar.gz -C /root
    sudo perl /root/vmware-tools-distrib/vmware-install.pl -d
    
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
