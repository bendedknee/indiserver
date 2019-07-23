FROM debian:stretch-slim as build

ENV INDI_VERSION=1.7.9
ENV INDI_FILE=v$INDI_VERSION.tar.gz

RUN set -x \
    && apt update \
    && apt install -y libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libftdi-dev libgps-dev libraw-dev libdc1394-22-dev libgphoto2-dev libboost-dev libboost-regex-dev librtlsdr-dev liblimesuite-dev libftdi1-dev

WORKDIR /tmp

ADD https://github.com/indilib/indi/archive/$INDI_FILE .

RUN set -x \
	&& tar xvfz $INDI_FILE \
	&& mkdir build \
	&& cd build \
	&& cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release ../indi-$INDI_VERSION/libindi \
	&& make \
	&& make install 

RUN set -x \
	&& mkdir 3rdparty \
	&& cd 3rdparty \
	&& cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release ../indi-$INDI_VERSION/3rdparty \
	&& make \
	&& make install

FROM debian:stretch-slim as release

RUN apt update && apt install -y --no-install-recommends \
		libusb-1.0-0 \
		libcfitsio5 \
		libcurl3-gnutls \
		libgsl2 \
		libjpeg62-turbo \
		ibnova-0.16-0 \
		libogg0 \
		libtheora0 \
		libdc1394-22 \
		libgphoto2-6 \
		libgphoto2-port12 \
		libraw15 \
		libtiff5 \
		libtiffxx5 \
		libgps22 \
		libftdi1-2 \
		libftdi1 \
		libboost-regex1.62.0 \
		&& rm -rf /var/lib/apt/lists/* 

COPY --from=build /usr/local /usr

EXPOSE 7624

ENTRYPOINT ["/usr/bin/indiserver", "-v"]

CMD ["indi_watchdog", "indi_simulator_ccd", "indi_simulator_dome", "indi_simulator_telescope"]


