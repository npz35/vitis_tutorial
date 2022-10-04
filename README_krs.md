# Kria Robotics Stackを動かす

`$HOME/output`ディレクトリを作成する。

```shell
mkdir -p $HOME/output
```

必要なパッケージをインストールする。

```shell
sudo apt install -y \
  python3-colcon-argcomplete \
  python3-colcon-bash \
  python3-colcon-cd \
  python3-colcon-cmake \
  python3-colcon-common-extensions \
  python3-colcon-core \
  python3-colcon-defaults \
  python3-colcon-devtools \
  python3-colcon-library-path \
  python3-colcon-metadata \
  python3-colcon-mixin \
  python3-colcon-notification \
  python3-colcon-output \
  python3-colcon-package-information \
  python3-colcon-package-selection \
  python3-colcon-parallel-executor \
  python3-colcon-pkg-config \
  python3-colcon-powershell \
  python3-colcon-python-setup-py \
  python3-colcon-recursive-crawl \
  python3-colcon-ros \
  python3-colcon-test-result \
  python3-colcon-zsh
```

Dockerイメージをビルドする。

```shell
cd $HOME/vitis_tutorial/krs
./scripts/docker_build.sh
```

Dockerコンテナを起動する。

```shell
cd $HOME/vitis_tutorial/krs
./scripts/docker_run.sh
```

Dockerコンテナの中でROSパッケージをビルドする。

```shell
cd $HOME/krs_ws
colcon build \
  --merge-install \
  --packages-ignore offloaded_doublevadd_publisher
```

ファームウェアを選択する。

```shell
source install/setup.bash
colcon acceleration select kv260
```

Kria KV260向けのROSパッケージをビルドする。

```shell
colcon build \
  --build-base=build-kv260 \
  --install-base=install-kv260 \
  --merge-install \
  --mixin kv260 \
  --cmake-args -DTRACETOOLS_LTTNG_ENABLED=true \
  --packages-select \
    ament_acceleration \
    ament_vitis \
    vitis_common \
    ros2acceleration \
    vadd_publisher \
    offloaded_doublevadd_publisher
colcon build \
  --build-base=build-kv260 \
  --install-base=install-kv260 \
  --merge-install \
  --mixin kv260 \
  --cmake-args -DTRACETOOLS_LTTNG_ENABLED=true \
  --packages-select simple_adder
colcon build \
  --build-base=build-kv260 \
  --install-base=install-kv260 \
  --merge-install \
  --mixin kv260 \
  --cmake-args -DNOKERNELS=true -DTRACETOOLS_LTTNG_ENABLED=true \
  --packages-up-to \
    perception_2nodes \
    image_pipeline_examples
colcon build \
  --build-base=build-kv260 \
  --install-base=install-kv260 \
  --merge-install \
  --mixin kv260 \
  --cmake-args -DNOKERNELS=false -DTRACETOOLS_LTTNG_ENABLED=true \
  --packages-select \
    image_proc \
    perception_2nodes
```

ホスト側へ必要なデータをコピーする。

```shell
mkdir -p $HOME/output/krs_ws/firmware
sudo cp -r -d acceleration/firmware/kv260 $HOME/output/krs_ws/firmware/kv260
cp -r -d src $HOME/output/krs_ws/ 2> /dev/null
cp -r -d build-kv260 $HOME/output/krs_ws/
cp -r -d install-kv260 $HOME/output/krs_ws/
```

ホスト側で、オーナーを変更する。

```shell
sudo chown -R $USER acceleration
```

`colcon-hardware-acceleration`をビルドする。

```shell
source /opt/ros/foxy/setup.bash
colcon build --merge-install \
  --packages-select \
    colcon-hardware-acceleration \
    ros2acceleration \
    perception_2nodes
```

ファームウェアのシンボリックリンクを更新する。

```shell
source install/setup.bash
unlink acceleration/firmware/select
colcon acceleration select kv260

BOOT_PATH=`readlink acceleration/firmware/select/BOOT.BIN | sed 's/.*krs_ws\///g'`
unlink acceleration/firmware/kv260/BOOT.BIN
ln -s `pwd`/${BOOT_PATH} acceleration/firmware/kv260/BOOT.BIN
```

SDイメージを作成する。

```shell
export PATH=/usr/bin:$PATH
export ROS_DISTRO=humble
LANG=C
colcon acceleration linux vanilla --install-dir install-kv260
```

microSDカードを初期化する。  
microSDカード上のデータは全て消えるため、注意する。

```shell
sudo XAUTHORITY=~/.Xauthority gparted
```

SDイメージをmicroSDカードに焼く。  
`/dev/sdb`はmicroSDカードのデバイスパスに適宜置き換える。

```shell
cd $HOME/output/krs_ws/acceleration/firmware/kv260/
sudo dd if=sd_card.img of=/dev/sdb bs=1M status=progress
```

第二パーティションをサイズ上限まで拡張する。

```shell
sudo XAUTHORITY=~/.Xauthority gparted
```

microSDカードのブート領域をマウントする。

```shell
sudo mkdir -p /mnt/BOOT
sudo mount /dev/sdb1 /mnt/BOOT
```

PetaLinux Toolsで生成した`system.dtb`で上書きする。

```shell
sudo cp $HOME/output/images/linux/system.dtb /mnt/BOOT/
sync
```

microSDカードをアンマウントする。

```shell
sudo umount /mnt/BOOT/
sudo eject /dev/sdb
```
