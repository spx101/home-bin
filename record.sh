#!/bin/bash

cvlc \
screen:// --one-instance \
-I dummy \
--extraintf rc \
--rc-host localhost:8082 \
--no-video :screen-fps=15 :screen-caching=300 \
--sout "#transcode{vcodec=h264,vb=800,fps=5,scale=1,acodec=none}:duplicate{dst=std{access=file,mux=mp4,dst='/home/lg/Videos/screen-$(date +%Y-%m-%d)-at-$(date +%H.%M.%S).mp4'}}"


# --screen-follow-mouse \
# --screen-left=0 --screen-top=0 --screen-width=800 --screen-height=600 \
#vlc \
#-I dummy screen://\
#--dummy-quiet \
#--screen-follow-mouse \
#--screen-left=0 --screen-top=0 --screen-width=1280 --screen-height=720 \
#--no-video :screen-fps=15 :screen-caching=300 \
#--sout "#transcode{vcodec=h264,vb=800,fps=5,scale=1,acodec=none}:duplicate{dst=std{access=file,mux=mp4,dst='/Users/YOUR_HOME_DIR/Desktop/Screencapture $(date +%Y-%m-%d) at $(date +%H.%M.%S).mp4'}}"
#}

# vlc -I dummy screen:// --screen-fps=10 --quiet --sout='#transcode{vcodec=h264,vb072}:standard{access=file,mux=mp4,dst=capture.mp4}'

# echo quit | nc localhost 8082
