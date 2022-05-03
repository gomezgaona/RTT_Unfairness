#!/usr/bin/python

import os
from mininet.net import Mininet
from mininet.node import Controller, RemoteController, OVSController
from mininet.node import CPULimitedHost, Host, Node
from mininet.node import OVSKernelSwitch, UserSwitch
from mininet.node import IVSSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink, Intf
from subprocess import call

def myNetwork():

    net = Mininet( topo=None,
                   build=False,
                   ipBase='10.0.0.0/24')

    info( '*** Creating a dumbel toplogy with N/2 senders and N/2 receivers ***\n')
    info( '*** Creating switches s1 and s2 ***\n')
    s1 = net.addSwitch('s1', cls=OVSKernelSwitch, failMode='standalone')
    s2 = net.addSwitch('s2', cls=OVSKernelSwitch, failMode='standalone')

    info( '*** Linking switches s1 and s2 ***\n')
    net.addLink(s1, s2)

    info( '*** Linking hosts to switch s1 ***\n')
    max_hosts = 4
    host_num = 1
    hosts = {}

    while host_num <= max_hosts/2 :
        hosts[host_num] = net.addHost('h'+str(host_num), cls=Host, ip=('10.0.0.'+str(host_num))+'/24', defaultRoute=None)
        net.addLink(hosts[host_num], s1)
        host_num += 1

    while host_num <= max_hosts :
        hosts[host_num] = net.addHost('h'+str(host_num), cls=Host, ip=('10.0.0.'+str(host_num))+'/24', defaultRoute=None)
        net.addLink(hosts[host_num], s2)
        host_num += 1       
    
    info( '*** Starting the network ***\n')
    net.build()
    net.start() 

    '''
    info( '*** Starting controllers\n')
    for controller in net.controllers:
        controller.start()
    '''

    info( '*** Starting switches ***\n')
    net.get('s1').start([])
    net.get('s2').start([])

    info( '*** Post configure switches and hosts ****\n')
    #os.system('ovs-vsctl add-port s1 ens2f0')
    #info('*** Adding routes ***')
    os.system('')
    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    myNetwork()