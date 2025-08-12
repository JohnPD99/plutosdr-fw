# Maia SDR ADALM Pluto firmware

This repository contains the modified ADALM Pluto firmware for the
[Maia SDR](https://maia-sdr.org) project. See
[analogdevicesinc/plutosdr-fw](https://github.com/analogdevicesinc/plutosdr-fw)
for the default ADI firmware.

Latest binary Release : [![GitHub Release](https://img.shields.io/github/release/maia-sdr/plutosdr-fw.svg)](https://github.com/maia-sdr/plutosdr-fw/releases/latest)  [![Github Releases](https://img.shields.io/github/downloads/maia-sdr/plutosdr-fw/total.svg)](https://github.com/maia-sdr/plutosdr-fw/releases/latest)

Firmware License : [![Many Licenses](https://img.shields.io/badge/license-LGPL2+-blue.svg)](https://github.com/analogdevicesinc/plutosdr-fw/blob/master/LICENSE.md)  [![Many License](https://img.shields.io/badge/license-GPL2+-blue.svg)](https://github.com/analogdevicesinc/plutosdr-fw/blob/master/LICENSE.md)  [![Many License](https://img.shields.io/badge/license-BSD-blue.svg)](https://github.com/analogdevicesinc/plutosdr-fw/blob/master/LICENSE.md)  [![Many License](https://img.shields.io/badge/license-apache-blue.svg)](https://github.com/analogdevicesinc/plutosdr-fw/blob/master/LICENSE.md) and many others.

## Installation and supported hardware

This repository contains Maia SDR firmware images for the ADI Pluto and the
Pluto+.

See the [installation instructions](https://maia-sdr.org/installation/) for how
to install the firmware and for other supported devices.

## Support

Support is handled through Github issues or dicussions. Issues dealing with the ADALM Pluto
firmware itself (building the firmware, flashing the firmware, etc.) should go
as
[issues in the plutosdr-fw repository](https://github.com/maia-sdr/plutosdr-fw/issues).
Issues having to do with Maia SDR (software or FPGA bugs, features requests, etc.)
should go as [issues in the maia-sdr repository](https://github.com/maia-sdr/maia-sdr/issues).
There are also
[Github discussions in the maia-sdr repository](https://github.com/maia-sdr/maia-sdr/discussions)
for any topics which are not issues (general questions, comments, etc.).

## Build instructions

### 🛠️ Building Custom Firmware Using a Forked `maia-sdr` Monorepo

This guide explains how to use a **custom fork of the full `maia-sdr` monorepo** inside your own `plutosdr-fw` fork, and build firmware using Docker and Vivado.

---

#### 📦 1. Fork Repositories

You need to fork the following GitHub repositories:

- [`maia-sdr/plutosdr-fw`](https://github.com/maia-sdr/plutosdr-fw) → `youruser/plutosdr-fw`
- [`maia-sdr/maia-sdr`](https://github.com/maia-sdr/maia-sdr) → `youruser/maia-sdr`

And then you shall clone plutosdr-fw into a folder called maia-fw inside the home directory.

---

#### 🔧 2. Replace the `maia-sdr` Submodule

From the root of your cloned `plutosdr-fw` repo:

```bash
# Remove existing submodule
git submodule deinit -f maia-sdr
git rm -f maia-sdr
rm -rf .git/modules/maia-sdr

# Add your custom fork as submodule
git submodule add git@github.com:youruser/maia-sdr.git maia-sdr
git submodule update --init --recursive

# Optional: switch to your working branch
cd maia-sdr
git checkout -b my-custom-branch
cd ..

# Commit the updated submodule reference
git add maia-sdr
git commit -m "Use custom fork of maia-sdr monorepo"
git push origin main
```

> ✅ After this, your firmware build will use your custom `maia-hdl`, `maia-httpd`, etc. from the full monorepo.

---

#### 🐳 3. Set Up Docker & Install Vivado 2023.2

> 💡 You must manually install Vivado due to licensing.

##### a. Pull the development container and create volume:

```bash
sudo docker pull ghcr.io/maia-sdr/maia-sdr-devel:latest
sudo docker volume create vivado2023_2
```

##### b. Run Docker with GUI support:

```bash
xhost +local:  # for Vivado GUI support

docker run --rm --net host -e DISPLAY=$DISPLAY -e TERM \
  --name=maia-sdr-devel --hostname=maia-sdr-devel \
  --ulimit "nofile=1024:1048576" \
  -v vivado2023_2:/opt/Xilinx \
  -v $HOME/maia-fw:/hdl \
  -it ghcr.io/maia-sdr/maia-sdr-devel
```

> 💡 You can mount a subdirectory of `$HOME` for safety (like `$HOME/maia-fw`) instead of the whole home directory.

##### c. Install Vivado inside the container

In a second terminal:

```bash
sudo docker exec -u 0 -it maia-sdr-devel /bin/bash
```

Then:

```bash
cd /home/ubuntu
chmod +x FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256_Lin64.bin
./FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256_Lin64.bin
```

- Select "Do not upgrade"
- Choose: VITIS, Vivado, Vitis HLS, Devices for Custom Platforms (SoCs only)
- Install to `/opt/Xilinx` (mapped to Docker volume)

---

#### ⚙️ 4. Configure the Environment Inside the Container

Set up the environment for building:

```bash
cat >> ~/.bashrc
# Paste the following, then press Ctrl+D
source /opt/Xilinx/Vivado/2023.2/settings64.sh
source /opt/rust/env
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin/:/usr/bin:/sbin:/bin:/opt/gcc-arm-linux-gnueabi/bin:$PATH:/opt/oss-cad-suite/bin
```

Apply changes immediately:

```bash
source ~/.bashrc
```

---

#### 🧪 5. Build the Firmware

Inside the Docker container:

```bash
cd /hdl/plutosdr-fw
make
```

This will:

- Use your custom `maia-sdr` contents (`maia-hdl`, `maia-httpd`, etc.)
- Build the firmware and place output in `build/`

---

#### ⚡ Optional: Headless Build Using Docker Compose

You can also build the firmware using the automated Docker Compose setup:

```bash
cd /hdl/plutosdr-fw
./build-docker.sh
```

> ✅ No `xhost`, GUI, or manual container steps required.  
> 🧪 Matches the GitHub Actions CI environment.

---

#### 🔁 Updating Your Submodule

If you push changes to your custom `maia-sdr` fork:

```bash
cd maia-sdr
git pull origin my-custom-branch
cd ..
git add maia-sdr
git commit -m "Update submodule to latest commit"
git push
```

---

#### 🧠 Notes

- GitHub will show the submodule (`maia-sdr`) as a single clickable entry, not its contents.
- The actual files live in the linked repo.
- You can avoid these submodule complexities by flattening the repo, but this is **not recommended** for long-term development.

---

#### ✅ Summary

| Task                             | Tool/Repo                  |
|----------------------------------|-----------------------------|
| Customize HDL, HTTP, etc.        | `maia-sdr` (monorepo)       |
| Wire it into firmware build      | `plutosdr-fw` via submodule |
| Build interactively with GUI     | Docker + Vivado             |
| Build headlessly / CI-style      | `./build-docker.sh`         |

## Hardwaremod:
On the back if the Pluto resistor R102 should be removed so that I2C can be used.
An external clock can not be used anymore due to the hardware mod.
 
## Flashing Instructions for Pluto

### 1. Unlock QSPI Partition via SSH

After building the project, plug in the Pluto and login via SSH. Run the following commands to unlock a locked QSPI partition, allowing the BOOT.BIN to be updated:

```
fw_setenv dfu_ram 'sf probe && sf protect unlock 0 100000;echo Entering DFU RAM mode ... && run dfu_ram_info && dfu 0 ram 0'
device_reboot ram
```

### 2. Enter DFU Mode

After executing the commands above, **power cycle** the Pluto and put it into **DFU mode**.

**To enter DFU mode**:
- Hold the pushbutton (next to the left USB port) while connecting Pluto to power.
- If one LED is illuminated brightly, you are in DFU mode.

### 3. Perform DFU Update from Host

On your host machine:

1. Navigate to `plutosdr-fw/build`
2. Unzip the `plutosdr-fw` zip file
3. Enter the unzipped directory in terminal

Run the following commands (⚠️ **Do not unplug the Pluto during this process, or it will be bricked**):

```
sudo dfu-util -a firmware.dfu -D ./pluto.dfu
sudo dfu-util -a boot.dfu -D ./boot.dfu
sudo dfu-util -R -a uboot-env.dfu -D ./uboot-env.dfu
```

### 4. Apply Hardware Hack via SSH

After the update, SSH into the Pluto again and run:

```
fw_setenv attr_name compatible
fw_setenv attr_val ad9364
fw_setenv mode 1r1t
```

### 5. Final Reboot

Reboot the Pluto. The radiometer should now be up and running.

## Test script for pincontrol and fasthop using gpio pins controlled from PS system

```
#!/bin/sh

if [ `id -u` != "0" ]
then
   echo "This script must be run as root" 1>&2
   exit 1
fi

phy_path="root"

for i in $(find -L /sys/bus/iio/devices -maxdepth 2 -name name)
do
  dev_name=$(cat $i)
  if [ "$dev_name" = "ad9361-phy" ]; then
     phy_path=$(echo $i | sed 's:/name$::')
     cd $phy_path
     break
  fi
done

if [ "$dev_name" != "ad9361-phy" ]; then
 exit
fi

#Setup 8 Profiles 100MHz spaced
for i in `seq 0 7`
do
  echo $((1100000000 + $i * 100000000)) > out_altvoltage0_RX_LO_frequency
  echo "Initializing PROFILE $i at $((1100000000 + $i * 100000000)) MHz"
  echo $i > out_altvoltage0_RX_LO_fastlock_store
done

#Enable Fastlock Mode
iio_attr -D ad9361-phy adi,rx-fastlock-pincontrol-enable 1
echo 0 > out_altvoltage0_RX_LO_fastlock_recall

GPIO_BASE=906

cd /sys/class/gpio

if [ $GPIO_BASE -ge 0 ]
then
  GPIO_CTRL_IN1=`expr $GPIO_BASE + 63`
  GPIO_CTRL_IN2=`expr $GPIO_BASE + 64`
  GPIO_CTRL_IN3=`expr $GPIO_BASE + 65`
  #Export the CTRL_IN GPIOs
  echo $GPIO_CTRL_IN1 > export 2> /dev/null
  echo $GPIO_CTRL_IN2 > export 2> /dev/null
  echo $GPIO_CTRL_IN3 > export 2> /dev/null
else
  echo ERROR: Wrong board?
  exit
fi

CTRL_IN1=gpio${GPIO_CTRL_IN1}/direction
CTRL_IN2=gpio${GPIO_CTRL_IN2}/direction
CTRL_IN3=gpio${GPIO_CTRL_IN3}/direction

for i in `seq 0 7`
do
  echo Setting PROFILE $i
  # BIT 0
  if [ $(($i & 1)) -gt 0 ]
  then
    echo CTRL_IN1:1
    echo high > $CTRL_IN1
  else
    echo CTRL_IN1:0
    echo low > $CTRL_IN1
  fi

  # BIT 1
  if [ $(($i & 2)) -gt 0 ]
  then
    echo CTRL_IN2:1
    echo high > $CTRL_IN2
  else
    echo CTRL_IN2:0
    echo low > $CTRL_IN2
  fi

  # BIT 2
  if [ $(($i & 4)) -gt 0 ]
  then
    echo CTRL_IN3:1
    echo high > $CTRL_IN3
  else
    echo CTRL_IN3:0
    echo low > $CTRL_IN3
  fi

  sleep 1
done

```