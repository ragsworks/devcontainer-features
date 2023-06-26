<h2 align="center">

<img height="128" src="https://raw.githubusercontent.com/Ragdata/media/master/project/ragsworks/logo/ragsworks-256.png" alt="Ragdata" />

<a name="top">RagsWorks SSHD Feature</a>

</h2>

## ⚓ [OS Support](#top)

This feature should work on recent versions of:

- ✅ **Alpine**
- ✅ **Debian/Ubuntu**

Requires the following tools / utilities:

- `bash`
- `apt`

## 📂 [Usage](#top)

While some services automate SSH setup (eg: when using the GitHub CLI for GitHub Codespaces), this may not be the case for other tools and services.  Follow these directions to connect to the DevContainer from these other tools:

1. Connect your DevContainer using a desktop tool or CLI that supports the DevContainer Spec (eg: VSCode Client)


2. The first time you start the container, you will want to set a password for your user.  If running as a user other than root, and you have `sudo` installed:

```shell
sudo passwd $(whoami)
```

or, if you're running as root:

```shell
passwd
```

3. Forward the SSH port (2222 by default) to your local machine using either the `forwardPorts` property in `devcontainer.json` or the user interface in your chosen tool (eg: you can press <kbd>F1</kbd> or <kbd>Ctrl / Cmd</kbd> + <kbd>shift</kbd> + <kbd>P</kbd> and select **Ports: Focus on Ports View** in VSCode to bring it into focus)


4. Use a **local terminal** (or other tool) to connect to it using the command and password from step 2 - eg:

```shell
ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null vscode@localhost
```

   ... where `vscode` above is the user you are running as in the container and `2222` after `P` is the **local address port** from step 2

   The "-o" arguments are optional, but will prevent you from getting warnings or errors about known hosts when you do this from multiple containers/codespaces

5. Next time you connect to your container, just repeat steps 3 and 4 and use the same password you used in step 2.


### [Using SSHFS](#top)

[SSHFS](https://en.wikipedia.org/wiki/SSHFS) allows you to mount a remote filesystem to your local machine using nothing but a SSH connection!  Here's how to do it with a DevContainer:

1. Follow the steps in the previous section to ensure you can connect to the container using a standard `ssh` client.\


2. Install a SSHFS Client:

	- **Windows**: Install [WinFSP](https://github.com/billziss-gh/winfsp/releases) and [SSHFS-Win](https://github.com/billziss-gh/sshfs-win/releases)
  - **MacOS**: Use [Homebrew](https://brew.sh/) to install: `brew install macfuse gromgit/fuse/sshfs-mac`
  - **Linux**: Use your native package-manager to install your distro's version of the sshfs package - eg: `sudo apt update && sudo apt install sshfs`

3. Mount the remote filesystem:

	- **Windows**: Press **Windows+R** and enter the following in the "Open" field in the run dialog.

  ```shell
  \\sshfs.r\vscode@localhost!2222\workspaces
  ```

... where `vscode` above is the user you are running as in the container and 2222 after the `!` is the same local port you used in the `ssh` command in the previous section.

  - **MacOS / Linux**: Use the `sshfs` command to mount the remote filesystem.  The arguments are similar to the standard `ssh` command, with a few extras.  For example:

```shell
mkdir -p ~/sshfs/devcontainer
sshfs "vscode@localhost:/workspaces" "$HOME/sshfs/devcontainer" -p 2222 -o follow_symlinks -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -C
```

  ... where `vscode` above is the user you are running as in the container (eg: `codespace`, `vscode`, `node`, or `root`) and `2222` after the `-p` is the same local port you used in the `ssh` command in step 1.

4. Your DevContainer's filesystem should now be available in the `~/sshfs/devcontainer` folder on MacOS or Linux or in a new explorer window on Windows. 


## ©️ [Copyright & Attributions](#top)

Aside from a few minor tweaks, the common-utils feature originally comes from:

[Development Container Features](https://github.com/devcontainers/features)<br />
Copyright © Microsoft Corporation. All rights reserved.<br />
Licensed under the MIT License

> "We see much further, and reach much higher,<br>
> only because we stand upon the shoulders of giants"
