#!/bin/bash


downloads_directory=/srv/yt/downloads

#Verification if directory exists
if [[ -d "$downloads_directory" ]] ; then
    echo "[INFO] The directory /downloads already exists."
else 
    echo "[INFO] The directory doesn't exist. It will be created."
    mkdir '/srv/yt/downloads'
fi

title="$(youtube-dl -e ${1})"

#Make directory of the video
mkdir "/srv/yt/downloads/${title}"


#Download the video 

youtube-dl -q -o "/srv/yt/downloads/${title}/%(title)s.%(ext)s" ${1}

#Output
echo "Video ${1} was downloaded."
echo "File path : /srv/yt/downloads/${title}/$(youtube-dl -e ${1})"

#Log

echo "[$(date "+%D  %H:%M:%S")] Video ${1} was downloaded. File path : /srv/yt/downloads/${title}/$(youtube-dl -e ${1})" >> /var/log/yt/download.log
