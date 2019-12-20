To determine the best way for merging Windows Operating System into the Appliance Box, we need to evaluate several Technologies:

KVM/QEMU

VirtualMachine

VMWare Sphere

KVM

kvm can be implemented as Kernel-Module directly on the host or in a docker-container.

Automation (scripted installation) section:

for Host install you need (root):

rpm-ostree install libvirt virt-install qemu-kvm samba
rpm-ostree install xorg-x11-xdm p7zip traceroute telnet
rpm-ostree install virt-top libguestfs-tools
rpm-ostree install virt-manager qemu virt-viewer spice-vdagent
##for fast installation:## rpm-ostree install libvirt virt-install qemu-kvm samba xorg-x11-xdm p7zip traceroute telnet virt-top libguestfs-tools virt-manager qemu virt-viewer spice-vdagent
systemctl reboot # to make group libvirt accessible

after reboot do add a new user kvmwin and add 

echo 'unix_sock_group = "libvirt"'>>/etc/libvirt/libvirtd.conf
echo 'unix_sock_rw_perms = "0770"'>>/etc/libvirt/libvirtd.conf
systemctl restart libvirtd.service
sed -i -e 's/AllowUsers\ maintenance/AllowUsers\ maintenance\ kvmwin/g' /etc/ssh/sshd_config
systemctl restart sshd.service
useradd kvmwin
getent group | grep libvirt >> /etc/group
usermod kvmwin --append --groups libvirt
usermod kvmwin --append --groups wheel
echo "kvmwin:OAkvmwin10" | chpasswd
chmod a+w /etc/sudoers
sed -i -e 's/\#\ \%wheel\tALL=(ALL)\tNOPASSWD:\ ALL/\%wheel\tALL=(ALL)\tNOPASSWD:\ ALL/g' /etc/sudoers
chmod a-w /etc/sudoers
echo 'user="kvmwin"' >>/etc/libvirt/qemu.conf
echo 'group="kvmwin"' >>/etc/libvirt/qemu.conf
systemctl restart libvirtd.service
su - kvmwin
echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"'>>/home/kvmwin/.bashrc

login as “kvmwin” user and make sure x11/cygwin is installed

#wget https://win10kvm.blob.core.windows.net/images/kvmuser-directory-initial-win10.7z
wget https://win10kvm.blob.core.windows.net/images/kvmuser-directory-initial-win10-withoutISOz.7z
#7za x kvmuser-directory-initial-win10.7z || exit 235
7za x kvmuser-directory-initial-win10-withoutISOz.7z || exit 235
cd scripts
sh install-isolated-net.sh
virsh define win10-LTSC.xml
virsh start win10
virsh autostart win10
virt-manager

now win10 is running and the anyDesk config-directory (%programdata%\AnyDesk) should be replaced with the one in the backup…

OR

in case of first install should be deleted or you can deinstall anyDesk and install it again with the proper password and start options

DEV-Section

the isolated network has to be created to run this xml… see {anchor:isolated}

XML:

<domain type='kvm' id='1'>
  <name>win10</name>
  <uuid>37b053b1-3fc1-4a84-8baa-2d07cc0d764a</uuid>
  <metadata>
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
      <libosinfo:os id="http://microsoft.com/win/10"/>
    </libosinfo:libosinfo>
  </metadata>
  <memory unit='KiB'>4194304</memory>
  <currentMemory unit='KiB'>4194304</currentMemory>
  <vcpu placement='static' current='1'>2</vcpu>
  <resource>
    <partition>/machine</partition>
  </resource>
  <os>
    <type arch='x86_64' machine='pc-q35-3.0'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <hyperv>
      <relaxed state='on'/>
      <vapic state='on'/>
      <spinlocks state='on' retries='8191'/>
    </hyperv>
    <vmport state='off'/>
  </features>
  <cpu mode='custom' match='exact' check='full'>
    <model fallback='forbid'>Skylake-Client-IBRS</model>
    <vendor>Intel</vendor>
    <feature policy='require' name='ss'/>
    <feature policy='require' name='vmx'/>
    <feature policy='require' name='hypervisor'/>
    <feature policy='require' name='tsc_adjust'/>
    <feature policy='require' name='clflushopt'/>
    <feature policy='require' name='md-clear'/>
    <feature policy='require' name='ssbd'/>
    <feature policy='require' name='xsaves'/>
    <feature policy='require' name='pdpe1gb'/>
  </cpu>
  <clock offset='localtime'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
    <timer name='hypervclock' present='yes'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/bin/qemu-kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw'/>
      <source file='/var/home/kvmwin/vm/win10.img'/>
      <backingStore/>
      <target dev='sda' bus='sata'/>
      <alias name='sata0-0-0'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <controller type='usb' index='0' model='qemu-xhci' ports='15'>
      <alias name='usb'/>
      <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
    </controller>
    <controller type='sata' index='0'>
      <alias name='ide'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1f' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pcie-root'>
      <alias name='pcie.0'/>
    </controller>
    <controller type='pci' index='1' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='1' port='0x10'/>
      <alias name='pci.1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0' multifunction='on'/>
    </controller>
    <controller type='pci' index='2' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='2' port='0x11'/>
      <alias name='pci.2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x1'/>
    </controller>
    <controller type='pci' index='3' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='3' port='0x12'/>
      <alias name='pci.3'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x2'/>
    </controller>
    <controller type='pci' index='4' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='4' port='0x13'/>
      <alias name='pci.4'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x3'/>
    </controller>
    <controller type='pci' index='5' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='5' port='0x14'/>
      <alias name='pci.5'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x4'/>
    </controller>
    <interface type='network'>
      <mac address='52:54:00:bd:bc:fd'/>
      <source network='default' bridge='virbr0'/>
      <target dev='vnet0'/>
      <model type='virtio'/>
      <alias name='net0'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </interface>
    <interface type='network'>
      <mac address='52:54:00:a7:47:61'/>
      <source network='isolated' bridge='virbr1'/>
      <target dev='vnet1'/>
      <model type='virtio'/>
      <alias name='net1'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
    </interface>
    <interface type='direct'>
      <mac address='52:54:00:cf:04:1d'/>
      <source dev='enp2s0' mode='bridge'/>
      <target dev='macvtap0'/>
      <model type='virtio'/>
      <alias name='net2'/>
      <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
    </interface>
    <serial type='pty'>
      <source path='/dev/pts/0'/>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
      <alias name='serial0'/>
    </serial>
    <console type='pty' tty='/dev/pts/0'>
      <source path='/dev/pts/0'/>
      <target type='serial' port='0'/>
      <alias name='serial0'/>
    </console>
    <input type='tablet' bus='usb'>
      <alias name='input0'/>
      <address type='usb' bus='0' port='1'/>
    </input>
    <input type='mouse' bus='ps2'>
      <alias name='input1'/>
    </input>
    <input type='keyboard' bus='ps2'>
      <alias name='input2'/>
    </input>
    <graphics type='spice' port='5900' autoport='yes' listen='127.0.0.1' keymap='de'>
      <listen type='address' address='127.0.0.1'/>
      <image compression='off'/>
    </graphics>
    <sound model='ich9'>
      <alias name='sound0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1b' function='0x0'/>
    </sound>
    <video>
      <model type='virtio' heads='1' primary='yes'>
        <acceleration accel3d='no'/>
      </model>
      <alias name='video0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x0'/>
    </video>
    <redirdev bus='usb' type='spicevmc'>
      <alias name='redir0'/>
      <address type='usb' bus='0' port='2'/>
    </redirdev>
    <redirdev bus='usb' type='spicevmc'>
      <alias name='redir1'/>
      <address type='usb' bus='0' port='3'/>
    </redirdev>
    <memballoon model='virtio'>
      <alias name='balloon0'/>
      <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
    </memballoon>
  </devices>
  <seclabel type='dynamic' model='selinux' relabel='yes'>
    <label>system_u:system_r:svirt_t:s0:c36,c357</label>
    <imagelabel>system_u:object_r:svirt_image_t:s0:c36,c357</imagelabel>
  </seclabel>
  <seclabel type='dynamic' model='dac' relabel='yes'>
    <label>+107:+107</label>
    <imagelabel>+107:+107</imagelabel>
  </seclabel>
</domain>




and the right directories and isos to install win 10 and of course an Xwin connection if you need to have a GUI (virt-manager) OR use virsh to do you work

this is the cmd-line as reference for docker container usage

[kvmwin@orange-appliance ~]$ virsh domxml-to-native qemu-argv win10
LC_ALL=C PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin QEMU_AUDIO_DRV=spice \
/usr/bin/qemu-kvm -name guest=win10,debug-threads=on \
-object secret,id=masterKey0,format=raw,file=/var/lib/libvirt/qemu/domain--1-win10/master-key.aes \
-machine pc-q35-3.0,accel=kvm,usb=off,vmport=off,dump-guest-core=off \
-cpu Skylake-Client-IBRS,ss=on,vmx=on,hypervisor=on,tsc_adjust=on,clflushopt=on,md-clear=on,ssbd=on,xsaves=on,pdpe1gb=on,hv_time,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff -m 4096 -realtime mlock=off \
-smp 1,maxcpus=2,sockets=2,cores=1,threads=1 -uuid 37b053b1-3fc1-4a84-8baa-2d07cc0d764a \
-no-user-config -nodefaults \
-chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/domain--1-win10/monitor.sock,server,nowait \
-mon chardev=charmonitor,id=monitor,mode=control -rtc base=localtime,driftfix=slew \
-global kvm-pit.lost_tick_policy=delay -no-hpet -no-shutdown -global ICH9-LPC.disable_s3=1 \
-global ICH9-LPC.disable_s4=1 -boot strict=on \
-device pcie-root-port,port=0x10,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0x2 \
-device pcie-root-port,port=0x11,chassis=2,id=pci.2,bus=pcie.0,addr=0x2.0x1 \
-device pcie-root-port,port=0x12,chassis=3,id=pci.3,bus=pcie.0,addr=0x2.0x2 \
-device pcie-root-port,port=0x13,chassis=4,id=pci.4,bus=pcie.0,addr=0x2.0x3 \
-device pcie-root-port,port=0x14,chassis=5,id=pci.5,bus=pcie.0,addr=0x2.0x4 \
-device qemu-xhci,p2=15,p3=15,id=usb,bus=pci.2,addr=0x0 \
-drive file=/var/home/kvmwin/vm/win10.img,format=raw,if=none,id=drive-sata0-0-0 \
-device ide-hd,bus=ide.0,drive=drive-sata0-0-0,id=sata0-0-0,bootindex=1 \
-netdev tap,fd=23,id=hostnet0 -device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:bd:bc:fd,bus=pci.1,addr=0x0 \
-netdev tap,fd=24,id=hostnet1 -device virtio-net-pci,netdev=hostnet1,id=net1,mac=52:54:00:a7:47:61,bus=pci.4,addr=0x0 \
-netdev tap,fd=26,id=hostnet2 -device virtio-net-pci,netdev=hostnet2,id=net2,mac=52:54:00:cf:04:1d,bus=pci.5,addr=0x0 \
-chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 \
-device usb-tablet,id=input0,bus=usb.0,port=1 -spice port=5901,addr=127.0.0.1,disable-ticketing,image-compression=off,seamless-migration=on -k de \
-device virtio-vga,id=video0,max_outputs=1,bus=pcie.0,addr=0x1 -device ich9-intel-hda,id=sound0,bus=pcie.0,addr=0x1b \
-device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0 -chardev spicevmc,id=charredir0,name=usbredir \
-device usb-redir,chardev=charredir0,id=redir0,bus=usb.0,port=2 -chardev spicevmc,id=charredir1,name=usbredir \
-device usb-redir,chardev=charredir1,id=redir1,bus=usb.0,port=3 \
-device virtio-balloon-pci,id=balloon0,bus=pci.3,addr=0x0 \
-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \
-msg timestamp=on

A fresh install of windows can be done the following way:

https://www.funtoo.org/Windows_10_Virtualization_with_KVM

to create a vm raw image :

qemu-img create -f raw win10.img 50G

my install script looks like and is executed as `kvmwin` user :

#!/bin/sh
WINIMG=~/ISOz/Win10_1903_V1_German_x64.iso
VIRTIMG=~/ISOz/virtio-win-0.1.173.iso
qemu-system-x86_64 --enable-kvm -drive driver=raw,file=/home/kvmwin/vm/win10.img,if=virtio -m 4096 \
-net nic,model=virtio -net user -cdrom ${WINIMG} \
-netdev user,id=virbr0,net=192.168.2.0/24,dhcpstart=192.168.2.130 \
-drive file=${VIRTIMG},index=3,media=cdrom \
-rtc base=localtime,clock=host -smp sockets=1,cores=2,threads=2 \
-usb -device usb-tablet \
-net user,smb=$HOME


before you shutdown install the network driver for kvm which is on drive E: for windows10

Do not forget to activate the image via virsh or virt-manager the later one needs xwin over ssh activated (xauth, xhost +)

and make it start on system boot

virsh autostart win10

You also need a isolated host to vm network which is created the following way:

create host-net.xml with the following content

<network>
     <name>isolated</name>
       <ip address='192.168.254.1' netmask='255.255.255.0'>
         <dhcp>
           <range start='192.168.254.254' end='192.168.254.254' />
         </dhcp>
       </ip>
</network>

and insert it to the netconfig and start it on boot:

virsh net-define host-net.xml 

virsh net-start isolated
virsh net-autostart isolated

{anchor:isolated}

and then add this to the win10 vm created above via virsh or virt-manager:

virsh edit win10

and insert an interface after the nat interface definition:

<interface type='network'>
  <mac address='52:54:00:a7:47:61'/>
  <source network='isolated'/>
  <model type='virtio'/>
  <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
</interface>