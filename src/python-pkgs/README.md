
# Install pip (or pipx) packages (python-pkgs)

Install custom packages via pip or pipx

## Example Usage

```json
"features": {
    "ghcr.io/zydou/devcontainer-features/python-pkgs:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| pipx_utils | Pipx tools to install.(space-delimited string) | string | pipx |
| pip_pkgs | Pip packages to install.(space-delimited string) | string | none |

## Customizations

### VS Code Extensions

- `ms-python.python`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zydou/devcontainer-features/blob/main/src/python-pkgs/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
