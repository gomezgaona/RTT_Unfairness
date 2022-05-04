#!/bin/bash

function ticker () {
  #Ticker
  n=0
  while [ $n -le $1 ]; do
    echo -en tick: $n "\r"
    ((n=n+1))
    sleep 1
  done
}

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
sudo tc qdisc add dev s1-eth1 root handle 1: tbf rate 10gbit burst 500000 limit 2500000 # for 60ms
sudo tc qdisc add dev s2-eth3 root handle 1: tbf rate 10gbit burst 500000 limit 78643200 # for 60ms

#Establishing RT Unfairness
sudo tc qdisc del dev s2-eth3 root
sudo tc qdisc add dev s2-eth3 root netem delay 60ms

#Killing previous iperf3 servers
sudo pkill iperf3 #&> /dev/null 

#Starting iperf3 servers
$h3 iperf3 -s  > /dev/null &
$h4 iperf3 -s  > /dev/null &
sleep 1

test_duration=120
#Starting iperf3 Clients
echo "Starting iperf3 Clients"

for i in {1..1}
do
   $h1 iperf3 -c 10.0.0.3 -t $test_duration -J > results/h1_"$i".json &
   $h2 iperf3 -c 10.0.0.4 -t $test_duration -J > results/h2_"$i".json &
   
   echo "Run: $i" 
   ticker "$test_duration"
done
