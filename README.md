# NeoVim

- Add mason bin folder to path (used by easy-dotnet for invoking `netcoredbg` debugger)

# WSL

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
