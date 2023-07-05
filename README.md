# Godot CICD Template
Template for Godot builds published to [itch.io](https://itch.io/)

### The Workflows

Github workflow actions are used to build and publish Godot projects to [itch.io](https://itch.io/):
* [godot-ci](https://github.com/abarichello/godot-ci) builds the actual Godot projects.
* [butler-push](https://github.com/marketplace/actions/butler-push) pushes the builds to [itch.io](https://itch.io/)
    * [Butler](https://itch.io/docs/butler/) is a CLI tool used to upload builds to [itch.io](https://itch.io/)

### Github Secrets
The following secrets are shared to all public repos in the `GameJamFam` Github Org.

| Name | Description |
| -----|-------------|
| ITCH_USER | The [itch.io](https://itch.io/) user. In this case `gamejamfam` |
| BUTLER_CREDENTIALS | The creds needed to publish via [Butler](https://itch.io/docs/butler/) |

# Getting Started

> [godot-ci](https://github.com/abarichello/godot-ci) supports builds for Windows, Mac, Linux, HTML5, and Android. Check thier docs for details and issues.

## Create the Github repo

> Check out the [cicd-tests](https://github.com/GameJamFam/cicd-tests) repo for a live example. You can view the [published project here](https://gamejamfam.itch.io/test-project) using the password `bitchjustshowmetheproject`

1. Create a new repo for the project on Github
    * Check `Add a README file`
    * Choose `Apache License 2.0`
2. Copy the `godot-project-dir` to your new repo and rename it for your game (avoid spaces)
3. Place entire Godot project inside the game directory

NOTE: If you replace the default `godot-project-dir/.gitignore` file, ensure you _are not_ ignoring `export_presets.cfg`

Example dir/file structure:
```
 - github-repo/
 | - my-game/
 | - LICENSE 
 | - README.md
```

## Add the workflow template

> The Butler credentials and itch.io user are provided

1. Copy the `.github` directory into your new repo
2. Update the `.github/workflows/godot-ci.yaml` file
    * Change `EXPORT_NAME` to match the dir with your Godot project files (`my-game` in the example above)
    * Remove any unwanted build configs `jobs` (e.g., if you only want a web build, remove all job configs except `export-web`)
    * Change all instances of `GAME_NAME_HERE` to the name of the project on [itch.io](https://itch.io/)

## Create the itch.io project

> The pusblishing tool only published to existing [itch.io](https://itch.io/) projects. You must first setup the project directly on [itch.io](https://itch.io/).

1. Login to [itch.io](https://itch.io/)
2. Select `Upload new project` From the profile dropdown on the top-right
3. Create the thing

### HTML5 playable deployments on itch.io

For HTML5 uploads to be playable, you have to modify settings directly for the [itch.io](https://itch.io/) project. See official docs for more details - https://itch.io/docs/butler/pushing.html#html--playable-in-browser-games

1. Login to [itch.io](https://itch.io/)
2. Open your project's edit page
3. Change `Kind of project` to `HTML`
4. Ensure the `This file will be played in the browser` is checked for the `<my-project>-web.zip` upload if multiple builds exist (e.g., Web, Windows, Mac, etc..)
5. Add the tag `'HTML5 / Playable in browser`

### Windows, Mac, Linux

> `TODO:` add instructions for OS builds.




