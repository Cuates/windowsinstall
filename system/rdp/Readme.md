[How to Enable Remote Desktop in Windows 11?](https://www.minitool.com/news/enable-remote-desktop-windows-11.html)<br />
[The Ultimate Guide to Secure Remote Desktop Connections to Safely Access Your PC over the Internet](https://www.youtube.com/watch?v=sax55mrOX54)<br />
[IANA Service Name and Transport Protocol Port Number Registry](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml)<br />

Remote Desktop Connection
* Modify RegEdit
  * regedit.exe
    * Computer > HKEY_LOCAL_MACHINE > SYSTEM > CurrentControlSet > Control > Terminal Server > WinStations > RDP - Tcp
      * Right Click on PortNumber Click on "Modify..."
        * Click Decimal
          * Change Port Number (Refer to Iana for unassigned port numbers)
        * Click button "OK"
* Enable Settings
  * Settings > System > Remote Desktop
    * Toggle Remote Desktop to On
    * Click button "Confirm" to enable remote desktop
    * NOTE: Make sure port number from above is shown in "Remote Desktop port"
* Add Port Number to firewall
  * Windows Defender Firewall
    * Click "Advanced settings"
    * Click "Inbound Rules"
      * Click "New Rule..."
        * Click radio button "Port"
          * Click "Next >"
        * Click radio button "TCP"
        * Click radio button "Specific local ports"
          * Type port number from above
          * Click "Next >"
        * Click radio button "Allow the connection"
          * Click button "Next >"
        * Make sure Domain, Private, and Public check boxes are checked
          * Click button "Next >"
        * Provide name and description of the rule
        * Click button "Finish"
