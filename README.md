# plumbus-freezer

WARNING: This script can ruin systems and cause damage. Only the person who runs it is responsible for the damage caused by it.

This is an educational demonstration of the power of root in the unix based world. Run it as a regular user on 
your demo machine, show what still logs and what doesn't, try using logger, then run it as root and see the difference.
If the non-root user shut things down, then there is a permissions/ownership problem on the host!

Also a sub-lesson on not keeping debugger/tracer programs on prod systems within this :)

A sHell script that makes a server... frozen. A complete jerk move demonstration of what root can do.
This thing is kinda like a pre-intrusion smoke screen if you will. Drop in the plumbus-freezer and then your activity
won't be logged for 9 minutes, most likely. Depends on what is going on, but it is made to be generic for most unix based systems.

Snapshot your machine before you run this! Especially if you use the freeze3 function or -redplumbus option.

This is for educational purposes, teaching cyber security and the importance of control over the root account etc.
