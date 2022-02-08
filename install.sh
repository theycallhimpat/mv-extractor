#!/bin/bash

INSTALL_BASE_DIR="$PWD/.."
INSTALL_DIR="$PWD"

echo "Installing module into: $INSTALL_DIR"

# Download OpenCV and build from source
cd "$INSTALL_BASE_DIR"
wget -O "$INSTALL_BASE_DIR"/opencv.zip https://github.com/opencv/opencv/archive/4.1.0.zip
unzip -q "$INSTALL_BASE_DIR"/opencv.zip
mv "$INSTALL_BASE_DIR"/opencv-4.1.0/ "$INSTALL_BASE_DIR"/opencv/
rm -rf "$INSTALL_BASE_DIR"/opencv.zip
wget -O "$INSTALL_BASE_DIR"/opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.1.0.zip
unzip -q "$INSTALL_BASE_DIR"/opencv_contrib.zip
mv "$INSTALL_BASE_DIR"/opencv_contrib-4.1.0/ "$INSTALL_BASE_DIR"/opencv_contrib/
rm -rf "$INSTALL_BASE_DIR"/opencv_contrib.zip

cd "$INSTALL_BASE_DIR"/opencv
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D OPENCV_GENERATE_PKGCONFIG=YES \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D OPENCV_ENABLE_NONFREE=ON \
      -D OPENCV_EXTRA_MODULES_PATH="$INSTALL_BASE_DIR"/opencv_contrib/modules ..
make -j $(nproc)
make install
ldconfig
