Updated: 2018.5.14
Metadata in emulationstation will be saved when rebooting and shutting down.

# retroflag-picase
RetroFlag Pi-Case Safe Shutdown

Turn switch "SAFE SHUTDOWN" on PCB to ON.

--------------------

Example for RetroPie:
1. Make sure internet connected.
2. Make sure keyboard connected.
3. Press F4 enter terminal.
4. In the terminal, type the one-line command below(Case sensitive):

wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/install.sh" | sudo bash

--------------------

Example for RecalBox:
1. Make sure internet connected.
2. Make sure keyboard connected.
3. Press F4 first. And then press ALT-F2 enter termial.
4. User:root Password:recalboxroot
5. In the terminal, type the one-line command below(Case sensitive):

wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/recalbox_install.sh" | bash

--------------------

Example for Kodi (LibreElec):

**Method A (via ssh):**
1. Get your raspberry IP: Settings > Sytem Information > Network
2. Connect via ssh from your computer: `ssh root@<your-ip-address>`. Default password is `libreelec`
3. Copy&Paste the command below:

`wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/libreelec_install.sh" | bash`

**Method B (directly to your raspberry)**
1. Make sure internet and keyboard are connected.
2. Press CONTROL+ALT+F3 to enter the terminal.
3. User:root Password:libreelec
4. In the terminal, type the one-line command below(Case sensitive):

`wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/libreelec_install.sh" | bash`
