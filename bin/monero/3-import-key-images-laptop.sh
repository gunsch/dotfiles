#!/bin/bash

DISK="/Volumes/KINGSTON/monero"

cd $DISK

echo "On desktop, run..."
echo ""
echo "    cd /media/usb/monero && rm -f key-images"
echo ""

wormhole send key-images

echo ""
echo "    cd ~/monero && ./3-import-key-images.sh"
echo ""

echo "Printing deets..."
cat /Volumes/KINGSTON/transfer
