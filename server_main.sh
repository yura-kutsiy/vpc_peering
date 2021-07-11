#!/bin/bash
echo "---------------START---------------"
sudo -- sh -c "apt update && apt upgrade"
sudo apt-get install -y nginx

myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

echo "<html><body bgcolor=#008080>
<center><h2><p><font color=#C0C0C0>Main Terraform VPC!</h2></center><br><p>
<center><font color=#013220>Public <font color=#013220>subnets</center><br><br>
<center><font color=#007070><b>version 1.1</b></center>
</body></html>"  >  /var/www/html/index.html
sudo systemctl enable nginx
sudo systemctl start nginx
echo "---------------FINISH---------------"
