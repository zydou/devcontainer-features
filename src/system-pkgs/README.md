
# Install system packages (system-pkgs)

Install system packages from package manager

## Example Usage

```json
"features": {
    "ghcr.io/zydou/devcontainer-features/system-pkgs:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| pkgs | Packges to install.(space-delimited string) | string | git |
| nonFreePackages | Add packages from non-free Debian repository? (Debian only) | boolean | false |
| upgradePackages | Upgrade OS packages? | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zydou/devcontainer-features/blob/main/src/system-pkgs/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
