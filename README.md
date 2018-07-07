# retroflag-picase
RetroFlag Pi-Case Safe Shutdown

with advanced shutdown features for more natural behaviour:
1. If you press restart if emulator is currently running, then you will be kicked back to ES main menu
2. If you press restart in ES main screen, ES will be restartet (no reboot!), good for quick saving metadata or internal saves.
3. If you press power-off then Raspberry will shutdown

All metadata is always saved

# Turn switch "SAFE SHUTDOWN" on PCB to ON.

--------------------

Example for RetroPie:
1. Make sure internet connected.
2. Make sure keyboard connected.
3. Press F4 enter terminal.
4. In the terminal, type the one-line command below(Case sensitive):

wget -O - "https://raw.githubusercontent.com/crcerror/retroflag-picase/master/install.sh" | sudo bash

--------------------
