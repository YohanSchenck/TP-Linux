#!/bin/bash

downloads_directory=/srv/yt/downloads
list_URL=/srv/yt/list_URL

#Verification if directory exists
if [[ -d "$downloads_directory" ]] ; then
    echo "[INFO] The directory /downloads already exists."
else
    echo "[INFO] The directory doesn't exist. It will be created."
    mkdir '/srv/yt/downloads'
fi

while :
do
	#Verification if the file is empty
	if [[ -s $list_URL ]] ; then

		url="$(sed -n 1p /srv/yt/list_URL)"
		
		#Verification URL
		youtube-dl -s -q ${url}

		if [[ $(echo $?) -eq  0 ]] ; then
			title="$(youtube-dl -e ${url})"

			#Make directory of the video
			mkdir "/srv/yt/downloads/${title}"


			#Download the video 
			youtube-dl -q -o "/srv/yt/downloads/${title}/%(title)s.%(ext)s" ${url}

			#Output
			echo "Video ${url} was downloaded."
			echo "File path : /srv/yt/downloads/${title}/$(youtube-dl -e ${url})"

			#Log

			echo "[$(date "+%D  %H:%M:%S")] Video ${url} was downloaded. File path : /srv/yt/downloads/${title}/$(youtube-dl -e ${url})" >> /var/log/yt/download.log


			#Delete line
			sed -i '1d' /srv/yt/list_URL
		else 
			sed -i '1d' /srv/yt/list_URL
		fi
	fi

sleep 5

done
