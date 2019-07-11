#!/bin/bash
#########################################################################
# James Hipp
# System Support Engineer
# Ready Computing
#
# System Monitor Script that Utilizes DSSH
# Easy way to run monitor commands on multiple servers
#
# Unlike dssh.sh, this Script Generates a Human-Readable
# Log Report File in /tmp
#
# run mon_dssh [hosts_file_name]
# Ex: ./mon_dssh.sh hosts.list
#
# Directional Key-Exchange Setup is Recommended
#
# Currently only has Functionality for CentOS/RHEL but checks for Debian
#
#
### CHANGE LOG ###
#
# 3/4/2019 = Changed CConsole Tail to Grep for 1-2-3 Error Codes
# 3/5/2019 = Added Hosts Filename to Log Report Filename
# 3/6/2019 = Added Memory as Percentage in check_mem
#
#########################################################################

HOST_LIST_FILE=$1
LOGFILE="/tmp/mon_dssh_`date +%Y%m%d_%H_%M`_${HOST_LIST_FILE}.log"

create_log () {

   echo "" >> $LOGFILE
   echo "Running Monitor DSSH Script for $HOST_LIST_FILE" >> $LOGFILE
   echo "Timestamp = `date`" >> $LOGFILE
   echo "" >> $LOGFILE
   echo "-----------------------------------------------------------------------------------------------" >> $LOGFILE
   echo "" >> $LOGFILE

}

check_version ()
{

   echo "### Version Details for $HOST ###" >> $LOGFILE
   echo "" >> $LOGFILE
   /bin/ssh -o ConnectTimeout=1 $HOST 'hostnamectl |egrep -i "hostname|System|Kernel|Arch"' >> $LOGFILE
   echo "" >> $LOGFILE

}

check_mem () {

   echo "### Memory Check for $HOST ###" >> $LOGFILE
   echo "" >> $LOGFILE
   /bin/ssh -o ConnectTimeout=1 $HOST 'free -m' >> $LOGFILE
   echo "" >> $LOGFILE
   echo "Percentage of RAM in Use:" >> $LOGFILE
   /bin/ssh -o ConnectTimeout=1 $HOST free -m |grep Mem |awk '{print $3/$2 * 100.0}' >> $LOGFILE
   echo "" >> $LOGFILE
   echo "Percentage of RAM Free:" >> $LOGFILE
   /bin/ssh -o ConnectTimeout=1 $HOST free -m |grep Mem |awk '{print $4/$2 * 100.0}' >> $LOGFILE
   echo "" >> $LOGFILE
   echo "" >> $LOGFILE
   echo "Percentage of Swap in Use:" >> $LOGFILE
   /bin/ssh -o ConnectTimeout=1 $HOST free -m |grep Swap |awk '{print $3/$2 * 100.0}' >> $LOGFILE
   echo "" >> $LOGFILE

}

check_cpu () {

   echo "### CPU Utilization for $HOST ###" >> $LOGFILE
   echo "(Top 10 Processes Listed)" >> $LOGFILE
   echo "" >> $LOGFILE
   /bin/ssh -o ConnectTimeout=1 $HOST 'top -bn1 |head -n 18' >> $LOGFILE
   echo "..." >> $LOGFILE
   echo "" >> $LOGFILE

}

check_disk () {

   echo "### Disk Usage for $HOST ###" >> $LOGFILE
   echo "" >> $LOGFILE
   /bin/ssh -o ConnectTimeout=1 $HOST 'df -h' >> $LOGFILE
   echo "" >> $LOGFILE

}

check_os () {

   if /bin/ssh -o ConnectTimeout=1 $HOST 'test -e /etc/redhat-release'
   then
      check_rhel
   fi


   if /bin/ssh -o ConnectTimeout=1 $HOST 'test -e /etc/debian_version'
   then
      check_deb
   fi

}

check_rhel () {

   ### Perform CentOS/RHEL Specific Checks ###
   echo "### Linux OS Specific Checks for $HOST ###" >> $LOGFILE
   echo "System OS is CentOS/RHEL" >> $LOGFILE
   echo "" >> $LOGFILE

   /bin/ssh -o ConnectTimeout=1 $HOST '/usr/sbin/sestatus' >> $LOGFILE
   echo "" >> $LOGFILE

   /bin/ssh -o ConnectTimeout=1 $HOST 'systemctl status firewalld |egrep "firewalld.service|Active|Main PID"' >> $LOGFILE
   echo "" >> $LOGFILE

   ### Check if Apache is Installed and Check Status
   if /bin/ssh -o ConnectTimeout=1 $HOST 'test -e /usr/sbin/httpd'
   then
      echo "Apache is Installed, Checking Status" >> $LOGFILE
      /bin/ssh -o ConnectTimeout=1 $HOST 'systemctl status httpd |egrep "httpd.service|Active|Main PID"' >> $LOGFILE
   else
      echo "Apache is Not Installed" >> $LOGILE
   fi

   echo "" >> $LOGFILE
   echo "Checking NTP Services" >> $LOGFILE
   echo "" >> $LOGFILE

   /bin/ssh -o ConnectTimeout=1 $HOST 'echo "Current System Timestamp = " `date`' >> $LOGFILE
   echo "Local System Timestamp (For Comparison)" `date` >> $LOGFILE 
   echo "" >> $LOGFILE

   ### Check if NTPD is Installed ###
   if /bin/ssh -o ConnectTimeout=1 $HOST 'test -e /usr/sbin/nttpd'
   then
      echo "NTPD is Installed, Checking Status" >> $LOGFILE
      /bin/ssh -o ConnectTimeout=1 $HOST 'systemctl status ntpd |egrep "ntpd.service|Active|Main PID"' >> $LOGFILE
   else
      echo "NTPD is Not Installed" >> $LOGFILE
   fi

   echo "" >> $LOGFILE

   ### Check if ChronyD is Installed ###
   if /bin/ssh -o ConnectTimeout=1 $HOST 'test -e /usr/sbin/chronyd'
   then
      echo "ChronyD is Installed, Checking Status" >> $LOGFILE
      /bin/ssh -o ConnectTimeout=1 $HOST 'systemctl status chronyd |egrep "chronyd.service|Active|Main PID"' >> $LOGFILE
   else
      echo "ChronyD is Not Installed" >> $LOGFILE
   fi

   echo "" >> $LOGFILE

   ### Checking if Cache is Installed ###
   if /bin/ssh -o ConnectTimeout=1 $HOST 'test -e /usr/bin/ccontrol'
   then
      echo "Cache is Installed, Running Some Checks" >> $LOGFILE
      /bin/ssh -o ConnectTimeout=1 $HOST 'ccontrol list' >> $LOGFILE
      echo "" >> $LOGFILE
      echo "Tailing CConsole Log Files:" >> $LOGFILE
      echo "" >> $LOGFILE
      /bin/ssh -o ConnectTimeout=1 $HOST 'cat /intersystems/*/mgr/cconsole.log \
         |egrep -i "\) 1 | \) 2 | \( 3" |tail -n 20' >> $LOGFILE
   else
      echo "Cache is Not Installed" >> $LOGFILE
   fi

   echo "" >> $LOGFILE

}

check_deb () {

   ### Perform Debian/Ubuntu Specific Checks ###
   echo "System OS is Debian/Ubuntu" >> $LOGFILE

}


mon_dssh () {

   create_log

   for HOST in `cat $HOST_LIST_FILE`
   do
      echo ""
      echo "Running mon_dssh for Host = $HOST"
      /bin/ssh -o ConnectTimeout=1 $HOST 'echo "--> Hostname = `hostname`" && echo ""' >> $LOGFILE
      ### Run our Check Functions ###
      #check_version
      check_mem
      check_cpu
      check_disk
      #check_os
      echo "-----------------------------------------------------------------------------------------------" >> $LOGFILE
      echo "" >> $LOGFILE
   done

   echo ""
   echo ""
   echo "Mon DSSH Script Run Complete!"
   echo ""

}

mon_dssh

