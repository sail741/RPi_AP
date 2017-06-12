#!/bin/bash

# Check that we are root
if [ "$EUID" -ne 0 ]
	then echo "Must be root"
	exit
fi

# Check that we got at least 1 param (password)
if [[ $# -lt 1 ]]; 
	then echo "You need to pass a password!"
	echo "Usage:"
	echo "sudo $0 yourChosenPassword [apName]"
	exit
fi

#We create a save of current conf to enable swap client/accessPoint
mkdir /home/pi/.saveConfWifi
cp /etc/dhcpcd.conf /home/pi/.saveConfWifi/dhcpcd.conf.bakCL
cp /etc/network/interfaces /home/pi/.saveConfWifi/interfaces.bakCL

APPASS="$1"
APSSID="rPi3"

if [[ $# -eq 2 ]]; then
	APSSID=$2
fi

apt-get remove --purge hostapd -y
apt-get install hostapd dnsmasq -y

cat > /etc/systemd/system/hostapd.service <<EOF
[Unit]
Description=Hostapd IEEE 802.11 Access Point
After=sys-subsystem-net-devices-wlan0.device
BindsTo=sys-subsystem-net-devices-wlan0.device
[Service]
Type=forking
PIDFile=/var/run/hostapd.pid
ExecStart=/usr/sbin/hostapd -B /etc/hostapd/hostapd.conf -P /var/run/hostapd.pid
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.5,255.255.255.0,12h
EOF

cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
hw_mode=g
channel=10
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
wpa_passphrase=$APPASS
ssid=$APSSID
EOF

sed -i -- 's/allow-hotplug wlan0//g' /etc/network/interfaces
sed -i -- 's/iface wlan0 inet manual//g' /etc/network/interfaces
sed -i -- 's/    wpa-conf \/etc\/wpa_supplicant\/wpa_supplicant.conf//g' /etc/network/interfaces

cat >> /etc/network/interfaces <<EOF
	wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
# Added by rPi Access Point Setup
allow-hotplug wlan0
iface wlan0 inet static
	address 10.0.0.1
	netmask 255.255.255.0
	network 10.0.0.0
	broadcast 10.0.0.255
EOF

echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf

systemctl enable hostapd

#We create a save of current conf to enable swap client/accessPoint
cp /etc/dhcpcd.conf /home/pi/.saveConfWifi/dhcpcd.conf.bakAP
cp /etc/network/interfaces /home/pi/.saveConfWifi/interfaces.bakAP


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
