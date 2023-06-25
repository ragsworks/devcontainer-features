<h2 align="center">

<img height="128" src="https://raw.githubusercontent.com/Ragdata/media/master/project/ragsworks/logo/ragsworks-256.png" alt="Ragdata" />

<a name="top">RagsWorks Node.js Feature</a>

</h2>

## ⚓ [OS Support](#top)

This feature should work on recent versions of:

- ✅ **Alpine**
- ✅ **Debian/Ubuntu**

Requires the following tools / utilities:

- `bash`
- `apt`

## ⚖️ [Using nvm from within LifeCycle Command](#toc)

Certain operations, like `postCreateCommand`, run non-interactive, non-login shells.  Unfortunately, `nvm` is very particular about needing to be 'sourced' before it's used, which can only happen automatically with interactive and/or login shells.  Fortunately, this is easy to work around:

We can source the `nvm` startup script before using it:

```shell
"postCreateCommand": ". ${NVM_DIR}/nvm.sh && nvm install --lts"
```

Note that typically the default shell in these cases is `sh` and not `bash`, so use `. ${NVM_DIR}/nvm.sh` instead of `source ${NVM_DIR}/nvm.sh`

Alternatively, you can start up an interactive shell which will, in turn, source `nvm`:

```shell
"postCreateCommand": "bash -i -c 'nvm install --lts'"
```

## ©️ [Copyright & Attributions](#top)

Aside from a few minor tweaks, the common-utils feature originally comes from:

[Development Container Features](https://github.com/devcontainers/features)<br />
Copyright © Microsoft Corporation. All rights reserved.<br />
Licensed under the MIT License

> "We see much further, and reach much higher,<br>
> only because we stand upon the shoulders of giants"
