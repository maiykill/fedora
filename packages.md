# Additional Packages to be installed

<!--toc:start-->
- [Additional Packages to be installed](#additional-packages-to-be-installed)
  - [Rpm Fusion repos](#rpm-fusion-repos)
  - [Multimedia codecs](#multimedia-codecs)
  - [Lazygit](#lazygit)
  - [Lf and Zellij](#lf-and-zellij)
  - [Mullvad browser](#mullvad-browser)
  - [Brave browser](#brave-browser)
  - [Zen Browser](#zen-browser)
  - [Wezterm](#wezterm)
  - [Others](#others)
<!--toc:end-->

## Rpm Fusion repos

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

## Multimedia codecs

```bash
sudo dnf groupinstall multimedia
sudo dnf install intel-media-driver libva libva-utils gstreamer1-vaapi ffmpeg intel-gpu-tools mesa-dri-drivers mpv
```

## Lazygit

```bash
sudo dnf copr enable atim/lazygit
```

## Lf and Zellij

```bash
sudo dnf copr enable pennbauman/ports
```

## Mullvad browser

```bash
sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo
```

## Brave browser

```bash
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
```

## Zen Browser

```bash
sudo dnf copr enable firminunderscore/zen-browser
```

## Wezterm

```bash
sudo dnf copr enable wezfurlong/wezterm-nightly
```

## Others

```bash
sudo dnf install fzf google-noto-fonts-common axel qbittorent neovim git fd-find ripgrep lua helix ruby yarn intel-media-driver libva libva-utils gstreamer1-vaapi ffmpeg intel-gpu-tools mesa-dri-drivers python3-secretstorage zig yt-dlp aria2 chafa btop mpv ffmpeg alacritty kitty chromium pcmanfm thunar nemo firefox nomacs libreoffice gimp inkscape fastfetch fastfetch-zsh-completion fastfetch-bash-completion afetch cpufetch onefetch yarnpkg zathura zathura-pdf-mupdf zathura-zsh-completion zathura-bash-completion zathura-cb zathura-djvu zathura-ps virtualenv prename perl-core wavemon skim eza zellij lazygit wezterm mullvad-browser brave-browser zen-twilight lf dnf-plugins-core bat zoxide
```
