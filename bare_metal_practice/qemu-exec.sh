#!/bin/zsh

# ブートローダのビルド
source ~/edk2/edksetup.sh
~/edk2/Build

# カーネルのビルド
cd ~/workspace/mikanos/kernel
make kernel.elf
cd ~/


if [ -e disk.img ]; then
    rm disk.img
fi

# FAT形式の擬似USB作成
qemu-img create -f raw disk.img 200M
mkfs.fat -n 'uchi os' -s 2 -f 2 -R 3 -F 32 disk.img
hdiutil attach -mountpoint mnt disk.img

# ブートローダ配置
mkdir -p mnt/EFI/BOOT
cp ~/edk2/Build/MikanLoaderX64/DEBUG_CLANGPDB/X64/Loader.efi ~/mnt/EFI/BOOT
mv ~/mnt/EFI/BOOT/Loader.efi ~/mnt/EFI/BOOT/BOOTX64.EFI

# カーネル配置
cp ~/workspace/mikanos/kernel/kernel.elf mnt
hdiutil detach mnt

# 実行
qemu-system-x86_64 -drive if=pflash,file=OVMF_CODE.fd -drive if=pflash,file=OVMF_VARS.fd -hda disk.img


