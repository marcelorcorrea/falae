#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Instalar o Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Instalar o Docker Compose
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# Adicionar seu usuário ao grupo "docker" para executar comandos Docker sem sudo
sudo usermod -a -G docker ubuntu

# Iniciar o serviço Docker
sudo systemctl start docker

# Habilitar o Docker para iniciar automaticamente na inicialização
sudo systemctl enable docker

# Aguardar um momento para que o Docker seja inicializado completamente
sleep 5

# Cria o diretório da aplicação (ajuste o caminho conforme necessário)
app_dir="/app"
sudo mkdir -p $app_dir
sudo chown -R ubuntu:ubuntu $app_dir  # Ajusta as permissões

# Clonar o repositório Git
git clone https://github.com/falae-it-talent/falae.git $app_dir

# Copiar o arquivo .env para o caminho /app
cp /tmp/.env /app/.env

# Entrar na pasta da aplicação
#cd $app_dir

# Executar o Docker Compose
#sudo docker compose up -d

#MAX_RETRIES=10
#RETRY_INTERVAL=10
#for ((i = 0; i < MAX_RETRIES; i++)); do
#  echo "Tentativa $((i + 1)) de $MAX_RETRIES: Verificando status dos contêineres..."
#  if sudo docker ps | grep -q "proxy_falae" && sudo docker ps | grep -q "app-app-1" && sudo docker ps | grep -q "mysql"; then
#    echo "Contêineres estão ativos e prontos!"
#    break
#  else
#    echo "Aguardando ${RETRY_INTERVAL} segundos antes da próxima verificação..."
#    sleep $RETRY_INTERVAL
#  fi
#done

# Reinicia o serviço Docker para garantir que os contêineres iniciem com o sistema
#sudo systemctl restart docker