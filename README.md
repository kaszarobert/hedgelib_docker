# HedgeLib Docker

A simple Docker image that contains [HedgeLib](https://github.com/Radfordhound/HedgeLib) and [Puyo Text Editor](https://github.com/nickworonekin/puyo-text-editor) for working with Sonic game based PAC (and other) files.

Usage example:

```
docker container run -v /home/pc/sonic:/app --user $(id -u):$(id -g) kaszarobert/hedgelib HedgeArcPack /app/text/text_common_en.pac /app/text_cnvrs2/text_common_en
```

```
docker container run -v /home/pc/sonic:/app --user $(id -u):$(id -g) kaszarobert/hedgelib PuyoTextEditor /app/text_cnvrs2/text_common_en/ui_Menu.cnvrs-text -o /app/text_xml/text_common_en/ui_Menu.xml
```
