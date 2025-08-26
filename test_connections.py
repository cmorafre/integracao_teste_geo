#!/usr/bin/env python3
"""
Arquivo para testar conexões com PostgreSQL (origem) e MySQL (destino)
Execute este arquivo antes do ETL principal para validar as conexões
"""

import psycopg2
import mysql.connector
import pandas as pd
from datetime import datetime
import sys

try:
    from config import POSTGRES_SOURCE_CONFIG, MYSQL_CONFIG
except ImportError as e:
    print(f"❌ Erro ao importar configurações: {e}")
    print("💡 Execute este arquivo no diretório do projeto com .env configurado")
    sys.exit(1)

def test_postgres_source_connection():
    """Testa conexão com PostgreSQL origem"""
    print("=" * 60)
    print("TESTANDO CONEXÃO COM POSTGRESQL ORIGEM")
    print("=" * 60)
    
    try:
        print(f"📡 Tentando conectar em: {POSTGRES_SOURCE_CONFIG['host']}:{POSTGRES_SOURCE_CONFIG['port']}/{POSTGRES_SOURCE_CONFIG['database']}")
        print(f"👤 Usuário: {POSTGRES_SOURCE_CONFIG['user']}")
        
        # Conectar
        connection = psycopg2.connect(
            host=POSTGRES_SOURCE_CONFIG['host'],
            port=POSTGRES_SOURCE_CONFIG['port'],
            database=POSTGRES_SOURCE_CONFIG['database'],
            user=POSTGRES_SOURCE_CONFIG['user'],
            password=POSTGRES_SOURCE_CONFIG['password']
        )
        cursor = connection.cursor()
        
        # Teste básico
        cursor.execute("SELECT NOW()")
        result = cursor.fetchone()
        print(f"✅ Conexão PostgreSQL origem OK!")
        print(f"🕐 Data/hora do servidor: {result[0]}")
        
        # Teste de schema
        cursor.execute("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public'")
        table_count = cursor.fetchone()[0]
        print(f"📊 Tabelas disponíveis no schema public: {table_count}")
        
        # Versão PostgreSQL
        cursor.execute("SELECT version()")
        version = cursor.fetchone()[0]
        print(f"🐘 Versão: {version.split(',')[0]}")
        
        cursor.close()
        connection.close()
        
        return True
        
    except Exception as e:
        print(f"❌ ERRO na conexão PostgreSQL origem: {e}")
        return False

def test_mysql_connection():
    """Testa conexão com MySQL destino"""
    print("\n" + "=" * 60)
    print("TESTANDO CONEXÃO COM MYSQL DESTINO")
    print("=" * 60)
    
    try:
        print(f"📡 Tentando conectar em: {MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}/{MYSQL_CONFIG['database']}")
        print(f"👤 Usuário: {MYSQL_CONFIG['user']}")
        
        # Conectar
        connection = mysql.connector.connect(
            host=MYSQL_CONFIG['host'],
            port=MYSQL_CONFIG['port'],
            database=MYSQL_CONFIG['database'],
            user=MYSQL_CONFIG['user'],
            password=MYSQL_CONFIG['password'],
            charset=MYSQL_CONFIG['charset']
        )
        cursor = connection.cursor()
        
        # Teste básico
        cursor.execute("SELECT NOW()")
        result = cursor.fetchone()
        print(f"✅ Conexão MySQL destino OK!")
        print(f"🕐 Data/hora do servidor: {result[0]}")
        
        # Teste de schema
        cursor.execute(f"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '{MYSQL_CONFIG['database']}'")
        table_count = cursor.fetchone()[0]
        print(f"📊 Tabelas disponíveis no database {MYSQL_CONFIG['database']}: {table_count}")
        
        # Versão MySQL
        cursor.execute("SELECT VERSION()")
        version = cursor.fetchone()[0]
        print(f"🐬 Versão: MySQL {version}")
        
        cursor.close()
        connection.close()
        
        return True
        
    except Exception as e:
        print(f"❌ ERRO na conexão MySQL destino: {e}")
        return False

def main():
    """Função principal"""
    print("🔍 TESTE DE CONEXÕES - ETL TESTE GEO")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("")
    
    # Testar conexões
    postgres_ok = test_postgres_source_connection()
    mysql_ok = test_mysql_connection()
    
    # Resultado final
    print("\n" + "=" * 60)
    print("RESUMO DOS TESTES")
    print("=" * 60)
    
    if postgres_ok:
        print("✅ PostgreSQL origem: OK")
    else:
        print("❌ PostgreSQL origem: FALHOU")
    
    if mysql_ok:
        print("✅ MySQL destino: OK")
    else:
        print("❌ MySQL destino: FALHOU")
    
    if postgres_ok and mysql_ok:
        print("\n🎉 Todas as conexões estão funcionando!")
        print("🚀 Você pode executar o ETL principal com: python main.py")
        return True
    else:
        print(f"\n💥 {2 - int(postgres_ok) - int(mysql_ok)} conexão(ões) falharam!")
        print("🔧 Verifique as configurações no arquivo .env")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)