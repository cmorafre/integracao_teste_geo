#!/usr/bin/env python3
"""
Funções principais do ETL TESTE GEO (Postgres → MySQL)
Contém todas as funções de extração, transformação e carga
"""

import pandas as pd
import psycopg2
import mysql.connector
import sqlalchemy
from sqlalchemy import create_engine, text, MetaData, Table, Column, inspect
import logging
import re
from pathlib import Path
from typing import List, Dict, Tuple, Optional
import time
from datetime import datetime

from config import (
    POSTGRES_SOURCE_CONFIG, MYSQL_CONFIG, ETL_CONFIG, 
    TYPE_MAPPING, PANDAS_TO_MYSQL,
    get_postgres_source_connection_string, get_mysql_connection_string,
    get_table_name_from_file
)

# Configurar logging
logger = logging.getLogger(__name__)

class ETLProcessor:
    """Classe principal para processamento ETL (Postgres → MySQL)"""
    
    def __init__(self):
        self.postgres_source_engine = None
        self.mysql_engine = None
        self.stats = {
            'processed_files': 0,
            'total_records': 0,
            'errors': 0,
            'start_time': None,
            'end_time': None
        }
    
    def connect_databases(self) -> bool:
        """Estabelece conexões com PostgreSQL (origem) e MySQL (destino)"""
        try:
            logger.info("Conectando aos bancos de dados...")
            
            # Conexão PostgreSQL origem
            pg_source_conn_str = get_postgres_source_connection_string()
            self.postgres_source_engine = create_engine(
                pg_source_conn_str,
                echo=False,
                pool_pre_ping=True,
                pool_recycle=3600
            )
            
            # Teste conexão PostgreSQL origem
            with self.postgres_source_engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            logger.info("✅ PostgreSQL origem conectado com sucesso")
            
            # Conexão MySQL destino
            mysql_conn_str = get_mysql_connection_string()
            self.mysql_engine = create_engine(
                mysql_conn_str,
                echo=False,
                pool_pre_ping=True,
                pool_recycle=3600
            )
            
            # Teste conexão MySQL
            with self.mysql_engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            logger.info("✅ MySQL conectado com sucesso")
            
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro ao conectar bancos: {e}")
            return False
    
    def get_sql_files(self, sql_dir: str) -> List[Path]:
        """Retorna lista de arquivos SQL para processamento"""
        sql_path = Path(sql_dir)
        
        if not sql_path.exists():
            logger.error(f"Diretório não encontrado: {sql_dir}")
            return []
        
        # Buscar arquivos SQL
        sql_files = []
        for ext in ETL_CONFIG['sql_extensions']:
            sql_files.extend(sql_path.glob(f"*{ext}"))
        
        # Filtrar arquivos ignorados
        filtered_files = []
        for file_path in sql_files:
            skip_file = False
            for pattern in ETL_CONFIG['ignore_patterns']:
                if re.search(pattern, str(file_path), re.IGNORECASE):
                    logger.info(f"⏭️  Ignorando arquivo: {file_path.name}")
                    skip_file = True
                    break
            
            if not skip_file:
                filtered_files.append(file_path)
        
        logger.info(f"📁 Encontrados {len(filtered_files)} arquivos SQL para processamento")
        return sorted(filtered_files)
    
    def extract_data_from_postgres(self, sql_file: Path) -> Optional[pd.DataFrame]:
        """Extrai dados do PostgreSQL executando script SQL"""
        try:
            logger.info(f"🔍 Extraindo dados de: {sql_file.name}")
            
            # Ler conteúdo do arquivo SQL
            with open(sql_file, 'r', encoding='utf-8') as f:
                sql_content = f.read().strip()
            
            if not sql_content:
                logger.warning(f"⚠️  Arquivo SQL vazio: {sql_file.name}")
                return None
            
            # Remover comentários e comandos não suportados
            sql_content = self._clean_sql(sql_content)
            
            # Executar query no PostgreSQL origem
            start_time = time.time()
            df = pd.read_sql(
                sql_content, 
                self.postgres_source_engine,
                coerce_float=True,
                parse_dates=True
            )
            
            execution_time = time.time() - start_time
            logger.info(f"✅ Extraídos {len(df)} registros em {execution_time:.2f}s")
            
            return df
            
        except Exception as e:
            logger.error(f"❌ Erro ao extrair dados de {sql_file.name}: {e}")
            self.stats['errors'] += 1
            return None
    
    def _clean_sql(self, sql_content: str) -> str:
        """Limpa SQL removendo comandos problemáticos"""
        # Remover comentários de linha única
        sql_content = re.sub(r'--.*$', '', sql_content, flags=re.MULTILINE)
        
        # Remover comentários de bloco
        sql_content = re.sub(r'/\*.*?\*/', '', sql_content, flags=re.DOTALL)
        
        # Remover comandos PostgreSQL específicos que podem causar problema
        postgres_commands = [
            r'SET\s+\w+.*?;',
            r'\\.*?;',  # comandos psql como \dt, \d, etc
            r'COPY\s+.*?;',
            r'\\COPY\s+.*?;'
        ]
        
        for cmd in postgres_commands:
            sql_content = re.sub(cmd, '', sql_content, flags=re.IGNORECASE)
        
        # Remover múltiplas quebras de linha
        sql_content = re.sub(r'\n\s*\n', '\n', sql_content)
        
        return sql_content.strip()
    
    def infer_mysql_schema(self, df: pd.DataFrame, table_name: str) -> List[Tuple[str, str]]:
        """Infere schema MySQL baseado no DataFrame"""
        schema = []
        
        for column, dtype in df.dtypes.items():
            # Limpar nome da coluna
            clean_column = str(column).lower().strip()
            clean_column = re.sub(r'[^a-zA-Z0-9_]', '_', clean_column)
            
            # Mapear tipo pandas para MySQL
            dtype_str = str(dtype)
            
            if dtype_str in PANDAS_TO_MYSQL:
                mysql_type = PANDAS_TO_MYSQL[dtype_str]
            elif 'int' in dtype_str:
                mysql_type = 'BIGINT'
            elif 'float' in dtype_str:
                mysql_type = 'DOUBLE'
            elif 'object' in dtype_str:
                # Para strings, tentar inferir tamanho máximo
                max_length = df[column].astype(str).str.len().max() if not df[column].empty else 255
                max_length = max(max_length, 50)  # Mínimo 50 chars
                max_length = min(max_length * 2, 4000)  # Máximo 4000 chars, com folga
                mysql_type = f'VARCHAR({max_length})'
            elif 'datetime' in dtype_str:
                mysql_type = 'DATETIME'
            elif 'bool' in dtype_str:
                mysql_type = 'BOOLEAN'
            else:
                mysql_type = 'LONGTEXT'  # Fallback
            
            schema.append((clean_column, mysql_type))
        
        logger.info(f"📋 Schema inferido para {table_name}: {len(schema)} colunas")
        return schema
    
    def create_mysql_table(self, table_name: str, schema: List[Tuple[str, str]]) -> bool:
        """Cria tabela no MySQL"""
        try:
            with self.mysql_engine.connect() as conn:
                # Drop table se existe (estratégia replace)
                if ETL_CONFIG['load_strategy'] == 'replace':
                    conn.execute(text(f'DROP TABLE IF EXISTS `{table_name}`'))
                    logger.info(f"🗑️  Tabela {table_name} removida (se existia)")
                
                # Construir CREATE TABLE
                columns_sql = []
                for col_name, col_type in schema:
                    columns_sql.append(f'`{col_name}` {col_type}')
                
                create_sql = f"""
                CREATE TABLE `{table_name}` (
                    {', '.join(columns_sql)}
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                """
                
                conn.execute(text(create_sql))
                conn.commit()
                
                logger.info(f"✅ Tabela {table_name} criada com {len(schema)} colunas")
                return True
                
        except Exception as e:
            logger.error(f"❌ Erro ao criar tabela {table_name}: {e}")
            return False
    
    def load_data_to_mysql(self, df: pd.DataFrame, table_name: str, schema: List[Tuple[str, str]]) -> bool:
        """Carrega dados no MySQL"""
        try:
            if df.empty:
                logger.warning(f"⚠️  DataFrame vazio para {table_name}")
                return True
            
            # Renomear colunas do DataFrame para match com schema
            column_mapping = {}
            df_columns = list(df.columns)
            schema_columns = [col[0] for col in schema]
            
            for i, original_col in enumerate(df_columns):
                if i < len(schema_columns):
                    column_mapping[original_col] = schema_columns[i]
            
            df_renamed = df.rename(columns=column_mapping)
            
            # Garantir que só temos as colunas do schema
            df_final = df_renamed[schema_columns]
            
            # Converter tipos problemáticos
            for col_name, col_type in schema:
                if col_name in df_final.columns:
                    if 'VARCHAR' in col_type or col_type == 'LONGTEXT':
                        df_final[col_name] = df_final[col_name].astype(str)
                        df_final[col_name] = df_final[col_name].replace('nan', None)
                    elif col_type in ['INT', 'BIGINT', 'SMALLINT']:
                        df_final[col_name] = pd.to_numeric(df_final[col_name], errors='coerce').astype('Int64')
                    elif col_type in ['FLOAT', 'DOUBLE']:
                        df_final[col_name] = pd.to_numeric(df_final[col_name], errors='coerce')
            
            # Inserir dados
            start_time = time.time()
            
            df_final.to_sql(
                table_name,
                self.mysql_engine,
                if_exists='append',
                index=False,
                chunksize=ETL_CONFIG['batch_size'],
                method='multi'
            )
            
            execution_time = time.time() - start_time
            logger.info(f"✅ {len(df_final)} registros inseridos em {table_name} ({execution_time:.2f}s)")
            
            self.stats['total_records'] += len(df_final)
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro ao carregar dados em {table_name}: {e}")
            self.stats['errors'] += 1
            return False
    
    def process_single_file(self, sql_file: Path) -> bool:
        """Processa um único arquivo SQL"""
        try:
            table_name = get_table_name_from_file(sql_file)
            logger.info(f"🚀 Processando: {sql_file.name} → {table_name}")
            
            # 1. Extract: Buscar dados no PostgreSQL origem
            df = self.extract_data_from_postgres(sql_file)
            if df is None:
                return False
            
            # 2. Transform: Inferir schema
            schema = self.infer_mysql_schema(df, table_name)
            
            # 3. Load: Criar tabela
            if not self.create_mysql_table(table_name, schema):
                return False
            
            # 4. Load: Inserir dados
            if not self.load_data_to_mysql(df, table_name, schema):
                return False
            
            self.stats['processed_files'] += 1
            logger.info(f"🎉 {sql_file.name} processado com sucesso!")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro geral ao processar {sql_file.name}: {e}")
            self.stats['errors'] += 1
            return False
    
    def process_all_files(self, sql_dir: str) -> Dict:
        """Processa todos os arquivos SQL"""
        self.stats['start_time'] = datetime.now()
        logger.info("🚀 INICIANDO PROCESSAMENTO ETL")
        
        try:
            # Conectar bancos
            if not self.connect_databases():
                raise Exception("Falha ao conectar nos bancos de dados")
            
            # Buscar arquivos SQL
            sql_files = self.get_sql_files(sql_dir)
            if not sql_files:
                raise Exception(f"Nenhum arquivo SQL encontrado em {sql_dir}")
            
            # Processar cada arquivo
            successful_files = 0
            for sql_file in sql_files:
                if self.process_single_file(sql_file):
                    successful_files += 1
                
                # Log de progresso
                progress = (successful_files + self.stats['errors']) / len(sql_files) * 100
                logger.info(f"📊 Progresso: {progress:.1f}% ({successful_files + self.stats['errors']}/{len(sql_files)})")
            
            self.stats['end_time'] = datetime.now()
            duration = self.stats['end_time'] - self.stats['start_time']
            
            # Relatório final
            logger.info("=" * 60)
            logger.info("🎯 RELATÓRIO FINAL ETL")
            logger.info("=" * 60)
            logger.info(f"📁 Arquivos processados: {successful_files}/{len(sql_files)}")
            logger.info(f"📊 Total de registros: {self.stats['total_records']:,}")
            logger.info(f"❌ Erros: {self.stats['errors']}")
            logger.info(f"⏱️  Tempo total: {duration}")
            logger.info(f"📈 Taxa de sucesso: {(successful_files/len(sql_files)*100):.1f}%")
            
            return {
                'success': self.stats['errors'] == 0,
                'processed_files': successful_files,
                'total_files': len(sql_files),
                'total_records': self.stats['total_records'],
                'errors': self.stats['errors'],
                'duration': str(duration),
                'success_rate': successful_files/len(sql_files)*100 if sql_files else 0
            }
            
        except Exception as e:
            self.stats['end_time'] = datetime.now()
            logger.error(f"💥 ERRO CRÍTICO NO ETL: {e}")
            return {
                'success': False,
                'error': str(e),
                'processed_files': self.stats['processed_files'],
                'total_records': self.stats['total_records'],
                'errors': self.stats['errors'] + 1
            }
        
        finally:
            # Fechar conexões
            if self.oracle_engine:
                self.oracle_engine.dispose()
            if self.postgresql_engine:
                self.postgresql_engine.dispose()
            logger.info("🔐 Conexões de banco fechadas")

    def get_statistics(self) -> Dict:
        """Retorna estatísticas do processamento"""
        return self.stats.copy()

# =====================================
# FUNÇÕES UTILITÁRIAS
# =====================================

def validate_sql_file(sql_file: Path) -> Tuple[bool, str]:
    """Valida se arquivo SQL é processável"""
    try:
        if not sql_file.exists():
            return False, "Arquivo não existe"
        
        if sql_file.stat().st_size == 0:
            return False, "Arquivo vazio"
        
        # Tentar ler arquivo
        with open(sql_file, 'r', encoding='utf-8') as f:
            content = f.read().strip()
        
        if not content:
            return False, "Conteúdo vazio"
        
        # Verificar se contém SELECT (básico)
        if not re.search(r'\bSELECT\b', content, re.IGNORECASE):
            return False, "Não contém comando SELECT"
        
        return True, "Arquivo válido"
        
    except Exception as e:
        return False, f"Erro ao validar: {e}"

def get_table_info_postgresql(engine, table_name: str) -> Dict:
    """Retorna informações sobre tabela PostgreSQL"""
    try:
        inspector = inspect(engine)
        
        if not inspector.has_table(table_name):
            return {'exists': False}
        
        columns = inspector.get_columns(table_name)
        indexes = inspector.get_indexes(table_name)
        
        # Contar registros
        with engine.connect() as conn:
            result = conn.execute(text(f'SELECT COUNT(*) FROM "{table_name}"'))
            row_count = result.scalar()
        
        return {
            'exists': True,
            'columns': len(columns),
            'column_details': columns,
            'indexes': indexes,
            'row_count': row_count
        }
        
    except Exception as e:
        return {'exists': False, 'error': str(e)}

def cleanup_old_logs(log_dir: Path, days_to_keep: int = 7):
    """Remove logs antigos"""
    try:
        from datetime import timedelta
        cutoff_date = datetime.now() - timedelta(days=days_to_keep)
        
        removed_count = 0
        for log_file in log_dir.glob("*.log*"):
            if log_file.stat().st_mtime < cutoff_date.timestamp():
                log_file.unlink()
                removed_count += 1
        
        if removed_count > 0:
            logger.info(f"🧹 Removidos {removed_count} arquivos de log antigos")
            
    except Exception as e:
        logger.warning(f"⚠️  Erro ao limpar logs antigos: {e}")

def send_notification(message: str, level: str = "INFO"):
    """Placeholder para notificações (email, Slack, etc)"""
    # TODO: Implementar notificações se necessário
    logger.info(f"📬 Notificação {level}: {message}")

def create_summary_report(stats: Dict) -> str:
    """Cria relatório resumido em texto"""
    report = f"""
🎯 RELATÓRIO ETL GEODATA - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
{'='*60}

📊 ESTATÍSTICAS:
   • Arquivos processados: {stats.get('processed_files', 0)}/{stats.get('total_files', 0)}
   • Registros carregados: {stats.get('total_records', 0):,}
   • Erros encontrados: {stats.get('errors', 0)}
   • Taxa de sucesso: {stats.get('success_rate', 0):.1f}%
   • Duração total: {stats.get('duration', 'N/A')}

{'✅ PROCESSAMENTO CONCLUÍDO COM SUCESSO' if stats.get('success') else '❌ PROCESSAMENTO COM ERROS'}

{'='*60}
"""
    return report

# =====================================
# FUNÇÕES DE TESTE E DEBUG
# =====================================

def test_single_sql_file(sql_file_path: str) -> Dict:
    """Testa processamento de um único arquivo SQL"""
    logger.info(f"🧪 TESTE: Processando arquivo individual: {sql_file_path}")
    
    etl = ETLProcessor()
    sql_file = Path(sql_file_path)
    
    if not etl.connect_databases():
        return {'success': False, 'error': 'Falha na conexão'}
    
    try:
        success = etl.process_single_file(sql_file)
        stats = etl.get_statistics()
        
        return {
            'success': success,
            'stats': stats,
            'file': sql_file.name
        }
        
    except Exception as e:
        return {'success': False, 'error': str(e)}
    
    finally:
        if etl.oracle_engine:
            etl.oracle_engine.dispose()
        if etl.postgresql_engine:
            etl.postgresql_engine.dispose()

def dry_run_validation(sql_dir: str) -> Dict:
    """Executa validação sem processar dados"""
    logger.info("🧪 MODO DRY RUN: Validando arquivos SQL")
    
    etl = ETLProcessor()
    sql_files = etl.get_sql_files(sql_dir)
    
    validation_results = {
        'total_files': len(sql_files),
        'valid_files': 0,
        'invalid_files': [],
        'file_details': []
    }
    
    for sql_file in sql_files:
        is_valid, message = validate_sql_file(sql_file)
        table_name = get_table_name_from_file(sql_file)
        
        file_info = {
            'file': sql_file.name,
            'table_name': table_name,
            'valid': is_valid,
            'message': message,
            'size_kb': round(sql_file.stat().st_size / 1024, 2)
        }
        
        validation_results['file_details'].append(file_info)
        
        if is_valid:
            validation_results['valid_files'] += 1
        else:
            validation_results['invalid_files'].append(file_info)
    
    logger.info(f"📋 Validação concluída: {validation_results['valid_files']}/{validation_results['total_files']} arquivos válidos")
    
    return validation_results

if __name__ == "__main__":
    # Teste rápido das funções
    from config import SQL_SCRIPTS_DIR
    
    print("🧪 Testando funções ETL...")
    
    # Teste de validação dry run
    validation = dry_run_validation(SQL_SCRIPTS_DIR)
    print(f"📁 Arquivos encontrados: {validation['total_files']}")
    print(f"✅ Arquivos válidos: {validation['valid_files']}")
    
    if validation['invalid_files']:
        print("❌ Arquivos com problema:")
        for invalid in validation['invalid_files']:
            print(f"   • {invalid['file']}: {invalid['message']}")
