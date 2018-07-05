# SSH tool

It is a very useful tool that allows for getting inside a container in a running pipeline via SSH. The tool makes use of [ngrok utility](https://ngrok.com/) and takes your public SSH key to setup SSH connection for you.

## Usage:

Just run this command inside a **freestyle** step providing it with the **required environment variables**:

For Debian/Ubuntu based images (curl must be installed before):

```
FreestyleUbuntu:
    image: ubuntu-debootstrap
    commands:
      - apt-get update && apt-get install curl -y
      - curl https://raw.githubusercontent.com/alex-codefresh/debug-tools/master/ssh_tool/getIn.sh | /bin/bash
```

or in case of Alpine based images you could use wget, which is already present:

```
FreestyleAlpine:
    image: alpine
    commands:
       - wget -O - https://raw.githubusercontent.com/alex-codefresh/debug-tools/master/ssh_tool/getIn.sh | /bin/sh
```

The tunnel will be up until you terminate the build

## Environment variables:

You need to set 2 environment variables for your pipeline:

**$NGROK_TOKEN** - this is the ngrok authentication token. To get it you should register on their site and proceed to this page: [https://dashboard.ngrok.com/auth](https://dashboard.ngrok.com/auth)

**$PUBL_KEY** - this is a **base64** hash of your **public SSH key**. You can retrieve it by running such command in your terminal:

`cat ~/.ssh/id_rsa.pub | base64 | tr -d '\n'`

## Requirements

- Only images that are based on **Alpine** or **Debina/Ubuntu** Linux distributions
- **curl** or **wget** must be present in the image or installed before running the script
- A free [ngrok](https://dashboard.ngrok.com/user/signup) account. Note that only **one simultaneous connection** is allowed per free ngrok account, so don't forget to terminate the build when you are finished with troubleshooting
