# retroflag-picase
## RetroFlag Pi-Case+ Safe Shutdown

#### Turn switch "SAFE SHUTDOWN" on PCB to ON position.

![Safe Shutdown Switch](http://retroflag.com/images/nespi_case+/safe_shutdown.jpg "Safe Shutdown Switch")

Script will attempt to close a running emulator kindly and force close if it takes too long to respond. Then it will close EmulationStation kindly to save metadata before reset or shutdown.

--------------------

Example for RetroPie:
1. Make sure internet is connected.
2. Make sure keyboard is connected.
3. Press F4 to enter terminal.
4. In the terminal, type the one-line command below(Case sensitive):

```bash
wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/install.sh" | sudo bash
```

--------------------

Example for RecalBox:
1. Make sure internet is connected.
2. Make sure keyboard is connected.
3. Press F4 first. Then press ALT-F2 to enter terminal.
4. User:root Password:recalboxroot
5. In the terminal, type the one-line command below(Case sensitive):

```bash
wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/recalbox_install.sh" | bash
```
