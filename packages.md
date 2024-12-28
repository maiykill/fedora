# Additional Packages to be installed

<!--toc:start-->
- [Additional Packages to be installed](#additional-packages-to-be-installed)
  - [Lazygit](#lazygit)
  - [Lf](#lf)
  - [Mullvad browser](#mullvad-browser)
  - [Brave browser](#brave-browser)
  - [Rpm Fusion repos](#rpm-fusion-repos)
  - [Multimedia codecs](#multimedia-codecs)
  - [Wezterm](#wezterm)
  - [Others](#others)
<!--toc:end-->

## Lazygit

```bash
sudo dnf copr enable atim/lazygit
sudo dnf install lazygit
```

## Lf

```bash
sudo dnf copr enable pennbauman/ports
sudo dnf install lf
```

## Mullvad browser

```bash
sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo
sudo dnf install mullvad-browser
```

## Brave browser

```bash
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser
```

## Zen Browser

```bash
sudo dnf copr enable firminunderscore/zen-browser
sudo dnf install zen-twilight
```

## Rpm Fusion repos

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

## Multimedia codecs

```bash
sudo dnf groupinstall multimedia
sudo dnf install intel-media-driver libva libva-utils gstreamer1-vaapi ffmpeg intel-gpu-tools mesa-dri-drivers mpv
```

## Wezterm

```bash
sudo dnf copr enable wezfurlong/wezterm-nightly
sudo dnf install wezterm
```

## Others

```bash
sudo dnf install btop mpv ffmpeg alacritty kitty chromium pcmanfm thunar nemo firefox nomacs libreoffice gimp inkscape fastfetch fastfetch-zsh-completion fastfetch-bash-completion afetch cpufetch onefetch yarnpkg 
```
