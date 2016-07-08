#!/bin/sh

cp intelekts.sh /home/pi
chmod 755 /home/pi/intelekts.sh

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
;;
*)
echo "Use start or stop parameter"
exit 1
;;
esac
EOF

chmod 755 /etc/init.d/radio
update-rc.d radio defaults
