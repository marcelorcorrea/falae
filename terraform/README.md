


# Executando o Terraform Localmente

Este README descreve os passos necessários para executar o Terraform localmente em seu ambiente. Certifique-se de seguir todas as etapas para configurar corretamente o Terraform e a AWS CLI.

## Instalando o Terraform 1.5.7

1.  Baixe a versão 1.5.7 do Terraform a partir do [site oficial do Terraform](https://developer.hashicorp.com/terraform/downloads).
    
2.  Extraia o arquivo baixado e adicione o binário do Terraform à sua variável de ambiente `PATH`.
    
    
```hcl 
    unzip terraform_0.15.7_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
```
    
3.  Verifique se a instalação foi bem-sucedida executando o seguinte comando:
    

```hcl 
    terraform version
```
    

## Instalando o AWS CLI

1.  Instale a AWS CLI seguindo as instruções para o seu sistema operacional disponíveis [aqui](https://aws.amazon.com/cli/).
    
2.  Verifique se a instalação foi bem-sucedida executando o seguinte comando:
    

```hcl 
    aws --version
```

## Configurando Credenciais da AWS

1.  Execute o seguinte comando para configurar suas credenciais da AWS:
    
```hcl 
    aws configure
```
2.  Você será solicitado a fornecer as seguintes informações:
    
    -   AWS Access Key ID
    -   AWS Secret Access Key
    -   Região padrão (por exemplo, `us-west-2`)
    -   Formato de saída (pode deixar como padrão)

## Criando uma Chave SSH

Copie e cole os valores das chaves nos arquvios dentro da pasta `./files`. Para criar uma nova chave SSH, apague os arquivos contidos dentro da pasta `/files` , use o comando `ssh-keygen`, siga estas etapas:

1. Abra um terminal ou prompt de comando no seu sistema.

2. Execute o comando `ssh-keygen` com a opção `-t` para especificar o tipo de chave (por exemplo, `rsa`) e a opção `-f` para especificar o caminho do arquivo de saída. Por exemplo:

```hcl
   ssh-keygen -t rsa -f /files/falae
```

## Modificando Variáveis

Antes de executar o Terraform, é necessário modificar as variáveis no arquivo de configuração do Terraform para refletir a AMI e a região corretas.

1.  Abra o arquivo de configuração do Terraform (`main.tf`) em um editor de texto.
    
2.  Localize as variáveis relacionadas à AMI e à região e atualize-as com os valores corretos (terraform.tfvars). Por exemplo:
    
    hclCopy code
    
```hcl
ubuntu_ami = "ami-0fc5d935ebf8bc3bc"

ec2 = {
  name              = "falae"
  os_type           = "ubuntu"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
}

region = "us-east-1"
```
    
3.  Salve as alterações no arquivo.
    

## Executando o Terraform

Agora que o Terraform está configurado corretamente, você pode executar o seguinte comando para iniciar o processo de implantação:
```hcl
terraform init     # Para inicializar o projeto
terraform fmt      # Para formatar arquivos
terraform validate # Para validar seu código fonte
terraform plan     # Para visualizar as alterações planejadas
terraform apply    # Para aplicar as alterações e provisionar recursos na AWS` 
```
Certifique-se de que todos os passos tenham sido seguidos corretamente e que as variáveis tenham sido configuradas adequadamente para garantir uma implantação bem-sucedida.