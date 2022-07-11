# microSDカードへイメージを焼く

## SDカードライターの接続

```shell
ls /dev/sd*
```

SDカードライターにmicroSDカードを入れて、ホストマシンに接続する。

```shell
ls /dev/sd*
```

デバイスパスを確認して、設定する。

```shell
DST_PATH=</dev/sd*>
```

## フォーマット

```shell
sudo XAUTHORITY=~/.Xauthority gparted
```

右上のプルダウンが、ターゲットのデバイスになっていることを確認する。

第一パーティションを、以下の設定でフォーマットする。

- 前方の空き領域は`4`\[MiB\]
- 新しいサイズは`512`\[MiB\]
- ファイルシステムは`fat32`

第二パーティションを、以下の設定でフォーマットする。

- 前方の空き領域は`0`\[MiB\]
- 新しいサイズは残り全て
- ファイルシステムは`ext4`

## microSDカードの作成

パーティションをそれぞれマウントする。

```shell
sudo mkdir -p /media/BOOT
sudo mkdir -p /media/rootfs
sudo mount ${DST_PATH}1 /media/BOOT
sudo mount ${DST_PATH}2 /media/rootfs
```

第一パーティションにデータを焼く。

```shell
sudo cp BOOT.BIN /media/BOOT/
sudo cp image.ub /media/BOOT/
sudo cp boot.scr /media/BOOT/
sync
```

第二パーティションにデータを焼く。

```shell
sudo cp rootfs.tar.gz /media/rootfs/
sync
```

アンマウントする。

```shell
sudo umount /media/BOOT/
sudo umount /media/rootfs/
```

## 起動確認

Kria KV260にmicroSDカードを差し込む。  
Kria KV260のUSB端子と、作業マシンをUSBケーブルで接続する。  
minicomでコンソールを開く。

```shell
minicom --baudrate 115200 --noinit --device /dev/ttyUSB1
```

Ctrl-A-Oから`configuration`を開いて、`serial port setup`を選択する。  
`Hardware Flow Control`が`YES`になっていたら`NO`にする。  
`ESC`で戻る。  
Ctrl-A-Oから`dflに設定を保存`を選択して設定を保存する。

Kria KV260の電源を接続する。  
起動ログが`minicom`のコンソールに表示される。  
`minicom`のコンソールからログインし、パスワードを設定する。
