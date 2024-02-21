#!/bin/bash

mkdir ~/{.config,Downloads,Docker,Workdir,Scripts,Screenshots}
sudo mkdir /root/.config

echo "LC_ALL=en_US.UTF-8" | sudo tee -a /etc/environment
echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
sudo locale-gen en_US.UTF-8


## Install pacman packages

echo "[+] Installing packages..."

sudo pacman -Syu --noconfirm --needed
sudo pacman -S adwaita-cursors adwaita-icon-theme alsa-lib alsa-plugins alsa-tools alsa-utils apr-util autoconf automake base base-devel bat bspwm bzip2 clang cmake curl devtools dpkg exploitdb feh firefox flameshot fuse fzf gc gcc gdb git gnu-netcat go gzip hashcat hydra impacket inetutils iputils john kitty less lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings lightdm-webkit2-greeter lsd lua man-db mesa mesa-utils metasploit net-tools networkmanager nmap perl picom pocl polybar psmisc pulseaudio python qt5ct rofi ruby sqlite samba sqlmap starship sxhkd systemd tar thunar tree unzip util-linux webkit2gtk wget wireshark-qt wmname xclip xdg-utils xdotool xf86-input-libinput xorg-server-common xorg-xrand xterm zip zsh zsh-autosuggestions zsh-syntax-highlighting --noconfirm --needed


## Install git packages

echo "[+] Installing additional packages..."

sudo find / -name "EXTERNALLY-MANAGED" 2>/dev/null -exec mv {} {}.old \;
sudo python3 -m ensurepip --upgrade
wget "https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz" && tar zxfv Python-2.7.18.tgz && cd Python-2.7.18 && ./configure && make && sudo make install && cd .. && rm -rf Python-2.7.18
#git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd .. && rm -rf yay
#git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si && cd .. && rm -rf 
wget "https://github.com/neovim/neovim/releases/download/v0.9.5/nvim.appimage" && chmod u+x nvim.appimage && sudo mv nvim.appimage /usr/bin/nvim
go install github.com/OJ/gobuster/v3@latest
sudo python -m pip install wfuzz
git clone https://aur.archlinux.org/hash-id.git && cd hash-id && makepkg -si && cd .. && rm -rf hash-id 
git clone https://aur.archlinux.org/burpsuite.git && cd burpsuite && makepkg -si && cd .. && rm -rf burpsuite
git clone https://github.com/longld/peda.git ~/peda && echo "source ~/peda/peda.py" >> ~/.gdbinit 
sudo git clone https://github.com/longld/peda.git /root/peda && echo "source /root/peda/peda.py" >> /root/.gdbinit
git clone https://github.com/helixarch/debtap.git && cd debtap && sudo mv debtap /usr/bin/debtap && cd .. && rm -rf debtap
wget "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.0.1_build/ghidra_11.0.1_PUBLIC_20240130.zip" -O ghidra.zip && unzip ghidra.zip && sudo mv ghidra /opt
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

cp zsh/.zshrc ~
sudo cp zsh/.zshrc /root/
sudo rm zsh/.zshrc
sudo cp -r zsh/* /usr/share/
sudo rm -rf zsh 

sudo systemctl enable lightdm.service
sudo mkdir -p /usr/share/lightdm-webkit/themes/
sudo mkdir -p /etc/lightdm/
sudo cp -r lightdm/light-wlock /usr/share/lightdm-webkit/themes/
sudo cp lightdm/lightdm.conf /etc/lightdm/
sudo cp lightdm/lightdm-webkit2-greeter.conf /etc/lightdm/
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
sudo mv SecLists /usr/share/wordlists/
wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt && sudo mv rockyou.txt /usr/share/wordlists/

sudo cp -r * /root/.config/
sudo mv /root/.config/root_starship.toml /root/.config/starship.toml
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
