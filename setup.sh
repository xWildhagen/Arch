#!/bin/bash

sudo systemctl enable iwd.service
sudo systemctl start iwd.service
iwctl
station wlan0 connect "😎"