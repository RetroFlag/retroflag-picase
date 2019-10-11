# retroflag-picase
## RetroFlag Pi-Case+ Safe Shutdown

#### Turn switch "SAFE SHUTDOWN" on PCB to ON position.

![Safe Shutdown Switch](http://retroflag.com/images/nespi_case+/safe_shutdown.jpg "Safe Shutdown Switch")

#### **Multi Switch Shutdown**
with advanced shutdown features for more natural behaviour:
1. If you press restart if emulator is currently running, then you will be kicked back to ES main menu
2. If you press restart in ES main screen, ES will be restartet (no reboot!), good for quick saving metadata or internal saves.
3. If you press power-off then Raspberry will shutdown

All metadata is always saved

Turn switch "SAFE SHUTDOWN" on PCB to ON.

--------------------

#### Example for **RetroPie:**
1. Make sure internet connected.
2. Make sure keyboard connected.
3. Press F4 enter terminal.
4. In the terminal, type the one-line command below (case sensitive):

**`wget -O - "https://raw.githubusercontent.com/crcerror/retroflag-picase/master/install.sh" | sudo bash`**

--------------------

#### Example for **RecalBox** and **Batocera:**
1. Make sure internet connected.
2. Make sure keyboard connected.
3. Press F4 first. And then press ALT-F2 enter termial.
4. User: root Password: recalboxroot
5. In the terminal, type the one-line command below (case sensitive):

For Recalbox:
**`wget -O - "https://raw.githubusercontent.com/crcerror/retroflag-picase/master/install_recalbox.sh" | bash`**

For Batocera:
**`wget -O - "https://raw.githubusercontent.com/crcerror/retroflag-picase/master/install_batocera.sh" | bash`**

You can edit the python script and add some parameters to the script calls:
```
                  --restart will RESTART EmulationStation only
                  --kodi will startup KODI Media Center
                  --emukill to exit any running EMULATORS
                  --espid to check if EmulationStation is currently active
                  --emupid to check if an Emulator is running"

```
