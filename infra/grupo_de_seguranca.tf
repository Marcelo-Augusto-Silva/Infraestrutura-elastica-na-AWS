resource "aws_security_group" "acesso_geral" {
    name = var.nome_grupo_seguranca
    description = var.nome_grupo_seguranca
    ingress{ # As Regras de entradas
        cidr_blocks = ["0.0.0.0/0"] # Configurar os IPs que podem entrar
        ipv6_cidr_blocks = ["::/0"] # Configurar os IpsV6
        from_port = 0 # Configurando as portas disponiveis
        to_port = 0
        protocol = "-1" # Liberar todos os protocolos
    } 
    egress{ # As Regras de Saida
        cidr_blocks = ["0.0.0.0/0"] # Configurar os IPs que podem entrar
        ipv6_cidr_blocks = ["::/0"] # Configurar os IpsV6
        from_port = 0 # Configurando as portas disponiveis
        to_port = 0
        protocol = "-1" # Liberar todos os protocolos

    }  
    tags = {
        name = var.nome_grupo_seguranca
    }

}