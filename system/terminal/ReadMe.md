[How Install WSL2 Windows 10](https://www.windowscentral.com/how-install-wsl2-windows-10)<br />
[WSL Windows 10 Install](https://docs.microsoft.com/en-us/windows/wsl/install-win10)<br />
[WSL Update x64 MSI](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)<br />
[WSL Issue](https://github.com/MicrosoftDocs/WSL/issues/404)

* Open PowerShell as administrator
  * Type
    * `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`
    * `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`
* Install WSL Update
  * Double click
    * wsl_update_x64.msi
* PowerShell as administrator
  * Type
    * `wsl --list --verbose`
    * `wsl --set-version Ubuntu 2`
      * **WAIT FOR THIS TO FINISH**
      * NOTE
        * Depends on which version of Linux distribution you are using
        * This version is Ubuntu
    * `wsl --set-default-version 2`
    * `wsl -d ubuntu`
      * Will launch you into the associated bash shell
