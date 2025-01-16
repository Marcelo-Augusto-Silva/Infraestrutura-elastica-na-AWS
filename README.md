# Projeto de Infraestrutura como Código (IaC)

Este repositório contém a configuração de infraestrutura para ambientes **Dev** e **Prod** utilizando **Terraform** e **Ansible**, além de scripts para testar aplicações com o **Locust**.

---

## Estrutura do Projeto

- **env/**: Contém os arquivos específicos para os ambientes **Dev** e **Prod**.
  - **Dev/**: Arquivos relacionados ao ambiente de desenvolvimento.
    - **main.tf**: Código Terraform para configurar o ambiente Dev.
    - **playbook.yml**: Playbook do Ansible para provisionamento no ambiente Dev.
  - **Prod/**: Arquivos relacionados ao ambiente de produção.
    - **.terraform/**: Diretório gerado automaticamente pelo Terraform.
    - **terraform.lock.hcl**: Arquivo de bloqueio para dependências Terraform.
    - **ansible.sh**: Script para executar o Ansible no ambiente Prod.
    - **main.tf**: Código Terraform para configurar o ambiente Prod.
    - **playbook.yml**: Playbook do Ansible para provisionamento no ambiente Prod.
    - **terraform.tfstate** e **terraform.tfstate.backup**: Arquivos de estado do Terraform.
- **infra/**: Configuração geral da infraestrutura.
  - **grupo_de_seguranca.tf**: Definição de grupos de segurança no Terraform.
  - **hosts.yml**: Configuração de hosts para o Ansible.
  - **main.tf**: Código principal do Terraform para provisionar recursos.
  - **variables.tf**: Variáveis utilizadas pelo Terraform.
- **testes/**: Diretório reservado para scripts de teste, como o Locust.
- **carga.py**: Script Python para testes de carga com o Locust.

---

## Passo a Passo para Configurar e Subir o Projeto

### 1. Pré-requisitos

Certifique-se de ter instalado:

- [Terraform](https://www.terraform.io/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Python](https://www.python.org/downloads) e o pacote `locust`

### 2. Criar Chaves SSH

Antes de configurar os ambientes, é necessário criar chaves SSH para acesso seguro aos servidores. Siga os passos abaixo para gerar as chaves:

1. Abra o terminal e execute o comando:

   ```bash
   ssh-keygen -t rsa -b 4096 -C "seu-email@exemplo.com"
   ```

2. Quando solicitado, escolha um local para salvar as chaves (ex.: `~/.ssh/iac_key`).

3. Opcionalmente, defina uma senha para proteger a chave privada.

4. O processo gerará dois arquivos:
   - Uma chave privada (`iac_key`).
   - Uma chave pública (`iac_key.pub`).

5. Adicione as seguintes entradas ao arquivo `.gitignore` para garantir que as chaves não sejam incluídas no repositório:

   ```gitignore
   *.pem
   *.pub
   iac_key
   ```

### 3. Configurar o Terraform

1. **Inicializar o Terraform**:
   
   No diretório do ambiente (ex.: `env/Dev` ou `env/Prod`), execute:

   ```bash
   terraform init
   ```

2. **Planejar a Infraestrutura**:

   Gere um plano para revisar as alterações que o Terraform realizará:

   ```bash
   terraform plan
   ```

3. **Aplicar a Configuração**:

   Execute o seguinte comando para criar a infraestrutura:

   ```bash
   terraform apply
   ```

   Confirme digitando `yes` quando solicitado.

### 4. Configurar o Ansible

1. **Executar o Playbook**:

   Após provisionar a infraestrutura com o Terraform, use o Ansible para configurar os servidores:

   ```bash
   ansible-playbook -i infra/hosts.yml env/Dev/playbook.yml
   ```

   Para o ambiente de produção, substitua o caminho do playbook pelo respectivo arquivo de **Prod**.

### 5. Testar a Aplicação com Locust

1. **Instalar o Locust**:

   Instale o Locust utilizando o `pip`:

   ```bash
   pip install locust
   ```

2. **Executar os Testes de Carga**:

   No diretório raiz, execute o comando:

   ```bash
   locust -f carga.py
   ```

3. **Acessar a Interface do Locust**:

   Abra o navegador e vá para [http://localhost:8089](http://localhost:8089). Configure os parâmetros de teste (número de usuários, taxa de spawn) e inicie os testes.

---

## Explicação dos Arquivos Principais

### Terraform

- **main.tf**: Código principal para provisionar a infraestrutura.
- **variables.tf**: Declaração de variáveis para parametrizar a infraestrutura.
- **grupo_de_seguranca.tf**: Configuração de grupos de segurança (regras de firewall).

### Ansible

- **playbook.yml**: Instruções para configurar os servidores provisionados.
- **hosts.yml**: Lista de hosts gerados pelo Terraform.

### Locust

- **carga.py**: Script de testes de carga que simula requisições à aplicação hospedada na infraestrutura provisionada.

---

## Infraestrutura Elástica

Infraestrutura elástica refere-se a uma abordagem de provisionamento e gerenciamento de recursos computacionais que permite escalar automaticamente, de forma vertical ou horizontal, com base na demanda do sistema. Essa característica é fundamental para garantir:

- **Eficiência de Recursos**: Os recursos são utilizados somente quando necessário, reduzindo custos.
- **Alta Disponibilidade**: Permite lidar com aumentos repentinos de tráfego sem impactar o desempenho.
- **Escalabilidade Dinâmica**: Ajusta automaticamente a capacidade da infraestrutura para atender picos de uso ou reduzir custos em períodos de baixa demanda.

Neste projeto, a elasticidade pode ser implementada configurando auto-scaling groups em provedores de nuvem através do Terraform, além de utilizar balanceadores de carga para distribuir o tráfego adequadamente.

---

## Boas Práticas

- Utilize ambientes isolados (ex.: virtualenv) para gerenciar dependências Python.
- Sempre revise o plano gerado pelo `terraform plan` antes de aplicar as mudanças.
- Mantenha os arquivos `.tfstate` protegidos, pois eles contêm informações sensíveis.
- Monitore os resultados do Locust para identificar gargalos de desempenho na aplicação.

---

## Contribuição

Sinta-se à vontade para abrir issues ou enviar pull requests para melhorias neste projeto.
