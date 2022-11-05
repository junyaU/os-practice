#!/bin/zsh

export PATH=/usr/local/Cellar/dosfstools/4.2/sbin:$PATH
export PATH=/usr/local/opt/llvm/bin:$PATH

# ブートローダのビルド
source ~/edk2/edksetup.sh
~/edk2/build

# カーネルのビルド
source ~/osbook/devenv/buildenv.sh
cd ~/workspace/mikanos/kernel
make kernel.elf
cd ~/


if [ -e disk.img ]; then
    rm disk.img
fi

# FAT形式の擬似USB作成
qemu-img create -f raw disk.img 200M
mkfs.fat -n 'URUUNARI' -s 2 -f 2 -R 3 -F 32 disk.img
hdiutil attach -mountpoint mnt disk.img

# ブートローダ配置
mkdir -p mnt/EFI/BOOT
cp ~/edk2/Build/MikanLoaderX64/DEBUG_CLANGPDB/X64/Loader.efi ~/mnt/EFI/BOOT
mv ~/mnt/EFI/BOOT/Loader.efi ~/mnt/EFI/BOOT/BOOTX64.EFI

# カーネル配置
cp ~/workspace/mikanos/kernel/kernel.elf mnt
hdiutil detach mnt

# 実行
qemu-system-x86_64 -m 1G -drive if=pflash,format=raw,file=OVMF_CODE.fd -drive if=pflash,format=raw,file=OVMF_VARS.fd -drive if=ide,index=0,media=disk,format=raw,file=disk.img -device nec-usb-xhci,id=xhci -device usb-mouse -device usb-kbd 


