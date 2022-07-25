# Petalinuxのビルド

事前に<https://japan.xilinx.com/support/download/index.html/content/xilinx/ja/downloadNav/embedded-design-tools.html>から`petalinux-v2021.1-final-installer.run`をダウンロードする。

```shell
$ md5sum petalinux-v2021.1-final-installer.run
a44e1ff42ef3eedc322a72d790b1931d  petalinux-v2021.1-final-installer.run
```

事前に<https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/1641152513/Kria+K26+SOM>から`xilinx-k26-starterkit-v2021.1-final.bsp`をダウンロードする。

```shell
$ md5sum xilinx-k26-starterkit-v2021.1-final.bsp
584f769158424e1b95279b1fed591f84  xilinx-k26-starterkit-v2021.1-final.bsp
```

また`$HOME/output`を作成しておく必要がある。

```shell
mkdir -p $HOME/output
```

また、ハードウェアプラットフォームファイルを`$HOME/output`以下に用意しておく必要がある。  
以下では`kv260_hardware_platform.xsa`とする。

## Dockerイメージのビルド

Petalinuxのビルド用のDockerイメージをビルドする。

```shell
./scripts/docker_build.sh
```

古いDockerコンテナが残っている場合には、renameで退避する。

```shell
docker rename build_petalinux build_petalinux.backup
```

## Dockerコンテナの起動

Petalinuxのビルド用のDockerコンテナを起動する。

```shell
./scripts/docker_run.sh
```

### 依存パッケージのインストール

```shell
sudo /tools/Xilinx/Vitis/2021.1/scripts/installLibs.sh
```

### ビルド設定

ビルド設定を行う。

```shell
source settings.sh
petalinux-upgrade -u 'http://petalinux.xilinx.com/sswreleases/rel-v2021/sdkupdate/2021.1_update1/' -p 'aarch64' --wget-args "--wait 1 -nH --cut-dirs=4"
petalinux-util --webtalk off
petalinux-create --type project --source xilinx-k26-starterkit-v2021.1-final.bsp
cp output/kv260_hardware_platform.xsa xilinx-k26-starterkit-2021.1/
cd xilinx-k26-starterkit-2021.1
petalinux-config --get-hw-description=kv260_hardware_platform.xsa --silent
petalinux-config
```

`user-rootfsconfig`の例を以下に追記しておく。

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

追加したいパッケージを有効化する。

```shell
petalinux-config --component rootfs
```

```shell
petalinux-config --component kernel --silentconfig
```

エラーが出て途中で止まることがある。  
何度か再開すれば通る。

```shell
petalinux-config --component rootfs --silentconfig
```

### Petalinuxのビルド

生成物を確認しながら、順にビルドしていく。


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

### ブートイメージの生成

microSDに書き込むファイルを生成する。

```shell
petalinux-package --force --boot --fsbl ./images/linux/zynqmp_fsbl.elf --u-boot
```

```shell
$ ls images/linux/
BOOT.BIN  image.ub      rootfs.cpio     rootfs.cpio.gz.u-boot  rootfs.manifest  system.bit  u-boot.bin  uImage   zImage
boot.scr  pxelinux.cfg  rootfs.cpio.gz  rootfs.jffs2           rootfs.tar.gz    system.dtb  u-boot.elf  vmlinux  zynq_fsbl.elf
```

ホスト側に必要なファイルをコピーする。

```shell
cp images/linux/BOOT.BIN ~/output/
cp images/linux/image.ub ~/output/
cp images/linux/boot.scr ~/output/
cp images/linux/rootfs.tar.gz ~/output/
```

`images/linux`はアプリケーションプロジェクトの`Root FS`の参照先として使用するため、必要な場合はホスト側にコピーする。

```shell
cp -r images ~/output/
```

`sdk.sh`が必要な場合は以下を実行する。

```shell
petalinux-build --sdk
```
