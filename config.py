#!/usr/bin/env python3
"""
Configurações do sistema ETL TESTE GEO (Postgres → MySQL)
Centralizadas todas as configurações de conexão e parâmetros

SEGURANÇA:
- Credenciais são carregadas de variáveis de ambiente
- Arquivo .env é usado para desenvolvimento local
- NUNCA commite credenciais no código!
"""

import os
from pathlib import Path
from typing import Dict, Any

# Carregar variáveis de ambiente do arquivo .env se existir
try:
    from dotenv import load_dotenv
    # Procurar arquivo .env no diretório do projeto
    env_path = Path(__file__).parent / '.env'
    if env_path.exists():
        load_dotenv(env_path)
        print(f"✅ Configurações carregadas de: {env_path}")
    else:
        print("⚠️  Arquivo .env não encontrado, usando variáveis de ambiente do sistema")
except ImportError:
    print("⚠️  python-decouple não instalado, usando variáveis de ambiente do sistema")

# =====================================
# CONFIGURAÇÕES DE PATHS
# =====================================

# Diretório base do projeto
BASE_DIR = Path(__file__).parent

# Pasta com os scripts SQL (prioritiza variável de ambiente)
SQL_SCRIPTS_DIR = os.getenv('SQL_SCRIPTS_PATH', str(BASE_DIR / 'sql_scripts'))

# Pasta de logs (prioritiza variável de ambiente)
LOG_DIR = Path(os.getenv('LOG_DIRECTORY', str(BASE_DIR / "logs")))
LOG_DIR.mkdir(exist_ok=True)

# =====================================
# CONFIGURAÇÕES POSTGRESQL (ORIGEM)
# =====================================

def get_postgres_source_config() -> Dict[str, Any]:
    """
    Carrega configurações PostgreSQL de origem de variáveis de ambiente
    Retorna erro se credenciais obrigatórias não estiverem definidas
    """
    config = {
        'host': os.getenv('POSTGRES_SOURCE_HOST'),
        'port': int(os.getenv('POSTGRES_SOURCE_PORT', '5432')),
        'database': os.getenv('POSTGRES_SOURCE_DATABASE'),
        'user': os.getenv('POSTGRES_SOURCE_USER'),
        'password': os.getenv('POSTGRES_SOURCE_PASSWORD')
    }
    
    # Validar campos obrigatórios
    required_fields = ['host', 'database', 'user', 'password']
    missing_fields = [field for field in required_fields if not config.get(field)]
    
    if missing_fields:
        raise ValueError(f"Configurações PostgreSQL origem obrigatórias não definidas: {missing_fields}. "
                        f"Defina as variáveis de ambiente: {[f'POSTGRES_SOURCE_{field.upper()}' for field in missing_fields]}")
    
    return config

# Carregar configurações PostgreSQL origem
try:
    POSTGRES_SOURCE_CONFIG = get_postgres_source_config()
except ValueError as e:
    print(f"❌ ERRO: {e}")
    # Em desenvolvimento, usar valores padrão com aviso
    if os.getenv('ENV', 'development') == 'development':
        print("🚨 ATENÇÃO: Usando configurações padrão para desenvolvimento!")
        print("🚨 Configure o arquivo .env com suas credenciais reais!")
        POSTGRES_SOURCE_CONFIG = {
            'host': 'localhost',
            'port': 5432,
            'database': 'origem_db',
            'user': 'postgres', 
            'password': 'CONFIGURE_NO_ARQUIVO_ENV'
        }
    else:
        raise

# =====================================
# CONFIGURAÇÕES MYSQL (DESTINO)
# =====================================

def get_mysql_config() -> Dict[str, Any]:
    """
    Carrega configurações MySQL de variáveis de ambiente
    Retorna erro se credenciais obrigatórias não estiverem definidas
    """
    config = {
        'host': os.getenv('MYSQL_HOST', 'localhost'),
        'port': int(os.getenv('MYSQL_PORT', '3306')),
        'database': os.getenv('MYSQL_DATABASE'),
        'user': os.getenv('MYSQL_USER'),
        'password': os.getenv('MYSQL_PASSWORD'),
        'charset': 'utf8mb4'
    }
    
    # Validar campos obrigatórios
    required_fields = ['database', 'user', 'password']
    missing_fields = [field for field in required_fields if not config.get(field)]
    
    if missing_fields:
        raise ValueError(f"Configurações MySQL obrigatórias não definidas: {missing_fields}. "
                        f"Defina as variáveis de ambiente: {[f'MYSQL_{field.upper()}' for field in missing_fields]}")
    
    return config

# Carregar configurações MySQL
try:
    MYSQL_CONFIG = get_mysql_config()
except ValueError as e:
    print(f"❌ ERRO: {e}")
    # Em desenvolvimento, usar valores padrão com aviso
    if os.getenv('ENV', 'development') == 'development':
        print("🚨 ATENÇÃO: Usando configurações padrão para desenvolvimento!")
        print("🚨 Configure o arquivo .env com suas credenciais reais!")
        MYSQL_CONFIG = {
            'host': 'localhost',
            'port': 3306,
            'database': 'destino_db',
            'user': 'root',
            'password': 'CONFIGURE_NO_ARQUIVO_ENV',
            'charset': 'utf8mb4'
        }
    else:
        raise

# =====================================
# CONFIGURAÇÕES DO ETL
# =====================================

ETL_CONFIG = {
    # Estratégia de carga: 'replace' (DROP/CREATE) ou 'append' (INSERT)
    'load_strategy': os.getenv('ETL_LOAD_STRATEGY', 'replace'),
    
    # Timeout para queries (em segundos)
    'query_timeout': int(os.getenv('ETL_QUERY_TIMEOUT', '300')),
    
    # Tamanho do batch para inserção
    'batch_size': int(os.getenv('ETL_BATCH_SIZE', '1000')),
    
    # Prefixo para tabelas (opcional)
    'table_prefix': os.getenv('ETL_TABLE_PREFIX', ''),
    
    # Sufixo para tabelas (opcional) 
    'table_suffix': os.getenv('ETL_TABLE_SUFFIX', ''),
    
    # Extensões de arquivo SQL aceitas
    'sql_extensions': ['.sql'],
    
    # Arquivos SQL para ignorar (regex patterns)
    'ignore_patterns': [
        r'.*test.*',
        r'.*backup.*',
        r'.*\.bak\.sql$'
    ]
}

# =====================================
# CONFIGURAÇÕES DE LOG
# =====================================

LOG_CONFIG = {
    'level': os.getenv('ETL_LOG_LEVEL', 'INFO'),  # DEBUG, INFO, WARNING, ERROR, CRITICAL
    'format': '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    'date_format': '%Y-%m-%d %H:%M:%S',
    'max_file_size': int(os.getenv('LOG_MAX_FILE_SIZE', str(10 * 1024 * 1024))),  # 10MB default
    'backup_count': int(os.getenv('LOG_BACKUP_COUNT', '5')),
    'log_file': LOG_DIR / 'etl_teste_geo.log'
}

# =====================================
# MAPEAMENTO DE TIPOS DE DADOS
# =====================================

# Mapeamento PostgreSQL -> MySQL
TYPE_MAPPING = {
    # Numéricos
    'NUMERIC': 'DECIMAL',
    'INTEGER': 'INT', 
    'BIGINT': 'BIGINT',
    'SMALLINT': 'SMALLINT',
    'REAL': 'FLOAT',
    'DOUBLE PRECISION': 'DOUBLE',
    
    # Texto
    'VARCHAR': 'VARCHAR',
    'CHAR': 'CHAR',
    'TEXT': 'LONGTEXT',
    
    # Data/Hora
    'DATE': 'DATE',
    'TIMESTAMP': 'DATETIME',
    'TIMESTAMPTZ': 'DATETIME',
    'TIME': 'TIME',
    
    # Binários
    'BYTEA': 'LONGBLOB',
    
    # Outros
    'BOOLEAN': 'BOOLEAN',
    'JSON': 'JSON',
    'JSONB': 'JSON'
}

# Tipos padrão para inferência pandas
PANDAS_TO_MYSQL = {
    'object': 'LONGTEXT',
    'int64': 'BIGINT',
    'int32': 'INT',
    'int16': 'SMALLINT',
    'float64': 'DOUBLE',
    'float32': 'FLOAT',
    'bool': 'BOOLEAN',
    'datetime64[ns]': 'DATETIME',
    'timedelta64[ns]': 'TIME'
}

# =====================================
# FUNÇÕES HELPER
# =====================================

def get_postgres_source_connection_string():
    """Retorna string de conexão PostgreSQL origem para SQLAlchemy"""
    return (f"postgresql://{POSTGRES_SOURCE_CONFIG['user']}:{POSTGRES_SOURCE_CONFIG['password']}"
            f"@{POSTGRES_SOURCE_CONFIG['host']}:{POSTGRES_SOURCE_CONFIG['port']}"
            f"/{POSTGRES_SOURCE_CONFIG['database']}")

def get_mysql_connection_string():
    """Retorna string de conexão MySQL para SQLAlchemy"""
    return (f"mysql+mysqlconnector://{MYSQL_CONFIG['user']}:{MYSQL_CONFIG['password']}"
            f"@{MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}"
            f"/{MYSQL_CONFIG['database']}?charset=utf8mb4")

def get_table_name_from_file(sql_file_path):
    """Extrai nome da tabela a partir do nome do arquivo SQL"""
    file_name = Path(sql_file_path).stem  # Remove extensão
    
    # Aplica prefixo e sufixo se configurados
    table_name = f"{ETL_CONFIG['table_prefix']}{file_name}{ETL_CONFIG['table_suffix']}"
    
    return table_name.lower()  # MySQL usa lowercase por padrão

# =====================================
# VALIDAÇÕES
# =====================================

def validate_config():
    """Valida se todas as configurações estão corretas"""
    errors = []
    
    # Verifica pasta de scripts SQL
    if not os.path.exists(SQL_SCRIPTS_DIR):
        errors.append(f"Pasta de scripts SQL não encontrada: {SQL_SCRIPTS_DIR}")
    
    # Verifica configurações obrigatórias PostgreSQL origem
    pg_source_required = ['host', 'port', 'database', 'user', 'password']
    for field in pg_source_required:
        if not POSTGRES_SOURCE_CONFIG.get(field):
            errors.append(f"Configuração PostgreSQL origem obrigatória faltando: {field}")
    
    # Verifica configurações obrigatórias MySQL
    mysql_required = ['host', 'port', 'database', 'user', 'password']
    for field in mysql_required:
        if not MYSQL_CONFIG.get(field):
            errors.append(f"Configuração MySQL obrigatória faltando: {field}")
    
    return errors

if __name__ == "__main__":
    # Teste das configurações
    errors = validate_config()
    if errors:
        print("❌ Erros de configuração encontrados:")
        for error in errors:
            print(f"   • {error}")
    else:
        print("✅ Configurações válidas!")
        print(f"📁 Scripts SQL: {SQL_SCRIPTS_DIR}")
        print(f"🐘 PostgreSQL origem: {POSTGRES_SOURCE_CONFIG['host']}:{POSTGRES_SOURCE_CONFIG['port']}")
        print(f"🐬 MySQL destino: {MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}")
