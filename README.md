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
  - [Syntax](#syntax)
  - [Slots](#slots)
  - [Options](#options)
  - [Environment](#environment)
  - [Configuration](#configuration)
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

#### Dependencies

- [`flock`](https://www.man7.org/linux/man-pages/man1/flock.1.html)
  - `util-linux` package on Arch
  - `util-linux` package on Debian
  - `util-linux` package on openSUSE
  - `util-linux-core` package on Fedora
- [`tput`](https://www.man7.org/linux/man-pages/man1/tput.1.html)
  - `ncurses` package on Arch
  - `ncurses-bin` package on Debian
  - `ncurses-utils` package on openSUSE
  - `ncurses` package on Fedora

### Packages

[![build result](https://build.opensuse.org/projects/home:jcgl/packages/wnl/badge.svg?type=percent)](https://build.opensuse.org/package/show/home:jcgl/wnl)

Download the packages or add the openSUSE Build Service repository [here](https://software.opensuse.org//download.html?project=home%3Ajcgl&package=wnl). Current distros include:

- Arch
- Debian
- Fedora
- openSUSE
- Ubuntu

Please report any issues you may encounter with the packages!

## Usage

### Syntax

```plain
wnl [SLOT_ID] COMMAND [COMMAND_ARGUMENTS...]
wnlctl [SLOT_ID]
```

### Slots

A "slot" (specified with `SLOT_ID`) represents a single instance of `wnl`.
This allows for multiple, separate commands to be bound:

```command
# running two instances in subshells, just to keep this example concise
$ (wnl 1 echo hi from slot 1! &); (wnl 2 echo hi from slot 2! &)
$ wnlctl 1; wnlctl 2
[[ running echo hi from slot 1! at 10:12:29 in slot 1 ]]
[[ running echo hi from slot 2! at 10:12:29 in slot 2 ]]
hi from slot 1!
hi from slot 2!
[[ finished echo hi from slot 1! with exit code 0 at 10:12:29 in slot 1 ]]
[[ finished echo hi from slot 2! with exit code 0 at 10:12:29 in slot 2 ]]
```

### Options

`SLOT_ID`: Numeric identifier of the slot.
`wnl` defaults to the first unused slot (counting up from 1).
`wnlctl` defaults to slot 1.

### Environment

`SIGNAL`: Used with `wnlctl`. The signal that is sent to `wnl`. Either `USR1` to tell `wnl` to start command execution, or `USR2` to tell `wnl` to terminate execution. Defaults to `USR1`.

`DOUBLE_TAP_REQUIRED`: Used with `wnl`. If true, two signals from `wnlctl` are required before triggering `COMMAND`. Choose `true` or `false`. Defaults to `false`.

### Configuration

User configuration file: `~/.config/wnl/wnlrc`

The only interesting things to configure are hooks.
Hooks are shell snippets that are executed at various points in wnl's lifecycle:

| Name           | Description                                                                                               |
| -------------- | --------------------------------------------------------------------------------------------------------- |
| `HOOK_STARTUP` | Run once when `wnl` starts                                                                                |
| `HOOK_EXIT`    | Run once when `wnl` exits (after you hit Ctrl-c)                                                          |
| `HOOK_PRE`     | Run just before each invocation of `COMMAND`                                                              |
| `HOOK_POST`    | Run just after each invocation of `COMMAND`. The variable `EXIT_CODE` contains the command's exit status. |

Example `wnlrc`:

```bash
# Play a gentle tone whenever wnl is triggered
HOOK_PRE='pw-play /usr/share/sounds/ocean/stereo/service-logout.oga &'
# Play a an alert whenever the command run by wnl fails with a nonzero exit code
# $EXIT_CODE is set to the exit code from the now-finished command
HOOK_POST='test "$EXIT_CODE" -eq 0 || pw-play /usr/share/sounds/oxygen/stereo/message-connectivity-error.ogg &'
# ANSI color/formatting codes are available in $FMT_* variables
HOOK_EXIT='echo "$FMT_GREEN$FMT_BOLD"; cowsay thanks for using wnl; echo "$FMT_NORMAL"'
```

## Roadmap

- [x] Multiple instances ("slots")
  - [x] Automatically use first available slot if slot ID not specified
- [x] Allow sending SIGINT to command executions
- [ ] Richer controls from `wnlctl`
  - [ ] Switch from signals for IPC to e.g. JSON-RPC over named pipes or unix sockets
  - [ ] `wnlctl` can instruct `wnl` to send arbitrary signals to command executions
  - [ ] Send text to command executions' `stdin`
- [ ] Add a mode to kill-and-restart when triggering a still-running command, rather than doing nothing
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
- [x] Add a config that requires multiple, quick signals from `wnlctl` to prevent accidental/fat-fingered triggers

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
