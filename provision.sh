
        ## IMPORTANTE
#Para poder acceder a los dominios hay que editar el archivo hosts
#C:\Windows\System32\drivers\etc\hosts
    #192.168.57.102 trm.com www.trm2.com
    #192.168.57.102 trm2.com www.trm2.com

!/bin/bash

#CONFIGURACIÓN GENERAL DEL SERVIDOR Y REPOSITORIOS

#Actualizar repositorios e instalar el servidor Nginx
    sudo apt update 
    sudo apt install -y nginx
    sudo apt install -y git
 #comprobar el funcionamiento de nginx
    sudo systemctl status nginx


#CREACIÓN DEL PRIMER SITIO WEB

#Crea la carpeta para la página web
    sudo mkdir -p /var/www/tomas_web/html
    sudo git clone https://github.com/cloudacademy/static-website-example.git /var/www/tomas_web/html

#Administrar permisos
     sudo chown -R www-data:www-data /var/www/tomas_web/html
     sudo chmod -R 775 /var/www/tomas_web

    sudo cp /vagrant/conf/trm /etc/nginx/sites-available/trm

    #Enlace simbólico
     sudo ln -sf /etc/nginx/sites-available/trm /etc/nginx/sites-enabled/


#Reinicia el servidor para aplicar la nueva configuración
     sudo systemctl restart nginx



#CONFIGURACIÓN SEGUNDO SITIO WEB
    sudo mkdir -p /var/www/tomas2_web/html

#Volvemos a asignar permisos esta vez al nuevo directorio
     sudo chown -R www-data:www-data /var/www/tomas2_web/html/
     sudo chmod -R 775 /var/www/tomas2_web/html/

#Creación del archivo y del enlace simbólico
    # sudo bash -c 'cat > /etc/nginx/sites-available/trm2 <<EOF
    #     server {
    #         listen 80;
    #         listen [::]:80;
    #         root /var/www/tomas2_web/html;
    #         index index.html index.htm index.nginx-debian.html;
    #         server_name trm2.com www.trm2.com;
    #         location / {
    #             try_files $uri $uri/ =404;
    #         }
    #     }
    # EOF'

    cp /vagrant/conf/trm2 /etc/nginx/sites-available/trm2

 #Enlace simbólico
    sudo ln -sf /etc/nginx/sites-available/trm2 /etc/nginx/sites-enabled/


#nos aseguramos que no va mostrar la página por defecto de Nginx
    sudo unlink /etc/nginx/sites-enabled/default
    sudo systemctl restart nginx

#CONFIGURACIÓN PARA EL SERVIDOR FTPS EN DEBIAN
#Instalación de repositorios
    sudo apt-get update
    sudo apt-get -y install vsftpd


    #USUARIO

    # Crea el usuario de FTP y configura permisos
        sudo useradd -m tomas_user -s /bin/bash
        echo "tomas_user:deaw" | sudo chpasswd

    #Crea la carpeta en el home de Debian
        sudo mkdir -p /home/tomas_user/ftp

    #Permisos
        sudo chown -R tomas_user:tomas_user /home/tomas_user/ftp
        sudo chown -R www-data:tomas_user /var/www/


#Creación de los certificados de seguridad
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt
    cp /vagrant/conf/vsftpd.crt /etc/ssl/certs/vsftpd.crt
    cp /vagrant/conf/vsftpd.key /etc/ssl/private/vsftpd.key

#configuración del vsftpd
cp /vagrant/conf/vsftpd.conf /etc/vsftpd.conf


#Reinicia el servidor para aplicar la nueva configuración
sudo systemctl restart vsftpd
