# Configuration related to the Packages

<!--toc:start-->
- [Configuration related to the Packages](#configuration-related-to-the-packages)
  - [Additional Configuration as Flags](#additional-configuration-as-flags)
    - [Brave](#brave)
    - [Chromium browser](#chromium-browser)
  - [Additional Packages to be installed](#additional-packages-to-be-installed)
    - [Rpm Fusion repos](#rpm-fusion-repos)
    - [Multimedia codecs](#multimedia-codecs)
    - [Lazygit](#lazygit)
    - [Lf and Zellij](#lf-and-zellij)
    - [Brave browser](#brave-browser)
    - [Zen Browser](#zen-browser)
    - [Wezterm](#wezterm)
    - [Floorp browser](#floorp-browser)
    - [LibreWolf](#librewolf)
    - [Others](#others)
<!--toc:end-->

## Additional Configuration as Flags

### Brave

this following supports the **Open Gl** based hardware decoding

```bash
brave-browser  --enable-features=AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL --disable-features=UseChromeOSDirectVideoDecoder,UseSkiaRenderer
```

### Chromium browser

this uses the **Vulkan** for hardware acceleration

```bash
chromium-browser  --use-angle=vulkan --enable-zero-copy--enable-gpu-rasterization --enable-features=Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,UseMultiPlaneFormatForHardwareVideo,AcceleratedVideoDecodeLinuxZeroCopyGL
```

## Additional Packages to be installed

### Rpm Fusion repos

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### Multimedia codecs

```bash
sudo dnf groupinstall multimedia
sudo dnf install intel-media-driver libva libva-utils gstreamer1-vaapi ffmpeg intel-gpu-tools mesa-dri-drivers mpv
```

### Lazygit

```bash
sudo dnf copr enable atim/lazygit
```

### Lf and Zellij

```bash
sudo dnf copr enable pennbauman/ports
```

### Brave browser

```bash
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
```

### Zen Browser

```bash
sudo dnf copr enable firminunderscore/zen-browser
```

### Wezterm

```bash
sudo dnf copr enable wezfurlong/wezterm-nightly
```

### Floorp browser

```bash
sudo dnf copr enable sneexy/floorp
```

### LibreWolf

```bash
curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
```

### Others

```bash
sudo dnf install fzf google-noto-fonts-common axel qbittorent neovim git fd-find ripgrep lua helix ruby yarn intel-media-driver libva libva-utils gstreamer1-vaapi ffmpeg intel-gpu-tools mesa-dri-drivers python3-secretstorage zig yt-dlp aria2 chafa btop mpv ffmpeg alacritty kitty chromium pcmanfm thunar firefox nomacs libreoffice gimp inkscape fastfetch fastfetch-zsh-completion fastfetch-bash-completion afetch cpufetch onefetch yarnpkg zathura zathura-pdf-mupdf zathura-zsh-completion zathura-bash-completion zathura-cb zathura-djvu zathura-ps virtualenv prename perl-core wavemon skim eza zellij lazygit wezterm brave-browser zen-twilight lf perl-File-MimeInfo dnf-plugins-core bat zoxide python3-neovim python3-devel golang xdotool wmctrl pypy3 groff floorp uv duf cheat cmatrix R lm_sensors hwinfo inxi lightdm-gtk-greeter-settings perl-Image-ExifTool scrot librewolf sudo-rs opendoas rofi dmenu awesome brightnessctl dunst xinput
```
