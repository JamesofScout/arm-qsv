FROM automaticrippingmachine/automatic-ripping-machine
LABEL desc="ARM w/ Intel Quick Sync Video Support"

# fix incompatibility https://github.com/automatic-ripping-machine/automatic-ripping-machine/issues/1522
RUN sed -i 's|HANDBRAKE_VERSION=.*|HANDBRAKE_VERSION=1.9.2|' /install_handbrake.sh &&\
         chmod +x /install_handbrake.sh && sleep 1 &&\
         /install_handbrake.sh

# add repo for Intel Arc drivers
RUN wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg > /dev/null &&\
    echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy unified" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list &&\
    apt update &&\
    # install      # Intel Arc compute runtime
    apt install -y libze-intel-gpu1 libze1 intel-opencl-icd clinfo \
                   # dependencies for libva
                   libmfx1 libmfx-tools libmfx-dev vorbis-tools wget libva-dev libdrm-dev \
                   # Intel media driver
                   # https://github.com/intel/media-driver
                   intel-media-va-driver-non-free \
                   # Intel VPL & GPU runtime
                   # https://github.com/intel/libvpl & https://github.com/intel/vpl-gpu-rt
                   libvpl2 libvpl-dev libmfx-gen1.2 &&\
    # cleanup
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# build & install latest libva
# https://github.com/intel/libva?tab=readme-ov-file#build-and-install-libva
RUN mkdir -p quicksync && cd quicksync &&\
    git clone https://github.com/intel/libva.git libva &&\
    cd libva &&\
    # overwrite any libva installed by setting directory to ubuntu default 
    ./autogen.sh --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu &&\
    make && make install &&\
    # cleanup
    cd ../.. && rm -r quicksync
