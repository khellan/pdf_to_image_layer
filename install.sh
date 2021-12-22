#!/bin/sh
#
# Installs pdf2image, poppler and required libraries.
# The reason we need to install poppler from scratch is
# that the one available with yum is outdated.

PYTHON_VERSION=$1

yum install -y \
    wget \
    freetype-devel \
    fontconfig-devel \
    libjpeg-devel \
    libpng-devel \
    cairo-devel \
    glib2-devel \
    openjpeg2-devel \
    lcms2-devel \
    libtiff-devel \
    libxcb-devel

# We need a recent version of CMake to build poppler
wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-x86_64.sh
chmod a+x cmake-3.22.1-linux-x86_64.sh
./cmake-3.22.1-linux-x86_64.sh --skip-license

# Poppler uses Boost and we need a recent version. We use binaries
wget https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.bz2
tar --bzip2 -xf boost_1_77_0.tar.bz2

# Now build poppler from head
git clone https://github.com/freedesktop/poppler
mkdir poppler/build
pushd poppler/build
../../bin/cmake .. \
    -DCMAKE_INSTALL_PREFIX=/var/task/lib \
    -DCMAKE_BUILD_TYPE=release \
    -DENABLE_LIBCURL=OFF \
    -DBUILD_GTK_TESTS=OFF \
    -DENABLE_QT5=OFF \
    -DENABLE_QT6=OFF \
    -DBUILD_GTK_TESTS=OFF \
    -DBUILD_QT5_TESTS=OFF \
    -DBUILD_QT6_TESTS=OFF \
    -DBUILD_CPP_TESTS=OFF \
    -DBUILD_MANUAL_TESTS=OFF \
    -DBUILD_GTK_DOC=OFF \
    -DBOOST_ROOT=boost_1_77_0
make
make install
popd

# Copy directories from OS to our package area
cp lib/lib64/libpoppler* lib/.
cp /usr/lib64/libcairo* lib/.
cp /usr/lib64/libfontconfig* lib/.
cp /usr/lib64/libEGL* lib/.
cp /usr/lib64/libexpat* lib/.
cp /usr/lib64/libfreetype* lib/.
cp /usr/lib64/libGL* lib/.
cp /usr/lib64/libglib-2* lib/.
cp /usr/lib64/libjbig* lib/.
cp /usr/lib64/libjpeg* lib/.
cp /usr/lib64/liblcms2.so* lib/.
cp /usr/lib64/libopenjp2* lib/.
cp /usr/lib64/libpixman* lib/.
cp /usr/lib64/libpng* lib/.
cp /usr/lib64/libtiff* lib/.
cp /usr/lib64/libuuid* lib/.
cp /usr/lib64/libxcb* lib/.
cp /usr/lib64/libX11* lib/.
cp /usr/lib64/libXau* lib/.
cp /usr/lib64/libXext* lib/.
cp /usr/lib64/libXrender* lib/.

# Copy binaries to our package area
cp lib/bin/pdftocairo bin/.
cp lib/bin/pdfinfo bin/.
cp lib/bin/pdftoppm bin/.

# Add Python libraries
pip install --upgrade pip
pip install -r requirements.txt -t python/lib/python${PYTHON_VERSION}/site-packages/
