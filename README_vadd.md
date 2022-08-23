# vaddを動かす

バージョンは2021.1しか動作しないように見える。

事前にハードウェアプラットフォームファイルを作成しておく必要がある。  
以下では`kv260_hardware_platform.xsa`とする。

また、<https://support.xilinx.com/s/article/76960?language=ja>を参考に`y2k22_patch`のパッチを当てておく必要がある。

## デバイスツリーの生成

```shell
git clone https://github.com/Xilinx/device-tree-xlnx
cd device-tree-xlnx
git checkout xlnx_rel_v2021.1
cd ..
readlink -f device-tree-xlnx
```

XSCTを起動する。

```shell
xsct
```

XSCTのコンソールで以下を実行する。  
`<repo_path>`は`readlink`で確認したパスに書き換える。

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
```

`pl.dtsi`の`firmware-name`を以下のように書き換える。

```shell
$ grep firmware-name pl.dtsi
                        firmware-name = "vadd.bit.bin";
```

コンパイルする。

```shell
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
cd ..
pwd
```

`<path>`は`pwd`で確認したパスを指定する。

```shell
./sdk.sh -d <path>/kv260_custom_pkg
```

`kv260_custom_plnx/images/linux/`へ以下をコピーする。  
`<path>`は`pwd`で確認したパスを指定する。

```shell
mkdir -p <path>/kv260_custom_plnx/
cp -r $HOME/output/images <path>/kv260_custom_plnx/
```

`kv260_custom_plnx/images/linux/`から以下をコピーする。  
`<path>`は`pwd`で確認したパスを指定する。

```shell
cd <path>/kv260_custom_pkg/pfm
mkdir boot
mkdir sd_dir
cd ../../kv260_custom_plnx/images/linux/
cp zynqmp_fsbl.elf \
  pmufw.elf \
  bl31.elf \
  u-boot-dtb.elf \
  system.dtb \
  ../../../kv260_custom_pkg/pfm/boot/
```

必要な場合は`sd_dir`に`boot.scr`と`system.dtb`をコピーしておく。

```shell
cp boot.scr \
  system.dtb \
  ../../../kv260_custom_pkg/pfm/sd_dir/
```

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

`platforminfo`でプラットフォームファイルの詳細を確認できる。

```shell
<path>/kv260_custom_pkg/kv260_custom/export/kv260_custom
platforminfo kv260_custom.xpfm
```

## プログラムのビルド・実行

<https://github.com/Xilinx/Vitis-Tutorials/blob/2021.1/Vitis_Platform_Creation/Design_Tutorials/01-Edge-KV260/step4.md>を参考にプログラムをビルド・実行する。

アプリケーションプロジェクトを作成する。  
`<path>`は前節で`pwd`で確認したパスを指定する。

- プラットフォーム：`kv260_custom`
- プロジェクト名：`vadd`
- Domain：`linux on psu_cortexa53`
- Sys_root path：`<path>/kv260_custom_pkg/sysroots/cortexa72-cortexa53-xilinx-linux`
- Root FS：`<path>/kv260_custom_plnx/images/linux/rootfs.ext4`
- Kernel Image：`<path>/kv260_custom_plnx/images/linux/Image`

`Acceleration templates with PL and AIE accelerators`の`Vector Addition`を選択する。

`vadd.prj`を開いて`Active Build configuration`を`Hardware`にする。

必要なファイルをコピーする。

```shell
cd kv260_custom_plnx/images/linux
cp u-boot.elf ../../../kv260_custom_pkg/kv260_custom/export/kv260_custom/sw/
```

`vadd_system`を開いてビルドボタンを押すとフリーズする。  
そのため`vadd_system_hw_link`などの`Hardware`ディレクトリの中で以下のコマンドを実行しCUIからビルドする。

```shell
make all
```

`makefile`が無い場合はVitisの`Explorer`から右クリックして作成しておく。  
以下の順でビルドする。

- vadd_kernels
- vadd_system_hw_link
- vadd
- vadd_system

`vadd_system/Hardware`以下にファイルが生成される。  
なおKria KV260はエミュレーションをサポートしていない。

- `package.build/package/system.bit`
- `package/sd_card/binary_container_1.xclbin`
- `package/sd_card/vadd`：実行ファイル

`<path>`は前節で`pwd`で確認したパスを指定する。

```shell
cd <path>/kv260_custom_pkg/vadd_system/Hardware/package.build/package
echo 'all:{system.bit}' > bootgen.bif
bootgen -w -arch zynqmp -process_bitstream bin -image bootgen.bif
cp system.bit.bin vadd.bit.bin
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
REMOTE_USER=ubuntu
cd <path>/kv260_hardware_platform.dts
scp vadd.dtbo shell.json ${REMOTE_USER}@${BOARD_IP}:/home/${REMOTE_USER}
cd <path>/kv260_custom_pkg/vadd_system/Hardware/package.build/package
scp vadd.bit.bin ${REMOTE_USER}@${BOARD_IP}:/home/${REMOTE_USER}
cd <path>/kv260_custom_pkg/vadd_system/Hardware/package/sd_card
scp vadd binary_container_1.xclbin ${REMOTE_USER}@${BOARD_IP}:/home/${REMOTE_USER}
```

Kria KV260側で配置する。

```shell
sudo mkdir -p /lib/firmware/xilinx/vadd
sudo cp \
  vadd.dtbo \
  vadd.bit.bin \
  shell.json \
  /lib/firmware/xilinx/vadd/
```

必要に応じてパッケージをインストールする。

```shell
sudo dnf install \
  binutils \
  git \
  gcc \
  g++ \
  xrt \
  opencl-clhpp-dev \
  opencl-headers-dev
```

ロードされているカーネルモジュールを確認する。

```shell
lsmod
```

`zocl`が含まれていない場合は、`zocl`のカーネルモジュールをロードする。

```shell
sudo insmod `find /lib/modules -name zocl.ko`
```

vaddをロードする。

```shell
$ sudo xmutil unloadapp
Accelerator successfully removed.
$ sudo xmutil loadapp vadd
Accelerator loaded to slot 0
$ sudo xmutil listapps
                     Accelerator                            Base           Type    #slots         Active_slot

                        kv260-dp                        kv260-dp       XRT_FLAT         0                  -1
                            vadd                            vadd       XRT_FLAT         0                  0,
```

実行する。

```shell
./vadd binary_container_1.xclbin
```

なお、2022年7月11日時点で、Vitis 2021.1の`Vector Addition`から作成するホストプログラムには不備があるため、出力は正しく得られていない。

Kria KV260上でホストプログラムをビルドする場合には以下を実行する。

```shell
g++ -Wall -g -std=c++11 host.cpp -o vadd -I/usr/include/xrt -lOpenCL -lpthread -lrt -lstdc++
```

なお、以下を事前に実行していないとエラーになることがある。

```shell
sudo ln -s /usr/lib/libOpenCL.so.1 /usr/lib/libOpenCL.so
```
