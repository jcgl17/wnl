# `wnl`—Wait 'n' Listen

This is a tool to facilitate the ["Unix as IDE" concept](https://blog.sanctum.geek.nz/series/unix-as-ide/).
It enables quick and easy execution of common tasks. For example, by binding those tasks to keyboard shortcuts.

If you have a command you want to be able to trigger again and again, preface the command with 'wnl':

[![asciicast](https://asciinema.org/a/716085.svg)](https://asciinema.org/a/716085)

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

## Installation

### Manual

Put these two shell scripts—`wnl` and `wnlctl`—in your `$PATH`, e.g. in `~/.local/bin`.

### Packages

I'm working on building packages for various distros, but only have RPM packages figured out for now.

Download the packages or add the openSUSE Build Service repository [here](https://software.opensuse.org//download.html?project=home%3Ajcgl&package=wnl).

## Roadmap

- [X] Multiple instances ("slots")
- [X] Allow sending SIGINT to command invocations
- [ ] Richer controls from `wnlctl`
  - [ ] Named pipes instead of signals for IPC
  - [ ] Custom signals (e.g. SIGTERM) to command invocations
  - [ ] Text to command invocations' `stdin`
- [X] Emit [shell integration escape codes](https://sw.kovidgoyal.net/kitty/shell-integration/#notes-for-shell-developers) to enable skipping between command invocations
- [X] Config file for things like emitting shell integration escape codes, enabling/configuring the banner emitted after a command invocation finishes
- [X] Pre- and post-exec hooks

## Additional features

### Multiple instances

To run multiple `wnl` instances, you can run `wnl SLOT_ID COMMAND`, where `SLOT_ID` is a number. `SLOT_ID` defaults to 1 for easy use, so you only need to specify `SLOT_ID` when you start using more than one instance of `wnl` at a time.

Correspondingly, call `wnlctl SLOT_ID` to signal the `wnl` instance with that SLOT_ID.

### Killing program execution

Not only can `wnl` start command execution, but it can also end it.

Call `SIGNAL=USR2 wnlctl` to kill the command running in `wnl` (SIGINT is sent).

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
