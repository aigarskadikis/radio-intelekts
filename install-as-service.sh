#!/bin/sh

#copy main script to users [pi] home directory
cp intelekts.sh /home/pi

#make main script executable
chmod 755 /home/pi/intelekts.sh

#install service, so the radio will start to stream at system boot
cat > /etc/init.d/radio << EOF
#!/bin/sh
case "\$1" in
start)
/home/pi/intelekts.sh &
echo "Radio started"
;;
stop)
mpc stop
echo "Radio stopped"
sleep 1
;;
restart)
mpc stop
echo "Radio stopped"
sleep 1
> /var/log/mpd/mpd.log
sleep 1
/home/pi/intelekts.sh &
echo "Radio restarted"
;;
*)
echo "Use start or stop parameter"
exit 1
;;
esac
EOF

#set service file executable
chmod 755 /etc/init.d/radio

#re-read all service situation
update-rc.d radio defaults

#shedule to restart radio two times in 24 hours
echo "55 14,3 * * * root /etc/init.d/radio restart" >> /etc/crontab
