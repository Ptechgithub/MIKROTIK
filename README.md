
# MIKROTIK

# install mikrotik on vps
# نصب میکروتیک روی سرور مجازی

# نصب خودکار

```
curl -Ls https://raw.githubusercontent.com/Ptechgithub/Mikrotik/master/install.sh -o install.sh && chmod +x install.sh && ./install.sh
```

.


### نصب دستی
## دستورات را به ترتیب وارد کنید👇

## قبل از نصب ابتدا دستور sudo -i را وارد کنید 

-
``
sudo -i
``

#1

```
sudo wget https://download.mikrotik.com/routeros/7.10/chr-7.10.2.img.zip -O chr.img.zip && gunzip -c chr.img.zip > chr.img
```


#2

```
sudo dd if=chr.img bs=1024 of=/dev/vda && echo s > /proc/sysrq-trigger
```

#3

```
sudo echo b > /proc/sysrq-trigger
```

.

- برای تشخیص نوع disk در لاین #2 میتوانید از دستور  df -h استفاده کنید. خروجی به شکل /dev/vda میباشد. اگر روی سرور دیگری غیر از آروان تست کردید و خروجی به صورت /dev/sda یا چیز دیگری بود آن را در لاین #2 قرار بدید. عدد بعد از sda یا vda یا ... را درج نکنید.
