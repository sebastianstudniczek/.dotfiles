# NeoVim

- Add mason bin folder to path (used by easy-dotnet for invoking `netcoredbg` debugger)

# Windows

## AHK

For hyper key setup (`CTRL+SHIFT+ALT+LWIN`) disable office key shortcut which opens browser by adding the following registry entry

```
REG ADD HKCU\Software\Classes\ms-officeapp\Shell\Open\Command /t REG_SZ /d rundll32
```

# WSL

## Path

WSL by default appends whole `$PATH` variable which is causing performance issues, to disable appending it add following lines to `/etc/wsl.conf`

```
[interop]
appendWindowsPath = false
```

Then share `$USERPROFILE` with wsl to be able invoke windows programs easily by utilizing `$WSLENV` variable.

Invoke in cmd

```
setx WSLENV USERPROFILE/p

/p - translate path to unix
```

## INotify settings

In order to make LSP work properly, values for `inotify` api needs to be increased.
Check the current one with 

```
cat /proc/sys/fs/inotify/max_user_instances
cat /proc/sys/fs/inotify/max_user_watches
```

Values respectively should be 8192 and 524288, if they are not they need to be set in `/etc/wsl.conf` file since currently wsl is not autoloading config from `/etc/sysctl.conf`.

Add this to your `wsl.conf`
```
[boot]
command="sysctl fs.inotify.max_user_instances=8192 && sysctl fs.inotify.max_user_instances=524288"
```
