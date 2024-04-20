#Pwnagotchi deployment script by SeverX
#Designed for headless rPi0w/rPi3b+ running an Alfa adapter for AI sniffing and MITM attacks/analysis
#Add or remove installs or plugins as needed, remember to adjust plugin enable section if you modify plugin install.

#Color palette for user-initiated script and de-bugging.
RED='\033[0;36m'
NC='\033[0m'

#For debugging and interrupted install issues.
sleep 1
cd

#Obligatory updates
echo -e "${RED}Running Deployment, this will take apx. 30 minutes and download apx. 2Gb, please leave the device connected to power and internet.${NC}" &&
echo -e "${RED}Updating Repositories${NC}" &&
sudo apt update 
echo -e "${RED}Updating Plugin List${NC}" &&
sudo pwnagotchi plugins update && 

#Airgeddon for MITM
echo -e "${RED}Installing Airgeddon${NC}" && 
sudo git clone --depth 1 https://github.com/v1s1t0r1sh3r3/airgeddon.git

#Change display for airgeddon for non-graphical interface.
sudo sed -i 's/xterm/tmux/g' /home/pi/airgeddon/.airgeddonrc

#Plugin Install
echo -e "${RED}Installing 2/8 Plugins${NC}" && 
sudo pwnagotchi plugins install enable_assoc
echo -e "${RED}Installing 3/8 Plugins${NC}" && 
sudo pwnagotchi plugins install enable_deauth 
echo -e "${RED}Installing 4/8 Plugins${NC}" && 
sudo pwnagotchi plugins install handshakes-dl
echo -e "${RED}Installing 5/8 Plugins${NC}" &&  
sudo pwnagotchi plugins install hashieclean
echo -e "${RED}Installing 6/8 Plugins${NC}" &&  
sudo pwnagotchi plugins install quickdic
echo -e "${RED}Installing 7/8 Plugins${NC}" &&  
sudo pwnagotchi plugins install tweak_view
echo -e "${RED}Installing 8/8 Plugins${NC}" &&  
sudo pwnagotchi plugins install instattack

#Plugin WGET
sleep 1
echo -e "${RED}Installing EXP Plugin${NC}" && 
cd /usr/local/share/pwnagotchi/custom-plugins/
sudo wget --progress=bar https://raw.githubusercontent.com/GaelicThunder/Experience-Plugin-Pwnagotchi/master/exp.py
echo -e "${RED}Installing AGE Plugin${NC}" && 
sudo wget --progress=bar https://raw.githubusercontent.com/hannadiamond/pwnagotchi-plugins/main/plugins/age.py

#Required and optional software for bettercap
echo -e "${RED}Starting Bettercap Software Install${NC}" &&
echo -e "${RED}Installing Software 1/15${NC}" &&
sudo apt install ettercap-text-only -y 
echo -e "${RED}Installing Software 2/15${NC}" &&
sudo apt install nmap -y
echo -e "${RED}Installing Software 3/15${NC}" &&
sudo apt install tmux -y
echo -e "${RED}Installing Software 4/15${NC}" &&
sudo apt install dnsmasq -y
echo -e "${RED}Installing Software 5/15${NC}" &&
sudo apt install bully -y
echo -e "${RED}Installing Software 6/15${NC}" &&
sudo apt install hashcat -y
echo -e "${RED}Installing Software 7/15${NC}" &&
sudo apt install mdk4 -y
echo -e "${RED}Installing Software 8/15${NC}" &&
sudo apt install reaver -y 
echo -e "${RED}Installing Software 9/15&{NC}" &&
sudo apt install hcxtools -y 
echo -e "${RED}Installing Software 10/15${NC}" &&
sudo apt install lighttpd -y
echo -e "${RED}Installing Software 11/15${NC}" &&
sudo apt install crunch -y
echo -e "${RED}Installing Software 12/15${NC}" &&
sudo apt install hostapd -y
echo -e "${RED}Installing Software 13/15${NC}" &&
sudo apt install udhcpd -y 
echo -e "${RED}Installing Software 14/15${NC}" &&
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install tshark -y 
echo -e "${RED}Installing Software 15/15${NC}" &&
sudo apt install isc-dhcp-server -y
sudo apt autoremove -y

#Download Miku into custom-faces directory
sleep 1
echo -e "${RED}Downloading Miku${NC}" &&
cd /
sudo git clone https://github.com/exosever/MikuGotchi.git
sudo mv /MikuGotchi/ /custom-faces/

#Place temporary touch file for enabling plugins
echo -e "${RED}Placing Touch File${NC}" &&
sudo touch /etc/pwnagotchi/rebooting-for-updates

#This places Plugin Enables in pwnlib file
echo -e "${RED}Placing Plugin Enable File${NC}" &&
echo -e "if [ -f /etc/pwnagotchi/rebooting-for-updates ]; then
  after_reboot
  rm /etc/pwnagotchi/rebooting-for-updates
  pwnagotchi plugins enable handshakes-dl
  pwnagotchi plugins enable hashieclean
  pwnagotchi plugins enable memtemp
  pwnagotchi plugins enable quickdic
  pwnagotchi plugins disable gps
  pwnagotchi plugins enable tweak_view
  pwnagotchi plugins enable wpa-sec
  pwnagotchi plugins enable onlinehashcrack
  pwnagotchi plugins enable enable_assoc
  pwnagotchi plugins enable enable_deauth
  touch /etc/pwnagotchi/updates-complete 
  sudo systemctl restart pwnagotchi
fi" | sudo tee -a /usr/bin/pwnlib


#Tweak_View JSON file
sleep 1
echo -e "${RED}Writing UI tweaks!!${NC}" &&
cd /etc/pwnagotchi
echo -e '{
    "VSS.status.font": "Small",
    "VSS.Exp.xy": "38,95",
    "VSS.name.xy": "5,16",
    "VSS.Lv.xy": "0,95",
    "VSS.Age.xy": "130,95",
    "VSS.Strength.xy": "192,95",
    "VSS.deauth_count.label": "D",
    "VSS.deauth_count.xy": "72,28,30,59",
    "VSS.Age.label": "\u2665 Age ",
    "VSS.friend_name.xy": "100,76",
    "VSS.assoc_count.xy": "72,17,30,59"
}
' | sudo tee tweak_view.json


#Enable root FTP !WARNING! THIS IS ROOT LEVEL SSH/FTP ACCESS! PLEASE CHANGE THE PASSWORD!
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config &&
sudo sh -c 'echo root:password | chpasswd'

#Echo to add WGET plugins to config.toml
echo -e "${RED}Modifying config.toml${NC}" && 
echo -e "
main.plugins.exp.enabled = true
main.plugins.exp.lvl_x_coord = 0
main.plugins.exp.lvl_y_coord = 81
main.plugins.exp.exp_x_coord = 38
main.plugins.exp.exp_y_coord = 81
main.plugins.exp.bar_symbols_count = 12

main.plugins.age.enabled = true
main.plugins.age.age_x_coord = 0
main.plugins.age.age_y_coord = 32
main.plugins.age.str_x_coord = 67
main.plugins.age.str_y_coord = 32" | sudo tee -a /etc/pwnagotchi/config.toml

#Create wordlist directory
sudo apt install pv
sudo mkdir /opt/wordlist/
sleep 1
cd /opt/wordlist
echo -e "${RED}Downloading Wordlist${NC}" &&
sudo wget https://download.weakpass.com/wordlists/1802/HashesOrg.gz
echo -e "${RED}Unzipping Wordlist${NC}" &&
sudo gzip HashesOrg.gz -d | pv -l

#Crontab to reconnect bluetooth every "5" minutes
sudo -c 'echo */5 * * * * (bluetoothctl info | grep -q "Connected: yes" || echo -e 'connect F0:CD:31:0D:6B:E6\n' | bluetoothctl) | crontab -e'

#Mandatory Reboot
echo -e "${RED}Rebooting... Please wait 5 minutes for device to complete setup!${NC}" &&
sudo reboot



#To Do
#Make it so script runs automatically on first boot?
#Possibly have it remove script after reboot?
