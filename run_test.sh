#!/bin/bash

#Hosts
h1='/home/gomezgaj/mininet/util/m h1'
h2='/home/gomezgaj/mininet/util/m h2'
h3='/home/gomezgaj/mininet/util/m h3'
h4='/home/gomezgaj/mininet/util/m h4'

#Setting the TCP send and receivce buffer size
$h1 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 20000000\" > /dev/null
$h1 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 200000000\" > /dev/null
$h2 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 200000000\" > /dev/null
$h2 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 200000000\" > /dev/null
$h3 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 200000000\" > /dev/null
$h3 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 200000000\" > /dev/null
$h4 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 200000000\" > /dev/null
$h4 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 200000000\" > /dev/null

#Setting the congestion control
cc="bbr"
$h1 sysctl -w net.ipv4.tcp_congestion_control=$cc > /dev/null
$h2 sysctl -w net.ipv4.tcp_congestion_control=$cc > /dev/null
$h3 sysctl -w net.ipv4.tcp_congestion_control=$cc > /dev/null
$h4 sysctl -w net.ipv4.tcp_congestion_control=$cc > /dev/null

#Deleting previous qdiscs
sudo tc qdisc del dev s1-eth1 root

#Setting the bottleneck 
#sudo tc qdisc add dev s1-eth1 root handle 1: tbf rate 10gbit burst 5000000 limit 78643200 # for 60ms
sudo tc qdisc add dev s1-eth1 root handle 1: tbf rate 1gbit burst 500000 limit 7864320 # for 60ms

#Establishing RT Unfairness
$h2 sudo tc qdisc del dev h2-eth0 root
$h2 sudo tc qdisc add dev h2-eth0 root netem delay 60ms

#Killing previous iperf3 servers
sudo pkill iperf3 #&> /dev/null 

#Starting iperf3 servers
$h3 iperf3 -s  > /dev/null &
$h4 iperf3 -s  > /dev/null &
sleep 1

test_duration=300
#Starting iperf3 Clients
echo "Starting iperf3 Clients"
$h1 iperf3 -c 10.0.0.3 -t $test_duration -J > results/out1.json &
$h2 iperf3 -c 10.0.0.4 -t $test_duration -J > results/out2.json &

#Ticker
i=1
while [ $i -le $test_duration ]; do
  echo -en tick: $i "\r"
  ((i=i+1))
  sleep 1
done
