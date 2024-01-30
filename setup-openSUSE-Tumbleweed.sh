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
wget https://github.com/Alex313031/thorium/releases/download/M120.0.6099.235/thorium-browser_120.0.6099.235_SSE3.rpm
sudo zypper install thorium-browser_120.0.6099.235_SSE3.rpm

# echo "########### Install KVM ###########"
sudo zypper --non-interactive in -t pattern kvm_server kvm_tools

