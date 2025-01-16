module "AWS-prod" {
    source = "../../infra"
    instancia = "t2.micro"
    regiao_aws = "us-west-2"
    chave = "IAC-PROD"
    nome_grupo_seguranca = "acesso Producao"
    minimo = 1
    maximo = 10
    nomeGrupo = "Prod"
    producao = true 
}
