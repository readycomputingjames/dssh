#########################################################################
#
# Distributed SSH (DSSH) Command
# Easy way to run a command(s) on multiple servers
#
# run dssh [hosts_file_name] ["command"]
# run dssh [hosts_file_name] ['command']
#
# Ex: ./dssh.sh hosts.list "cat /etc/redhat-release"
# Ex: ./dssh.sh hosts.list 'hostname && ip a'
# Ex: ./dssh.sh hosts.list 'hostname && echo "" && cat /etc/lsb-release'
#
#
# Note = Run as User You Want Commands to Execute or Specify User in Hosts File
#
# Key-Exchange is Recommended, unlesss you Want to Type Password for Each One
#
#
## Change Log ##
#
# 4/16/19 = Added "-t" flag to ssh for sudo commands
#
#########################################################################


----------


Reasoning for Script:

This script is designed for a quick way to run low level system or simple application 
commands in an ad-hoc fashion. The script loops through each host in the list, so it 
is not executed in parallel, but rather sequentially. 


----------


Sample Hosts File:

[root@rcjamesworkpc ~]# cat /home/jthipp/Documents/Documentation/Scripts_SRC/hosts.list
james.hipp@10.1.0.7
james.hipp@10.1.0.9
james.hipp@10.1.0.4
james.hipp@10.1.0.6
james.hipp@10.1.0.8
james.hipp@10.1.0.13


----------


Test Usage:

[root@rcjamesworkpc Scripts_SRC]# ./dssh.sh hosts.list 'hostname && echo "" && cat /etc/redhat-release'

james.hipp@10.1.0.7

hostname1

Red Hat Enterprise Linux Server release 7.5 (Maipo)
____________________________________


james.hipp@10.1.0.9

hostname2

Red Hat Enterprise Linux Server release 7.5 (Maipo)
____________________________________


james.hipp@10.1.0.4

hostname3

Red Hat Enterprise Linux Server release 7.5 (Maipo)
____________________________________


james.hipp@10.1.0.6

hostname4

Red Hat Enterprise Linux Server release 7.5 (Maipo)
____________________________________


james.hipp@10.1.0.8

hostname5

Red Hat Enterprise Linux Server release 7.5 (Maipo)
____________________________________


james.hipp@10.1.0.13

hostname6

Red Hat Enterprise Linux Server release 7.5 (Maipo)
____________________________________




