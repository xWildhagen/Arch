# Arch

### Initial setup

```
sudo loadkeys no
pacman -Sy git
git clone https://github.com/xwildhagen/arch.git
sudo chmod +x arch/setup.sh
sudo arch/setup.sh
```

### Pull changes from GitHub

```
git -C nixos reset --hard && git -C nixos pull
```
