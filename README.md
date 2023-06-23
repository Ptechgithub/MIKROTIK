
# MIKROTIK

# install mikrotik on vps
# نصب میکروتیک روی سرور مجازی

# نصب

```
curl -Ls https://raw.githubusercontent.com/Ptechgithub/Mikrotik/master/install.sh -o install.sh && chmod +x install.sh && ./install.sh
```


#install on Arvancloud 
برایرنصب روی سرورهای آروان دستورات را به ترتیب وارد کنید
``
sudo wget https://download.mikrotik.com/routeros/7.10/chr-7.10.img.zip -O chr.img.zip
``
`
 gunzip -c chr.img.zip > chr.img
`
`dd if=chr.img bs=1024 of=/dev/vda
`
`
echo s > /proc/sysrq-trigger
`
echo b > /proc/sysrq-trigger
`
