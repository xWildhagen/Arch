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
pacman -Sy git
git clone https://github.com/xwildhagen/arch.git
archinstall --config arch/user_configuration.json --creds arch/user_credentials.json
```

## Stuff

### Pull changes from GitHub

```
git -C arch reset --hard
git -C arch pull
```
