# Contents
* [GPiCase2 (GPi Case 2 only)](#gpicase2-gpi-case-2-only)
* [GPi Case (GPi Case only)](#gpi-case-gpi-case-only)
    * [For RetroPie](#for-retropie)
    * [For Recalbox](#for-recalbox)
* [Pi Case (nespi+, superpi, megapi,nespi4 case)](#pi-case)
    * [Example for RetroPie](#example-for-retropie)
    * [Example for RecalBox](#example-for-recalbox)
    * [Example for batocera](#example-for-batocera)

-------------------- 

# GPiCase2 (GPi Case 2 only)
The RetroFlag GPiCase 2 CM4 safe shutdown script will automatically switch between the LCD display and HDMI output when using the dock.

### Click the link Jump to install GPiCase2 script：[GPiCase2 Script](https://github.com/RetroFlag/GPiCase2-Script).

    
-------------------- 


# GPi Case (GPi Case only)
### Turn switch "SAFE SHUTDOWN" to ON.

### For RetroPie:

1. Make sure internet connected.
2. Make sure keyboard connected.
3. Press F4 enter terminal.
4. In the terminal, type the one-line command below(Case sensitive):

wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/install_gpi.sh" | sudo bash


### For Recalbox
1. Make sure internet connected.
2. Make sure keyboard connected.
3. Press F4 first. And then press ALT-F2 enter terminal.
4. User: root Password: recalboxroot
5. In the terminal, type the one-line command below(Case sensitive):

wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/recalbox_install_gpi.sh" | bash

  
-------------------- 


# Pi Case 
## (nespi+, superpi, megapi,nespi4 case)
RetroFlag Pi-Case Safe Shutdown

### Turn switch "SAFE SHUTDOWN" to ON.


### Example for RetroPie:
1. Make sure internet connected.
2. Make sure keyboard connected.
3. Press F4 enter terminal.
4. In the terminal, type the one-line command below(Case sensitive):

wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/install.sh" | sudo bash



### Example for RecalBox:
1. Make sure internet connected.
2. Make sure keyboard connected.
3. Press F4 first. And then press ALT-F2 enter terminal.
4. User: root Password: recalboxroot
5. In the terminal, type the one-line command below(Case sensitive):

wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/recalbox_install.sh" | bash



### Example for batocera:
1. Make sure internet connected.
2. Make sure keyboard connected.
3. Enter terminal. How to enter terminal: https://wiki.batocera.org/access_the_batocera_via_ssh
4. User: root Password: linux
5. In the terminal, type the one-line command below(Case sensitive):

wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/batocera_install.sh" | bash



### Example for lakkatv:
https://github.com/marcelonovaes/lakka_nespi_power
