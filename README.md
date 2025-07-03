# Arch

### Initial setup

```
loadkeys no
pacman -Sy git
git clone https://github.com/xwildhagen/arch.git
chmod +x arch/setup.sh
arch/setup.sh
```

### Pull changes from GitHub

```
git -C arch reset --hard && git -C arch pull
```
