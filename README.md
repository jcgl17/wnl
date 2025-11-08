# wnl—Wait 'n' Listen

wnl helps create a ["Unix as IDE"](https://blog.sanctum.geek.nz/series/unix-as-ide/) workflow.
You bind a frequently-run command with `wnl`, then trigger it from anywhere with `wnlctl`.
Optionally configure a hotkey in your desktop environment, and you have keyboard shortcuts for ad-hoc shell commands.

[![asciicast](https://asciinema.org/a/716085.svg)](https://asciinema.org/a/716085)

<!-- markdownlint-disable no-inline-html -->
<details>

<summary>plaintext demo</summary>

```console
# you frequently run this command,
# usually pressing up+enter to run it again and again
me@pc:~$ make test
running tests...
done
# preface that command with `wnl` to bind that command
me@pc:~$ wnl make test
# nothing happens until you trigger wnl with the `wnlctl` command,
# e.g. in another shell.
# it's useful to bind `wnlctl` to a global shortcut in your desktop environment
running tests...
done
[[ finished with exit code 0 at 13:07:25 ]]
# even after that, wnl keeps running, waiting to be triggered again
running tests...
done
[[ finished with exit code 0 at 13:08:17 ]]
```

</details>
<!-- markdownlint-enable no-inline-html -->

For example:

1. Bind a command (`COMMAND`) to `SLOT_ID` `1` in one shell with `wnl`
   (see below for explanation of slots)

    ```command
    $ wnl 1 make test
    ```

2. (repeatedly) Trigger `COMMAND` by calling `wnlctl` from another shell

    ```command
    $ wnlctl 1
    ```

   Or bind `wnlctl 1` to a keyboard shortcut within your desktop environment.

3. (optional) Interrupt `COMMAND` with `wnlctl`

    ```command
    $ SIGNAL=USR2 wnlctl 1
    ```

4. When you're done with this command, un-bind it by exiting `wnl` with `Ctrl-c`

While `COMMAND` is running, repeated calls to `wnlctl` do nothing.
When `COMMAND` is not running, `wnl` will sit and wait until `wnlctl` triggers it again.

## Contents

<!-- mtoc-start -->

- [Installation](#installation)
  - [Manual](#manual)
    - [Dependencies](#dependencies)
  - [Packages](#packages)
- [Usage](#usage)
- [Roadmap](#roadmap)
- [The problem space](#the-problem-space)
- [Example scenarios](#example-scenarios)
  - [Application deployment](#application-deployment)
  - [Applying configuration management](#applying-configuration-management)
- [Other Unix-as-IDE tools](#other-unix-as-ide-tools)

<!-- mtoc-end -->

## Installation

### Manual

Run `sudo make install` to install system-wide.

Run `make install USER_LOCAL=1` to install just to your home directory.

Uninstall with `sudo make uninstall` and `make uninstall USER_LOCAL=1` respectively.

Alternatively, you can just put these two shell scripts—`wnl` and `wnlctl`—in your `$PATH`, e.g. in `~/.local/bin`.

(`asciidoctor` is required to build the manpage, and is required for the above `make install` commands.)

#### Dependencies

- [`flock`](https://www.man7.org/linux/man-pages/man1/flock.1.html)
  - `util-linux` package on Arch
  - `util-linux` package on Debian
  - `util-linux-core` package on Fedora
  - `util-linux` package on openSUSE
- [`tput`](https://www.man7.org/linux/man-pages/man1/tput.1.html)
  - `ncurses` package on Arch
  - `ncurses-bin` package on Debian
  - `ncurses` package on Fedora
  - `ncurses-utils` package on openSUSE
- [`pgrep`](https://www.man7.org/linux/man-pages/man1/pgrep.1.html) and
  [`pkill`](https://www.man7.org/linux/man-pages/man1/pkill.1.html)
  - `procps-ng` package on Arch
  - `procps` package on Debian
  - `procps-ng` package on Fedora
  - `procps` package on openSUSE
- [`socat`](https://linux.die.net/man/1/socat)
  - `socat` package on Arch
  - `socat` package on Debian
  - `socat` package on Fedora
  - `socat` package on openSUSE

### Packages

[![build result](https://build.opensuse.org/projects/home:jcgl/packages/wnl/badge.svg?type=percent)](https://build.opensuse.org/package/show/home:jcgl/wnl)

Download the packages or add the openSUSE Build Service repository [here](https://software.opensuse.org//download.html?project=home%3Ajcgl&package=wnl). Current distros include:

- Arch
- Debian
- Fedora
- openSUSE
- Ubuntu

It's recommended to follow the instructions for "Add repository and install manually."
If instead you choose "Grab binary package directly," you'll need to install the package with your package manager, such as with `pacman -U /path/to/wnl*.pkg.tar.zst` for Arch.

Please report any issues you may encounter with the packages!

## Usage

[`wnl` manpage](share/man/wnl.1.adoc)

## Roadmap

- [x] Multiple instances ("slots")
  - [x] Automatically use first available slot if slot ID not specified
- [x] Allow sending SIGINT to command executions
- [ ] Richer controls from `wnlctl`
  - [x] Switch from signals for IPC to text over unix stream sockets
  - [ ] `wnlctl` can instruct `wnl` to send arbitrary signals to command executions
  - [ ] Send text to command executions' `stdin`
  - [ ] `wnlctl` can optionally wait for command execution to finish before returning
- [x] Add RESTART_MODE to restart a still-running command, rather than doing nothing
- [x] Emit [shell integration escape codes](https://sw.kovidgoyal.net/kitty/shell-integration/#notes-for-shell-developers) to enable skipping between command executions
- [x] Config file for things like emitting shell integration escape codes, enabling/configuring the banner emitted after a command executions finishes
- [x] Pre- and post-exec hooks
- [x] Shell completion
  - [x] Bash
  - [x] Fish
- [x] Manpage
- [x] Packages
  - [x] Arch
  - [x] Debian
  - [x] RPM
- [x] Add DOUBLE_TAP_REQUIRED to require multiple, quick signals from `wnlctl` to prevent accidental/fat-fingered triggers
- [x] Add `wnl ssh` subcommand

## The problem space

In both IDEs and Unix-as-IDE, you need to execute various tasks besides editing source code:

- run tests
- build executables
- push code

In a typical IDE, you have buttons for these functions. More critically, you have keyboard shortcuts.
Those shortcuts allow you execute those other tasks with little friction—just a brief flick of your fingers, without any need to even unfocus from your editor.

In Unix-as-IDE, what's typical is to go to a shell
(either by Ctrl-Z to background your text editor, or by switching to a window, terminal pane, etc.).
Then you run your command in the shell. Since it's probably the same command you had run in that shell before, you press Up+Enter to make it easy.

That typical Unix-as-IDE approach has the virtues of being both simple and easily composable—
it's easy to understand, and it's trivial to modify your command lines as your needs, languages, and toolchains change.

However, it lacks the extremely rapid feedback loops and reduced mental overhead that you get with IDEs' keyboard shortcuts.

## Example scenarios

### Application deployment

You are writing an application and want to frequently deploy from your workstation to a test environment.
Deployment isn't sufficiently fast/cheap/safe, so it doesn't make sense to trigger a deploy whenever you save in your editor.
Normally, you work in your text editor, and then periodically switch to a shell and deploy with `make deploy`.

To set up wnl, you bind `wnlctl` to `Ctrl-F1`, and `SIGNAL=USR2 wnlctl` to `Ctrl-Super-F1` in your desktop environment.
Then, when you start to work on your application, you run `wnl make deploy` in a shell.
At any point, you can hit `Ctrl-F1` to run your deployment, and `Ctrl-Super-F1` to abort the deployment.

### Applying configuration management

You're writing some config management code like Ansible or Terraform/OpenTofu.
Frequently, you run `terraform apply -auto-approve`.
Sometimes, you also run a diagnostic like `curl https://dev.example.com/api/healthz -ik`.

With wnl, you'd use your desktop environment to set up shortcuts for a couple different slots:

| Shortcut      | Command                | Description                                             |
| ------------- | ---------------------- | ------------------------------------------------------- |
| Ctrl-F1       | `wnlctl 1`             | Runs the commmand in slot 1 if it's not already running |
| Ctrl-Super-F1 | `SIGNAL=USR2 wnlctl 1` | Stops the command in slot 1 if it's running             |
| Ctrl-F2       | `wnlctl 2`             | Runs the commmand in slot 2 if it's not already running |
| Ctrl-Super-F2 | `SIGNAL=USR2 wnlctl 2` | Stops the command in slot 2 if it's running             |

You then run `wnl 1 terraform apply -auto-approve` in one shell, and `wnl 2 curl https://…` in another.
You can then use the configured keyboard shortcuts to trigger terraform and curl without ever leaving your editor or breaking your focus.

## Other Unix-as-IDE tools

- [`entr`](https://eradman.com/entrproject/): run arbitrary commands when files change
  This will do much of what wnl does, but automatically, based on file changes.
  Good if your tasks are suitable for automatic execution.
