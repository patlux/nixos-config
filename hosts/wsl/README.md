# wsl

## Setup

1. Setup [openssh](https://medium.com/@wuzhenquan/windows-and-wsl-2-setup-for-ssh-remote-access-013955b2f421) on wsl

- Edit `/etc/ssh/sshd_config` to allow login with root:

```
PermitRootLogin yes
```

2. Install [tailscale](https://tailscale.com/kb/1295/install-windows-wsl2)

```sh
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

3. Connect via ssh

```sh
ssh root@wsXXX
ssh-copy-id -i ~/.ssh/... root@wsXXX
```

Add to `~/.ssh/config`:

```
Host wsl
  Hostname wsXXX
  User root
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_rsa
```

4. [Install nix](https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#determinate-nix-installer)

5. Setup nixos-config

```sh
ssh wsl
cd ~/.config
git clone https://github.com/patlux/nixos-config.git
cd nixos-config
NIXNAME=wsl make
```
