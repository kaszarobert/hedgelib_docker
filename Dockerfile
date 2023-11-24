# docker build -t kaszarobert/hedgelib:latest .

# 1st build HedgeLib from source.
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update -y && \
    apt-get install -yq \
    wget \
    sudo \
    lsb-release \
    gnupg

RUN wget -qO - https://gist.githubusercontent.com/Radfordhound/6e6ce00535d14ae87d606ece93f1e336/raw/9796f644bdedaa174ed580a8aa6874ab82853170/install-lunarg-ubuntu-repo.sh | sh

RUN apt-get update -y && \
    apt-get install -yq \
    git \
    cmake \
    gcc-9-multilib \
    g++-9-multilib \
    libuuid1 \
    rapidjson-dev \
    libglm-dev \
    liblz4-dev \
    zlib1g-dev \
    libglfw3-dev \
    vulkan-sdk \
    zip

RUN apt-get update -y \
  && apt-get -y install build-essential \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-Linux-x86_64.sh \
      -q -O /tmp/cmake-install.sh \
      && chmod u+x /tmp/cmake-install.sh \
      && mkdir /opt/cmake-3.24.1 \
      && /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake-3.24.1 \
      && rm /tmp/cmake-install.sh \
      && ln -s /opt/cmake-3.24.1/bin/* /usr/local/bin

RUN mkdir /Dependencies && \
    cd /Dependencies && \
    git clone https://github.com/martinus/robin-hood-hashing.git && \
    cd robin-hood-hashing && \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DRH_STANDALONE_PROJECT=OFF && \
    cmake --build build --config Release && \
    cmake --install build --config Release

RUN git clone -b HedgeLib++ https://github.com/Radfordhound/HedgeLib.git /app

RUN apt-get update -y && apt-get install uuid-dev -y

WORKDIR /app

RUN cmake -S . -B build "-DCMAKE_INSTALL_PREFIX=/app/bin" -DCMAKE_BUILD_TYPE=Release

RUN cmake --build build

# 2nd build puyo text editor and copy the built HedgeLib binaries here.
FROM mcr.microsoft.com/dotnet/sdk:7.0

RUN mkdir -p /application/HedgeLib
COPY --from=0 /app/build/HedgeArcPack /application/HedgeLib/HedgeArcPack
COPY --from=0 /app/build/HedgeNeedle /application/HedgeLib/HedgeNeedle
COPY --from=0 /app/build/HedgeSet /application/HedgeLib/HedgeSet

RUN chmod -R a+x /application/HedgeLib/* \
  && git clone https://github.com/nickworonekin/puyo-text-editor.git /application/puyo-text-editor \
  && dotnet publish /application/puyo-text-editor -c Release

ENV PATH="${PATH}:/application/puyo-text-editor/src/PuyoTextEditor/bin/Release/net5.0/:/application/HedgeLib/"

CMD ["bash"]

# docker container run kaszarobert/hedgelib HedgeArcPack
# docker container run kaszarobert/hedgelib PuyoTextEditor
