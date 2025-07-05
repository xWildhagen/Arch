# Arch

## Initial setup

### SSH

```
passwd
ssh root@IP
```

### Installation

```
loadkeys no
pacman -Sy git archinstall
git clone https://github.com/xwildhagen/arch.git
chmod +x arch/main.sh
arch/main.sh
```

## Stuff

### Pull changes from GitHub

```
git -C arch reset --hard
git -C arch pull
```
