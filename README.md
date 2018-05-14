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
