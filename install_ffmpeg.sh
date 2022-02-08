#!/bin/bash

INSTALL_BASE_DIR="$PWD/.."
INSTALL_DIR="$PWD"

echo "Installing module into: $INSTALL_DIR"

# Download FFMPEG source
FFMPEG_VERSION="4.1.3"
mkdir -p "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg "$INSTALL_BASE_DIR"/bin
cd "$INSTALL_BASE_DIR"/ffmpeg_sources
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-"$FFMPEG_VERSION".tar.bz2
tar xjf ffmpeg-snapshot.tar.bz2 -C "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg --strip-components=1

echo "Cleaning up"
rm -rf "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg-snapshot.tar.bz2
cd "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg

# Install patch for FFMPEG which exposes timestamp in AVPacket
export FFMPEG_INSTALL_DIR="$INSTALL_BASE_DIR/ffmpeg_sources/ffmpeg"
export FFMPEG_PATCH_DIR="$INSTALL_DIR/ffmpeg_patch"

echo "Patching ffmpeg"
chmod +x "$FFMPEG_PATCH_DIR"/patch.sh
"$FFMPEG_PATCH_DIR"/patch.sh

# Compile FFMPEG
echo "Configuring ffpmeg"
echo $PKG_CONFIG_PATH
#export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/lib/aarch64-linux-gnu/pkgconfig/"
cd "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg && \
./configure \
--prefix="$INSTALL_BASE_DIR/ffmpeg_build" \
--pkg-config-flags="--static" \
--extra-cflags="-I$INSTALL_BASE_DIR/ffmpeg_build/include " \
--extra-ldflags="-L$INSTALL_BASE_DIR/ffmpeg_build/lib " \
--extra-libs="-lpthread -lm" \
--ld="g++" \
--bindir="$INSTALL_BASE_DIR/bin" \
--enable-gpl \
--enable-libfreetype \
--enable-libmp3lame \
--enable-libopus \
--enable-libvorbis \
--enable-libvpx \
--enable-libx264 \
--enable-nonfree \
--enable-pic 


echo "Compiling ffpmeg"
make -j $(nproc) && \
make install && \
hash -r

