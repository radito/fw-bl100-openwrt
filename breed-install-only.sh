#!/bin/sh

cp /etc_ro/lighttpd/www/adm/system_command.shtml /tmp/system_command.shtml

/bin/rm /tmp/installer.sh
/bin/rm /tmp/install.log
/bin/rm /tmp/checksum_breed
/bin/rm /tmp/md5_breed
/bin/rm /tmp/breed.bin

echo '<pre><!--#exec cmd="cat /tmp/install.log"--></pre><script>setInterval(function(){window.location.reload()},1000);</script>' > /etc_ro/lighttpd/www/adm/system_command.shtml

cat <<EOF > /tmp/installer.sh
#!/bin/sh

echo "95ed514e89bace9726142cde060d9c59"  > /tmp/checksum_breed

{
    echo -e "Breed Installer For Bolt BL-100/BL-201\n"
    echo -e "Initializing ...\n"
    
    echo -e "ID : \`id\`"
    echo -e "Flash Layout : \n\`cat /proc/mtd\`\n"

    echo "Downloading Breed ..."
    wget --content-disposition -O /tmp/breed.bin http://ghuseraccess.000webhostapp.com/?url=https://raw.githubusercontent.com/radito/fw-bl100-openwrt/master/breed-mt7620-xiaomi-mini.bin

    chmod +x /tmp/breed.bin

    /usr/bin/md5sum /tmp/breed.bin | /usr/bin/awk '{print \$1}' > /tmp/md5_breed

    if [ "\`cat /tmp/md5_breed\`" != "\`cat /tmp/checksum_breed\`" ]; then
        echo -e "\nInvalid Breed Checksum !"
        echo "Valid Checksum: \`cat /tmp/checksum_breed\`"
        echo "File Checksum: \`cat /tmp/md5_breed\`"
        
        echo -e "\nAborting Installation !"
        exit 0
    fi

    echo -e "Valid Breed Checksum: \`cat /tmp/md5_breed\`\n"
    
    echo -e "----------------------- WARNING !!! -------------------------"
    echo -e "| Begin writing to Flash Memory...                          |"
    echo -e "| Do Not Unplug the Power or Your Device will be Bricked !  |"
    echo -e "-------------------------------------------------------------\n"

    echo -e "Installing Breed to Flash Memory ...\n"
    mtd_write write /tmp/breed.bin Bootloader

    echo '<pre><!--#exec cmd="cat /tmp/install.log"--></pre>' > /etc_ro/lighttpd/www/adm/system_command.shtml
    echo "Rebooting..."

    reboot

} > /tmp/install.log 2>&1
EOF

chmod +x /tmp/installer.sh
/bin/sh /tmp/installer.sh &