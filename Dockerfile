# docker build -t kaszarobert/hedgelib:newtagname . --progress=plain

# 1st build HedgeLib from source.
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# To skip build cache for new versions of external repos we jump to a specified commit.
ARG HEDGELIB_REPO_COMMITID=f0ded0a
ARG HEDGELIB_REPO_BRANCH=HedgeLib++

RUN apt-get update -y \
    && apt-get install -yq \
    wget \
    sudo \
    lsb-release \
    gnupg

RUN wget -qO - https://gist.githubusercontent.com/Radfordhound/6e6ce00535d14ae87d606ece93f1e336/raw/9796f644bdedaa174ed580a8aa6874ab82853170/install-lunarg-ubuntu-repo.sh | sh

RUN apt-get update -y \
    && apt-get install -yq \
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
    uuid-dev \
    vulkan-sdk \
    zip \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-Linux-x86_64.sh \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && mkdir /opt/cmake-3.24.1 \
    && /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake-3.24.1 \
    && rm /tmp/cmake-install.sh \
    && ln -s /opt/cmake-3.24.1/bin/* /usr/local/bin \
    && mkdir /Dependencies \
    && cd /Dependencies \
    && git clone https://github.com/martinus/robin-hood-hashing.git \
    && cd robin-hood-hashing \
    && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DRH_STANDALONE_PROJECT=OFF \
    && cmake --build build --config Release \
    && cmake --install build --config Release

RUN git clone -b $HEDGELIB_REPO_BRANCH https://github.com/Radfordhound/HedgeLib.git /application \
      && cd application \
      && git checkout $HEDGELIB_REPO_COMMITID \
      && cmake -S . -B build "-DCMAKE_INSTALL_PREFIX=/application/bin" -DCMAKE_BUILD_TYPE=Release \
      && cmake --build build

# 2nd build puyo text editor and copy the built HedgeLib binaries here.
FROM mcr.microsoft.com/dotnet/sdk:7.0

# To skip build cache for new versions of external repos we jump to a specified commit.
ARG PUYO_REPO_COMMITID=583f7f7
ARG PUYO_REPO_BRANCH=main

RUN mkdir -p /application/HedgeLib
COPY --from=0 /application/build/HedgeArcPack /application/HedgeLib/HedgeArcPack
COPY --from=0 /application/build/HedgeNeedle /application/HedgeLib/HedgeNeedle
COPY --from=0 /application/build/HedgeSet /application/HedgeLib/HedgeSet

RUN chmod -R a+x /application/HedgeLib/* \
  && git clone -b $PUYO_REPO_BRANCH https://github.com/nickworonekin/puyo-text-editor.git /application/puyo-text-editor \
  && cd /application/puyo-text-editor \
  && git checkout $PUYO_REPO_COMMITID \
  && dotnet publish /application/puyo-text-editor -c Release

ENV PATH="${PATH}:/application/puyo-text-editor/src/PuyoTextEditor/bin/Release/net5.0/:/application/HedgeLib/"

CMD ["bash"]

# docker container run kaszarobert/hedgelib HedgeArcPack
# docker container run kaszarobert/hedgelib PuyoTextEditor
