#!/bin/sh

rm -f TLV_Mounty/TLV_Mounty.zip

cd "/Applications/World of Warcraft/_retail_/Interface/Addons"

zip -r TLV_Mounty/TLV_Mounty.zip TLV_Mounty/localization TLV_Mounty/Bindings.xml TLV_Mounty/CHANGELOG.md TLV_Mounty/LICENSE TLV_Mounty/README.md TLV_Mounty/TLV_Mounty.lua TLV_Mounty/TLV_Mounty.toc
