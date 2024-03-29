#!/bin/bash
clear

echo -ne "\e[1;31m
----------------------------------------------------------------------------
                Automated openSUSE Tumbleweed Setup Script
                            MadeBy: Vuk1lis™
                        https://github.com/vukilis
----------------------------------------------------------------------------
\e[1;33m"

echo "##########################################"
echo "#### Updating System and Repositories ####"
echo "##########################################"

sudo zypper ref
sudo zypper update
sudo zypper ar -cfp 90 https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
sudo zypper dup --from packman --allow-vendor-change

echo "#########################################"
echo "########## Essential Packages ##########"
echo "#########################################"

sudo zypper --non-interactive install opi
opi -n codecs

echo "########################################"
echo "####### Enable Snaps and Flatpak #######"
echo "########################################"

sudo zypper --non-interactive install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
sudo zypper --gpg-auto-import-keys refresh
sudo zypper dup --from snappy
sudo zypper --non-interactive install snapd
sudo systemctl enable --now snapd
sudo systemctl enable --now snapd.apparmor

echo "########### Install devel_basis ###########"
sudo zypper --non-interactive install -t pattern devel_basis

echo "########################################"
echo "########### Install Programs ###########"
echo "########################################"

# echo "########### Install VSCode ###########"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
sudo zypper refresh

for pkg in `cat pkgs.txt`
do sudo zypper --non-interactive install $pkg
done

# echo "########### Install Thorium ###########"
# wget https://github.com/Alex313031/thorium/releases/download/M120.0.6099.235/thorium-browser_120.0.6099.235_SSE3.rpm

thorium_latest_ver=$(git ls-remote https://github.com/Alex313031/Thorium | grep refs/tags | grep -oE "([a-zA-Z0-9.-_]*)" | awk '{ print substr($0, 10); }' | sort --version-sort | tail -n 1)
echo $thorium_latest_ver is latest version;
thorium_package="thorium-browser_${thorium_latest_ver#/M}_SSE3.rpm"
wget https://github.com/Alex313031/thorium/releases/download/$thorium_latest_ver/$thorium_package -O thorium-browser.rpm
sudo zypper install "thorium-browser.rpm"
rm -rf thorium-browser.rpm

# echo "########### Install KVM ###########"
sudo zypper --non-interactive in -t pattern kvm_server kvm_tools

# install snap packages
sudo snap install tldr

echo -ne "
-------------------------------------------------------------------------
                    Setup GRUB BIOS Bootloader
-------------------------------------------------------------------------
"

sudo sed -i 's/set timeout=8/set timeout=3/' /boot/grub2/grub.cfg

echo -ne "
-------------------------------------------------------------------------
                    Setup SDDM Display Manager
-------------------------------------------------------------------------
"

echo -e "\nEnabling Login Display Manager"
systemctl enable sddm.service
echo -e "\nSetup SDDM Theme"
sudo tar -xzvf ~/sugar‑candy.tar.gz -C /usr/share/sddm/themes
cat <<EOF > /etc/sddm.conf
[Theme]
Current=sugar-candy
EOF
sudo systemctl restart sddm.service
# sddm-greeter --test-mode --theme /usr/share/sddm/themes/sugar-candy



