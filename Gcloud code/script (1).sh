#!/bin/bash


#updating & install sysbench & apache packages
sudo apt-get update -y
sudo apt-get install sysbench -y
sudo apt-get install apache2 -y

#start and enable your apache webserver to access html file
sudo systemctl start apache2
sudo systemctl enable apache2

#permission to edit /var/www/html folder

#adding user to the apache group
sudo usermod -aG apache $USER
#changing the group owner to apache 
sudo chown -R $USER:apache /var/www/html

#Outputing data as HTML file 
sudo echo "<html>"  > /var/www/html/index.html
sudo echo "<h1><b> Sysbench Benchmarks <3 </b></h1>" >> /var/www/html/index.html
sudo echo "<body>" >>/var/www/html/index.html
sudo echo "<pre>" >>/var/www/html/index.html

#CPU benchmarks
sudo echo "<p><b>CPU Metrics</b></p>" >> /var/www/html/index.html
sudo echo "<p>****************************************</p>" >> /var/www/html/index.html
sudo sysbench cpu run >> /var/www/html/index.html
sudo echo "<p>****************************************</p>" >> /var/www/html/index.html

#MEMORY benchmarks
sudo echo "<p><b>MEMORY Metrics</b></p>" >> /var/www/html/index.html
sudo echo "<p>*****************************************</p>" >> /var/www/html/index.html
sudo sysbench memory run >> /var/www/html/index.html
sudo echo "<p>******************************************</p>" >> /var/www/html/index.html

#I/O benchmarks
sudo echo "<p><b>I/O Metrics</b></p>" >> /var/www/html/index.html
sudo sysbench fileio --file-test-mode=seqwr run >> /var/www/html/index.html
sudo echo "</pre>" >>/var/www/html/index.html
sudo echo "</body>" >>/var/www/html/index.html
sudo echo "</html>" >> /var/www/html/index.html

#Restart apache server
sudo systemctl restart apache2
