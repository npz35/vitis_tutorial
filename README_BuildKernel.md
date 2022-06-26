# Petalinuxのビルド

事前に<https://japan.xilinx.com/support/download/index.html/content/xilinx/ja/downloadNav/embedded-design-tools.html>から`petalinux-v2020.2-final-installer.run`をダウンロードする。

```shell
$ sha512sum petalinux-v2020.2-final-installer.run
3aa66cb6b604c5d58f92a7d6bc9efd81a4b2b2720282c8b0610a4bb6dc64f9147fd882f22dd39dd6ba7268187556e674365f25c69f0e1645a0335e567e51f1c7  petalinux-v2020.2-final-installer.run
```

## Dockerイメージのビルド

```shell
./scripts/docker_build.sh
```

古いDockerコンテナが残っている場合には、renameで退避する。

```shell
docker rename build_petalinux build_petalinux.backup
```

## Dockerコンテナの起動

```shell
./scripts/docker_run.sh
```

### 依存パッケージのインストール

```shell
sudo /tools/Xilinx/Vitis/2020.2/scripts/installLibs.sh
```

### config

```shell
TARGET_HOSTNAME=coconut-milk
XSA_DIR=${HOME}/output/xsa

petalinux-util --webtalk off
petalinux-create --type project --template zynq --name ${TARGET_HOSTNAME}
cd ${TARGET_HOSTNAME}
petalinux-config --get-hw-description=${XSA_DIR}
```

設定画面で、rootfsのfilesystemをext4に変更する。

- `Image Packaging Configuration` → `Root filesystem type` → `EXT4`

`user-rootfsconfig`に以下を追記しておく。

```shell
$ cat project-spec/meta-user/conf/user-rootfsconfig
#Note: Mention Each package in individual line
#These packages will get added into rootfs menu entry

CONFIG_gpio-demo
CONFIG_peekpoke
CONFIG_xrt
CONFIG_xrt-dev
CONFIG_zocl
CONFIG_opencl-clhpp-dev
CONFIG_opencl-headers-dev
CONFIG_packagegroup-petalinux-opencv
CONFIG_packagegroup-petalinux-opencv-dev
CONFIG_cmake
CONFIG_tmux
CONFIG_clinfo
```

```shell
petalinux-config --component kernel --silentconfig
```

エラーが出て途中で止まることがある。  
何度か再開すれば通る。

```shell
petalinux-config --component rootfs --silentconfig
```

### build

```shell
petalinux-build --component kernel
```

```shell
$ ls images/linux/
image.ub  system.dtb  uImage  vmlinux  zImage
```

```shell
petalinux-build --component u-boot
```

```shell
$ ls images/linux/
image.ub  system.dtb  u-boot.bin  u-boot.elf  uImage  vmlinux  zImage
```

```shell
petalinux-build --component rootfs
```

```shell
$ ls images/linux/
image.ub  rootfs.cpio  rootfs.cpio.gz  rootfs.cpio.gz.u-boot  rootfs.jffs2  rootfs.manifest  rootfs.tar.gz  system.dtb  u-boot.bin  u-boot.elf  uImage  vmlinux  zImage
```

```shell
petalinux-build
```

```shell
$ ls images/linux/
boot.scr  image.ub  pxelinux.cfg  rootfs.cpio  rootfs.cpio.gz  rootfs.cpio.gz.u-boot  rootfs.jffs2  rootfs.manifest  rootfs.tar.gz  system.dtb  u-boot.bin  u-boot.elf  uImage  vmlinux  zImage  zynq_fsbl.elf
```

### package

```shell
cp ${HOME}/petalinux/Cora-Z7-07S/base.bit images/linux/system.bit
petalinux-package --force --boot --fsbl ./images/linux/zynq_fsbl.elf --fpga ./images/linux/system.bit --u-boot # --bif boot.bif
```

```shell
$ ls images/linux/
BOOT.BIN  image.ub      rootfs.cpio     rootfs.cpio.gz.u-boot  rootfs.manifest  system.bit  u-boot.bin  uImage   zImage
boot.scr  pxelinux.cfg  rootfs.cpio.gz  rootfs.jffs2           rootfs.tar.gz    system.dtb  u-boot.elf  vmlinux  zynq_fsbl.elf
```

```shell
cp images/linux/BOOT.BIN ~/output/
cp images/linux/image.ub ~/output/
cp images/linux/boot.scr ~/output/
cp images/linux/rootfs.tar.gz ~/output/
```

`sdk.sh`が必要な場合は以下を実行する。

```shell
cd ${TARGET_HOSTNAME}/images/linux/
petalinux-build --sdk
```
