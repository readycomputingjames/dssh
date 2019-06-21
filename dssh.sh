#!/bin/bash
#########################################################################
#
# Distribute SSH (DSSH) Command
# Easy way to run a command on multiple servers
#
# run dssh [hosts_file_name] ["command"]
# run dssh [hosts_file_name] ['command']
#
# Ex: dssh hosts.list "cat /etc/redhat-release"
# Ex: ./dssh.sh hosts.list "hostname && echo "" && cat /etc/lsb-release"
#
#
# Note = Run Locally as Root User
#
# Directional Key-Exchange Setups:
#
# RC  = Local Root Account -> James.Hipp
# BH  = Local Root Account -> James.Hipp
# BKC = Local Root Account -> James.Hipp
# HF  = Local Root Account -> James.Hipp
# WCM = Local Root Account -> James.Hipp
#
## Change Log ##
#
# 4/16/19 = Added "-t" flag to ssh for sudo commands
#
#########################################################################

host_list_file=$1
input_command=$2

dssh () {

   for HOST in `cat $host_list_file`
   do
      echo ""
      echo $HOST
      echo ""
      /bin/ssh -t -o ConnectTimeout=5 $HOST $input_command
      echo "____________________________________"
      echo ""
   done

}

dssh

