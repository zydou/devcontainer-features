
# Homebrew (homebrew)

Install Homebrew and custom formulas (or init with `Brewfile`).

## Example Usage

```json
"features": {
    "ghcr.io/zydou/devcontainer-features/homebrew:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| USERNAME | Install Homebrew under this user, defaults to `linuxbrew`. If you change this, you should also change `containerEnv` accordingly. | string | linuxbrew |
| SHALLOW_CLONE | Install Homebrew using shallow clone. Shallow clone allows significant reduction in the installation size at the expense of not being able to run `brew update`, which effectively means the package index will be frozen at the moment of the image creation. | boolean | true |
| FORMULAS | Formulas to install once the brew is finished. (space-delimited string) | string | none |
| BREWFILE | Use this URL to download the `Brewfile` and then `brew bundle install` this `Brewfile`. | string | none |
| HOMEBREW_BREW_GIT_REMOTE | Use this URL as the Homebrew/brew remote. | string | https://github.com/Homebrew/brew |
| HOMEBREW_CORE_GIT_REMOTE | Use this URL as the `Homebrew/homebrew-core` remote. | string | https://github.com/Homebrew/homebrew-core |
| HOMEBREW_BOTTLE_DOMAIN | Use this URL as the download mirror for bottles. If bottles at that URL are temporarily unavailable, the default bottle domain will be used as a fallback mirror. | string | https://ghcr.io/v2/homebrew/core |
| HOMEBREW_PIP_INDEX_URL  | If set, `brew install` will use this URL to download PyPI package resources. | string | https://pypi.org/simple |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zydou/devcontainer-features/blob/main/src/homebrew/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
