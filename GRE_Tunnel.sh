#!/bin/bash
read -r -p "Select server fot configuration? [A(local)/B(Wan)/N(none)]: " response

if [[ "$response" =~ ^([a]|[A])$ ]]
then
    echo "Configuration Server A(as local):"
    
    sudo modprobe ip_gre
    lsmod | grep gre
    sudo apt install iptables iproute2
    sudo echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    sudo sysctl -p

    read -p "Insert local ipaddress: " local
    read -p "Insert remote ipaddress: " remote

    sudo ip tunnel add gre1 mode gre local $local remote $remote ttl 255
    sudo ip addr add 10.0.0.1/30 dev gre1
    sudo ip link set gre1 up 

    #ping -c 6 10.0.0.2

    sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/30 ! -o gre+ -j SNAT --to-source $local
    sudo iptables -A PREROUTING -d $local -p tcp -m tcp --dport 22 -j DNAT --to-destination $local:22
    sudo iptables -A PREROUTING -d $local -p tcp -m tcp --dport 53 -j DNAT --to-destination $local
    sudo iptables -A PREROUTING -d $local -p udp -m udp --dport 53 -j DNAT --to-destination $local
    sudo iptables -A PREROUTING -d $local -j DNAT --to-destination $remote
    sudo iptables -A POSTROUTING -j MASQUERADE


elif [[ "$response" =~ ^([bB])$ ]]
then
    #[[ "$response" =~ ^([bB])$ ]]
    echo "Configuration Server B(as Wan):"

    sudo modprobe ip_gre
    lsmod | grep gre
    sudo apt install iptables iproute2
    sudo echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    sudo sysctl -p

    read -p "Insert local ipaddress: " local
    read -p "Insert remote ipaddress: " remote

    sudo ip tunnel add gre1 mode gre local $local remote $remote ttl 255
    sudo ip addr add 10.0.0.2/30 dev gre1
    sudo ip link set gre1 up 

    #ping -c 6 10.0.0.1

    #iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    
    #sudo iptables -t nat -A POSTROUTING -s $local -j MASQUERADE
    sudo iptables -A POSTROUTING -j MASQUERADE


else
    [[ "$response" =~ ^([nN])$ ]]
    exit
fi
