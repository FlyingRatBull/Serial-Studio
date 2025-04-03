FROM ubuntu:22.04

RUN apt update && apt install -y wget
RUN apt install -y libxkbcommon-x11-0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-sync1 libxcb-xfixes0 libxcb-shape0 libx11-xcb1 libfreetype6 libfontconfig1 libdbus-1-3
RUN wget https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/qt-online-installer-linux-x64-4.9.0.run && \
    chmod +x qt-online-installer-linux-x64-4.9.0.run && \
    ./qt-online-installer-linux-x64-4.9.0.run -p minimal --ao --al -m "nraddlvryifjshwpyn@nbmbb.com" --pw "nraddlvryifjshwpyn@nbmbb.com" --rm -c --cp /tmp/qt in qt6.8-full && \
    rm qt-online-installer-linux-x64-4.9.0.run && \
    rm -Rf /tmp/qt

RUN useradd -ms /bin/bash -u 1000 qt
USER qt

RUN cd ~/ && wget https://github.com/dantti/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage && \
    wget https://github.com/dantti/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage && \
    chmod +x linuxdeploy-x86_64.AppImage && \
    chmod +x linuxdeploy-plugin-qt-x86_64.AppImage

USER root

RUN apt update && apt install -y fuse libfuse2 libfuse-dev pkg-config libssl-dev libcups2-dev libgl1-mesa-dev \
    libxkbcommon-x11-0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-xinerama0 libzstd-dev \
    libxcb-image0-dev libxcb-util0-dev libxcb-cursor-dev libudev-dev rpm fakeroot libxkbcommon-dev libxcb-shape0 file \
    qml-module-qtquick-controls cmake g++

USER qt

RUN mkdir ~/build
VOLUME /build
VOLUME /out

ENV QML_SOURCES_PATHS=/src/app/qml
ENV QMAKE=/opt/Qt/6.8.3/gcc_64/bin/qmake
ENV PATH=/opt/Qt/6.8.3/gcc_64/lib/cmake/Qt6/libexec:$PATH

WORKDIR /build
CMD cmake -D CMAKE_PREFIX_PATH="/opt/Qt/6.8.3/gcc_64/lib/cmake" /src && cmake --build . --parallel && \
    ~/linuxdeploy-x86_64.AppImage --appdir /tmp/AppDir -e /build/app/serial-studio -i /src/app/deploy/linux/serial-studio.svg -d /src/app/deploy/linux/serial-studio.desktop --plugin qt --output appimage && mv *.AppImage /out/