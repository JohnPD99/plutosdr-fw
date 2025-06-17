#!/bin/bash

xhost +local:

docker run --rm --net host -e DISPLAY=$DISPLAY -e TERM \
  --name=maia-sdr-devel --hostname=maia-sdr-devel \
  --ulimit "nofile=1024:1048576" \
  -v vivado2023_2:/opt/Xilinx \
  -v $HOME/Software:/hdl \
  -it ghcr.io/maia-sdr/maia-sdr-devel
