[Microsoft SQL Server](https://filecr.com/windows/microsoft-sql-server/)<br />
[Install SQL Server Developer Edition On Windows  Server](https://computingforgeeks.com/install-sql-server-developer-edition-on-windows-server/)<br />
[How To Enable Remote Connections To SQL Server](https://medium.com/@nishancw/how-to-enable-remote-connections-to-sql-server-dc5b6c812b5)<br />
[How To Enable  Remote  Desktop In Windows Server 2019](https://www.rootusers.com/how-to-enable-remote-desktop-in-windows-server-2019/)<br />
[Download SQL Server Management Studio SSMS](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)<br />
[SQL Server 2019 Installation Step By Step 2020](https://www.youtube.com/watch?v=bfMoKqpigxI)<br />
[How To Download And Install SQL 2019 And SQL Server Management Studio 2020](https://www.youtube.com/watch?v=1lOUm5CZlAk)<br />
[Allow SQL Server through Windows Firewall](https://www.youtube.com/watch?v=3jVTUll4PXs)<br />
[How to allow SQL Server thorugh Window Firewall](https://www.youtube.com/watch?v=9O2GLm3iNp8)<br />
[Windows Firewall Configuration For SQL Server To Allow Remote Connection](https://www.youtube.com/watch?v=3Eyva0OG2tc)<br />
[Connect To SQL Server From Another Computer](https://www.youtube.com/watch?v=EqI77fd_1kU)<br />
[Allow Remote Connections To SQL Server Express](https://www.youtube.com/watch?v=5UkHYNwUtCo)

# Windows Server
  * Steps after installing the Microsoft Server onto the machine
    * Change the computer name
    * Change work group name

# Microsoft SQL Server Check and Install
  * Check the system
  * After opening the SQL Server Installation Center
    * Click System Configuration Checker
      * Show details and see if everything has passed
    * Click Okay

# Install
  * Click the Installation on the left pane
    * Click New SQL Server stand-alone installation or add features to an existing installation
      * Enter product key if you have one else choose free edition
      * Click Next
      * Check I accept the license terms and Privacy Statement box
      * Click Next
        * **WAIT FOR THIS PROCESS TO FINISH**
      * Click Next
        * **WAIT FOR THIS PROCESS TO FINISH**
      * Click Next
      * Check the features you want
        * At the minimum you will need to check Database Engine Services
        * Leave all the directories as is
      * Click Next
        * **WAIT FOR THIS PROCESS TO FINISH**
      * Leave instance id to Default instance
        * Unless you need it to be called something else
      * Click Next
        * **WAIT FOR THIS PROCESS TO FINISH**
      * Note if PolyBase was chosen then leave default option as is
        * Click Next
      * Note if Java was chosen then leave default option as is
        * Click Next
      * Click Next
      * Leave all server configuration options as is except for
        * SQL Server Browser should be set to Automatic
        * Click Next
      * Add Current User to the Database Engine Configuration
      * Select Mixed Mode for authentication Mode (user can either be from a domain or added manually in the SQL instance)
        * Enter sa password
        * Click Next
      * If Analysis was chosen
        * Add Current User as administrator then leave option as is
        * Select Multidimensional and Data Mining Mode
        * Click Next
      * Integration Services Scale Out Configuration - Master Node
        * Leave as is
        * Click Next
      * Integration Services Scale Out Configuration - Worker Node
        * Leave as is
        * Click Next
      * Distributed Replay Controller
        * Add Current User
        * Click Next
      * Distributed Replay Client
        * Leave as is
        * Click Next
      * Consent to install Microsoft R Open
        * Accept
          * **WAIT FOR THIS PROCESS TO FINISH**
        * Click Next
      * Consent to install Python
        * Accept
          * **WAIT FOR THIS PROCESS TO FINISH**
        * Click Next
      * Ready to Install
        * Check that everything is correct
        * Click Next
      * Click Install
        * **WAIT FOR THIS PROCESS TO FINISH** (this will take a while)
      * Check to make sure all Succeeded and Green Check Marks
        * Click Close

# Microsoft SQL Server Management Studio (SSMS)
  * Download and install SQL Server Management Studio (SSMS)
    * Install and restart machine
    * Launch SSMS
      * Make sure you are able to connect to the SQL Server via SSMS
      * Create database
        * Right click database
        * Select New database...
        * Type database name
        * Leave Owner as is
        * Use logical name for file name
        * Click Okay
      * Create new users
        * Login as administrator
        * Expand security
        * Right click logins
        * Select New Login...
        * Type Login name of user
        * Select SQL Server Authentication
        * Type in password
        * Un-check
          * Enforce password expiration
          * User must change password at next login
        * Select a default database
        * Select a default language
        * Select server roles on the left pane
          * Default server role to public
        * User mapping
          * Check map for the database of choice
          * User default to user name of choice
          * Default schema is dbo
          * Check db_reader
          * Check db_writer
          * Check db_owner
          * Leave public checked
          * Click Okay

# Windows Firewall
  * Allow SQL through Windows Firewall
    * Run services.msc
      * Find SQL Server (Instance Name)
      * Right click and select properties
      * Find path to executable and select and copy everything including the double quotes
      * Close properties window
    * Run firewall.cpl
      * Click Allows an app or feature through Windows firewall
        * If everything is greyed out click change settings
      * Click Allow another app
        * Click Browse
        * Paste the path to executable into the filename text box and click open
        * Click Add
        * Ensure private is checked and public is unchecked, if you have a domain column check it
      * Click Allow another app
        * Click Browse
        * Navigate back to the services window
        * Find the service for SQL Server Browser
        * Right click and select properties
      * Find path to executable and select and copy everything including the double quotes
      * Close properties window
    * Navigate back to the Allowed apps and browse window we had opened
        * Click Browse
        * Paste the path to executable into the filename text box and click open
        * Click Add
        * Ensure private is checked and public is unchecked, if you have a domain column check it
        * Click Okay

# SQL Remote Connection
  * Allow Remove Connection
    * Open SSMS as an administrator
      * Login
      * Right click Server Name
      * Click properties
      * Click Connections under Select a page
        * Make sure the check Allow remote connections to this server is checked
    * Open SQL Server Configuration Manager
      * Expand SQL Server Network Configuration in the left pane
        * Select Protocols for Instance Name
          * Enable Named Pipes and TCP/IP is not already enabled
          * Click Okay to the Warning
        * Right click on TCP/IP
        * Click properties
        * Select the IP Addresses tab
          * Make sure port is 1433 for all ports and the IP Address is correct for IP2
            * This can be check by opening the cmd and typing in ipconfig
          * Click Okay
      * Click On SQL Server Services on the left pane
        * Right click SQL Server (Instance Name)
          * Select restart
      * Windows Defender Firewall
        * Click on Advanced Settings
          * Select Inbound Rules in the left pane
          * Click New Rule... in the right pane
          * Select Port in the New Inbound Rule Wizard
          * Click Next
          * Make sure TCP is selected
          * Specific local ports should be 1433
          * Click Next
          * Make sure Allow the connection is selected
          * Click Next
          * Make sure all Domain, Private, and Public are checked
          * Click Next
          * Give the new rule a name
            * e.g. Allow_SQL_Connection
          * Give the new rule a description but is optional
          * Click Finish

# Router Port Forwarding
  * Port Forwarding (this is optional)
    * Open your router and allow port 1433 for the SQL Server

# Windows Server Remote Desktop
  * Enable remote connection to Windows Server
    * Allow Remote Desktop with the GUI
      * Open Server Manager
      * Select Local Server
      * Click on Disable link
      * Select te Remote Tab
        * Select Allow remote connections to this computer
        * Click Okay on the pop up
        * Click Apply
        * Click Okay
      * Refresh the properties view
