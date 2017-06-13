#!/bin/bash

# Check that we are root
if [ "$EUID" -ne 0 ]
	then echo "Must be root"
	exit
fi

#We create a save of current conf to enable swap client/accessPoint
mkdir /home/pi/.saveConfWifi
cp /etc/dhcpcd.conf /home/pi/.saveConfWifi/dhcpcd.conf.bakAP
cp /etc/network/interfaces /home/pi/.saveConfWifi/interfaces.bakAP


#We create a save of current conf to enable swap client/accessPoint
cp dhcpcd.conf.bakCL /home/pi/.saveConfWifi/dhcpcd.conf.bakCL
cp interfaces.bakCL /home/pi/.saveConfWifi/interfaces.bakCL


# Creating alias to enable swap AP / client faster
cat >> /home/pi/.saveConfWifi/swap_wifi.sh <<EOF
#!/bin/bash

if [ "$EUID" -ne 0 ]
	then echo "Must be root"
	exit
fi

hostapd=hostapd;
dnsmasq=dnsmasq;

# We test if hostapd and dnsmasq are started 
if P=$(pgrep $hostapd) && P=$(pgrep $dnsmasq)
then
    echo "hostapd and dnsmasq are running. Stopping AP and switching to normal wifi"

    sudo service hostapd stop
	sudo service dnsmasq stop
	sudo systemctl disable hostapd.service
	sudo systemctl disable dnsmasq.service

	sudo cp /home/pi/.saveConfWifi/dhcpcd.conf.bakCL /etc/dhcpcd.conf
    sudo cp /home/pi/.saveConfWifi/interfaces.bakCL /etc/network/interfaces

else
    echo "hostapd or dnsmasq or both are not running. Stopping normal wifi and switching to AP"
    sudo service hostapd start
	sudo service dnsmasq start
    sudo systemctl enable hostapd.service
	sudo systemctl enable dnsmasq.service

	sudo cp /home/pi/.saveConfWifi/dhcpcd.conf.bakAP /etc/dhcpcd.conf
	sudo cp /home/pi/.saveConfWifi/interfaces.bakAP /etc/network/interfaces
fi


echo "Done. Please reboot to make change active."
EOF

sudo chmod +x /home/pi/.saveConfWifi/swap_wifi.sh

echo "alias sudo='sudo '" >> /home/pi/.bash_aliases
echo "alias swapwifi='/home/pi/.saveConfWifi/swap_wifi.sh'" >> /home/pi/.bash_aliases

echo "All done! You can swap acess point / normal client wifi by using the command 'sudo swapwifi'"
echo "Please reboot"
