# Akamai EdgeWorkers Template

An up-to-date Akamai [EdgeWorkers] setup with [TypeScript], [ESLint], [esbuild]
and a custom build + deploy script for improved DX. 🚀

## Content

<!-- **Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)* -->
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Motivation](#motivation)
- [Features](#features)
- [Development](#development)
  - [Requirements](#requirements)
    - [Node.js Development Setup](#nodejs-development-setup)
  - [Setup](#setup)
  - [Create a new EdgeWorker](#create-a-new-edgeworker)
  - [Build and Deploy](#build-and-deploy)
  - [Other Commands](#other-commands)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Motivation

Improve DX. Provide an opinionated up-to-date starter template.

## Features

- [TypeScript] ✨
- [ESLint] and [Prettier] 🧹
- Supports multiple EdgeWorkers in one repository. 📁
- Multiple source files and external dependencies (compatible packages from npm) npm are supported,
  the bundling is done via [esbuild] (minify, tree shaking, etc.). 📦

## Development

### Requirements

> [!NOTE]  
> Currently, this guide assumes a Unix-like OS (macOS/Linux) with Bash support etc.

- [Node.js] >=20
- [npm] (comes with Node.js)
- You can follow the [Node.js Development Setup](#nodejs-development-setup) guide below.
- [Akamai CLI]
  - Install following Akamai CLI modules [EdgeWorkers CLI], [Sandbox CLI],
    optionally also [Property Manager CLI] and [CLI for Purge].
    ```bash
    # The Akamai CLI
    brew install akamai
    # required modules
    akamai install edgeworkers
    akamai install sandbox
    # optional modules
    akamai install property-mananger
    akamai install purge
    ```
- [jq] (like sed for JSON data) (`brew install jq`)

#### Node.js Development Setup

<details>
<summary>Click to expand the Node.js Development Setup</summary>

We'll install a recent version of [Node.js] using [nvm].

1. Install nvm using Git:

   ```bash
   cd ~/
   git clone https://github.com/nvm-sh/nvm.git .nvm
   cd ~/.nvm
   git checkout v0.40.3
   ```

2. Add the following at the end of your `~/.bashrc`:

   ```bash
   ###
   # nvm
   # source: https://github.com/nvm-sh/nvm#git-install
   ###
   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
   ```

3. Restart your terminal. Verify nvm works (should print something like `0.40.3`):

   ```bash
   nvm -v
   ```

4. Install the latest Node.js 20:

   ```bash
   nvm install 20.*
   ```

5. Verify Node.js is installed and active (should print something like `v20.19.4`):

   ```bash
   node -v
   ```

6. Upgrade the bundled npm:

   ```bash
   npm --global install npm
   ```

7. Check the installed npm version:
   ```bash
   npm -v
   ```

That's all!

</details>

### Setup

Clone this repository.

> [!TIP]  
> You can quickly create a copy of this repository on GitHub
> using the [Use this template][use-akamai-edgeworkers-template] feature
> (the green button located in the top-right corner of the page, next to the Star button/counter).

Then, inside the repository/project root, install the dependencies using [npm]:

```bash
npm install
```

### Create a new EdgeWorker

Either use the Akamai Control Panel or use Akamai CLI:

```bash
akamai edgeworkers create-id <group-id> <worker-name>
```

To list the all the groups you have access to, you can use [Property Manager CLI] (note that the `--section default` is
necessary because for the `property-manager` module, the section defaults to `papi`):

```bash
akamai --section default property-manager list-groups
```

Finally, create new config for the [build.sh](#build-and-deploy) script by copying
the [worker-template.json](./worker-template.json), presumably to a file named `worker-<name>.json` and fill in the
EdgeWorker ID that you got when you created the EdgeWorker though Akamai Control Panel or Akamai CLI.

### Build and Deploy

You can run build and deploy an EdgeWorker using the [build.sh](./build.sh) script,
which greatly simplifies the required steps.

```bash
./build.sh <worker-config> [command]
```

The script automatically builds, packages, and deploys the given EdgeWorker.

`<worker-config>` is a path to an extended bundle.json file with two additional fields:

- `edgeworker-id`: Akamai EdgeWorker ID (number)"
- `main`: the entrypoint (e.g.: `./src/worker.ts`), path is relative to the config file location

The `[command]` is an optional argument (defaults to `build`) that allows choosing what action to perform:

- `build` (default if not specified) – increment the version number, build (bundle) the worker's code
  (uses the `main` field that specifies the entrypoint),
  and output the final bundle to `dist/<edgeworker-id>/bundle.tgz`.
- `status` – show the current deployment status (and history) across all Akamai networks
- `open` – open the Akamai Control Panel in browser and navigate to the worker's details page
- `sandbox` – build the bundle (same as `build`) and update the worker in the default Akamai **sandbox** using the that
  bundle
- `staging` – build the bundle (same as `build`) and deploy the worker to the Akamai **staging** network in one single step
- `production` – build the bundle (same as `build`) and deploy the worker to the Akamai **production** network in one single step

### Other Commands

This section describes the available commands that you can use during the development process.

Refer to the [package.json scripts section](./package.json) to see the underlying commands.

In order to pass additional arguments to the scripts invoked using `npm run`, an extra `--` is needed, otherwise,
npm won't pass the arguments correctly.

If you want to pass different arguments, you can use the command directly (but you might need to use the full name for
the Node.js executables, e.g. `prettier` -> `./node_modules/.bin/prettier` or use `npx`).

- `npm run format` – Formats the code using [Prettier] (`prettier . --write`).

- `npm run format:check` – Checks if all the code is correctly formatted with [Prettier] (`prettier . --check`).

- `npm run lint` – Runs [ESLint]. Outputs errors to console. See [the ESLint config](./eslint.config.mjs).

- `npm run tsc` – Runs the TypeScript compiler (`tsc`) that check the types and outputs any type errors to console.

<!-- links references -->

[use-akamai-edgeworkers-template]: https://github.com/new?template_name=akamai-edgeworkers-template&template_owner=merj
[EdgeWorkers]: https://techdocs.akamai.com/edgeworkers/docs/welcome-to-edgeworkers
[nvm]: https://github.com/nvm-sh/nvm
[Node.js]: https://nodejs.org/en/
[npm]: https://www.npmjs.com/
[TypeScript]: https://www.typescriptlang.org/
[ESLint]: https://eslint.org/
[Prettier]: https://prettier.io/
[esbuild]: https://esbuild.github.io/
[GitHub flow]: https://docs.github.com/en/get-started/using-github/github-flow
[jq]: https://jqlang.org/
[Akamai CLI]: https://techdocs.akamai.com/developer/docs/cli
[EdgeWorkers CLI]: https://github.com/akamai/cli-edgeworkers
[Sandbox CLI]: https://github.com/akamai/cli-sandbox
[Property Manager CLI]: https://github.com/akamai/cli-property-manager
[CLI for Purge]: https://github.com/akamai/cli-purge
