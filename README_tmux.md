# PetaLinux上でtmuxを使用する

**作成中です**

```shell
sudo dnf install \
  glibc-localedata-ja-jp \
  glibc-localedata-en-us \
  glibc-charmap-utf-8 \
  glibc-locale-locale.alias
```

```shell
sudo mkdir /usr/lib/locale/
```

```shell
sudo localectl set-locale LANG=en_US.UTF-8
```

```shell
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
```
