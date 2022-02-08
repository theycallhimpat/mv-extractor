FROM ubuntu:20.04 AS builder

WORKDIR /home/video_cap

# Install build tools
RUN apt-get update -qq --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        wget \
        unzip \
        build-essential \ 
        cmake \
        git \
        pkg-config \
        autoconf \
        automake \
        git-core \
        python3-dev \
        python3-pip \
        python3-numpy \
        python3-pkgconfig && \
    rm -rf /var/lib/apt/lists/*

# Install opencv dependencies
RUN apt-get update -qq --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        libgtk-3-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libv4l-dev \
        libxvidcore-dev \
        libx264-dev \
        libx265-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libatlas-base-dev \
        gfortran \
        openexr \
        libtbb2 \
        libtbb-dev \
        libdc1394-22-dev && \
    rm -rf /var/lib/apt/lists/*


COPY install.sh /home/video_cap

# Install dependencies
RUN mkdir -p /home/video_cap && \
  cd /home/video_cap && \
  chmod +x install.sh
RUN cd /home/video_cap && ./install.sh

# Install FFMPEG dependencies
RUN apt-get update -qq --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libass-dev \
        libfreetype6-dev \
        libsdl2-dev \
        libtool \
        libva-dev \
        libvdpau-dev \
        libvorbis-dev \
        libxcb1-dev \
        libxcb-shm0-dev \
        libxcb-xfixes0-dev \
        texinfo \
        zlib1g-dev \
        nasm \
        yasm \
        libx264-dev \
        libx265-dev \
        libnuma-dev \
        libvpx-dev \
        libfdk-aac-dev \
        libmp3lame-dev \
        libopus-dev && \
    rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY install_ffmpeg.sh /home/video_cap
COPY ffmpeg_patch /home/video_cap/ffmpeg_patch/
RUN mkdir -p /home/video_cap && \
  cd /home/video_cap && \
  chmod +x install_ffmpeg.sh && \
  ./install_ffmpeg.sh

# Install debugging tools
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -yq install \
  gdb \
  python3-dbg

FROM ubuntu:20.04

# install Python
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    pkg-config \
    python3-dev \
    python3-pip \
    python3-pkgconfig && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
  apt-get -yq install \
    libgtk-3-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libmp3lame-dev \
    zlib1g-dev \
    libx264-dev \
    libsdl2-dev \
    libvpx-dev \
    libvdpau-dev \
    libvorbis-dev \
    libopus-dev \
    libdc1394-22-dev \
    liblzma-dev && \
    rm -rf /var/lib/apt/lists/*

# copy libraries
WORKDIR /usr/local/lib
COPY --from=builder /usr/local/lib .
WORKDIR /usr/local/include
COPY --from=builder /home/ffmpeg_build/include .
WORKDIR /home/ffmpeg_build/lib
COPY --from=builder /home/ffmpeg_build/lib .
WORKDIR /usr/local/include/opencv4/
COPY --from=builder /usr/local/include/opencv4/ .
WORKDIR /home/opencv/build/lib
COPY --from=builder /home/opencv/build/lib .

# Set environment variables
ENV PATH="$PATH:/home/bin"
ENV PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/ffmpeg_build/lib/pkgconfig"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/opencv/build/lib"

WORKDIR /home/video_cap

COPY setup.py /home/video_cap
COPY src /home/video_cap/src/

#RUN apt-get update && \
#  DEBIAN_FRONTEND=noninteractive apt-get -yq install software-properties-common && \
#  add-apt-repository ppa:deadsnakes/ppa && \
#  DEBIAN_FRONTEND=noninteractive apt-get -yq install \
#    python3.8 \
#    python3.8-distutils \
#    python3.8-dev && \
#    rm -rf /var/lib/apt/lists/*

# https://stackoverflow.com/questions/65640476/pip3-on-python3-9-fails-on-htmlparser-object-has-no-attribute-unescape
#RUN python3.8 -m pip install --upgrade setuptools pip distlib
#RUN python3.8 -m pip install numpy==1.17.5
RUN python3 -m pip install numpy==1.17.5

# Install Python package
COPY vid.mp4 /home/video_cap
RUN cd /home/video_cap && \
  python3 setup.py install

#CMD ["sh", "-c", "tail -f /dev/null"]
