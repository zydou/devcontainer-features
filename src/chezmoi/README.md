
# Chezmoi (chezmoi)

Manage your dotfiles across multiple diverse machines, securely.

## Example Usage

```json
"features": {
    "ghcr.io/zydou/devcontainer-features/chezmoi:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| username | Install chezmoi under this user. | string | automatic |
| version | chezmoi version to install | string | latest |
| dotfiles_repo | Use this dotfiles repo to initialize | string | none |
| one_shot | use `--one-shot` during init process. It is the equivalent of `--apply`, `--depth=1`, `--force`, `--purge`, and `--purge-binary`. It attempts to install your dotfiles with chezmoi and then remove all traces of chezmoi from the system. This is useful for setting up temporary environments (e.g. Docker containers). | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zydou/devcontainer-features/blob/main/src/chezmoi/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
