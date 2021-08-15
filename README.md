# 3D accelerated qemu on MacOS

![ubuntu](https://user-images.githubusercontent.com/6728841/111193747-90da1a00-85cb-11eb-9517-36c1a19c19be.gif)

## What is it for

If you own a Mac (x86 or ARM) and want to have a full Linux desktop for development or testing, you'll find that having a responsive desktop is a nice thing. The graphical acceleration is possible thanks to [the work](https://gist.github.com/akihikodaki/87df4149e7ca87f18dc56807ec5a1bc5) of [Akihiko Odaki](https://github.com/akihikodaki). I've only packaged it into an easily-installable brew repository while the changes are not yet merged into upstream.

Features:

- Support for both ARM and X86 acceleration with Hypervisor.framework (works without root or kernel extensions)
- Support for OpenGL acceleration in the guest (both X11 and Wayland)
- Works on large screens (5k+)
- Dynamically changing guest resolution on window resize
- Properly handle sound output when plugging/unplugging headphones

## Installation

`brew install knazarov/qemu-virgl/qemu-virgl`

Or `brew tap knazarov/qemu-virgl` and then `brew install qemu-virgl`.


## Usage

Qemu has many command line options and emulated devices, so the
sections are specific to your CPU (Intel/M1).

For the best experience, maximize the qemu window when it starts. To
release the mouse, press `Ctrl-Alt-g`.

### Usage - M1 Macs

**Latest release needs virtio-gpu-gl-pci command line option instead of virtio-gpu-pci, otherwise gpu acceleration won't work**

First, create a disk image you'll run your Linux installation from (tune image size as needed):

```sh
qemu-img create hdd.raw 64G
```

Download an ARM based Fedora 34 image:

```sh
curl -LO https://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/fedora/linux/releases/34/Workstation/aarch64/iso/Fedora-Workstation-Live-aarch64-34-1.2.iso
```

Copy the firmware:

```sh
cp $(dirname $(which qemu-img))/../share/qemu/edk2-aarch64-code.fd .
cp $(dirname $(which qemu-img))/../share/qemu/edk2-arm-vars.fd .
```

Install the system from the CD image:

```sh
qemu-system-aarch64 \
         -machine virt,accel=hvf,highmem=off \
         -cpu cortex-a72 -smp 2 -m 4G \
         -device intel-hda -device hda-output \
         -device qemu-xhci \
         -device virtio-gpu-gl-pci \
         -device usb-kbd \
         -device virtio-net-pci,netdev=net \
         -device virtio-mouse-pci \
         -display cocoa,gl=es \
         -netdev user,id=net,ipv6=off \
         -drive "if=pflash,format=raw,file=./edk2-aarch64-code.fd,readonly=on" \
         -drive "if=pflash,format=raw,file=./edk2-arm-vars.fd,discard=on" \
         -drive "if=virtio,format=raw,file=./hdd.raw,discard=on" \
         -cdrom Fedora-Workstation-Live-aarch64-34-1.2.iso \
         -boot d
```

Run the system without the CD image to boot into the primary partition:

```sh
qemu-system-aarch64 \
         -machine virt,accel=hvf,highmem=off \
         -cpu cortex-a72 -smp 2 -m 4G \
         -device intel-hda -device hda-output \
         -device qemu-xhci \
         -device virtio-gpu-gl-pci \
         -device usb-kbd \
         -device virtio-net-pci,netdev=net \
         -device virtio-mouse-pci \
         -display cocoa,gl=es \
         -netdev user,id=net,ipv6=off \
         -drive "if=pflash,format=raw,file=./edk2-aarch64-code.fd,readonly=on" \
         -drive "if=pflash,format=raw,file=./edk2-arm-vars.fd,discard=on" \
         -drive "if=virtio,format=raw,file=./hdd.raw,discard=on"
```


### Usage - Intel Macs

First, create a disk image you'll run your Linux installation from (tune image size as needed):

```sh
qemu-img create hdd.raw 64G
```

Download an x86 based Fedora 34 image:

```sh
curl -LO https://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/fedora/linux/releases/34/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-34-1.2.iso
```

Install the system from the CD image:

```sh
qemu-system-x86_64 \
         -machine accel=hvf \
         -cpu Haswell-v4 -smp 2 -m 4G \
         -device intel-hda -device hda-output \
         -device qemu-xhci \
         -device virtio-vga-gl \
         -device usb-kbd \
         -device virtio-net-pci,netdev=net \
         -device virtio-mouse-pci \
         -display cocoa,gl=es \
         -netdev user,id=net,ipv6=off \
         -drive "if=virtio,format=raw,file=hdd.raw,discard=on" \
         -cdrom Fedora-Workstation-Live-x86_64-34-1.2.iso \
         -boot d
```

Run the system without the CD image to boot into the primary partition:

```sh
qemu-system-x86_64 \
         -machine accel=hvf \
         -cpu Haswell-v4 -smp 2 -m 4G \
         -device intel-hda -device hda-output \
         -device qemu-xhci \
         -device virtio-vga-gl \
         -device usb-kbd \
         -device virtio-net-pci,netdev=net \
         -device virtio-mouse-pci \
         -display cocoa,gl=es \
         -netdev user,id=net,ipv6=off \
         -drive "if=virtio,format=raw,file=hdd.raw,discard=on"
```


## Usage - Advanced

This section has additional configuration you may want to do to improve your workflow


### Clipboard sharing

There's now support for sharing clipboard in both directions: from vm->host and host->vm. To enable clibpoard sharing, add this to your command line:

```
         -chardev qemu-vdagent,id=spice,name=vdagent,clipboard=on \
         -device virtio-serial-pci \
         -device virtserialport,chardev=spice,name=com.redhat.spice.0
```

### Mouse integration

By default, you have mouse pointer capture and have to release mouse pointer from the VM using keyboard shortcut. In order to have seamless mouse configuration,
add the following to your command line instead of `-device virtio-mouse-pci`:

```
	-device usb-tablet \
```

### MacOS native networking for VMs (vmnet)

akihikodaki's patch set includes support for vmnet which offers more flexibility than `-netdev user`, and allows higher network throughput. (see https://github.com/akihikodaki/qemu/commit/72a35bb6e0a16bb7d346ba822a6d47293915fc95).

For instance, to enable bridge mode, replace:

```
    -device virtio-net-pci,netdev=net \
    -netdev user,id=net,ipv6=off \
```

with


```
    -netdev vmnet-macos,id=n1,mode=bridged,ifname=en0 \
    -device virtio-net,netdev=n1 \
```

vmnet also offers "host" and "shared" networking model:

```
   -netdev vmnet-macos,id=str,mode=host|shared[,dhcp_start_address=addr,dhcp_end_address=addr,dhcp_subnet_mask=mask]
```

***caveats:***

1) vmnet requires running qemu as root, for now.
2) current vmnet API (Apple) doesn't support setting MAC address, so it will be randomized every time the VM is started.

To work around 2), for now it's possible to set the MAC address within the VM.

As root, create a file `/etc/udev/rules.d/75-mac-vmnet.rules` with the following content:

```
ACTION=="add", SUBSYSTEM=="net", KERNEL=="enp0s3", RUN+="/usr/bin/ip link set dev %k address 00:11:22:33:44:55"
```

replace `enp0s3` with the name of your interface and `00:11:22:33:44:55` with the desired MAC address.

Reboot or issue a `ip link set dev enp0s3 address 00:11:22:33:44:55` to change your MAC address.
