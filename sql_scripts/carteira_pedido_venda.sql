SELECT codigo_loja, loja, pedido, serie, dt_emissao, cod_parceiro, parceiro, cod_propriedade, propriedade, cod_ciclo, ciclo_safra, cod_condicao, condicao, cod_vendedor, vendedor, 
cod_operacao, operacao, cfop, desc_cfop, vcto_pedido, vcto_pfp, cod_indexador, indexador, vlor_indexador, total_pedido, total_om_pedido, cod_produto, produto, cod_grupo, grupo, 
cod_subgrupo, subgrupo, cod_fabricante, fabricante, qtde_pedida, qtde_entregue, qtde_perdida, saldo_pedido, qtde_pedida_om, qtde_entregue_om, qtde_perdida_om, saldo_om, vlor_unitario, 
vlor_unit_om, total_item, total_item_om, custo_tabela, custo_tabela_om, cod_tabela, tabela_preco, usuario_inclusao, custo_medio, custo_compra, princ_ativo, cgc_tra
FROM public.f_carteira_pedido_venda
where cod_ciclo >=22