
# MIKROTIK

# install mikrotik on vps
# نصب میکروتیک روی سرور مجازی

# نصب

```
curl -Ls https://raw.githubusercontent.com/Ptechgithub/Mikrotik/master/install.sh -o install.sh && chmod +x install.sh && ./install.sh
```

.

.
 
.

.

#install on Arvancloud 
# برای نصب روی سرورهای آروان از دستورات زیر استفاده کنید . دستورات را به ترتیب وارد کنید👇

## قبل از نصب ابتدا دستور sudo -i را وارد کنید 

-
``
sudo -i
``

#1

```
sudo wget https://download.mikrotik.com/routeros/7.10/chr-7.10.img.zip -O chr.img.zip
```

#2

```
gunzip -c chr.img.zip > chr.img
```

#3

```
dd if=chr.img bs=1024 of=/dev/vda
```

#4

```
echo s > /proc/sysrq-trigger
```

#5

```
echo b > /proc/sysrq-trigger
```


- برای تشخیص نوع disc در لاین #3 میتوانید از دستور  df -h استفاده کنید. خردجی به شکل /dev/vda میباشد.
