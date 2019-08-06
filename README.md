
# Remote development in Rpi in rust.

 Development for Raspberry pi (or other arm linux single boards computer) can be painfull as it require runining your dev enviroment in small computer or define cross compilation+remote debugingg.0
 
 VSCode has changed the rules here with the remote development plugings.


## Requirmets:
  On the PC:
  - PC with linux or MacOs
  - Visual studio code insiders version (required for remote in arm targets)
  - ssh client installed (e.g. OpenSSH)
  - ssh extensions ssh-keygen & ssh-copy-id
  - rsync
  On the Pi:
  - Exting user with ```sudo``` grants.

In macOs ssh is installed by default but extensions and rsync need to be installed if not alredy installed. Using ```brew``` is recommended. On linux please refer to you distribution documentation to check out how to install these components.

VsCode insiders need to be in your path. If not please check [this](https://github.com/Microsoft/vscode/issues/6627) to activate __code-insiders__ in your terminal.


## How to use it
  Copy the shell script ```rust-rpi-up.sh``` and run the following command for starting a new project:

  ```bash
    $ rust-rpi-up.sh -r mypi.local -u pi hellorust
  ```




## What the script does?

On your desktop:

    - Configure your ~/.ssh/config to access your Pi with shh keys. [optional]
    - Create a proyect directory with

On the Rpi/SBC:
    - A exiting user in the rpi with sudo privileges.
    - Install ssh keys for remote accessing
    - rustup
    - lldb for debuging.
    - rsycn for syncronize sources
    - git for version management







## What has been tested

    -Linux & MacOs with RPi with



