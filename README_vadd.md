# vaddを動かす

バージョンは2021.1しか動作しないように見える。

`kv260_hardware_platform.xsa`を事前に作成しておく必要がある。

また、`y2k22_patch`のパッチを当てておく必要がある。

## Ubuntuのイメージを焼く

```shell
xzcat ~/Downloads/iot-kria-classic-desktop-2004-x03-20211110-98.img.xz | sudo dd of=/dev/sda bs=32M
```

## Petalinux用のDockerイメージをビルドする

Dockerイメージをビルドする。

```shell
./scripts/docker_build.sh
```

Dockerコンテナを作成する。

```shell
./scripts/docker_run.sh
```

## Petalinuxイメージをビルドする

<https://github.com/Xilinx/Vitis-Tutorials/blob/2021.1/Vitis_Platform_Creation/Design_Tutorials/01-Edge-KV260/step2.md>を参考にPetalinuxをビルドする。

```shell
source settings.sh
petalinux-upgrade -u 'http://petalinux.xilinx.com/sswreleases/rel-v2021/sdkupdate/2021.1_update1/' -p 'aarch64' --wget-args "--wait 1 -nH --cut-dirs=4"
petalinux-util --webtalk off
petalinux-create --type project -s xilinx-k26-starterkit-v2021.1-final.bsp
cd xilinx-k26-starterkit-2021.1
petalinux-config --get-hw-description=kv260_hardware_platform.xsa --silent
petalinux-config -c rootfs
petalinux-build
petalinux-build --sdk
```

## デバイスツリーの生成

ホスト側で以下を実行する。

```shell
ghq get https://github.com/Xilinx/device-tree-xlnx
cd device-tree-xlnx
git checkout xlnx_rel_v2021.1
```

XSCTを起動する。

```shell
xsct
```

XSCTのコンソールで以下を実行する。  
`<repo_path>`は適切なpathに書き換える。

```shell
hsi open_hw_design kv260_hardware_platform.xsa
hsi set_repo_path <repo_path>/device-tree-xlnx
hsi create_sw_design device-tree -os device_tree -proc psu_cortexa53_0
hsi set_property CONFIG.dt_overlay true [hsi::get_os]
hsi set_property CONFIG.dt_zocl true [hsi::get_os]
hsi generate_target -dir kv260_hardware_platform.dts
hsi close_hw_design [hsi current_hw_design]
```

`kv260_hardware_platform.dts`の中で以下を実行する。

```shell
$ cd <path>/kv260_hardware_platform.dts
$ grep firmware-name pl.dtsi
                        firmware-name = "kv260_hardware_platform.bit.bin";
$ vim pl.dtsi # 書き換える
$ grep firmware-name pl.dtsi
                        firmware-name = "vadd.bit.bin";
dtc -@ -O dtb -o pl.dtbo pl.dtsi
cp pl.dtbo vadd.dtbo
```

## プラットフォームファイルの生成

<https://github.com/Xilinx/Vitis-Tutorials/blob/2021.1/Vitis_Platform_Creation/Design_Tutorials/01-Edge-KV260/step3.md>を参考にプラットフォームファイルを作成する。

`kv260_custom_platform`と同じ階層にディレクトリを作成する。

```shell
mkdir kv260_custom_pkg
cd kv260_custom_pkg
mkdir pfm
```

`<path>`は適切なpathを指定する。

```shell
./sdk.sh -d <path>/kv260_custom_pkg
```

`kv260_custom_plnx/images/linux/`から以下をコピーする。  
`<path>`は適切なpathを指定する。

```shell
cd <path>/kv260_custom_pkg/pfm
mkdir boot
mkdir sd_dir
cp zynqmp_fsbl.elf \
  pmufw.elf \
  bl31.elf \
  u-boot-dtb.elf \
  system.dtb \
  boot/
```

必要な場合は`sd_dir`に`boot.scr`と`system.dtb`をコピーしておく。

Vitisを起動する。  
ワークスペースは`kv260_custom_pkg`を指定する。

プラットフォームプロジェクトを作成する。  

- プロジェクト名：`kv260_custom`
- XSAファイル：`kv260_custom_platform.xsa`
- operating system：`linux`
- processor：`psu_cortexa53`
- Architecture：`64bit`
- Generate boot componentsのチェックを外す

`linux on psu_cortexa53`ドメインを選択する。  

- `Bif file`：`Generate BIF`
- `Boot Components Directory`：`kv260_custom_pkg/pfm/boot`
- `FAT32 Partition Directory`：`kv260_custom_pkg/pfm/sd_dir`

`kv260_custom`を選択して、ビルドボタンを押す。  
`export`ディレクトリにプラットフォームファイルが生成される。

```shell
<path>/kv260_custom_pkg/kv260_custom/export/kv260_custom
platforminfo kv260_custom.xpfm
```

## プログラムのビルド・実行

<https://github.com/Xilinx/Vitis-Tutorials/blob/2021.1/Vitis_Platform_Creation/Design_Tutorials/01-Edge-KV260/step4.md>を参考にプログラムをビルド・実行する。

アプリケーションプロジェクトを作成する。  
`<path>`は適切なpathを指定する。

- プラットフォーム：`kv260_custom`
- プロジェクト名：`vadd`
- Domain：`linux on psu_cortexa53`
- Sys_root path：`<path>/kv260_custom_pkg/sysroots/cortexa72-cortexa53-xilinx-linux`
- Root FS：`kv260_custom_plnx/images/linux`
- Kernel Image：`kv260_custom_plnx/images/linux`

`Acceleration templates with PL and AIE accelerators`の`Vector Addition`を選択する。

`vadd.prj`を開いて`Active Build configuration`を`Hardware`にする。

```shell
<path>/kv260_custom_plnx/images/linux
cp u-boot.elf <path>/kv260_custom_pkg/kv260_custom/export/kv260_custom/sw/
```

`vadd_system`を開いてビルドボタンを押すとフリーズする。  
`vadd_system_hw_link`などの`Hardware`ディレクトリの中で以下のコマンドを実行しCUIからビルドする。  
`vadd_system/Hardware`はGUIからビルドする。

```shell
make all
```

`vadd_system/Hardware`以下に生成される。  
なおKria KV260はエミュレーションをサポートしていない。

- `package.build/package/system.bit`
- `package/sd_card/binary_container_1.xclbin`
- `package/sd_card/vadd`：実行ファイル

`<path>`はそれぞれ適切なpathを指定する。

```shell
cd <path>/kv260_custom_pkg/vadd_system/Hardware/package.build/package
echo 'all:{system.bit}' > bootgen.bif
bootgen -w -arch zynqmp -process_bitstream bin -image bootgen.bif
mv system.bit.bin vadd.bit.bin
```

```shell
echo '{
  "shell_type" : "XRT_FLAT",
  "num_slots": "1"
}' > shell.json
```

Kria KV260の`/lib/firmware/xilinx/vadd`に必要なファイルを送信する。  
`<path>`はそれぞれ適切なpathを指定する。

```shell
cd <path>/kv260_hardware_platform.dts
scp vadd.dtbo shell.json ubuntu@${BOARD_IP}:/home/ubuntu
cd <path>/kv260_custom_pkg/vadd_system/Hardware/package.build/package
scp vadd.bit.bin ubuntu@${BOARD_IP}:/home/ubuntu
cd <path>/kv260_custom_pkg/vadd_system/Hardware/package/sd_card
scp vadd binary_container_1.xclbin ubuntu@${BOARD_IP}:/home/ubuntu
cd <path>/kv260_custom_pkg/sysroots/cortexa72-cortexa53-xilinx-linux/usr/lib
scp libcrypt.so* ubuntu@${BOARD_IP}:/home/ubuntu
```

Kria KV260側で配置する。

```shell
sudo mkdir -p /lib/firmware/xilinx/vadd
sudo cp \
  vadd.dtbo \
  vadd.bit.bin \
  shell.json \
  /lib/firmware/xilinx/vadd/
sudo cp libcrypt.so* /usr/lib/
```

```shell
sudo dnf install xrt
```

```shell
./vadd binary_container_1.xclbin
```
