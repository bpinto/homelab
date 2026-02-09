# redhat-image-mode-actions

## Project for Github Actions based builds of bootc images.

This project provides a Containerfile and workflow for building RHEL bootc images. The workflow can be triggered in two ways:

- **Manually**: Through the GitHub Actions interface (workflow_dispatch)
- **Automatically**: When changes are made to files within the `bootc-rhel/` folder

Manual triggers will set one of the tags to the branch name, which may overwrite older manual builds.

## Using Red Hat accounts

For RHEL, this template uses an _activation key_ to get access to a subscription and a _service account_ to get access to the terms based registry images. These are secrets defined within the repo settings.

## Accessing a subscription during build

To use packages from the RHEL repositories, the GHA runner will need to have subscription information available. This workflow will register the build container, execute the build, and then unregister as a final step. You will only be using the subscription for the duration of the build. To use `subscription-manager` in a pipeline like this, it's easiest to use an activation key. If you don't have a subscription already, the [No-cost RHEL for developers subscription](https://developers.redhat.com/products/rhel/download) is a good option.

If you aren't familiar with activation keys, from the docs:

> An activation key is a preshared authentication token that enables authorized users to register and auto-configure systems. Running a registration command with an activation key and organization ID combination, instead of a username and password combination, increases security and facilitates automation.

[Creating an activation key in the console](https://docs.redhat.com/en/documentation/subscription_central/1-latest/html/getting_started_with_activation_keys_on_the_hybrid_cloud_console/assembly-creating-managing-activation-keys#proc-creating-act-keys-console_)

### Activation key secrets

To use this template, the following two secrets need to be created as _Actions secrets and variables_ with the appropriate values:

- _RHT_ORGID_ stores the Red Hat Subscription Manager Organization ID
- _RHT_ACT_KEY_ stores the Red Hat Subscription Manager Activation Key

## Getting access to the base image

Unlike UBI, the bootc base image does require an account to access since this is a full RHEL host. To log into the registry during a pipeline build or other automation, you can [create a registry service account](https://access.redhat.com/RegistryAuthentication#registry-service-accounts-for-shared-environments-4) in the customer portal.

### Token secrets

To use this template, the following two secrets need to be created as _Actions secrets and variables_ with the appropriate values:

- _SOURCE_REGISTRY_USER_ stores the token username (has a "|" character in the name)
- _SOURCE_REGISTRY_PASSWORD_ stores the token password
