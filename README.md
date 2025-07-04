# Arch

## Initial setup

### SSH

```
passwd
ssh root@IP
```

### Install

```
loadkeys no
pacman -Sy git
git clone https://github.com/xwildhagen/arch.git
archinstall --config arch/user_configuration.json --creds arch/user_credentials.json
```

### Post-installation (chroot)

```
cd /home/wildhagen
git clone https://github.com/xwildhagen/arch.git
chown -R 1000:1000 arch
```

## Stuff

### Pull changes from GitHub

```
git -C arch reset --hard
git -C arch pull
```
