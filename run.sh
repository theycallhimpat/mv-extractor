# see https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285
#export HOSTNAME=`hostname`
#export DISPLAY="${HOSTNAME}:0"
# this seems to work better
export DISPLAY=host.docker.internal:0
docker run -it --ipc=host --env="DISPLAY" -v $(pwd):/home/video_cap -v /tmp/.X11-unix:/tmp/.X11-unix:rw mv-extractor /bin/bash
