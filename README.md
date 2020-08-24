# Pharo

This repository contains sources of the [Pharo language](http://pharo.org/). Pharo is a pure object-oriented programming language and a powerful environment, focused on simplicity and immediate feedback (think IDE and OS rolled into one).

![Pharo 6 screenshot](https://pbs.twimg.com/media/DBpdIGrXkAA8SJ1.jpg)

## Download Pharo

To download the Pharo stable version for your platform, please visit:

- [http://pharo.org/download](http://pharo.org/download)

## Virtual machine

This repository contains only sources of the Pharo image. The virtual machine source code is managed in a separate repository:

- [https://github.com/pharo-project/opensmalltalk-vm](https://github.com/pharo-project/opensmalltalk-vm)

## Automated Builds

This repository is being built on a [Jenkins server](https://ci.inria.fr/pharo-ci-jenkins2) and uploaded to [files.pharo.org](https://files.pharo.org).

- [Latest build - 64bit](http://files.pharo.org/image/80/latest-64.zip)
- [Latest build - 32bit](http://files.pharo.org/image/80/latest.zip)

The minimal image contains the basic Pharo packages without the graphical user interface. It is useful as a base for server-side applications deployment.

- [Minimal image latest build - 64bit](http://files.pharo.org/image/80/latest-minimal-64.zip)
- [Minimal image latest build - 32bit](http://files.pharo.org/image/80/latest-minimal-32.zip)


## Bootstrapping Pharo from sources

To bootstrap a new Pharo image you need the latest stable version of Pharo. For more information about bootstrapping, refer to [guillep/PharoBootstrap](https://github.com/guillep/PharoBootstrap).

The bootstrapping can be done on a properly-named branch using the following script:

```
BUILD_NUMBER=42 BOOTSTRAP_ARCH=32 bash ./bootstrap/scripts/bootstrap.sh
```

This will generate and archive images at various stages of the bootstrap process up to the full image in Pharo8.0-32bit-hhhhhhh.zip where hhhhhhh is the hash of the current checkout.

Additional information on the stages of the bootstrap and how to snapshot during the process are provided as comments in bootstrap.sh.

__Tip:__ You can set `BOOTSTRAP_REPOSITORY` and `BOOTSTRAP_CACHE` environment variables to do the bootstrap outside of the source repository.

__Note:__ If you are on a branch that doesn't follow the expected naming convention ('`PharoX.Y`'), then the script will pick an appropriate default (such as `Pharo7.0`). To build Pharo8.0 from a custom branch, you need to set `BRANCH_NAME=Pharo8.0` before the bootstrap script is run.

### Bootstrapping with docker

You can also use docker if you prefer to control the bootstrapping environment completely. In the root directory of this project cloned from git, do

```
docker run --rm -it -v $(pwd)/:/src --workdir /src ubuntu:20.04 bash
```

In this container, you'll have to do some setup.

Bootstrapping requires the use of a 32-bit Smalltalk VM, hence we need 32-bit libraries

```
dpkg --add-architecture i386
apt update
```

You'll need these libraries/programs for the bootstrapping process

```
apt install -y build-essential git wget zip unzip libc6:i386 zlib1g:i386 libfreetype6:i386
```

## File format

This source code repository is exported in [Tonel format](https://github.com/pharo-vcs/tonel). In this format, packages are represented as directories and each class is inside a single file.

## How to contribute

Pharo is an opensource project very friendly to contributions of the users. See the document [CONTRIBUTING](CONTRIBUTING.md) how you can help to improve Pharo.


## Pharo friendly links and organisations

[http://github.com/Pharo-project/PharoMap](http://github.com/Pharo-project/PharoMap)
