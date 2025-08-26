-- Exemplo de consulta PostgreSQL para teste
-- Este arquivo será executado no PostgreSQL origem
SELECT 
    'user_' || generate_series(1, 100) as id_usuario,
    'Usuario ' || generate_series(1, 100) as nome,
    'usuario' || generate_series(1, 100) || '@email.com' as email,
    CASE 
        WHEN generate_series(1, 100) % 2 = 0 THEN 'Ativo'
        ELSE 'Inativo'
    END as status,
    NOW() - INTERVAL '1 day' * (generate_series(1, 100) % 365) as data_criacao