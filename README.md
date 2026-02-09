# Installing base OS

The base OS image is configured in the `bootc-rhel` folder. It's built automatically via an GHA workflow.

With the base image built, we can use the `bootc-image-builder` container to build a bootc image with our custom configuration. The builder container needs access to the base image, so make sure to log in to the registry with `podman login` before running the builder.

```shell
 sudo podman run \
 --rm \
 -it \
 --privileged \
 --security-opt label=type:unconfined_t \
 -v ./config.toml:/config.toml:ro \
 -v ./output:/output \
 -v /var/lib/containers/storage:/var/lib/containers/storage \
 quay.io/centos-bootc/bootc-image-builder:latest \
 --type anaconda-iso \
 --use-librepo=True \
 ghcr.io/bpinto/homelab:latest
```
