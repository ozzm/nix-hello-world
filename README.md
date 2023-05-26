### Build a Rust application using Nix Flakes

Generate a docker image using Nix flakes as well as as the binary.

Install the following pre-requisites

Ensure nix, docker in installed and flakes are enabled,then

```shell
$ nix profile nixpkgs#direnv
$ nix profile github:serokell/nixfmt

```

### Automatically load nix enviroment
In the root of the project run:
```shell
$ echo "use flake" >> .envrc
$ direnv allow
```
###  Generate cargo lock file

```shell
$ cargo generate-lock-file
```
### To enter the nix shell

Bash is the default nix shell

```shell
$ nix develop
```
### Build the binary

```shell
$ nix build && nix run
```

### Build, Load and tag the docker image

nix build produces a tarball that can be imported into Docker, but as a symlink to a store path, rendering it unusable outside the Nix container.
You should copy the actual file out of the container  and load it into Docker.
See the `load-docker` file.

Run this shell file to build the docker image, tag it and load it in docker

```shell
$ ./load-docker
```

**Run the image**

Exit `nix-shell` then,

```shell
$ docker run nix-docker-hello:latest
```

### References
- https://blog.sekun.net/posts/create-rust-binaries-and-docker-images-with-nix/
- https://ayats.org/blog/nix-rustup/
- https://johns.codes/blog/rust-enviorment-and-docker-build-with-nix-flakes

