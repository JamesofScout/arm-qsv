FROM docker.io/automaticrippingmachine/automatic-ripping-machine:latest
LABEL desc="ARM with Intel Quick Sync Video (QSV) Support"

# ===== Environment =====
ENV LIBVA_DRIVERS_PATH="/usr/lib/x86_64-linux-gnu/dri"

# ===== Install dependencies and Intel drivers =====
RUN set -eux; \
	echo "**** Install base dependencies ****" \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		gnupg \
		wget \
		libexpat1 \
		libglib2.0-0 \
		libgomp1 \
		libharfbuzz0b \
		libmediainfo0v5 \
		libv4l-0 \
		libx11-6 \
		libxcb1 \
		libxext6 \
		libxml2 \
		hwinfo \
	\
	# ==== Intel GPU repository and driver install ====
	&& echo "**** Add Intel GPU repository ****" \
	&& wget -qO - https://repositories.intel.com/gpu/intel-graphics.key \
		| gpg --dearmor -o /usr/share/keyrings/intel-graphics.gpg \
	&& echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" \
		> /etc/apt/sources.list.d/intel-gpu-jammy.list \
	&& apt-get update \
	&& echo "**** Install Intel VAAPI & VPL packages ****" \
	&& apt-get install -y --no-install-recommends \
		intel-media-va-driver-non-free \
		intel-opencl-icd \
		intel-level-zero-gpu \
		level-zero \
		libigdgmm12 \
		libmfx1 \
		libmfxgen1 \
		libva-drm2 \
		libva2 \
		libvpl2 \
		# This is just upgrading preinstalled packages to the latst versions from the intel repo
		# but they probably aren't required
		libdrm-amdgpu1 \
		libdrm-common \
		libdrm-dev \
		libdrm-intel1 \
		libdrm-nouveau2 \
		libdrm-radeon1 \
		libdrm2	\
		libegl-dev \
		libegl-mesa0 \
		libegl1	\
		libgbm1	\
		libgl-dev \
		libgl1-mesa-dri	\
		libgl1 \
		libglapi-mesa \
		libglvnd0 \
		libglx-dev \
		libglx-mesa0 \
		libglx0	\
		libopengl0 \
		libvdpau1 \
		mesa-va-drivers \	
		va-driver-all \
		vainfo \
	\
	# ==== Jellyfin FFmpeg (includes AV1_QSV support) ====
	&& echo "**** Add Jellyfin FFmpeg repository ****" \
	&& wget -qO - https://repo.jellyfin.org/jellyfin_team.gpg.key \
		| gpg --dearmor -o /usr/share/keyrings/jellyfin_team.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/jellyfin_team.gpg] https://repo.jellyfin.org/ubuntu jammy main" \
		> /etc/apt/sources.list.d/jellyfin.list \
	&& apt-get update \
	&& apt-get remove --purge ffmpeg -y \
	&& apt-get install -y --no-install-recommends \
		jellyfin-ffmpeg6 \
		openssl \
		locales \
	&& ln -sf /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/local/bin/ffmpeg \
	&& ln -sf /usr/lib/jellyfin-ffmpeg/ffprobe /usr/local/bin/ffprobe \
	\
	# ==== Cleanup ====
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
