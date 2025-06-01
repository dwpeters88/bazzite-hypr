#!/bin/bash

RELEASE="$(rpm -E %fedora)"
set -ouex pipefail

enable_copr() {
    repo="$1"
    repo_with_dash="${repo/\//-}"
    wget "https://copr.fedorainfracloud.org/coprs/${repo}/repo/fedora-${RELEASE}/${repo_with_dash}-fedora-${RELEASE}.repo" \
        -O "/etc/yum.repos.d/_copr_${repo_with_dash}.repo"
}

# Example: Adding 1Password repo (commented out)
# get_1_password() {
#     rpm --import https://downloads.1password.com/linux/keys/1password.asc
#     sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
# }

### Install packages

# Packages can be installed from any enabled dnf5 repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/41/x86_64/repoview/index.html&protocol=https&redirect=1

# Enable COPR repositories for Hyprland ecosystem
enable_copr solopasha/hyprland
enable_copr erikreider/SwayNotificationCenter
enable_copr pgdev/ghostty
enable_copr wezfurlong/wezterm-nightly

# Aurora-dx-nvidia already has fish, but if there are conflicts with ghostty, handle them
# ncurses-term dependency is in conflict with ghostty so remove fish if needed
# dnf5 remove -y fish

# Install Hyprland and essential Wayland components
# Aurora already has NVIDIA drivers, so we focus on the Hyprland ecosystem
dnf5 install -y --setopt=install_weak_deps=False \
    xdg-desktop-portal-hyprland \
    hyprland \
    hyprlock \
    hypridle \
    hyprpicker \
    hyprsysteminfo \
    hyprsunset \
    hyprpaper \
    hyprcursor \
    hyprgraphics \
    hyprpolkitagent \
    hyprland-qtutils \
    hyprland-qt-support \
    hyprland-uwsm \
    uwsm \
    pyprland \
    waybar \
    wofi \
    rofi-wayland \
    swaync \
    wl-clipboard \
    grim \
    slurp \
    brightnessctl \
    pavucontrol \
    network-manager-applet \
    clipman \
    nwg-drawer \
    wdisplays \
    SwayNotificationCenter \
    NetworkManager-tui \
    tmux \
    ghostty \
    wezterm \
    blueman \
    qt5-qtwayland \
    qt6-qtwayland \
    firefox-wayland \
    mpv \
    imv \
    nautilus \
    gnome-terminal

# Developer tools (Aurora-dx already has many, but add Hyprland-specific ones)
dnf5 install -y --setopt=install_weak_deps=False \
    neovim \
    git \
    curl \
    wget \
    unzip \
    tree \
    htop \
    btop

# Remove gaming-focused packages that might conflict (since we're moving from Bazzite base)
# Aurora doesn't have these by default, but just in case
# dnf5 remove -y steam gamescope

# Clean up - disable COPRs so they don't end up enabled on the final image
dnf5 -y copr disable solopasha/hyprland
dnf5 -y copr disable erikreider/SwayNotificationCenter  
dnf5 -y copr disable pgdev/ghostty
dnf5 -y copr disable wezfurlong/wezterm-nightly

#### System Configuration

# Configure authentication for hyprlock
echo "auth required pam_unix.so" > /etc/pam.d/hyprlock
echo "auth include system-auth" >> /etc/pam.d/hyprlock

# Enable necessary services
systemctl enable podman.socket

# Aurora uses GDM by default, but for Hyprland we might want SDDM
# Uncomment the following lines if you prefer SDDM over GDM:
# systemctl disable gdm
# systemctl enable sddm

# Ensure GDM works well with Hyprland (default for Aurora)
systemctl enable gdm

# Create directories for Nix (if using Nix package manager)
mkdir -p /nix/var/nix/gcroots/per-user

# Set up proper permissions for Hyprland
# This ensures proper functionality on Aurora base
chmod +s /usr/bin/hyprland

#### Deploy Hyprland Configuration Files

# Create skel directories for new users
mkdir -p /etc/skel/.config/hypr
mkdir -p /etc/skel/.config/waybar

# Copy Hyprland configuration files to skel so new users get them
if [ -f /ctx/hyprland-configs/hyprland.conf ]; then
    cp /ctx/hyprland-configs/hyprland.conf /etc/skel/.config/hypr/
fi

if [ -f /ctx/hyprland-configs/waybar-config.json ]; then
    cp /ctx/hyprland-configs/waybar-config.json /etc/skel/.config/waybar/config
fi

# Create a simple hyprpaper config
cat > /etc/skel/.config/hypr/hyprpaper.conf << 'EOF'
preload = ~/Pictures/wallpaper.jpg
wallpaper = ,~/Pictures/wallpaper.jpg
splash = false
EOF

# Create a simple hyprlock config
cat > /etc/skel/.config/hypr/hyprlock.conf << 'EOF'
general {
    disable_loading_bar = true
    grace = 300
    hide_cursor = true
    no_fade_in = false
}

background {
    monitor =
    path = screenshot
    blur_passes = 3
    blur_size = 8
}

input-field {
    monitor =
    size = 200, 50
    position = 0, -80
    dots_center = true
    fade_on_empty = false
    font_color = rgb(202, 211, 245)
    inner_color = rgb(91, 96, 120)
    outer_color = rgb(24, 25, 38)
    outline_thickness = 5
    placeholder_text = <span foreground="##cad3f5">Password...</span>
    shadow_passes = 2
}
EOF

# Create desktop entry for Hyprland
cat > /usr/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=A dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF
