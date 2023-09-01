
# Set up username and UID:GID (set-user)

Set up a non-root user with UID and GID

## Example Usage

```json
"features": {
    "ghcr.io/zydou/devcontainer-features/set-user:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| username | Enter name of non-root user to configure or none to skip | string | automatic |
| uid | Enter uid for non-root user | string | automatic |
| gid | Enter gid for non-root user | string | automatic |
| debug | Enable detailed logging of this feature | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zydou/devcontainer-features/blob/main/src/set-user/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
