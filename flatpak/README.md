# Building the Flatpak locally

To build the Flatpak for this application locally, you need to have `flatpak` and `flatpak-builder` installed. You also need `flatpak-node-generator`, which can be installed with `pipx`:

```bash
pipx install flatpak-node-generator
```

Before building, you need to generate the sources for the node modules. Run this command from the root of the repository:

```bash
flatpak-node-generator npm package-lock.json
```

This will create a `generated-sources.json` file and a `flatpak-node` directory in the root of the repository.

Now you can build the Flatpak. To build for your native architecture, run this command from the root of the repository:

```bash
# Build locally (no FLATHub dependencies)
flatpak-builder --repo=_repo --force-clean _build flatpak/dev.mukkematti.qobuz-linux.yml --user

# Or build with FLATHub deps
flatpak-builder --verbose --user --disable-rofiles-fuse --install-deps-from=flathub --force-clean --repo=repo _build flatpak/dev.mukkematti.qobuz-linux.yml
```

To build for a specific architecture, use the `--arch` flag:

```bash
# For x86_64
flatpak-builder --arch=x86_64 --verbose --user --disable-rofiles-fuse --install-deps-from=flathub --force-clean --repo=repo _build flatpak/dev.mukkematti.qobuz-linux.yml

# For aarch64
flatpak-builder --arch=aarch64 --verbose --user --disable-rofiles-fuse --install-deps-from=flathub --force-clean --repo=repo _build flatpak/dev.mukkematti.qobuz-linux.yml
```

To create a bundle file for distribution:

```bash
# From the repo directory containing your .flatpak file
cd repo
flatpak build-bundle ./qobuz-linux.flatpak dev.mukkematti.qobuz-linux qobuz-linux.flatpak

# Or from the root
flatpak build-bundle _repo qobuz-linux.flatpak dev.mukkematti.qobuz-linux
```

To install the built Flatpak:

```bash
# From _repo directory (local installation)
cd ~/git/qobuz-linux/_repo
flatpak install -y dev.mukkematti.qobuz-linux.flatpak

# Or from bundle file
flatpak install qobuz-linux.flatpak
```

To run after installation:

```bash
flatpak run dev.mukkematti.qobuz-linux
```

**Quick build for local testing:**
```bash
cd ~/git/qobuz-linux
flatpak-builder --repo=_repo --force-clean _build flatpak/dev.mukkematti.qobuz-linux.yml --user
# This creates ~/git/qobuz-linux/_repo/dev.mukkematti.qobuz-linux.flatpak automatically

# Install and run
cd ~/git/qobuz-linux/_repo && flatpak install -y dev.mukkematti.qobuz-linux.flatpak
flatpak run dev.mukkematti.qobuz-linux
```

**Build for distribution (bundle):**
```bash
cd ~/git/qobuz-linux
flatpak-builder --repo=_repo --force-clean _build flatpak/dev.mukkematti.qobuz-linux.yml --user
# Wait for build to complete (~5 minutes)
flatpak build-bundle _repo qobuz-linux.flatpak dev.mukkematti.qobuz-linux
```
