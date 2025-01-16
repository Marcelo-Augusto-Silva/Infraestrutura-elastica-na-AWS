# Bloco de configuração do Terraform
terraform {
  # Define os provedores necessários para o Terraform
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Especifica o provedor AWS da HashiCorp
      version = "~> 4.16"       # Define a versão do provedor (compatível com 4.16 e atualizações menores)
    }
  }
  required_version = ">= 1.2.0" # Exige que a versão do Terraform seja 1.2.0 ou superior
}

# Configuração do provedor AWS
provider "aws" {
  region = var.regiao_aws # Define a região da AWS a ser utilizada (valor definido em variáveis)
}

# Recurso para criar um Launch Template na AWS
resource "aws_launch_template" "maquina" {
  image_id       = "ami-0075013580f6322a1" # ID da AMI para instância EC2 (sistema operacional)
  instance_type  = var.instancia          # Tipo de instância (por exemplo, t2.micro)
  key_name       = var.chave              # Nome da chave SSH para acesso à instância

  # user_data fornece um script que será executado no início da instância (usando Base64 neste caso)
  user_data = var.producao ? filebase64("ansible.sh") : ""
  #Aqui nós colocamos um IF por assim dizer, onde se a var producao for verdadeira ele executa o script, caso ele nao ache o script ele nao ira executar o script

  # security_group_names refere-se ao grupo de segurança associado à instância
  security_group_names = [ var.nome_grupo_seguranca ]

  # Tags associadas ao recurso para organização e identificação
  tags = {
    Name = "Terraform Ansible Python" # Nome amigável para a instância
  }
}

# Recurso para criar uma chave SSH na AWS
resource "aws_key_pair" "chaveSSH" {
  key_name   = var.chave                 # Nome da chave
  public_key = file("${var.chave}.pub") # Arquivo contendo a chave pública SSH
}

# Recurso para criar um grupo de Auto Scaling
resource "aws_autoscaling_group" "grupo" {
  availability_zones = [ "${var.regiao_aws}a", "${var.regiao_aws}b" ] # Zonas de disponibilidade para instâncias
  name               = var.nomeGrupo                                 # Nome do grupo
  max_size           = var.maximo                                    # Número máximo de instâncias
  min_size           = var.minimo                                    # Número mínimo de instâncias

  # Referência ao Launch Template
  launch_template {
    id      = aws_launch_template.maquina.id # ID do Launch Template
    version = "$Latest"                      # Versão mais recente do template
  }

  # Associa um grupo de destino ao Auto Scaling se nao for producao ele nao vai criar o ? é um IF
  target_group_arns = var.producao ? [ aws_lb_target_group.alvoLoadBalancer[0].arn ] : []
}

# Recurso para criar uma sub-rede padrão na Zona de Disponibilidade "a"
resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.regiao_aws}a" # Zona de disponibilidade "a"
}

# Recurso para criar uma sub-rede padrão na Zona de Disponibilidade "b"
resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.regiao_aws}b" # Zona de disponibilidade "b"
}

# Recurso para criar um Load Balancer
resource "aws_lb" "loadBalancer" {
  internal = false # Define o Load Balancer como público
  subnets  = [ aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id ] # Sub-redes associadas
  count = var.producao ? 1 : 0 # O count serve para especificar quantos recursos irao ser criados, caso nao seja producao ele sera 0 e nao criara nenhum recurso
}

# Recurso para criar uma VPC padrão
resource "aws_default_vpc" "vpc" {}

# Recurso para criar um grupo de destino para o Load Balancer
resource "aws_lb_target_group" "alvoLoadBalancer" {
  name      = "alvoLoadBalancer"      # Nome do grupo
  port      = "8000"                  # Porta usada pelo grupo
  protocol  = "HTTP"                  # Protocolo
  vpc_id    = aws_default_vpc.vpc.id # ID da VPC associada
  count = var.producao ? 1 : 0
}

# Recurso para criar um listener para o Load Balancer
resource "aws_lb_listener" "entradaLoadBalancer" {
  load_balancer_arn = aws_lb.loadBalancer[0].arn # Associa ao Load Balancer
  port              = "8000"                 # Porta de escuta
  protocol          = "HTTP"                 # Protocolo de escuta

  # Ação padrão: encaminhar para o grupo de destino
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer[0].arn
  }
  count = var.producao ? 1 : 0
}

# Politica do autoscaling
resource "aws_autoscaling_policy" "escala-Producao" {
  name = "terraform-escala"
  autoscaling_group_name = var.nomeGrupo
  policy_type = "TargetTrackingScaling" #Aqui especificamos que o autoscaling ira provisionar maquinas automaticamente 
  target_tracking_configuration { #Aqui nós colocamos a configuraçao 
    predefined_metric_specification { #Metrica pre definida
      predefined_metric_type = "ASGAverageCPUUtilization" #Ira se basear no consumo de CPU
    }
    target_value = 40.0
  }
  count =  var.producao ? 1 : 0
}
