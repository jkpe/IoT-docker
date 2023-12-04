doctl compute droplet create iot-droplet --size s-2vcpu-4gb --image ubuntu-23-10-x64 --region lon1 --enable-backups --user-data "#cloud-config

runcmd:
  - apt-get update && apt-get upgrade
  - curl -fsSL https://get.docker.com -o get-docker.sh
  - sh get-docker.sh
  - apt-get update && apt-get install -y docker-compose git
  - git clone https://github.com/jkpe/docker-compose-mosquitto-influxdb-telegraf-grafana
  - cd docker-compose-mosquitto-influxdb-telegraf-grafana
  - export INFLUXDB_ADMIN_TOKEN=$(openssl rand -hex 24)
  - export INFLUXDB_USERNAME=$(openssl rand -hex 8)
  - export INFLUXDB_PASSWORD=$(openssl rand -hex 8)
  - sed -i 's/DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=/DOCKER_INFLUXDB_INIT_ADMIN_TOKEN='$INFLUXDB_ADMIN_TOKEN'/g' docker-compose.yml
  - sed -i 's/DOCKER_INFLUXDB_INIT_USERNAME=/DOCKER_INFLUXDB_INIT_USERNAME='$INFLUXDB_USERNAME'/g' docker-compose.yml
  - sed -i 's/DOCKER_INFLUXDB_INIT_PASSWORD=/DOCKER_INFLUXDB_INIT_PASSWORD='$INFLUXDB_PASSWORD'/g' docker-compose.yml
  - sed -i 's/token = \"\"/token = \"'$INFLUXDB_ADMIN_TOKEN'\"/g' telegraf.conf
  - sed -i 's/token: token_here/token: '$INFLUXDB_ADMIN_TOKEN'/g' grafana-provisioning/datasources/automatic.yml

  - docker-compose up -d