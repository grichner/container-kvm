## virsh domxml-to-native qemu-argv win10
LC_ALL=C PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin \
QEMU_AUDIO_DRV=spice \
/usr/bin/qemu-kvm -name guest=win10,debug-threads=on \
-object secret,id=masterKey0,format=raw,file=/var/lib/libvirt/qemu/domain--1-win10/master-key.aes \
-machine pc-q35-3.0,accel=kvm,usb=off,vmport=off,dump-guest-core=off \
-cpu Skylake-Client-IBRS,ss=on,vmx=on,hypervisor=on,tsc_adjust=on,clflushopt=on,md-clear=on,ssbd=on,xsaves=on,pdpe1gb=on,hv_time,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff \
-m 4096 -realtime mlock=off -smp 2,sockets=2,cores=1,threads=1 \
-uuid 37b053b1-3fc1-4a84-8baa-2d07cc0d764a -no-user-config -nodefaults \
-chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/domain--1-win10/monitor.sock,server,nowait \
-mon chardev=charmonitor,id=monitor,mode=control \
-rtc base=localtime,driftfix=slew -global kvm-pit.lost_tick_policy=delay \
-no-hpet -no-shutdown -global ICH9-LPC.disable_s3=1 \
-global ICH9-LPC.disable_s4=1 -boot strict=on \
-device pcie-root-port,port=0x10,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0x2 \
-device pcie-root-port,port=0x11,chassis=2,id=pci.2,bus=pcie.0,addr=0x2.0x1 \
-device pcie-root-port,port=0x12,chassis=3,id=pci.3,bus=pcie.0,addr=0x2.0x2 \
-device pcie-root-port,port=0x13,chassis=4,id=pci.4,bus=pcie.0,addr=0x2.0x3 \
-device qemu-xhci,p2=15,p3=15,id=usb,bus=pci.2,addr=0x0 \
-drive file=/var/home/kvmwin/vm/win10.img,format=raw,if=none,id=drive-sata0-0-0 \
-device ide-hd,bus=ide.0,drive=drive-sata0-0-0,id=sata0-0-0,bootindex=1 \
-netdev tap,fd=23,id=hostnet0 \
-device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:bd:bc:fd,bus=pci.1,addr=0x0 \
-netdev tap,fd=24,id=hostnet1 -device virtio-net-pci,netdev=hostnet1,id=net1,mac=52:54:00:a7:47:61,bus=pci.4,addr=0x0 \
-chardev pty,id=charserial0 \
-device isa-serial,chardev=charserial0,id=serial0 \
-device usb-tablet,id=input0,bus=usb.0,port=1 -spice port=5901,addr=127.0.0.1,disable-ticketing,image-compression=off,seamless-migration=on \
-k de -device virtio-vga,id=video0,max_outputs=1,bus=pcie.0,addr=0x1 \
-device ich9-intel-hda,id=sound0,bus=pcie.0,addr=0x1b \
-device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0 \
-chardev spicevmc,id=charredir0,name=usbredir \
-device usb-redir,chardev=charredir0,id=redir0,bus=usb.0,port=2 \
-chardev spicevmc,id=charredir1,name=usbredir \
-device usb-redir,chardev=charredir1,id=redir1,bus=usb.0,port=3 \
-device virtio-balloon-pci,id=balloon0,bus=pci.3,addr=0x0 \
-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
-msg timestamp=on