# My dotfiles

Meant to be used with GNU Stow.

```sh
stow --dir=. --target=$HOME --dotfiles -v -S <list-of-modules>
```

# Details

## Shell

Using `bash` as login shell. It's job is to load the user-wide environment configuration in `~/.profile`. After that I use `fish` or `zsh` as interactive shell.

The environment configuration is not stored in `~/.profile`, but in small scripts in `~/.profile.d/`. The `~/.profile` script just sources everything under `~/.profile.d/`. This makes it easier to manage, as different modules can create their own scripts with the variables they need exported, which can be easily installed and removed separately.
