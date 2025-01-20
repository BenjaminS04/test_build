# define locals for terraform configuration
locals {
  instances = {
    # Define a map of instances with different user data scripts
    target = <<-EOF
    
      # creates cloudwatch config file for sending logs to cloudwatch

      cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOL'
      {
        "agent": {
          "metrics_collection_interval": 60,
          "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
        },
        "metrics": {
        
          "append_dimensions": {
            "InstanceId": "$${aws:InstanceId}"
          },
          "metrics_collected": {
            "mem": {
              "measurement": [
                {
                  "name": "mem_used_percent",        
                  "rename": "MemoryUtilization",     
                  "unit": "Percent"                  
                }
              ],
              "metrics_collection_interval": 60
            }
            
          }
        },
        "logs": {
          "logs_collected": {
            "files": {
              "collect_list": [
                {
                  "file_path": "/var/log/syslog",
                  "log_group_name": "syslog",
                  "log_stream_name": "{instance_id}"
                },
                {
                  "file_path": "/var/log/auth.log",
                  "log_group_name": "auth-log",
                  "log_stream_name": "{instance_id}"
                },
                {
                  "file_path": "/var/log/cloud-init-output.log",
                  "log_group_name": "cloud-init-output",
                  "log_stream_name": "{instance_id}",
                  "timestamp_format": "%b %d %H:%M:%S"
                }
              ]
            }
          }
        }
      }
      EOL


      
      # restarts cloudwatch agent using new config

      /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

      
      
      # updates and upgrades instance
      
      sudo apt update
      sudo apt upgrade -y && sudo apt install -y
      sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
      sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

      # install nginx

      sudo apt install nginx -y
      nginx -t
      sudo sed -i -e 's/<h1>Welcome to nginx!/<h1>target/g' /var/www/html/index.nginx-debian.html
    EOF






    monitor = <<-EOF

      # ${timestamp()}  - causes unique user data every apply meaning this ec2 to be remade if user_data_replace_on_change is true

      
      
      # restarts cloudwatch agent using new config

      /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

      
      
      # updates and upgrades instance

      sudo apt update
      sudo apt upgrade -y

      sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
      sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

      
      
      # install nginx

      sudo apt install nginx -y

      
      
      # install git
      
      sudo apt install -y git
      
      
      
      # install node and dotenv

      sudo apt-get install -y nodejs npm


      
      # clone app repo from specified branch
      
      sudo git clone --branch ${var.app-branch} ${var.app-repo} /var/www/monitorapp


      # adds env file
      cat <<EOT > /var/www/monitorapp/.env
      AWS_REGION=${var.region}
      SNS_TOPIC_ARN=${module.sns.topic_arn}
      EOT



      # create server js folder and move server js file from static files location

      cd /var/www/monitorapp
      npm install dotenv
      sudo npm init -y
      sudo npm install express aws-sdk body-parser
      cd ~

      
      
      # set directory permissions
      
      sudo chown -R www-data:www-data /var/www/monitorapp
      sudo chmod -R 755 /var/www/monitorapp
      


      # creates ssl self signed key and certificate

      PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
      sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/selfsigned.key \
        -out /etc/ssl/certs/selfsigned.crt \
        -subj "/C=GB/ST=England/L=Manchester/O=bens EPA/CN=$PUBLIC_IP"

      
      
      # configure nginx
      
      NGINX_CONFIG="/etc/nginx/sites-available/monitorapp"
      cat << 'EOL' | sudo tee $NGINX_CONFIG > /dev/null
      server {
        listen 443 ssl;
        server_name _;

        ssl_certificate /etc/ssl/certs/selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/selfsigned.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        root /var/www/monitorapp;
        index html/index.html;

        location / {
            autoindex on; 
            try_files $uri $uri/ /index.html;
        }

        # Other location blocks remain the same
        location /css/ {
            alias /var/www/monitorapp/css/;
        }

        location /js/ {
            alias /var/www/monitorapp/js/;
        }

        location /api/ {
            proxy_pass http://localhost:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }
      }
      EOL

      sudo ln -s $NGINX_CONFIG /etc/nginx/sites-enabled/

      
      
      # remove default nginx config to avoid conflicts
      
      sudo rm /etc/nginx/sites-enabled/default

      
      
      # test nginx config
      
      sudo nginx -t

      
      
      # reload nginx 
      
      sudo systemctl reload nginx
      


      # starts node server

      sudo node /var/www/monitorapp/server.js

      EOF
  }
}