#SITE_PACKAGES=$(python3 -c "import sys; from distutils.sysconfig import get_python_lib; print(get_python_lib())")


# Install Throttlestop
#dnf5 install -y python3-devel

# Create Python library directories
#mkdir -p "$SITE_PACKAGES" 
#echo "$SITE_PACKAGES created"
#mkdir -p /usr/local/lib/python3.14/site-packages  
#mkdir -p /usr/local/bin  


#pip3 install throttlestop



# Throttlestop: add conf to load MSR kernel module
echo "msr" > /etc/modules-load.d/msr.conf


cat > /etc/systemd/system/throttlestop.service << EOL
# /etc/systemd/system/throttlestop.service  
[Unit]  
Description=throttlestop  
  
[Service]  
Type=oneshot  
User=root  
ExecStart=/usr/bin/python3 -m throttlestop voltage {"cpu": -129, "gpu": -70, "cache": -129}
ExecStart=/usr/bin/python3 -m throttlestop tdp {"first": {"power_limit": 42}, "second": {"power_limit": 53}} 
  
[Install]  
WantedBy=multi-user.target
EOL
