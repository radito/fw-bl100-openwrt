#!/bin/sh

cp /etc_ro/lighttpd/www/adm/system_command.shtml /tmp/system_command.shtml

/bin/rm /tmp/install.log
/bin/rm /tmp/checksum_openwrt
/bin/rm /tmp/md5_openwrt
/bin/rm /tmp/checksum_breed
/bin/rm /tmp/md5_breed
/bin/rm /tmp/openwrt.bin
/bin/rm /tmp/breed.bin

echo '<pre><!--#exec cmd="cat /tmp/install.log"--></pre><script>setInterval(function(){window.location.reload()},1000);</script>' > /etc_ro/lighttpd/www/adm/system_command.shtml

cat <<EOF > /tmp/installer.sh
#!/bin/sh

echo "b060ae5daa529f356b41961692d22bf4" > /tmp/checksum_openwrt
echo "95ed514e89bace9726142cde060d9c59"  > /tmp/checksum_breed

{
    echo -e "OpenWRT Installer For Bolt BL-100/BL-201\n"
    echo -e "Initializing ...\n"
    
    echo -e "ID : \`id\`"
    echo -e "Flash Layout : \n\`cat /proc/mtd\`\n"

    echo "Downloading OpenWRT ..."
    wget --content-disposition -O /tmp/openwrt.bin http://ghuseraccess.000webhostapp.com/?url=https://raw.githubusercontent.com/radito/fw-bl100-openwrt/master/openwrt-15.05.1-ramips-mt7620-xiaomi-miwifi-mini-squashfs-sysupgrade.bin
    
    echo "Downloading Breed ..."
    wget --content-disposition -O /tmp/breed.bin http://ghuseraccess.000webhostapp.com/?url=https://raw.githubusercontent.com/radito/fw-bl100-openwrt/master/breed-mt7620-xiaomi-mini.bin

    chmod +x /tmp/openwrt.bin
    chmod +x /tmp/breed.bin

    /usr/bin/md5sum /tmp/openwrt.bin | /usr/bin/awk '{print \$1}' > /tmp/md5_openwrt
    /usr/bin/md5sum /tmp/breed.bin | /usr/bin/awk '{print \$1}' > /tmp/md5_breed

    if [ "\`cat /tmp/md5_openwrt\`" != "\`cat /tmp/checksum_openwrt\`" ]; then
        echo -e "\nInvalid OpenWRT Checksum !"
        echo "Valid Checksum: \`cat /tmp/checksum_openwrt\`"
        echo "File Checksum: \`cat /tmp/md5_openwrt\`"

        echo -e "\nAborting Installation !"
        exit 0
    fi

    if [ "\`cat /tmp/md5_breed\`" != "\`cat /tmp/checksum_breed\`" ]; then
        echo -e "\nInvalid Breed Checksum !"
        echo "Valid Checksum: \`cat /tmp/checksum_breed\`"
        echo "File Checksum: \`cat /tmp/md5_breed\`"
        
        echo -e "\nAborting Installation !"
        exit 0
    fi

    echo -e "Valid OpenWRT Checksum: \`cat /tmp/checksum_openwrt\`"
    echo -e "Valid Breed Checksum: \`cat /tmp/md5_breed\`\n"
    
    echo -e "----------------------- WARNING !!! -------------------------"
    echo -e "| Begin writing to Flash Memory...                          |"
    echo -e "| Do Not Unplug the Power or Your Device will be Bricked !  |"
    echo -e "-------------------------------------------------------------\n"

    echo -e "Installing OpenWRT to Flash Memory ...\n"
    mtd_write -o 0 -l \`wc -c /tmp/openwrt.bin\` write /tmp/openwrt.bin Kernel

    echo -e "Installing Breed to Flash Memory ...\n"
    mtd_write write /tmp/breed.bin Bootloader

    echo '<pre><!--#exec cmd="cat /tmp/install.log"--></pre>' > /etc_ro/lighttpd/www/adm/system_command.shtml
    echo "Rebooting..."

    reboot

} > /tmp/install.log 2>&1
EOF

chmod +x /tmp/installer.sh
/bin/sh /tmp/installer.sh &