# `wnl`—Wait 'n' Listen

This tool facilitates ["Unix as IDE"](https://blog.sanctum.geek.nz/series/unix-as-ide/) workflows.
It enables easy execution/automation of ad-hoc tasks. For example, you can bind those tasks to keyboard shortcuts.

If you have a command you want to be able to trigger again and again, preface the command with 'wnl':

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
# preface that command with `wnl` to have wnl to be told to trigger it
me@pc:~$ wnl make test
# nothing happens until you trigger wnl with the `wnlctl` command,
# e.g. in another shell.
# it's best to bind `wnlctl` to a global shortcut in your Desktop Environment
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

## Contents

<!-- mtoc-start -->

- [Installation](#installation)
  - [Manual](#manual)
    - [Dependencies](#dependencies)
  - [Packages](#packages)
- [Features](#features)
  - [Multiple instances—slots](#multiple-instancesslots)
  - [Stopping program execution](#stopping-program-execution)
  - [User configuration](#user-configuration)
- [Roadmap](#roadmap)
- [The problem space](#the-problem-space)
- [Example scenarios](#example-scenarios)
  - [Application deployment](#application-deployment)
  - [Applying configuration management](#applying-configuration-management)
- [Other Unix-as-IDE tools](#other-unix-as-ide-tools)

<!-- mtoc-end -->

## Installation

### Manual

Put these two shell scripts—`wnl` and `wnlctl`—in your `$PATH`, e.g. in `~/.local/bin`.

Optionally, copy shell completion files and the manpage to their respective directories.

#### Dependencies

- [`flock`](https://www.man7.org/linux/man-pages/man1/flock.1.html)
  - `util-linux` package on Arch
  - `util-linux` package on Debian
  - `util-linux` package on openSUSE
  - `util-linux-core` package on Fedora

### Packages

[![build result](https://build.opensuse.org/projects/home:jcgl/packages/wnl/badge.svg?type=percent)](https://build.opensuse.org/package/show/home:jcgl/wnl)

Download the packages or add the openSUSE Build Service repository [here](https://software.opensuse.org//download.html?project=home%3Ajcgl&package=wnl). Current distros include:

- Arch
- Debian
- Fedora
- openSUSE
- Ubuntu

Please report any issues you may encounter with the packages!

## Features

### Multiple instances—slots

To run multiple instances, wnl has a feature called "slots".
You can run `wnl $SLOT_ID $COMMAND`, where `$SLOT_ID` is a number.
If you do not specify `$SLOT_ID`, then wnl will use the next available slot ID, counting up from 1.

Correspondingly, call `wnlctl $SLOT_ID` to signal the `wnl` instance with that SLOT_ID.
`wnlctl` default to `1` for `SLOT_ID` if not specified.

### Stopping program execution

Call `SIGNAL=USR2 wnlctl $SLOT_ID` to kill the command running in wnl (SIGINT is sent).
If wnl is not currently running the command, then no action is taken.

### User configuration

Behavior can be customized using a file at `~/.config/wnl/wnlrc`.
Right now, hooks are the main reason to customize your configuration.
These are simply shell snippets that get run by your shell (`$SHELL`).
There are four hooks:

| Name           | Description                                                                                                  |
| -------------- | ------------------------------------------------------------------------------------------------------------ |
| `HOOK_PRE`     | Every time wnl is triggered with `wnlctl`, this snippet is run _before_ executing the command given to `wnl` |
| `HOOK_POST`    | Every time wnl is triggered with `wnlctl`, this snippet is run _after_ executing the command given to `wnl`  |
| `HOOK_STARTUP` | This snippet is run when `wnl` is started                                                                    |
| `HOOK_EXIT`    | This snippet is run when `wnl` is exited (e.g. with `Ctrl-c`)                                                |

A simple example of a `wnlrc`:

```bash
# Play a gentle tone whenever wnl is triggered
HOOK_PRE='pw-play /usr/share/sounds/ocean/stereo/service-logout.oga &'
# Play a an alert whenever the command run by wnl fails with a nonzero exit code
# $EXIT_CODE is set to the exit code from the now-finished command
HOOK_POST='test "$EXIT_CODE" -eq 0 || pw-play /usr/share/sounds/oxygen/stereo/message-connectivity-error.ogg &'
# ANSI color/formatting codes are available in $FMT_* variables
HOOK_EXIT='echo "$FMT_GREEN$FMT_BOLD"; cowsay thank you for using wnl!; echo "$FMT_NORMAL"'
```

## Roadmap

- [x] Multiple instances ("slots")
  - [x] Automatically use first available slot if slot ID not specified
- [x] Allow sending SIGINT to command executions
- [ ] Richer controls from `wnlctl`
  - [ ] Named pipes instead of signals for IPC
  - [ ] Custom signals (e.g. SIGTERM) to command executions
  - [ ] Text to command executions' `stdin`
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

To set up wnl, you bind `wnlctl` to `Ctrl-F1`, and `SIGNAL=USR2 wnlctl` to `Ctrl-Super-F1` in your Desktop Environment.
Then, when you start to work on your application, you run `wnl make deploy` in a shell.
At any point, you can hit `Ctrl-F1` to run your deployment, and `Ctrl-Super-F1` to abort the deployment.

### Applying configuration management

You're writing some config management code like Ansible or Terraform/OpenTofu.
Frequently, you run `terraform apply -auto-approve`.
Sometimes, you also run a diagnostic like `curl https://dev.example.com/api/healthz -ik`.

With wnl, you'd use your Desktop Environment to set up shortcuts for a couple different slots:

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
