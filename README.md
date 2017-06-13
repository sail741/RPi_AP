# RPi_AP
Raspberry pi 3 acces point set up & swap AP / client mode

HIGHLY inspired by https://gist.github.com/Lewiscowles1986/fecd4de0b45b2029c390

++++++++++++++++++++++++++++++++++++++++++++++++++++++
If you wanna install Access Point and enable swap wifi
++++++++++++++++++++++++++++++++++++++++++++++++++++++
Run the script with "sudo ./rPi3-ap-setup.sh password AP_name".
Wait until it say to reboot.
Reboot the RPI.
You can swap from Access Point to Client Mode (and Client Mode to Access Point) by using the alias "sudo swapwifi".


++++++++++++++++++++++++++++++++++++++++++++++++++++++
If you already installed AP but wanna enable swap wifi
++++++++++++++++++++++++++++++++++++++++++++++++++++++
Go to the subfolder "make_swap_wifi_late" and run "sudo make_swap_wifi_late.sh".
Wait until it say to reboot.
Reboot the RPI.
You can swap from Access Point to Client Mode (and Client Mode to Access Point) by using the alias "sudo swapwifi".
