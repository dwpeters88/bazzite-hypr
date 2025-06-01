# Aurora-Hyprland

# Purpose

This repository builds a custom Universal Blue image based on **Aurora-DX-Nvidia** with **Hyprland** window manager pre-configured. This image combines:

- **Aurora-DX-Nvidia**: Developer-focused desktop with NVIDIA drivers, developer tools, and container workflows
- **Hyprland**: Modern, dynamic tiling Wayland compositor with smooth animations and excellent performance
- **Pre-configured ecosystem**: Waybar, wofi, hyprlock, and other essential Wayland tools

Perfect for developers who want the reliability of Aurora with the power and customization of Hyprland.

## Features

### From Aurora-DX-Nvidia Base:
- Pre-installed NVIDIA drivers (proprietary)
- Full developer toolchain (containers, IDEs, languages)
- Aurora's curated application set
- Automatic updates via bootc
- Container-first workflows

### Added Hyprland Ecosystem:
- **Hyprland**: Dynamic tiling Wayland compositor
- **Waybar**: Highly customizable status bar
- **wofi/rofi**: Application launchers
- **hyprlock**: Screen locker
- **hyprpaper**: Wallpaper utility
- **SwayNotificationCenter**: Notification daemon
- **grim/slurp**: Screenshot tools
- **wl-clipboard**: Wayland clipboard utilities

### Developer Tools:
- **Ghostty**: Modern terminal emulator
- **WezTerm**: Feature-rich terminal
- **Neovim**: Advanced text editor
- **Git**: Version control
- **Multiple terminal options**: gnome-terminal, ghostty, wezterm

## Prerequisites

Working knowledge in the following topics:

- Containers and Containerfiles
- bootc and Fedora Atomic systems
- Basic Hyprland configuration
- Git workflows

## Installation

### Option 1: Use Pre-built ISO
1. Download the latest ISO from the [Releases page](releases) or GitHub Actions artifacts
2. Flash to USB drive using Ventoy, Rufus, or `dd`
3. Boot and install normally
4. The system will come with Hyprland pre-configured

### Option 2: Rebase from Existing Universal Blue Installation
If you're already running Aurora, Bluefin, or another Universal Blue image:

```bash
# Replace YOUR_GITHUB_USERNAME with the actual username
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/YOUR_GITHUB_USERNAME/aurora-hyprland:latest
systemctl reboot
```

## Usage

### First Boot
1. Log in to your account
2. At the login screen, select "Hyprland" from the session menu
3. The system will start with a pre-configured Hyprland setup

### Key Bindings (Default)
- **Super + Q**: Open terminal (Ghostty)
- **Super + E**: File manager (Nautilus)
- **Super + R**: Application launcher (wofi)
- **Super + C**: Close window
- **Super + V**: Toggle floating mode
- **Super + F**: Fullscreen
- **Super + L**: Lock screen
- **Super + 1-9**: Switch workspaces
- **Super + Shift + 1-9**: Move window to workspace

### Customization
Configuration files are located in `~/.config/hypr/`. The setup includes:
- `hyprland.conf`: Main Hyprland configuration
- `hyprpaper.conf`: Wallpaper settings
- `hyprlock.conf`: Lock screen appearance
- `~/.config/waybar/config`: Status bar configuration

## Building Your Own

### Using the GitHub Workflow (Recommended)
1. Fork this repository
2. Update `iso.toml` with your GitHub username
3. Enable GitHub Actions in your fork
4. Push changes to trigger a build
5. Download the ISO from Actions artifacts

### Local Building with Just

This project uses [just](https://github.com/casey/just) for task automation:

```bash
# Install just on Fedora
sudo dnf5 install just

# Build the container image locally
just build

# Build an ISO locally
just build-iso

# Build and test in a VM
just build-qcow2
just run-vm-qcow2
```

### Manual Building

```bash
# Build the container image
podman build -t aurora-hyprland .

# Test the image
podman run --rm -it aurora-hyprland /bin/bash
```

## Workflows

### build.yml
Builds the custom OCI image and publishes it to GitHub Container Registry (GHCR).

### build-iso.yml  
Generates a bootable ISO from your custom image using bootc-image-builder.

## Container Signing

This image uses sigstore for container signing. The signing is handled automatically by GitHub Actions using the `SIGNING_SECRET` repository secret.

## Configuration Files

### Environment Variables
The image sets appropriate environment variables for NVIDIA + Wayland:
- `LIBVA_DRIVER_NAME=nvidia`
- `GBM_BACKEND=nvidia-drm`
- `__GLX_VENDOR_LIBRARY_NAME=nvidia`
- `WLR_NO_HARDWARE_CURSORS=1`

### Display Manager
By default, the image uses GDM (Aurora's default) with Hyprland available as a session option. To switch to SDDM, uncomment the relevant lines in `build_files/build.sh`.

## Troubleshooting

### NVIDIA Issues
- Ensure you're using the `-nvidia` variant of Aurora
- Check that NVIDIA drivers are loaded: `lsmod | grep nvidia`
- Verify environment variables are set correctly

### Hyprland Issues
- Check logs: `journalctl --user -u hyprland`
- Verify configuration: `hyprctl info`
- Test configuration syntax: `hyprland --check`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `just build`
5. Submit a pull request

## Related Projects

- [Aurora](https://getaurora.dev/) - The base operating system
- [Universal Blue](https://universal-blue.org/) - Cloud-native OS builder
- [Hyprland](https://hyprland.org/) - The window manager

## License

Apache 2.0 - see LICENSE file for details.
