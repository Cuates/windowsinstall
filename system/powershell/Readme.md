[Setup Awesome Prompt](https://www.youtube.com/watch?v=lu__oGZVT98)<br />
[Cascadia Code Release](https://github.com/microsoft/cascadia-code/releases)<br />
[CascadiaCode-2009.22 ZIP](https://github.com/microsoft/cascadia-code/releases/download/v2009.22/CascadiaCode-2009.22.zip)<br />
[Powerline Setup](https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup)<br />
[Customize The Windows Terminal With WSL2](https://www.youtube.com/watch?v=oHhiMf_6exY)<br />
[How To Make A Pretty Prompt In Windows Terminal With Powerline Nerd Fonts Cascadia Code Wsl And Oh My Posh](https://www.hanselman.com/blog/how-to-make-a-pretty-prompt-in-windows-terminal-with-powerline-nerd-fonts-cascadia-code-wsl-and-ohmyposh)<br />
[Nerd Fonts Repo](https://github.com/ryanoasis/nerd-fonts/tree/gh-pages)<br />
[Nerd Fonts](https://www.nerdfonts.com/)<br />
[Powerline In PowerShell](https://docs.microsoft.com/en-us/windows/terminal/custom-terminal-gallery/powerline-in-powershell)<br />
[Terminal Custom Schemes](https://docs.microsoft.com/en-us/windows/terminal/custom-terminal-gallery/custom-schemes)<br />
[Windows 10 Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10)<br />
[Powerline Repo](https://github.com/justjanne/powerline-go?WT.mc_id=-blog-scottha)<br />
[PowerShell Get Date](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7.1)<br />
[How To Format Date String In PowerShell](https://www.tutorialspoint.com/how-to-format-date-string-in-powershell)

Install Paradox and PowerLine via Command Line Using PowerShell ZSH oh-my-posh

* Download and Install Apps
  * Microsoft Store
    * Search
      * Windows Terminal (1.4.3243.0) or Windows Terminal Preview (1.5.3242.0)
      * PowerShell (7.1.0 stable version)
* Download and Install True Type Fonts ttf
  * https://github.com/microsoft/cascadia-code/releases
    * https://github.com/microsoft/cascadia-code/releases/download/v2009.22/CascadiaCode-2009.22.zip
      * Unzip CascadiaCode-2009.22.zip
  * Navigate to the ttf folder you just unzipped
    * Double click and install the following fonts
      * CascadiaCodePL.ttf
      * CascadiaMonoPL.ttf
    * OR Drag and drop the ttf files to C:\Windows\Fonts
* Configure Powerline for PowerShell
  * Open Windows Terminal/PowerShell as administrator
    * Type in command line
      * `Install-Module posh-git -Scope CurrentUser`
        * The following message will display if NuGet is not installed
          * <pre>
              NuGet provider is required to continue
              PowerShellGet requires NuGet provider version '2.8.5.201' or newer to interact with NuGet-based repositories. The NuGet
               provider must be available in 'C:\Program Files\PackageManagement\ProviderAssemblies' or
              'C:\Users\cuateshd\AppData\Local\PackageManagement\ProviderAssemblies'. You can also install the NuGet provider by
              running 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force'. Do you want PowerShellGet to install
              and import the NuGet provider now?
              [Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): Y Enter
            </pre>
        * Untrusted repository
          * A Enter ([A] Yes to All)
            * **WAIT FOR THIS TO FINISH**
      * `Install-Module oh-my-posh -Scope CurrentUser`
        * Untrusted repository
          * A Enter ([A] Yes to All)
            * **WAIT FOR THIS TO FINISH**
  * Locate and modify profile file
    * Type in command line
      * `echo $profile`
      * `notepad $PROFILE`
        * If prompted to create file, then proceed to create file
        * Add to file
          * <pre>
            Import-Module posh-git
            Import-Module oh-my-posh
            Set-Theme Powerlevel10k-Classic
            </pre>
      * Save and Exit
  * Set Execution Policy
    * Issue with Microsoft.PowerShell_profile.ps1 cannot be loaded because running scripts is disabled on this system
    * Open a Windows Terminal for Windows PowerShell as Administrator
      * Type
        * `Set-ExecutionPolicy Unrestricted`
          * If the following menu is prompted then proceed below
            * A Enter ([A] Yes to All)
  * Modify Settings to enable new ttfs
    * Open Windows Terminal/PowerShell
      * Click Settings
      * Click Open JSON file
    * Modify settings.json file
      * Add the following lines in the default section for global modification
        * <pre>
          "defaults":
          {
            // Put settings here that you want to apply to all profiles.
            "fontFace": "Cascadia Code PL",
            "fontSize": 14
          },
          </pre>
      * OR Add the following lines to the PowerShell sub-element in the list section
        * <pre>
          "fontFace": "Cascadia Code PL",
          "fontSize": 14
          </pre>
      * Save and Exit
  * Change oh-my-posh Themes (OPTIONAL)
    * Locate themes
      * C:\Users\\\<username>\Documents\WindowsPowerShell\Modules\oh-my-posh\2.0.487\Themes
    * Open Windows Terminal
      * Type
        * `Set-Prompt`
        * `Set-Theme <theme_name_without_extension_psm1>`
* Modify C:\Users\<username>\Documents\PowerShell\Modules\oh-my-posh\2.0.487\ThemesParadox.psm1 file
  * Locate $timeStamp
    * Modify with the following
      * <pre>
        $dateStamp = Get-Date -Format "yyyy-MM-dd"
        $datestamp = "[$dateStamp]"

        $timeStamp = Get-Date -Format "HH:mm:ss"
        # $timeStamp = Get-Date -UFormat %R
        $timestamp = "[$timeStamp]"

        $prompt += Set-CursorForRightBlockWrite -textLength (($datestamp.Length + $timestamp.Length) + 1)
        $prompt += Write-Prompt $datestamp -ForegroundColor $sl.Colors.PromptForegroundColor
        # $prompt += Set-CursorForRightBlockWrite -textLength ($timestamp.Length + 1)
        $prompt += Write-Prompt $timeStamp -ForegroundColor $sl.Colors.PromptForegroundColor
        </pre>
  * Locate Prompt
    * Modify with the following
      * <pre>
        $sl.PromptSymbols.PromptIndicator = '$'
        $sl.Colors.PromptSymbolColor = [ConsoleColor]::Green
        </pre>
  * Save and Exit
  * Open Windows Terminal PowerShell mode to see changes
