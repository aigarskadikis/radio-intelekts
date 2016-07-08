#!/bin/sh

#it is 5:55 in the morning

#lets clean existing log file
> /var/log/mpd/mpd.log

#reread all files in music direcotry
mpc update

#make sure we do not repeat playlist
mpc repeat off

#do not play songs randomly
mpc random off

#clear all playlist
mpc clear

#we need to generate new song on playlist to play
generatenewsong=1

#list all songs in playlist without skits
allmusic=$(mpc ls | grep -v "^Speech")

#caunt how many songs is in playlist now
skaits=$(mpc playlist | wc -l)

#tell the intelect that we do not know what is the next song
nextsongok=0
afterskit=0

#stop playing when the playlist has reached 400 songs
until [ $skaits -gt 399 ]
do

#this happens only if the last song is playing
until [ $generatenewsong -eq 0 ]
do
echo The next song is not calculated yet. Lets do it now.

until [ $nextsongok -eq 1 ]
do

#randomly take one song from list
nextsong=$(echo "$allmusic" | sort --random-sort | tail -1)

#check if the song has not already played today
grep played /var/log/mpd/mpd.log | grep "$nextsong"
if [ $? -ne 0 ]; then
  echo "$nextsong is not played today"
  echo "Lets add $nextsong"
  echo "$nextsong" | mpc add
  nextsongok=1
  else
  echo "$nextsong has been already played"
  nextsongok=0
fi

done



#is this last song in playlist?
nr=$(mpc play | grep playing | sed "s/ /\n/g" | grep "#" | sed "s/#//")
playing=$(echo "$nr" | sed "s/\/.*$//")
all=$(echo "$nr" | sed "s/^.*\///")
if [ $playing -eq $all ]; then
  echo "Now the last song on playlist is playing"
  generatenewsong=1
  nextsongok=0
  else
  generatenewsong=0
fi

done

#is this last song in playlist?
nr=$(mpc play | grep playing | sed "s/ /\n/g" | grep "#" | sed "s/#//")
playing=$(echo "$nr" | sed "s/\/.*$//")
all=$(echo "$nr" | sed "s/^.*\///")
if [ $playing -eq $all ]; then
  echo "Now the last song on playlist is playing"
  generatenewsong=1
  nextsongok=0
  else
  generatenewsong=0
fi


#check if the last two songs include skit
last2songs=$(mpc playlist | tail -3)
echo "$last2songs" | grep "^derek\|^Radio Alise" > /dev/null
if [ $? -eq 0 ]; then
insertskit=0
else
insertskit=1
fi

while [ $insertskit -eq 1 ]
do
echo "Now it is time for skit.."

	hournow=$(date +%H)
	case "$hournow" in
	*)
	#be prepared for next skit
	nextskitok=0

		#lets take seach for next skit and make sure it is not played yet
		until [ $nextskitok -eq 1 ]
		do

		#look for all skits in mp3 direcotry
		allskits=$(mpc ls | grep "^Speech")

		#take randomly next skit
		nextskit=$(echo "$allskits" | sort --random-sort | tail -1)

			#make sure this skit is not played yet
			grep played /var/log/mpd/mpd.log | grep "$nextskit"
			if [ $? -ne 0 ]; then
					echo "$nextskit is not played today"
					nextskitok=1
					echo "Lets add $nextskit"
					echo "$nextskit" | mpc add
				else
					echo "$nextskit has been already played"
					nextskitok=0
			fi

		done
		
	;;
	esac
insertskit=0
afterskit=0
done

until [ $afterskit -eq 1 ]
do

#randomly take one song from list
nextafterskit=$(echo "$allmusic" | sort --random-sort | tail -1)

#check if the song has not already played today
grep played /var/log/mpd/mpd.log | grep "$nextafterskit"
if [ $? -ne 0 ]; then
  echo "$nextafterskit is not played today"
  echo "Lets add $nextafterskit"
  echo "$nextafterskit" | mpc add
  afterskit=1
  generatenewsong=0
  else
  echo "$nextafterskit has been already played"
  afterskit=0
fi

done



sleep 5
echo "hello"

done


