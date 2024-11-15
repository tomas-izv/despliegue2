!/bin/bash

# Para instalar el servidor nginx en nuestra Debian, primero actualizamos los repositorios y después instalamos el paquete correspondiente:
sudo apt update
sudo apt install -y nginx
sudo apt install -y git

# Comprobamos que nginx se ha instalado y que está funcionando correctamente:
systemctl status nginx

# Así pues, vamos a crear la carpeta de nuestro primer sitio web o dominio:
sudo mkdir -p /var/www/tomas_web/html 

sudo git clone https://github.com/cloudacademy/static-website-example /var/www/tomas_web/html 

# Además, haremos que el propietario de esta carpeta y todo lo que haya dentro sea el usuario wwwdata, típicamente el usuario del servicio web.
sudo chown -R www-data:www-data /var/www/tomas_web/html

#Y le daremos los permisos adecuados para que no nos de un error de acceso no autorizado al entrar en el sitio web:
sudo chmod -R 755 /var/www/tomas_web

#Para que Nginx presente el contenido de nuestra web, es necesario crear un bloque de servidor con las directivas correctas. En vez de modificar el archivo de configuración predeterminado directamente, crearemos uno nuevo.
#sudo nano /etc/nginx/sites-available/trm

#Creación del archivo y del enlace simbólico
     sudo bash -c 'cat > /etc/nginx/sites-available/tomasweb <<EOF
         server {
             listen 80;
             listen [::]:80;
             root /var/www/tomasweb/html;
             index index.html index.htm index.nginx-debian.html;
             server_name tomasweb.com www.tomasweb.com;
             location / {
                 try_files $uri $uri/ =404;
             }
         }
    EOF'

#Y crearemos un archivo simbólico entre este archivo y el de sitios que están habilitados, para que se dé de alta automáticamente.
sudo ln -s /etc/nginx/sites-available/trm /etc/nginx/sites-enabled/

#Y reiniciamos el servidor para aplicar la configuración:
sudo systemctl restart nginx

#-------------------------------------------------------------------------------

# Así pues, vamos a crear la carpeta de nuestro segundo sitio web o dominio:
sudo mkdir -p /var/www/tomas2web/html 

#Volvemos a asignar permisos esta vez al nuevo directorio
     sudo chown -R www-data:www-data /var/www/tomas2web/html
     sudo chmod -R 755 /var/www/tomas2web

#Para que Nginx presente el contenido de nuestra web, es necesario crear un bloque de servidor con las directivas correctas. En vez de modificar el archivo de configuración predeterminado directamente, crearemos uno nuevo.
#sudo nano /etc/nginx/sites-available/trm

#Creación del archivo y del enlace simbólico
     sudo bash -c 'cat > /etc/nginx/sites-available/tomas2web <<EOF
         server {
             listen 80;
             listen [::]:80;
             root /var/www/tomas2web/html;
             index index.html index.htm index.nginx-debian.html;
             server_name tomas2web.com www.tomas2web.com;
             location / {
                 try_files $uri $uri/ =404;
             }
         }
    EOF'

 #Enlace simbólico
    sudo ln -sf /etc/nginx/sites-available/trm2 /etc/nginx/sites-enabled/

#nos aseguramos que no va mostrar la página por defecto de Nginx
    sudo unlink /etc/nginx/sites-enabled/default
    sudo systemctl restart nginx

#Como aún no poseemos un servidor DNS que traduzca los nombres a IPs, debemos hacerlo de
#forma manual. Vamos a editar el archivo /etc/hosts de nuestra máquina anfitriona para que
#asocie la IP de la máquina virtual, a nuestro server_name. Este archivo, en Linux, está en /etc/hosts
#y en Windows: C:\Windows\System32\drivers\etc\hosts
#Y deberemos añadirle la línea:
######################
#192.168.X.X nombre_web

# En primer lugar, lo instalaremos desde los repositorios:
sudo apt-get update
sudo apt-get install vsftpd

 # Crea el usuario de FTP y configura permisos
        sudo useradd -m tomas_user -s /bin/bash
        echo "tomas_user:deaw" | sudo chpasswd

# Ahora vamos a crear una carpeta en nuestro home en Debian:
sudo mkdir -p /home/tomas_user/ftp

#Permisos
        sudo chown -R tomas_user:tomas_user /home/tomas_user/ftp
        sudo chown -R tomas_user:tomas_user /var/www/tomas2_web/html

# Ahora vamos a crear los certificados de seguridad necesarios para aportar la capa de cifrado a nuestra conexión (algo parecido a HTTPS)
#sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt
    cp /vagrant/conf/vsftpd.crt /etc/ssl/certs/vsftpd.crt
    cp /vagrant/conf/vsftpd.key /etc/ssl/private/vsftpd.key
#Y una vez realizados estos pasos, procedemos a realizar la configuración de vsftpd propiamente dicha. Se trata, con el editor de texto que más os guste, de editar el archivo de configuración de este servicio, por ejemplo con nano:
cp /vagrant/conf/vsftpd.conf /etc/vsftpd.conf

#En primer lugar, buscaremos las siguientes líneas del archivo y las eliminaremos por completo:
#rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
#rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
#ssl_enable=NO

#Tras ello, añadiremos estas líneas en su lugar
#rsa_cert_file=/etc/ssl/certs/vsftpd.crt
#rsa_private_key_file=/etc/ssl/private/vsftpd.key
#ssl_enable=YES
#allow_anon_ssl=NO
#force_local_data_ssl=YES
#force_local_logins_ssl=YES
#ssl_tlsv1=YES
#ssl_sslv2=NO
#ssl_sslv3=NO
#require_ssl_reuse=NO
#ssl_ciphers=HIGH
#local_root=/home/nombre_usuario/ftp

#Y, tras guardar los cambios, reiniciamos el servicio para que coja la nueva configuración:
sudo systemctl restart vsftp

