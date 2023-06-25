<h2 align="center">

<img height="128" src="https://raw.githubusercontent.com/Ragdata/media/master/project/ragsworks/logo/ragsworks-256.png" alt="Ragdata" />

<a name="top">RagsWorks Common Utilities Feature</a>

</h2>

## ⚓ [OS Support](#top)

This feature should work on recent versions of:

 - ✅ **Alpine**
 - ✅ **Debian/Ubuntu**

## ⚠️ [Caution](#top)

This feature is used in many of the containers published by RagsWorks.  Attempting to add this feature to a container which already makes use of it will result in an error. 

## ♻️ [Customising the Command Prompt](#top)

By default, this script provides a custom command prompt which includes information about the git repository for the current folder.  However, with certain large repositories, this can result in poor performance due to the required git operation.

So, for performance reasons, the "dirty" indicator tells you whether or not there are uncommitted changes is disabled by default.  You can opt to turn this on for smaller repositories by entering the following in a terminal or adding it to your `postCreateCommand`:

```shell
git config devcontainers-theme.show-dirty 1
```

To completely disable the git portion of the prompt for the current folder's repository, you can use this config instead:

```shell
git config devcontainers-theme.hide-status 1
```

For `zsh`, the default is a [standard 'Oh My Zsh!' theme](https://ohmyz.sh/).  You may pick a different one by modifying the `ZSH_THEME` variable in `~/.zshrc`.

## ©️ [Copyright & Attributions](#top)

Aside from a few minor tweaks, the common-utils feature originally comes from:

[Development Container Features](https://github.com/devcontainers/features)<br />
Copyright © Microsoft Corporation. All rights reserved.<br />
Licensed under the MIT License

> "We see much further, and reach much higher,<br>
> only because we stand upon the shoulders of giants"
