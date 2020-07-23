# VSCode Python Development Boilerplate
## Using the remote-containers plugin
### Centos 8 as the base dev image
In order to use, simply launch VSCode with the [`ms-vscode-remote.remote-containers`](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) plugin.
Once you clone your repository, initialized from this repository, open vscode from the path you cloned it to
```bash
user@host:/path/to/repo$ code .
```
and it will automatically prompt you to launch in a container (assuming you have docker installed).