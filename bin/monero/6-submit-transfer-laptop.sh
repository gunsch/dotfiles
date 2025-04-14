#!/bin/bash

DISK="/Volumes/KINGSTON/monero"

cd $DISK

echo "On desktop, run..."
echo ""
echo "    cd /media/usb/monero && rm -f signed_monero_tx"
echo ""

wormhole send signed_monero_tx

echo ""
echo "    cd ~/monero && ./6-submit-transfer.sh"
echo ""
