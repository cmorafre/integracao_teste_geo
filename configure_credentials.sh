#!/bin/bash

# =============================================================================
# CONFIGURAÇÃO DE CREDENCIAIS - ETL TESTE GEO (PostgreSQL → MySQL)
# =============================================================================
# Este script configura as credenciais de acesso aos bancos de dados
# Execute após a instalação da infraestrutura (setup.sh)
# =============================================================================

set -e  # Parar se qualquer comando falhar

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para ler entrada com valor padrão
read_with_default() {
    local prompt="$1"
    local default="$2"
    local value
    
    echo -ne "${CYAN}$prompt${NC}" >&2
    if [ -n "$default" ]; then
        echo -ne " [${YELLOW}$default${NC}]: " >&2
    else
        echo -ne ": " >&2
    fi
    
    read value
    echo "${value:-$default}"
}

# Função para ler senha (mascarada)
read_password() {
    local prompt="$1"
    local password
    
    echo -ne "${CYAN}$prompt${NC}: " >&2
    read -s password
    echo "" >&2  # Nova linha após input mascarado
    echo "$password"
}

# Função para testar conexão PostgreSQL origem
test_postgres_source_connection() {
    local host="$1"
    local port="$2"
    local database="$3"
    local user="$4"
    local password="$5"
    
    echo -e "${YELLOW}🧪 Testando conexão PostgreSQL origem...${NC}"
    echo -e "${CYAN}    Host: $host:$port${NC}"
    echo -e "${CYAN}    Database: $database${NC}"
    echo -e "${CYAN}    User: $user${NC}"
    
    # Verificar se python e módulos necessários estão disponíveis
    if ! python3 -c "import psycopg2" 2>/dev/null; then
        echo -e "${RED}❌ Módulo psycopg2 não encontrado${NC}"
        return 1
    fi
    
    # Usar python para testar conexão com timeout
    timeout 30 python3 << EOF
import sys
try:
    import psycopg2
    
    # Tentar conexão
    connection = psycopg2.connect(
        host='$host',
        port='$port',
        database='$database',
        user='$user',
        password='$password'
    )
    cursor = connection.cursor()
    cursor.execute("SELECT NOW()")
    result = cursor.fetchone()
    cursor.close()
    connection.close()
    
    print("✅ Conexão PostgreSQL origem OK!")
    print(f"📅 Data/hora do servidor: {result[0]}")
    sys.exit(0)
    
except Exception as e:
    print(f"❌ Erro na conexão PostgreSQL origem: {e}")
    sys.exit(1)
EOF
}

# Função para testar conexão MySQL destino
test_mysql_connection() {
    local host="$1"
    local port="$2"
    local database="$3"
    local user="$4"
    local password="$5"
    
    echo -e "${YELLOW}🧪 Testando conexão MySQL destino...${NC}"
    echo -e "${CYAN}    Host: $host:$port${NC}"
    echo -e "${CYAN}    Database: $database${NC}"
    echo -e "${CYAN}    User: $user${NC}"
    
    # Verificar se python e módulos necessários estão disponíveis
    if ! python3 -c "import mysql.connector" 2>/dev/null; then
        echo -e "${RED}❌ Módulo mysql.connector não encontrado${NC}"
        return 1
    fi
    
    # Usar python para testar conexão com timeout
    timeout 30 python3 << EOF
import sys
try:
    import mysql.connector
    
    # Tentar conexão
    connection = mysql.connector.connect(
        host='$host',
        port='$port',
        database='$database',
        user='$user',
        password='$password',
        charset='utf8mb4'
    )
    cursor = connection.cursor()
    cursor.execute("SELECT NOW()")
    result = cursor.fetchone()
    cursor.close()
    connection.close()
    
    print("✅ Conexão MySQL destino OK!")
    print(f"📅 Data/hora do servidor: {result[0]}")
    sys.exit(0)
    
except Exception as e:
    print(f"❌ Erro na conexão MySQL destino: {e}")
    sys.exit(1)
EOF
}

# =============================================================================
# INÍCIO DO SCRIPT
# =============================================================================

echo -e "${BLUE}=================================="
echo -e "🔒 CONFIGURAÇÃO DE CREDENCIAIS"
echo -e "     ETL TESTE GEO"
echo -e "     PostgreSQL → MySQL"
echo -e "==================================${NC}"
echo ""

# Verificar se estamos no diretório correto
echo -e "${CYAN}📍 Diretório atual: $(pwd)${NC}"

if [ ! -f "main.py" ] || [ ! -f "config.py" ]; then
    echo -e "${RED}❌ Execute este script no diretório /opt/etl_teste_geo/${NC}"
    echo -e "${YELLOW}💡 Comando: cd /opt/etl_teste_geo && ./configure_credentials.sh${NC}"
    
    # Mostrar arquivos presentes para debug
    echo -e "${BLUE}📋 Arquivos encontrados no diretório atual:${NC}"
    ls -la
    exit 1
fi

echo -e "${GREEN}✅ Arquivos principais encontrados${NC}"

# Verificar se ambiente virtual existe e ativar
if [ -d "venv" ]; then
    echo -e "${GREEN}🐍 Ativando ambiente virtual...${NC}"
    
    # Verificar se o activate existe e é executável
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
        echo -e "${GREEN}✅ Ambiente virtual ativado${NC}"
        
        # Verificar e instalar python-dotenv se necessário
        if ! python3 -c "import dotenv" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Instalando python-dotenv...${NC}"
            pip install python-dotenv >/dev/null 2>&1
            if python3 -c "import dotenv" 2>/dev/null; then
                echo -e "${GREEN}✅ python-dotenv instalado${NC}"
            else
                echo -e "${YELLOW}⚠️  Falha ao instalar python-dotenv, continuando...${NC}"
            fi
        fi
        
    else
        echo -e "${RED}❌ Arquivo venv/bin/activate não encontrado${NC}"
        echo -e "${YELLOW}💡 Continuando com Python global...${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Ambiente virtual não encontrado${NC}"
    echo -e "${BLUE}💡 Continuando com Python global do sistema${NC}"
fi

# Não há configurações especiais de ambiente para PostgreSQL/MySQL
echo -e "${BLUE}🔧 Ambiente preparado para PostgreSQL e MySQL${NC}"

echo -e "${CYAN}Este script irá configurar as credenciais de acesso aos bancos de dados.${NC}"
echo -e "${YELLOW}As senhas não serão exibidas na tela por segurança.${NC}"
echo ""
echo -e "${GREEN}🚀 COMO USAR:${NC}"
echo -e "${CYAN}   1. Para cada pergunta, você verá um valor padrão em [amarelo]${NC}"
echo -e "${CYAN}   2. Pressione ENTER para aceitar o padrão${NC}"
echo -e "${CYAN}   3. Ou digite um novo valor para substituir${NC}"
echo -e "${CYAN}   4. As senhas ficarão ocultas quando digitadas${NC}"
echo ""

# =============================================================================
# CONFIGURAÇÕES POSTGRESQL ORIGEM
# =============================================================================

echo -e "${BLUE}🐘 CONFIGURAÇÕES POSTGRESQL (Banco de Origem)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}💡 Instruções:${NC}"
echo -e "${YELLOW}   • Pressione ENTER para aceitar valores padrão [em amarelo]${NC}"
echo -e "${YELLOW}   • Digite um novo valor para substituir o padrão${NC}"
echo -e "${YELLOW}   • A senha será oculta por segurança${NC}"
echo ""

POSTGRES_SOURCE_HOST=$(read_with_default "Host/IP do servidor PostgreSQL origem" "localhost")
POSTGRES_SOURCE_PORT=$(read_with_default "Porta do PostgreSQL" "5432")
POSTGRES_SOURCE_DATABASE=$(read_with_default "Nome do database origem" "origem_db")
POSTGRES_SOURCE_USER=$(read_with_default "Usuário PostgreSQL" "postgres")
POSTGRES_SOURCE_PASSWORD=$(read_password "Senha PostgreSQL origem")

if [ -z "$POSTGRES_SOURCE_PASSWORD" ]; then
    echo -e "${RED}❌ Senha PostgreSQL origem é obrigatória!${NC}"
    exit 1
fi

echo ""

# =============================================================================
# CONFIGURAÇÕES MYSQL
# =============================================================================

echo -e "${BLUE}🐬 CONFIGURAÇÕES MYSQL (Banco de Destino)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}💡 Configure as credenciais do MySQL:${NC}"
echo ""

MYSQL_HOST=$(read_with_default "Host/IP do servidor MySQL" "localhost")
MYSQL_PORT=$(read_with_default "Porta do MySQL" "3306")
MYSQL_DATABASE=$(read_with_default "Nome do database MySQL" "destino_db")
MYSQL_USER=$(read_with_default "Usuário MySQL" "root")
MYSQL_PASSWORD=$(read_password "Senha MySQL")

if [ -z "$MYSQL_PASSWORD" ]; then
    echo -e "${RED}❌ Senha MySQL é obrigatória!${NC}"
    exit 1
fi

echo ""

# =============================================================================
# CONFIGURAÇÕES OPCIONAIS DO ETL
# =============================================================================

echo -e "${BLUE}⚙️  CONFIGURAÇÕES DO ETL (Opcionais)${NC}"
echo -e "${BLUE}═══════════════════════════════════${NC}"
echo -e "${CYAN}💡 Configure parâmetros do ETL (pode aceitar os padrões):${NC}"
echo ""

ETL_LOAD_STRATEGY=$(read_with_default "Estratégia de carga (replace/append)" "replace")
ETL_QUERY_TIMEOUT=$(read_with_default "Timeout de queries (segundos)" "300")
ETL_BATCH_SIZE=$(read_with_default "Tamanho do batch" "1000")
ETL_LOG_LEVEL=$(read_with_default "Nível de log (DEBUG/INFO/WARNING/ERROR)" "INFO")

echo ""

# =============================================================================
# TESTE DE CONEXÕES
# =============================================================================

echo -e "${YELLOW}🔍 TESTANDO CONEXÕES...${NC}"
echo ""

# Testar PostgreSQL origem
if ! test_postgres_source_connection "$POSTGRES_SOURCE_HOST" "$POSTGRES_SOURCE_PORT" "$POSTGRES_SOURCE_DATABASE" "$POSTGRES_SOURCE_USER" "$POSTGRES_SOURCE_PASSWORD"; then
    echo -e "${RED}💥 Falha na conexão PostgreSQL origem!${NC}"
    echo -e "${YELLOW}🔧 Verifique as credenciais e tente novamente.${NC}"
    echo -e "${BLUE}💡 Para reconfigurar: ./configure_credentials.sh${NC}"
    exit 1
fi

echo ""

# Testar MySQL destino
if ! test_mysql_connection "$MYSQL_HOST" "$MYSQL_PORT" "$MYSQL_DATABASE" "$MYSQL_USER" "$MYSQL_PASSWORD"; then
    echo -e "${RED}💥 Falha na conexão MySQL destino!${NC}"
    echo -e "${YELLOW}🔧 Verifique as credenciais e tente novamente.${NC}"
    echo -e "${BLUE}💡 Para reconfigurar: ./configure_credentials.sh${NC}"
    exit 1
fi

echo ""

# =============================================================================
# CRIAÇÃO DO ARQUIVO .env
# =============================================================================

echo -e "${YELLOW}📝 Criando arquivo de configuração .env...${NC}"

# Backup do .env anterior se existir
if [ -f ".env" ]; then
    cp .env .env.backup
    echo -e "${GREEN}✅ Backup do .env anterior salvo em .env.backup${NC}"
fi

# Criar novo arquivo .env
cat > .env << EOF
# =============================================================================
# CONFIGURAÇÕES ETL TESTE GEO - PRODUÇÃO (PostgreSQL → MySQL)
# =============================================================================
# ⚠️  Este arquivo contém credenciais sensíveis - mantenha seguro!
# 🔒 Criado automaticamente em: $(date)
# =============================================================================

# CONFIGURAÇÕES POSTGRESQL (ORIGEM)
POSTGRES_SOURCE_HOST=$POSTGRES_SOURCE_HOST
POSTGRES_SOURCE_PORT=$POSTGRES_SOURCE_PORT
POSTGRES_SOURCE_DATABASE=$POSTGRES_SOURCE_DATABASE
POSTGRES_SOURCE_USER=$POSTGRES_SOURCE_USER
POSTGRES_SOURCE_PASSWORD=$POSTGRES_SOURCE_PASSWORD

# CONFIGURAÇÕES MYSQL (DESTINO)
MYSQL_HOST=$MYSQL_HOST
MYSQL_PORT=$MYSQL_PORT
MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD

# CONFIGURAÇÕES DO ETL
ETL_LOAD_STRATEGY=$ETL_LOAD_STRATEGY
ETL_QUERY_TIMEOUT=$ETL_QUERY_TIMEOUT
ETL_BATCH_SIZE=$ETL_BATCH_SIZE
ETL_LOG_LEVEL=$ETL_LOG_LEVEL

# DIRETÓRIOS
SQL_SCRIPTS_PATH=/opt/etl_teste_geo/sql_scripts
LOG_DIRECTORY=/opt/etl_teste_geo/logs

# AMBIENTE
ENV=production
EOF

# Configurar permissões restritas
chmod 600 .env

echo -e "${GREEN}✅ Arquivo .env criado com sucesso!${NC}"
echo -e "${GREEN}🔒 Permissões restritivas aplicadas (600)${NC}"

# =============================================================================
# TESTE FINAL
# =============================================================================

echo ""
echo -e "${YELLOW}🧪 Executando teste final de configuração...${NC}"

# Testar carregamento das configurações
if python3 -c "from config import POSTGRES_SOURCE_CONFIG, MYSQL_CONFIG; print('✅ Configurações carregadas com sucesso!')" 2>/dev/null; then
    echo -e "${GREEN}✅ Sistema configurado e funcional!${NC}"
else
    echo -e "${RED}❌ Erro ao carregar configurações!${NC}"
    exit 1
fi

# Desativar ambiente virtual
deactivate

# =============================================================================
# FINALIZAÇÃO
# =============================================================================

echo ""
echo -e "${GREEN}🎉 CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📋 PRÓXIMOS PASSOS:${NC}"
echo -e "1. Testar conexões: ${CYAN}python test_connections.py${NC}"
echo -e "2. Executar ETL teste: ${CYAN}python main.py --dry-run${NC}"
echo -e "3. Executar ETL completo: ${CYAN}python main.py${NC}"
echo ""
echo -e "${YELLOW}🔧 COMANDOS ÚTEIS:${NC}"
echo -e "• Ativar ambiente virtual: ${CYAN}source venv/bin/activate${NC}"
echo -e "• Ver logs: ${CYAN}tail -f logs/etl_teste_geo.log${NC}"
echo -e "• Reconfigurar credenciais: ${CYAN}./configure_credentials.sh${NC}"
echo ""
echo -e "${GREEN}🔒 Suas credenciais estão seguras em: /opt/etl_teste_geo/.env${NC}"
echo -e "${BLUE}🚀 Sistema ETL TESTE GEO pronto para produção!${NC}"