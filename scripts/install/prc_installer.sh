#!/bin/bash
# Colors: \e[36m=Cyan M ; \e[92m=Light green ; \e[91m=Light red ; \e[93m=Light yellow ; \e[31m=green ; \e[0m=Default ; \e[33m=Yellow ; \e[31m=Red

#Version: 1.1.5 - 20211217
#branch="development"
repo="https://github.com/splitti/phoniebox_rotary_control"
branch="main"

nocolor='\e[0m'
red="\e[1;91m"
cyan="\e[1;36m"
yellow="\e[1;93m"
green="\e[1;92m"
installPath="/home/pi/phoniebox_rotary_control"
insttype=""

clear
echo -e "///////////////////////////////////////////////////////////////////////////////////////";
echo -e "///${cyan}       ____       _                      ____            _             _         ${nocolor}///";
echo -e "///${cyan}      |  _ \ ___ | |_ __ _ _ __ _   _   / ___|___  _ __ | |_ _ __ ___ | |        ${nocolor}///";
echo -e "///${cyan}      | |_) / _ \| __/ _' | '__| | | | | |   / _ \| '_ \| __| '__/ _ \| |        ${nocolor}///";
echo -e "///${cyan}      |  _ < (_) | || (_| | |  | |_| | | |__| (_) | | | | |_| | | (_) | |        ${nocolor}///";
echo -e "///${cyan}      |_| \_\___/ \__\__,_|_|   \__, |  \____\___/|_| |_|\__|_|  \___/|_|        ${nocolor}///";
echo -e "///${cyan}        __              ____  _ |___/           _      _                         ${nocolor}///";
echo -e "///${cyan}       / _| ___  _ __  |  _ \| |__   ___  _ __ (_) ___| |__   _____  __          ${nocolor}///";
echo -e "///${cyan}      | |_ / _ \| '__| | |_) | '_ \ / _ \| '_ \| |/ _ \ '_ \ / _ \ \/ /          ${nocolor}///";
echo -e "///${cyan}      |  _| (_) | |    |  __/| | | | (_) | | | | |  __/ |_) | (_) >  <           ${nocolor}///";
echo -e "///${cyan}      |_|  \___/|_|    |_|   |_| |_|\___/|_| |_|_|\___|_.__/ \___/_/\_\          ${nocolor}///";
echo -e "///${cyan}                                                                                 ${nocolor}///";
echo -e "///${green}                          developed by Peter Mayer                               ${nocolor}///";                                                                    
echo -e "///${cyan}                                                                                 ${nocolor}///";
echo -e "///////////////////////////////////////////////////////////////////////////////////////"
echo -e "///                                                                                 ///"
echo -e "///${cyan}      Github:  https://github.com/splitti/phoniebox_rotary_control               ${nocolor}///"
echo -e "///${cyan}      Support: https://discord.gg/pNNHUaCSAD                                     ${nocolor}///"
echo -e "///                                                                                 ///"
echo -e "///////////////////////////////////////////////////////////////////////////////////////"
echo -e ""
echo -e "${red}Please notice:${nocolor} This script will install or remove the rotary control for phoniebox"
echo -e "by Peter Mayer."
echo -e " "
if [ -d "/home/pi/RPi-Jukebox-RFID" ]; then
	echo -e "${green}RPi-Jukebox-RFID seems to be installed${nocolor}"
	echo -e " "
else
	echo -e "${red}Notice: RPi-Jukebox-RFID is missing!${nocolor}"
	echo -e " "
fi

echo -e "Do you want to install or remove Rotary-Control-Service?"
echo -e " "
options=("Install" "Remove" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Install")
		    insttype="i"
            break
            ;;

        "Remove")
		    insttype="r"
            break
            ;;

        "Quit")
            exit
            ;;
        *) echo -e "invalid option $REPLY";;
    esac
done

clear
echo -e "///////////////////////////////////////////////////////////////////////////"
echo -e "///${cyan}   Remove Service:                                                   ${nocolor}///"
echo -e "///////////////////////////////////////////////////////////////////////////"
echo -e ""
echo -e -n "   --> Delete Service:            "
sudo service phoniebox_rotary_control stop > /dev/null 2>&1
sudo systemctl disable /etc/systemd/phoniebox_rotary_control.service > /dev/null 2>&1
sudo rm /etc/systemd/phoniebox_rotary_control.service > /dev/null 2>&1
echo -e "${green}done${nocolor}"
echo -e -n "   --> Remove config-entries:     "
sudo sed -i '/dtoverlay=rotary-encoder/c\' /boot/config.txt
sudo sed -i '/dtoverlay=gpio-key/c\' /boot/config.txt
echo -e "${green}done${nocolor}"
echo -e -n "   --> Delete Repository:         "
sudo rm -R ${installPath} > /dev/null 2>&1
echo -e "${green}done${nocolor}"
echo -e ""

if [ "$insttype" = "i" ]
then
    read -n 1 -s -r -p "Service removed. Press any key to continue"
else
	echo -e "${green}Service successfully removed...${nocolor}"
	exit
fi

clear
cd
echo -e "////////////////////////////////////////////////////////////////////"
echo -e "///${cyan}   Check/Install Prerequirements:                             ${nocolor}///"
echo -e "////////////////////////////////////////////////////////////////////"
echo -e " "
echo -e "Starting installation-process, pleae wait, some"
echo -e "installation steps take some time..."
echo -e ""
echo -e -n "   --> Update Sources:          "
sudo apt -qq update > /dev/null 2>&1
echo -e "${green}done${nocolor}"
echo -e ""
echo -e "Install packages..."

lineLen=24
packages=(git python3) 
for p in ${packages[@]}; do
	i=0
	echo -n -e "   --> $p:"
    let lLen="$lineLen"-"${#p}"
    while [ "$i" -lt "$lLen" ]
    do
		let i+=1
		echo -n -e " "
	done
    installer=`sudo dpkg -s ${p}  2>&1 | grep Status | grep installed`
    if [ "$installer" = "" ]
    then
		installer=`sudo apt -qq -y install ${p} > /dev/null 2>&1`
		installer=`sudo dpkg -s ${p} 2>&1 | grep Status | grep installed`
		if [ "$installer" = "" ]
		then
			echo -e "${red}failed${nocolor}"
		else
			echo -e "${green}done${nocolor}"
		fi
	else
		echo -e "${green}already installed${nocolor}"
	fi
done
lumaPackages=(evdev)
for p in ${lumaPackages[@]}; do
	i=0
	let lLen="$lineLen"-"${#p}"
	echo -n -e "   --> $p:"
	while [ "$i" -lt "$lLen" ]
	do
		let i+=1
		echo -n -e " "
	done
	pipInstalled=`sudo pip3 show ${p}`
	if [ "$pipInstalled" = "" ]
	then
		sudo pip3 install ${p}  > /dev/null 2>&1
		pipInstalled=`sudo pip3 show ${p}`
		if [ "$pipInstalled" = "" ]
		then
			echo -e "${red}failed${nocolor}"
		else
			echo -e "${green}done${nocolor}"
		fi
	else
		echo -e "${green}already installed${nocolor}"
	fi
done

echo -e -n "   --> Adding config-entries:   "
echo 'dtoverlay=rotary-encoder,pin_a=23,pin_b=24,relative_axis=1' | sudo tee -a /boot/config.txt > /dev/null 2>&1
echo 'dtoverlay=gpio-key,gpio=22,keycode=28,label="ENTER"' | sudo tee -a /boot/config.txt > /dev/null 2>&1
echo -e "${green}done${nocolor}"

echo -e ""
read -n 1 -s -r -p "Press any key to continue"



clear
echo -e "///////////////////////////////////////////////////////////////////////////"
echo -e "///${cyan}   Installing Service:                                               ${nocolor}///"
echo -e "///////////////////////////////////////////////////////////////////////////"
echo -e ""
echo -e "Repository:       ${green}${repo}${nocolor}"
echo -e "Branch:           ${green}${branch}${nocolor}"
echo -e "Install Path:     ${green}${installPath}${nocolor}"
echo -e ""
echo -e "   Installing Service:                "
echo -e "   -------------------------------------------------------------------------"
echo -e -n "   --> Clone Rotary Repository:           "
git clone ${repo} --branch ${branch} ${installPath} > /dev/null 2>&1
echo -e "${green}Done${nocolor}"
echo -e -n "   --> Installing Service:                "
sudo chown -R pi:pi ${installPath} > /dev/null  2>&1
sudo chmod +x ${installPath}/scripts/phoniebox_rotary_control.py> /dev/null
sudo cp ${installPath}/templates/service.template /etc/systemd/system/phoniebox-rotary-control.service > /dev/null
sudo chown root:root /etc/systemd/system/phoniebox-rotary-control.service > /dev/null 2>&1
sudo chmod 644 /etc/systemd/system/phoniebox-rotary-control.service > /dev/null 2>&1
sudo sed -i -e "s:<PATH>:${installPath}:g" /etc/systemd/system/phoniebox-rotary-control.service > /dev/null
sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl enable /etc/systemd/system/phoniebox-rotary-control.service > /dev/null 2>&1
sudo service phoniebox-rotary-control restart > /dev/null 2>&1
echo -e "${green}Done${nocolor}"
echo -e ""
echo -e ""
echo -e "${green}Installation finished${nocolor}"
echo -e "If this is a fresh installation, a reboot is recommend..."
echo -e ""
echo -e "Do you want to reboot now?"
echo -e " "
options=("Reboot" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Reboot")
            sudo reboot
            ;;

        "Quit")
            exit
            ;;
        *) echo -e "invalid option $REPLY";;
    esac
done