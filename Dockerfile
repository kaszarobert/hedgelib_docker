# docker build -t kaszarobert/hedgelib:latest .

FROM mcr.microsoft.com/dotnet/sdk:7.0

RUN apt update -y && apt install unzip -y

RUN mkdir /application \
  && wget https://ci.appveyor.com/api/buildjobs/ngm89dex1t8d1n10/artifacts/HedgeLib.zip -P /application \
  && unzip /application/HedgeLib.zip -d /application/HedgeLib \
  && chmod -R a+x /application/HedgeLib/* \
  && git clone https://github.com/nickworonekin/puyo-text-editor.git /application/puyo-text-editor \
  && dotnet publish /application/puyo-text-editor -c Release

ENV PATH="${PATH}:/application/puyo-text-editor/src/PuyoTextEditor/bin/Release/net5.0/:/application/HedgeLib/bin/"

CMD ["bash"]

# docker container run kaszarobert/hedgelib HedgeArcPack
# docker container run kaszarobert/hedgelib PuyoTextEditor
