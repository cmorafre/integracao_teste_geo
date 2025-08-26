
SELECT TIPO_NF,
    LOJA,
    EMISSAO_RECBTO,
    NF,
    SERIE,
    COD_OPERACAO,
    DESC_OPERACAO,
    COD_PARCEIRO,
    RAZAO,
    COD_VENDEDOR,
    NOME_VENDEDOR,
    CPF_VENDEDOR,
    COD_PROD,
    DESC_PRODUTO,
    COD_GRUPO,
    DESC_GRUPO,
    COD_SUBGRUPO,
    DESC_SUBGRUPO,
    QTDE,
    CASE
      WHEN QTDE < 0
      THEN ABS(VLR_UNIT) * -1
      ELSE ABS(VLR_UNIT)
    END VLR_UNIT,
    CASE
      WHEN QTDE < 0
      THEN ABS(CAST(TOTAL_PRODUTO AS DECIMAL (16,2))) * -1
      ELSE ABS(CAST(TOTAL_PRODUTO AS DECIMAL (16,2)))
    END TOTAL_PRODUTO,
    CASE
      WHEN QTDE < 0
      THEN ABS(CAST (TOTAL_NF AS DECIMAL (16,2))) * -1
      ELSE ABS(CAST (TOTAL_NF AS DECIMAL (16,2)))
    END TOTAL_NF,
    CASE
      WHEN QTDE < 0
      THEN ABS(CUSTO_UNIT) * -1
      ELSE ABS(CUSTO_UNIT)
    END CUSTO_TABELA,
    CASE
      WHEN QTDE < 0
      THEN ABS(CAST( CUSTO_UNIT * QTDE AS DECIMAL (16,2))) * -1
      ELSE ABS(CAST( CUSTO_UNIT * QTDE AS DECIMAL (16,2)))
    END CUSTO_TOTAL_TABELA,
    CASE
      WHEN QTDE < 0
      THEN ABS(CUSTO_MED_UNIT) * -1
      ELSE ABS(CUSTO_MED_UNIT)
    END CUSTO_MEDIO,
    CASE
      WHEN QTDE < 0
      THEN ABS(CAST(CUSTO_MED_UNIT * QTDE AS DECIMAL (16,2))) * -1
      ELSE ABS(CAST(CUSTO_MED_UNIT * QTDE AS DECIMAL (16,2)))
    END CUSTO_TOTAL_MEDIO,
    TIPO_ENTRADA_SAIDA,
    VENC_REC,
    ITEM,
    COD_CICLO,
    CICLO,
    CAST(
    CASE
      WHEN VLR_UNIT <> 0
      THEN ((VLR_UNIT-CUSTO_UNIT)/VLR_UNIT)*100
      ELSE 0
    END AS DECIMAL (16,2)) MARGEM,
    COALESCE(VENCIMENTO_INICIAL,EMISSAO_RECBTO) VENCIMENTO_INICIAL,
    COALESCE(VENCIMENTO_FINAL,EMISSAO_RECBTO) VENCIMENTO_FINAL,
    COD_FABRICANTE,
    FABRICANTE,
    VLOR_VLR COTACAO,
    QTDE / VLOR_VLR QTDE_OM,
    CASE
      WHEN QTDE < 0
      THEN (ABS(VLR_UNIT)  * -1) / VLOR_VLR
      ELSE (ABS(VLR_UNIT)) / VLOR_VLR
    END VLR_UNIT_OM,
    CASE
      WHEN QTDE < 0
      THEN ABS(CAST(TOTAL_PRODUTO / VLOR_VLR AS DECIMAL (16,2))) * -1
      ELSE ABS(CAST(TOTAL_PRODUTO / VLOR_VLR AS DECIMAL (16,2)))
    END TOTAL_PRODUTO_OM,
    CASE
      WHEN QTDE < 0
      THEN ABS(CAST (TOTAL_NF / VLOR_VLR AS DECIMAL (16,2))) * -1
      ELSE ABS(CAST (TOTAL_NF / VLOR_VLR AS DECIMAL (16,2)))
    END TOTAL_NF_OM,
    CASE
      WHEN QTDE < 0
      THEN ABS(CUSTO_UNIT/ VLOR_VLR ) * -1
      ELSE ABS(CUSTO_UNIT/ VLOR_VLR )
    END CUSTO_TABELA_OM,
    CASE
      WHEN QTDE < 0
      THEN ABS(CAST( (CUSTO_UNIT * QTDE) / VLOR_VLR AS DECIMAL (16,2))) * -1
      ELSE ABS(CAST( (CUSTO_UNIT * QTDE) / VLOR_VLR AS DECIMAL (16,2)))
    END CUSTO_TOTAL_TABELA_OM,
    CASE
      WHEN QTDE < 0
      THEN ABS(CUSTO_MED_UNIT/ VLOR_VLR ) * -1
      ELSE ABS(CUSTO_MED_UNIT/ VLOR_VLR )
    END CUSTO_MEDIO_OM,
    CASE
      WHEN QTDE < 0
      THEN ABS(CAST(CUSTO_MED_UNIT  * QTDE AS             DECIMAL (16,2))) * -1
      ELSE ABS(CAST((CUSTO_MED_UNIT * QTDE) / VLOR_VLR AS DECIMAL (16,2)))
    END CUSTO_TOTAL_MEDIO_OM,
    CONDICAO,
    INDEXADOR,
    CMVD_INO CUSTO_MEDIO_DOC,
    CASE
      WHEN CUST_CFO = '1'
      THEN UPPER('1-Valor Nominal da NF Deduzindo ICMS')
      WHEN CUST_CFO = '2'
      THEN UPPER('2-Valor Nominal da NF NÃO Deduzindo ICMS')
      WHEN CUST_CFO = '3'
      THEN UPPER('3-Custo mEdio na data')
      WHEN CUST_CFO = '4'
      THEN UPPER('4-BonificaCAO')
      WHEN CUST_CFO = '5'
      THEN UPPER('5-Valor nominal da NF deduzindo ICMS Origem')
      WHEN CUST_CFO = '9'
      THEN UPPER('9-NAO Atualiza')
    END ATUALIZA_CUSTO,
    COALESCE(DEPC_CFO,'N') DEDUZ_PIS_COFINS,
    CCFO_CFO,
    DESC_CFO,
    TIPO_EST,
    PROP_PRO,
    DESC_PRO,
    CODI_MUN CODI_MUN_PRO,
    DESC_MUN DESC_MUN_PRO,
    ESTA_MUN ESTA_MUN_PRO,
    CGC_TRA,
    CODI_MUN_TRA,
    DESC_MUN_TRA,
    ESTA_MUN_TRA,
    TABE_CTA, DESC_CTA, PERC,
    CASE
      WHEN QTDE < 0
      THEN ABS(CCPD_INO) * -1
      ELSE ABS(CCPD_INO)
    END CUSTO_COMPRA,
   empr_ped EMPRESA_PEDIDO, 
    pedi_ped NUMERO_PEDIDO,  seri_ped SERIE_PEDIDO,  vcto_ped VENCIMENTO_PEDIDO,
    BASE_ICMS,
    ALIQ_ICMS,
    ICMS,
    IPI,
    ALIQ_IPI,
    BASE_PIS,
    ALIQ_PIS,
    PIS,
    BASE_COFINS,
    ALIQ_COFINS,
    COFINS,
    BASE_ISS,
    ALIQ_ISS,
    ISS,
    OBSE_NOT OBSERVACAO,
    CHAVE_ACESSO,
    CODI_CUL COD_CULTURA_PEDIDO, NOME_CUL CULTURA_PEDIDO,
     NUME_REC NUMERO_RECEITA,  COD_CULTURA_RECEITA,  CULTURA_RECEITA
  FROM
    (SELECT 'NE' TIPO_NF,
      N.CODI_EMP LOJA,
      N.DEMI_NOT EMISSAO_RECBTO,
      N.NOTA_NOT NF,
      N.SERI_NOT SERIE,
      N.CODI_TOP COD_OPERACAO,
      TOP.DESC_TOP DESC_OPERACAO,
      N.CODI_TRA COD_PARCEIRO,
      T.RAZA_TRA RAZAO,
      N.COD1_PES COD_VENDEDOR,
      P.NOME_PES NOME_VENDEDOR,
      CPF_PES CPF_VENDEDOR,
      I.CODI_PSV COD_PROD,
      PSV.DESC_PSV DESC_PRODUTO,
      PSV.CODI_GPR COD_GRUPO,
      G.DESC_GPR DESC_GRUPO,
      PSV.CODI_SBG COD_SUBGRUPO,
      S.DESC_SBG DESC_SUBGRUPO,
      CASE
        WHEN f.func_top = 'A'
        THEN I.QTDE_INO
        ELSE I.QTDE_INO * -1
      END QTDE,
      I.VLIQ_INO VLR_UNIT,
      CASE
        WHEN f.func_top = 'A'
        THEN COALESCE((I.QTDE_INO * I.VLIQ_INO),0)
        ELSE COALESCE((I.QTDE_INO * I.VLIQ_INO),0) * -1
      END TOTAL_PRODUTO,
      CASE
        WHEN f.func_top = 'A'
        THEN N.TOTA_NOT
        ELSE N.TOTA_NOT * -1
      END TOTAL_NF ,
      CASE
        WHEN COALESCE(PNFO_TOP,'N') = 'N'
        THEN I.CTAB_INO
        ELSE nfr.ctab_ino
      END CUSTO_UNIT,
      CASE
      WHEN (TOP.tipo_top = 'E') AND 
           (CFO.CUST_CFO = '3') AND           
           (CFO.RETO_CFO = 'S') then nfr.CMVD_INO 
        --WHEN COALESCE(PNFO_TOP,'N') = 'N' THEN nfr.CMVD_INO 
        ELSE I.CMVD_INO
      END CUSTO_MED_UNIT,
      F.CODI_PTO TIPO_ENTRADA_SAIDA,
      T.VENC_REC,
      I.ITEM_INO ITEM,
      N.CODI_CIC COD_CICLO,
      CIC.DESC_CIC CICLO,
      T.VENCIMENTO_INICIAL,
      T.VENCIMENTO_FINAL,
      FAB.CODI_TRA COD_FABRICANTE,
      FAB.RAZA_TRA FABRICANTE,
      COALESCE(IND.VLOR_VLR,1) VLOR_VLR,
      CON.COND_CON
      || '-'
      || CON.DESC_CON CONDICAO,
      CASE
        WHEN ND.CODI_IND IS NOT NULL
        THEN ND.CODI_IND
          || '-'
          || ND.DESC_IND
        ELSE NULL
      END "INDEXADOR",
      I.CMVD_INO,
      CFO.CUST_CFO,
      CFO.DEPC_CFO,
      CFO.CCFO_CFO,
      CFO.DESC_CFO,
      EST.TIPO_EST,
      PROP.PROP_PRO,
      PROP.DESC_PRO,
      MUN.CODI_MUN,
      MUN.DESC_MUN,
      MUN.ESTA_MUN,
      T.CGC_TRA,
      MUNT.CODI_MUN CODI_MUN_TRA,
      MUNT.DESC_MUN DESC_MUN_TRA,
      MUNT.ESTA_MUN ESTA_MUN_TRA,
      CTA.TABE_CTA, CTA.DESC_CTA ,
      COALESCE((I.QTDE_INO ),0) /
      (SELECT SUM(COALESCE((I1.QTDE_INO ),0)) FROM INOTA I1 
       WHERE I1.NPRE_NOT = I.NPRE_NOT AND
             I1.CODI_PSV = I.CODI_PSV) PERC,
    COALESCE(CCPD_INO,0) CCPD_INO  ,
    PED.empr_ped, 
   PED.pedi_ped, PED.seri_ped, ped.vcto_ped,
   I.BICM_INO BASE_ICMS,
    I.AICM_INO ALIQ_ICMS,
    I.VICM_INO ICMS,
    I.VIPI_INO IPI,
    I.AIPI_INO ALIQ_IPI,
    I.BPIS_INO BASE_PIS,
    I.APIS_INO ALIQ_PIS,
    I.PIS_INO PIS,
    I.BCOF_INO BASE_COFINS,
    I.ACOF_INO ALIQ_COFINS,
    I.COFI_INO COFINS,
    I.BISS_INO BASE_ISS,
    I.AISS_INO ALIQ_ISS,
    I.VISS_INO ISS,
    RETO_CFO,
    CAST(N.OBSE_NOT AS VARCHAR (4000)) OBSE_NOT,
    N.CHAV_NOT CHAVE_ACESSO,
    PED.CODI_CUL, PED.NOME_CUL,
    RECEI.NUME_REC, RECEI.CODI_CUL COD_CULTURA_RECEITA, RECEI.NOME_CUL CULTURA_RECEITA
    FROM INOTA I
    INNER JOIN NOTA N
    ON (N.NPRE_NOT = I.NPRE_NOT)
    LEFT JOIN CICLO CIC
    ON CIC.CODI_CIC = N.CODI_CIC
    LEFT join CABTAB CTA ON CTA.TABE_CTA = I.TABE_CTA
    INNER JOIN TRANSAC T
    ON (T.CODI_TRA = N.CODI_TRA)
    LEFT JOIN PROPRIED PROP
    ON PROP.PROP_PRO = N.PROP_PRO
    LEFT JOIN MUNICIPIO MUN
    ON MUN.CODI_MUN = PROP.CODI_MUN
    LEFT JOIN MUNICIPIO MUNT
    ON MUNT.CODI_MUN = T.CODI_MUN
    LEFT JOIN PESSOAL P
    ON (P.CODI_PES = N.COD1_PES)
    INNER JOIN FUNCAOTOPER F
    ON (F.CODI_TOP = N.CODI_TOP)
    INNER JOIN TIPOOPER TOP
    ON (TOP.CODI_TOP = N.CODI_TOP)
    INNER JOIN CFO CFO
    ON (CFO.CCFO_CFO = I.CCFO_CFO)
    INNER JOIN PRODSERV PSV
    ON (PSV.CODI_PSV = I.CODI_PSV)
    INNER JOIN GRUPO G
    ON (G.CODI_GPR = PSV.CODI_GPR)
    LEFT JOIN SUBGRUPO S
    ON (S.CODI_SBG = PSV.CODI_SBG
    AND S.CODI_GPR = PSV.CODI_GPR)
    LEFT JOIN PRODUTO PRO
    ON (PRO.CODI_PSV = PSV.CODI_PSV)
    LEFT JOIN transac fab
    ON (fab.codi_tra = PRO.codi_tra)
    LEFT JOIN condicao con
    ON con.COND_CON = n.COND_CON
    LEFT JOIN indexador nd
    ON nd.codi_ind = n.codi_ind
    LEFT JOIN INDVALOR IND
    ON IND.CODI_IND  = N.CODI_IND
    AND IND.CODI_EMP = N.CODI_EMP
    AND IND.DATA_VLR = N.DATA_VLR
    LEFT JOIN
      (SELECT codi_top,
        tipo_est
      FROM
        (SELECT t.codi_top,
          LISTAGG( t.tipo_est,';') WITHIN GROUP (
        ORDER BY t.tipo_est) tipo_est
        FROM
          ( SELECT DISTINCT t.codi_top,
            CASE
              WHEN tipo_est = '1'
              THEN UPPER ('1-Estoque DisponIvel')
              WHEN tipo_est = '2'
              THEN UPPER ('2-Estoque Pertencente a Empresa')
              WHEN tipo_est = '3'
              THEN UPPER ('3-Estoque da Empresa com Terceiros')
              WHEN tipo_est = '4'
              THEN UPPER ('4-Estoque de Terceiros com a Empresa')
              WHEN tipo_est = '5'
              THEN UPPER ('5-Estoque Disponível Fiscal')
              WHEN tipo_est = '6'
              THEN UPPER ('6-Estoque Físico DisponIvel para Faturamento')
            END tipo_est
          FROM estoque e
          INNER JOIN topctrl t
          ON t.codi_ctr   = e.codi_ctr
          WHERE TIPO_EST <> 0
          ORDER BY 1
          ) T
        GROUP BY t.codi_top
        )
      ) EST ON EST.CODI_TOP = TOP.CODI_TOP
    LEFT JOIN
      (SELECT T.codi_emp,
        T.codi_tra,
        T.ndoc_nOC,
        T.sdoc_nOC,
        T.Tdoc_nOC,
        (SELECT LISTAGG( to_date(VENC_REC,'dd/mm/yyyy'),';') WITHIN GROUP (
        ORDER BY VENC_REC) VENC_REC
        FROM
          ( SELECT DISTINCT VENC_REC, CTRL_CBR FROM receber rec
          )
        WHERE CTRL_CBR = C.CTRL_CBR
        ) VENC_REC,
        (SELECT VENC_REC
        FROM
          (SELECT VENC_REC
          FROM receber r
          WHERE r.ctrl_cbr = c.ctrl_cbr
          ORDER BY r.VENC_REC
          )
        WHERE rownum <=1
        ) VENCIMENTO_INICIAL ,
        (SELECT VENC_REC
        FROM
          (SELECT VENC_REC
          FROM receber r
          WHERE r.ctrl_cbr = c.ctrl_cbr
          ORDER BY r.VENC_REC DESC
          )
        WHERE rownum <=1
        ) VENCIMENTO_FINAL
      FROM CABREC C
      INNER JOIN NOTACRC T
      ON T.ctrl_cBR     = C.ctrl_cBR
      WHERE C.SITU_CBR <> 'C'
      ) T ON T.CODI_EMP = N.CODI_EMP
    AND T.CODI_TRA      = N.CODI_tRA
    AND T.NDOC_NOC      = N.NOTA_NOT
    AND T.sdoc_NOC      = N.SERI_NOT
    AND T.Tdoc_NOC      = 'NE'
    LEFT JOIN
      (SELECT nfr.notd_nfr,
        nfr.serd_nfr,
        nfr.codi_emp,
        nfr.ited_nfr,
        nfr.tipd_nfr,
        nfr.tipo_nfr,
        nfr.trad_nfr,
        nfr.ctrd_nfr,
        ctab_ino,
        CMVD_INO
      FROM
        (SELECT nfr.notd_nfr,
          nfr.serd_nfr,
          nfr.codi_emp,
          nfr.ited_nfr,
          nfr.tipd_nfr,
          nfr.tipo_nfr,
          nfr.trad_nfr,
          nfr.ctrd_nfr,
          INO.ctab_ino,
          ino.CMVD_INO
        FROM inota ino
        INNER JOIN nota nta
        ON nta.npre_not = ino.npre_not
        INNER JOIN notaorig nfr
        ON nfr.noto_nfr     = ino.npre_not
        AND nfr.codi_emp    = nta.codi_emp
        AND nfr.sero_nfr    = nta.seri_not
        AND nfr.iteo_nfr    = ino.item_ino
        WHERE nfr.tipd_nfr IN('NE','NT')
        AND nfr.tipo_nfr    = 'NE'
        UNION ALL
        SELECT nfr.notd_nfr,
          nfr.serd_nfr,
          nfr.codi_emp,
          nfr.ited_nfr,
          nfr.tipd_nfr,
          nfr.tipo_nfr,
          nfr.trad_nfr,
          nfr.ctrd_nfr,
          INF.ctab_inf,
          INF.CMED_INF
        FROM INFENTRA INF
        INNER JOIN NOTAORIG NFR
        ON nfr.noto_nfr     = INF.nume_nfe
        AND nfr.codi_emp    = INF.codi_emp
        AND nfr.sero_nfr    = INF.seri_nfe
        AND nfr.iteo_nfr    = INF.item_inf
        AND NFR.trao_nfr    = INF.codi_tra
        WHERE nfr.tipd_nfr IN('NE','NT')
        AND nfr.tipo_nfr    = 'NT'
        ) nfr
      ) nfr ON nfr.notd_nfr = n.npre_not
    AND nfr.serd_nfr        = n.seri_not
    AND nfr.codi_emp        = n.codi_emp
    AND nfr.ited_nfr        = i.item_ino
    AND nfr.tipd_nfr        = 'NE'
    LEFT JOIN 
    (select 
   ino.npre_not,  ino.empr_ped, 
   ino.pedi_ped, ino.seri_ped, ped.vcto_ped,
   ino.item_ino,
   ipe.codi_cul, ipe.codi_psv,
     C.NOME_CUL
   from nota nta 
    inner join inota ino on ino.npre_not = nta.npre_not 
    inner join pedido ped on ped.pedi_ped = ino.pedi_ped and
                            ped.codi_emp = ino.empr_ped and
                            ped.seri_ped = ino.seri_ped
    inner join ipedido ipe on ped.pedi_ped = ipe.pedi_ped and
                              ped.codi_emp = ipe.codi_emp and
                              ped.seri_ped = ipe.seri_ped and 
                              ipe.codi_psv = ino.codi_psv
    LEFT JOIN CULTURA C ON C.CODI_CUL = IPE.CODI_CUL                          
    UNION 
    select 
     NFR.NOTD_NFR,  ino.empr_ped, 
     ino.pedi_ped, ino.seri_ped, ped.vcto_ped,
     NFR.ITED_NFR,
     ipe.codi_cul, ipe.codi_psv,
     C.NOME_CUL
    from nota nta 
    inner join inota ino on ino.npre_not = nta.npre_not 
    inner join pedido ped on ped.pedi_ped = ino.pedi_ped and
                             ped.codi_emp = ino.empr_ped and
                             ped.seri_ped = ino.seri_ped
    inner join ipedido ipe on ped.pedi_ped = ipe.pedi_ped and
                              ped.codi_emp = ipe.codi_emp and
                              ped.seri_ped = ipe.seri_ped and
                              ino.codi_psv = ipe.codi_psv
    LEFT JOIN CULTURA C ON C.CODI_CUL = IPE.CODI_CUL                           
    inner join notaorig nfr on nfr.codi_emp = nta.codi_emp and
                               nfr.noto_nfr = nta.npre_not and
                               nfr.sero_nfr = nta.seri_not and 
                               nfr.iteo_nfr = ino.item_ino and
                               nfr.tipO_nfr = 'NE' AND
                               NFR.TIPD_NFR = 'NE'
    ) PED ON PED.NPRE_NOT = N.NPRE_NOT AND
             PED.ITEM_INO = I.ITEM_INO
    LEFT JOIN 
    (

    select TMP.NUME_REC, TMP.NOTA_NOT, TMP.SERI_NOT, TMP.CODI_EMP, TMP.CODI_PSV, TMP.CODI_CUL, C.NOME_CUL FROM
    (SELECT 
    R.NUME_REC, R.NOTA_NOT, R.SERI_NOT, R.CODI_EMP, I.CODI_PSV, MIN(I.CODI_CUL) CODI_CUL
    from receita R
    INNER JOIN ireceita I ON I.CTRL_REC = R.CTRL_REC     
    WHERE STAT_REC <> 'C'
    GROUP BY
    R.NOTA_NOT, R.SERI_NOT, R.CODI_EMP, I.CODI_PSV,  R.NUME_REC )
    TMP
    LEFT JOIN CULTURA C ON C.CODI_CUL = TMP.CODI_CUL
    ) RECEI ON RECEI.NOTA_NOT = N.NOTA_NOT AND
               RECEI.SERI_NOT = N.SERI_NOT AND
               RECEI.CODI_EMP = N.CODI_EMP AND
               RECEI.CODI_PSV = I.CODI_PSV
    WHERE N.SITU_NOT        = 5
    AND cfo.COMP_CFO       IN ('1','2','7','11','D','E')
    UNION
    SELECT 'NT' TIPO_NF,
      N.CODI_EMP LOJA,
      N.DREC_NFE EMISSAO_RECEBTO,
      N.NUME_NFE NF,
      N.SERI_NFE SERIE,
      N.CODI_TOP COD_OPERACAO,
      TOP.DESC_TOP DESC_OPERACAO,
      N.CODI_TRA COD_PARCEIRO,
      T.RAZA_TRA RAZAO,
      N.COD1_PES COD_VENDEDOR,
      P.NOME_PES NOME_VENDEDOR,
      CPF_PES CPF_VENDEDOR,
      I.CODI_PSV COD_PROD,
      PSV.DESC_PSV DESC_PRODUTO,
      PSV.CODI_GPR COD_GRUPO,
      G.DESC_GPR DESC_GRUPO,
      PSV.CODI_SBG COD_SUBGRUPO,
      S.DESC_SBG DESC_SUBGRUPO,
      CASE
        WHEN f.func_top = 'A'
        THEN I.QUAN_INF
        ELSE I.QUAN_INF * -1
      END QTDE,
      I.VLIQ_INF VLR_UNIT,
      CASE
        WHEN f.func_top = 'A'
        THEN COALESCE((I.QUAN_INF * I.VLIQ_INF),0)
        ELSE COALESCE((I.QUAN_INF * I.VLIQ_INF),0) * -1
      END TOTAL_PRODUTO,
      CASE
        WHEN f.func_top = 'A'
        THEN N.TOTA_NFE
        ELSE N.TOTA_NFE * -1
      END TOTAL_NF ,
      CASE
        WHEN COALESCE(PNFO_TOP,'N') = 'N'
        THEN I.CTAB_INF
        ELSE NFR.ctab_ino
      END,
      CASE
        WHEN (TOP.tipo_top = 'E') AND 
           (CFO.CUST_CFO = '3') AND           
           (CFO.RETO_CFO = 'S') then NFR.CMVD_INO         
        ELSE I.CMED_INF
      END CUST_MED_UNIT,
      F.CODI_PTO,
      T.VENC_REC,
      I.ITEM_INF,
      N.CODI_CIC,
      CIC.DESC_CIC,
      T.VENCIMENTO_INICIAL,
      T.VENCIMENTO_FINAL,
      FAB.CODI_TRA COD_FABRICANTE,
      FAB.RAZA_TRA FABRICANTE,
      COALESCE(IND.VLOR_VLR,1) VLOR_VLR,
      CON.COND_CON
      || '-'
      || CON.DESC_CON CONDICAO,
      CASE
        WHEN ND.CODI_IND IS NOT NULL
        THEN ND.CODI_IND
          || '-'
          || ND.DESC_IND
        ELSE NULL
      END INDEXADOR,
      I.CMED_INF,
      CFO.CUST_CFO,
      CFO.DEPC_CFO,
      CFO.CCFO_CFO,
      CFO.DESC_CFO,
      EST.TIPO_EST,
      PROP.PROP_PRO,
      PROP.DESC_PRO,
      MUN.CODI_MUN,
      MUN.DESC_MUN,
      MUN.ESTA_MUN,
      T.CGC_TRA,
      MUNT.CODI_MUN CODI_MUN_TRA,
      MUNT.DESC_MUN DESC_MUN_TRA,
      MUNT.ESTA_MUN ESTA_MUN_TRA,
      NULL TABE_CTA, NULL DESC_CTA ,
      (I.QUAN_INF )/
      (select sum(COALESCE((I1.QUAN_INF ),0)) from infentra I1
       where i1.codi_emp = i.codi_emp and
             i1.nume_nfe = i.nume_nfe and
             i1.codi_emp = i.codi_emp and
             i1.ctrl_nfe = i.ctrl_nfe and
             i1.seri_nfe = i.seri_nfe AND
             I1.CODI_PSV = I.CODI_PSV) PERC,
    COALESCE(CCPD_INF,0) CCPD_INF  ,
    PED.empr_ped, 
   PED.pedi_ped, PED.seri_ped, ped.vcto_ped,
   I.BICM_INF BASE_ICMS,
    I.AICM_INF ALIQ_ICMS,
    I.VICM_INF ICMS,
    I.TIPI_INF IPI,
    I.PIPI_INF ALIQ_IPI,
    I.BPIS_INF BASE_PIS,
    I.APIS_INF ALIQ_PIS,
    I.PIS_INF PIS,
    I.BCOF_INF BASE_COFINS,
    I.ACOF_INF ALIQ_COFINS,
    I.COFI_INF COFINS,
    I.BISS_INF BASE_ISS,
    I.AISS_INF ALIQ_ISS,
    I.VISS_INF ISS,
    RETO_CFO,
    CAST(OBSE_NFE AS VARCHAR (4000)),
    N.CHAV_NFE CHAVE_ACESSO,
    PED.CODI_CUL, PED.NOME_CUL,
    NULL NUME_REC, NULL COD_CULTURA_RECEITA, NULL CULTURA_RECEITA
    FROM INFENTRA I
    INNER JOIN NFENTRA N
    ON (N.CTRL_NFE = I.CTRL_NFE)
    LEFT JOIN CICLO CIC
    ON CIC.CODI_CIC = N.CODI_CIC
    INNER JOIN TRANSAC T
    ON (T.CODI_TRA = N.CODI_TRA)
    LEFT JOIN PROPRIED PROP
    ON PROP.PROP_PRO = N.PROP_PRO
    LEFT JOIN MUNICIPIO MUN
    ON MUN.CODI_MUN = PROP.CODI_MUN
    LEFT JOIN MUNICIPIO MUNT
    ON MUNT.CODI_MUN = T.CODI_MUN
    LEFT JOIN PESSOAL P
    ON (P.CODI_PES = N.COD1_PES)
    INNER JOIN FUNCAOTOPER F
    ON (F.CODI_TOP = N.CODI_TOP)
    INNER JOIN TIPOOPER TOP
    ON (TOP.CODI_TOP = N.CODI_TOP)
    INNER JOIN CFO CFO
    ON (CFO.CCFO_CFO = I.CCFO_CFO)
    INNER JOIN PRODSERV PSV
    ON (PSV.CODI_PSV = I.CODI_PSV)
    LEFT JOIN PRODUTO PRO
    ON (PRO.CODI_PSV = PSV.CODI_PSV)
    LEFT JOIN condicao con
    ON con.COND_CON = n.COND_CON
    LEFT JOIN indexador nd
    ON nd.codi_ind = n.codi_ind
    LEFT JOIN transac fab
    ON (fab.codi_tra = PRO.codi_tra)
    LEFT JOIN INDVALOR IND
    ON IND.CODI_IND  = N.CODI_IND
    AND IND.CODI_EMP = N.CODI_EMP
    AND IND.DATA_VLR = N.DATA_VLR
    LEFT JOIN
      (SELECT codi_top,
        tipo_est
      FROM
        (SELECT t.codi_top,
          LISTAGG( t.tipo_est,';') WITHIN GROUP (
        ORDER BY t.tipo_est) tipo_est
        FROM
          ( SELECT DISTINCT t.codi_top,
            CASE
              WHEN tipo_est = '1'
              THEN UPPER ('1-Estoque DisponIvel')
              WHEN tipo_est = '2'
              THEN UPPER ('2-Estoque Pertencente a Empresa')
              WHEN tipo_est = '3'
              THEN UPPER ('3-Estoque da Empresa com Terceiros')
              WHEN tipo_est = '4'
              THEN UPPER ('4-Estoque de Terceiros com a Empresa')
              WHEN tipo_est = '5'
              THEN UPPER ('5-Estoque Disponível Fiscal')
              WHEN tipo_est = '6'
              THEN UPPER ('6-Estoque Físico DisponIvel para Faturamento')
            END tipo_est
          FROM estoque e
          INNER JOIN topctrl t
          ON t.codi_ctr   = e.codi_ctr
          WHERE TIPO_EST <> 0
          ORDER BY 1
          ) T
        GROUP BY t.codi_top
        )
      ) EST ON EST.CODI_TOP = TOP.CODI_TOP
    INNER JOIN GRUPO G
    ON (G.CODI_GPR = PSV.CODI_GPR)
    LEFT JOIN SUBGRUPO S
    ON (S.CODI_SBG = PSV.CODI_SBG
    AND S.CODI_GPR = PSV.CODI_GPR)
    LEFT JOIN
      (SELECT T.codi_emp,
        T.codi_tra,
        T.ndoc_nOC,
        T.sdoc_nOC,
        T.Tdoc_nOC,
        (SELECT LISTAGG( VENC_REC,';') WITHIN GROUP (
        ORDER BY VENC_REC) VENC_REC
        FROM
          ( SELECT DISTINCT VENC_REC, CTRL_CBR FROM receber rec
          )
        WHERE CTRL_CBR = C.CTRL_CBR
        ) VENC_REC,
        (SELECT VENC_REC
        FROM
          (SELECT VENC_REC
          FROM receber r
          WHERE r.ctrl_cbr = c.ctrl_cbr
          ORDER BY r.VENC_REC
          )
        WHERE rownum <=1
        ) VENCIMENTO_INICIAL ,
        (SELECT VENC_REC
        FROM
          (SELECT VENC_REC
          FROM receber r
          WHERE r.ctrl_cbr = c.ctrl_cbr
          ORDER BY r.VENC_REC DESC
          )
        WHERE rownum <=1
        ) VENCIMENTO_FINAL
      FROM CABREC C
      INNER JOIN NOTACRC T
      ON T.ctrl_cBR     = C.ctrl_cBR
      WHERE C.SITU_CBR <> 'C'
      ) T ON T.CODI_EMP = N.CODI_EMP
    AND T.CODI_TRA      = N.CODI_tRA
    AND T.NDOC_NOC      = N.NUME_NFE
    AND T.sdoc_NOC      = N.SERI_NFE
    AND T.Tdoc_nOC      = 'NT'
    LEFT JOIN
      (SELECT nfr.notd_nfr,
        nfr.serd_nfr,
        nfr.codi_emp,
        nfr.ited_nfr,
        nfr.tipd_nfr,
        nfr.tipo_nfr,
        nfr.trad_nfr,
        nfr.ctrd_nfr,
        ctab_ino,
        CMVD_INO
      FROM
        (SELECT nfr.notd_nfr,
          nfr.serd_nfr,
          nfr.codi_emp,
          nfr.ited_nfr,
          nfr.tipd_nfr,
          nfr.tipo_nfr,
          nfr.trad_nfr,
          nfr.ctrd_nfr,
          INO.ctab_ino,
          ino.CMVD_INO
        FROM inota ino
        INNER JOIN nota nta
        ON nta.npre_not = ino.npre_not
        INNER JOIN notaorig nfr
        ON nfr.noto_nfr     = ino.npre_not
        AND nfr.codi_emp    = nta.codi_emp
        AND nfr.sero_nfr    = nta.seri_not
        AND nfr.iteo_nfr    = ino.item_ino
        WHERE nfr.tipd_nfr IN('NE','NT')
        AND nfr.tipo_nfr    = 'NE'
        UNION ALL
        SELECT nfr.notd_nfr,
          nfr.serd_nfr,
          nfr.codi_emp,
          nfr.ited_nfr,
          nfr.tipd_nfr,
          nfr.tipo_nfr,
          nfr.trad_nfr,
          nfr.ctrd_nfr,
          INF.ctab_inf,
          INF.CMED_INF
        FROM INFENTRA INF
        INNER JOIN NOTAORIG NFR
        ON nfr.noto_nfr     = INF.nume_nfe
        AND nfr.codi_emp    = INF.codi_emp
        AND nfr.sero_nfr    = INF.seri_nfe
        AND nfr.iteo_nfr    = INF.item_inf
        AND NFR.trao_nfr    = INF.codi_tra
        WHERE nfr.tipd_nfr IN('NE','NT')
        AND nfr.tipo_nfr    = 'NT'
        ) nfr
      ) nfr ON nfr.notd_nfr = I.NUME_NFE
    AND nfr.serd_nfr        = I.seri_NFE
    AND nfr.codi_emp        = I.codi_emp
    AND nfr.ited_nfr        = i.ITEM_INF
    AND nfr.trad_nfr        = i.CODI_TRA
    AND NFR.CTRD_NFR        = I.CTRL_NFE
    AND nfr.tipd_nfr        = 'NT'
    LEFT JOIN 
    (select 
     nfr.notd_nfr,
          nfr.serd_nfr,
          nfr.codi_emp,
          nfr.ited_nfr,
          nfr.tipd_nfr,
          nfr.tipo_nfr,
          nfr.trad_nfr,
          nfr.ctrd_nfr,
     ino.empr_ped, 
     ino.pedi_ped, ino.seri_ped, ped.vcto_ped,
     ipe.codi_cul, ipe.codi_psv,
     C.NOME_CUL
    from nota nta 
    inner join inota ino on ino.npre_not = nta.npre_not 
    inner join pedido ped on ped.pedi_ped = ino.pedi_ped and
                             ped.codi_emp = ino.empr_ped and
                             ped.seri_ped = ino.seri_ped
    inner join ipedido ipe on ped.pedi_ped = ipe.pedi_ped and
                              ped.codi_emp = ipe.codi_emp and
                              ped.seri_ped = ipe.seri_ped and
                              ino.codi_psv = ipe.codi_psv
    LEFT JOIN CULTURA C ON C.CODI_CUL = IPE.CODI_CUL                          
    inner join notaorig nfr on nfr.codi_emp = nta.codi_emp and
                               nfr.noto_nfr = nta.npre_not and
                               nfr.sero_nfr = nta.seri_not and 
                               nfr.iteo_nfr = ino.item_ino and
                               nfr.tipO_nfr = 'NE' AND
                               NFR.TIPD_NFR = 'NT'
    ) PED ON PED.notd_nfr = I.NUME_NFE
    AND PED.serd_nfr        = I.seri_NFE
    AND PED.codi_emp        = I.codi_emp
    AND PED.ited_nfr        = i.ITEM_INF
    AND PED.trad_nfr        = i.CODI_TRA
    AND PED.CTRD_NFR        = I.CTRL_NFE
    AND PED.CODI_PSV        = I.CODI_PSV
    AND PED.tipd_nfr        = 'NT'
    WHERE cfo.COMP_CFO     IN ('1','2','7','11','D','E')
    UNION ALL
    SELECT 'DZNT' TIPO_NF,
      IDD.CODI_EMP LOJA,
      CDS.DATA_CDS EMISSAO_RECBTO,
      CDS.CODI_CDS NF,
      'DZ' SERIE,
      TOP.CODI_TOP COD_OPERACAO,
      TOP.DESC_TOP DESC_OPERACAO,
      TRA.CODI_TRA COD_PARCEIRO,
      TRA.RAZA_TRA RAZAO,
      P.CODI_PES COD_VENDEDOR,
      P.NOME_PES NOME_VENDEDOR,
      CPF_PES CPF_VENDEDOR,
      PSV.CODI_PSV COD_PROD,
      PSV.DESC_PSV DESC_PRODUTO,
      PSV.CODI_GPR COD_GRUPO,
      G.DESC_GPR DESC_GRUPO,
      PSV.CODI_SBG COD_SUBGRUPO,
      S.DESC_SBG DESC_SUBGRUPO,
      CASE
        WHEN f.func_top = 'A'
        THEN IDD.QTDE_IDD
        ELSE IDD.QTDE_IDD * -1
      END QTDE,
      INFE.VLIQ_inf VLR_UNIT,
      CASE
        WHEN f.func_top = 'A'
        THEN COALESCE((IDD.TOTA_IDD),0)
        ELSE COALESCE((IDD.TOTA_IDD),0) * -1
      END TOTAL_PRODUTO,
      CASE
        WHEN f.func_top = 'A'
        THEN CDS.TOTA_CDS
        ELSE CDS.TOTA_CDS * -1
      END TOTAL_NF,
      COALESCE(INFE.CTAB_INF,0) CUSTO_TAB_UNIT,
      COALESCE(INFE.CMED_INF,0) CUSTO_MED_UNIT,
      F.CODI_PTO,
      T.VENC_REC,
      INFE.ITEM_INF,
      NFE.CODI_CIC,
      CIC.DESC_CIC,
      T.VENCIMENTO_INICIAL,
      T.VENCIMENTO_FINAL,
      FAB.CODI_TRA COD_FABRICANTE,
      FAB.RAZA_TRA FABRICANTE,
      COALESCE(IND.VLOR_VLR,1) VLOR_VLR,
      CON.COND_CON
      || '-'
      || CON.DESC_CON CONDICAO,
      CASE
        WHEN ND.CODI_IND IS NOT NULL
        THEN ND.CODI_IND
          || '-'
          || ND.DESC_IND
        ELSE NULL
      END INDEXADOR,
      INFE.CMED_INF,
      '' CUST_CFO,
      '' DEPC_CFO,
      ''CCFO_CFO,
      '' DESC_CFO,
      EST.TIPO_EST,
      PROP.PROP_PRO,
      PROP.DESC_PRO,
      MUN.CODI_MUN,
      MUN.DESC_MUN,
      MUN.ESTA_MUN,
      TRA.CGC_TRA,
      MUNT.CODI_MUN CODI_MUN_TRA,
      MUNT.DESC_MUN DESC_MUN_TRA,
      MUNT.ESTA_MUN ESTA_MUN_TRA,
      NULL TABE_CTA, NULL DESC_CTA ,
      IDD.QTDE_IDD/
       (SELECT SUM (COALESCE((IDD1.QTDE_IDD),0) ) FROM IDOCDESFAZ IDD1
       WHERE IDD1.CODI_CDS = IDD.CODI_CDS AND
             IDD1.CODI_EMP = IDD.CODI_EMP AND             
             IDD1.CODI_PSV = IDD.CODI_PSV) PERC,
    COALESCE(INFE.CCPD_INF,0) CCPD_INF ,
     NULL empr_ped, 
   NULL pedi_ped, NULL seri_ped, NULL vcto_ped,
   NULL BASE_ICMS,
NULL ALIQ_ICMS,
NULL ICMS,
NULL IPI,
NULL ALIQ_IPI,
NULL BASE_PIS,
NULL ALIQ_PIS,
IDD.VPIS_IDD PIS,
NULL BASE_COFINS,
NULL ALIQ_COFINS,
IDD.VCOF_IDD COFINS,
NULL BASE_ISS,
    NULL ALIQ_ISS,
    NULL ISS,
    null RETO_CFO,
    NULL OBSE_NFE,
    NULL CHAVE_ACESSO,
    NULL CODI_CUL, NULL NOME_CUL,
    NULL NUME_REC, NULL COD_CULTURA_RECEITA, NULL CULTURA_RECEITA
    FROM IDOCDESFAZ IDD
    JOIN DOCDESFAZ DDZ
    ON (DDZ.CODI_EMP  = IDD.CODI_EMP)
    AND (DDZ.CODI_CDS = IDD.CODI_CDS)
    AND (DDZ.CTRL_DDZ = IDD.CTRL_DDZ)
    JOIN CABDESFAZ CDS
    ON (CDS.CODI_EMP  = DDZ.CODI_EMP)
    AND (CDS.CODI_CDS = DDZ.CODI_CDS)
    JOIN TIPOOPER TOP
    ON (CDS.CODI_TOP = TOP.CODI_TOP)
    INNER JOIN FUNCAOTOPER F
    ON (F.CODI_TOP = TOP.CODI_TOP)
    INNER JOIN PRODSERV PSV
    ON (PSV.CODI_PSV = IDD.CODI_PSV)
    LEFT JOIN PRODUTO PRO
    ON (PRO.CODI_PSV = PSV.CODI_PSV)
    LEFT JOIN transac fab
    ON (fab.codi_tra = PRO.codi_tra)
    INNER JOIN GRUPO G
    ON (G.CODI_GPR = PSV.CODI_GPR)
    LEFT JOIN SUBGRUPO S
    ON (S.CODI_SBG = PSV.CODI_SBG
    AND S.CODI_GPR = PSV.CODI_GPR)
    JOIN TRANSAC TRA
    ON (TRA.CODI_TRA = CDS.CODI_TRA)
    JOIN NFENTRA NFE
    ON (NFE.CODI_EMP  = DDZ.CODI_EMP)
    AND (NFE.CODI_TRA = DDZ.CODI_TRA)
    AND (NFE.NUME_NFE = DDZ.NDOC_DDZ)
    AND (NFE.SERI_NFE = DDZ.SERI_DDZ)
    JOIN INFENTRA INFE
    ON (INFE.CODI_EMP  = NFE.CODI_EMP)
    AND (INFE.CODI_TRA = NFE.CODI_TRA)
    AND (INFE.NUME_NFE = NFE.NUME_NFE)
    AND (INFE.SERI_NFE = NFE.SERI_NFE)
    AND (INFE.CODI_PSV = IDD.CODI_PSV)
    AND (INFE.ITEM_INF = IDD.ITEM_IDD)
    LEFT JOIN PROPRIED PROP
    ON PROP.PROP_PRO = NFE.PROP_PRO
    LEFT JOIN MUNICIPIO MUN
    ON MUN.CODI_MUN = PROP.CODI_MUN
    LEFT JOIN MUNICIPIO MUNT
    ON MUNT.CODI_MUN = TRA.CODI_MUN
    LEFT JOIN INDVALOR IND
    ON IND.CODI_IND  = NFE.CODI_IND
    AND IND.CODI_EMP = NFE.CODI_EMP
    AND IND.DATA_VLR = NFE.DATA_VLR
    LEFT JOIN
      (SELECT codi_top,
        tipo_est
      FROM
        (SELECT t.codi_top,
          LISTAGG( t.tipo_est,';') WITHIN GROUP (
        ORDER BY t.tipo_est) tipo_est
        FROM
          ( SELECT DISTINCT t.codi_top,
            CASE
              WHEN tipo_est = '1'
              THEN UPPER ('1-Estoque DisponIvel')
              WHEN tipo_est = '2'
              THEN UPPER ('2-Estoque Pertencente a Empresa')
              WHEN tipo_est = '3'
              THEN UPPER ('3-Estoque da Empresa com Terceiros')
              WHEN tipo_est = '4'
              THEN UPPER ('4-Estoque de Terceiros com a Empresa')
              WHEN tipo_est = '5'
              THEN UPPER ('5-Estoque Disponível Fiscal')
              WHEN tipo_est = '6'
              THEN UPPER ('6-Estoque Físico DisponIvel para Faturamento')
            END tipo_est
          FROM estoque e
          INNER JOIN topctrl t
          ON t.codi_ctr   = e.codi_ctr
          WHERE TIPO_EST <> 0
          ORDER BY 1
          ) T
        GROUP BY t.codi_top
        )
      ) EST ON EST.CODI_TOP = TOP.CODI_TOP
    LEFT JOIN condicao con
    ON con.COND_CON = nfe.COND_CON
    LEFT JOIN indexador nd
    ON nd.codi_ind = nfe.codi_ind
    LEFT JOIN PESSOAL P
    ON (P.CODI_PES = NFE.COD1_PES)
    LEFT JOIN CICLO CIC
    ON CIC.CODI_CIC = NFE.CODI_CIC
    LEFT JOIN
      (SELECT T.codi_emp,
        T.codi_tra,
        T.ndoc_nOC,
        T.sdoc_nOC,
        T.Tdoc_nOC,
        (SELECT LISTAGG( VENC_REC,';') WITHIN GROUP (
        ORDER BY VENC_REC) VENC_REC
        FROM
          ( SELECT DISTINCT VENC_REC, CTRL_CBR FROM receber rec
          )
        WHERE CTRL_CBR = C.CTRL_CBR
        ) VENC_REC,
        (SELECT VENC_REC
        FROM
          (SELECT VENC_REC
          FROM receber r
          WHERE r.ctrl_cbr = c.ctrl_cbr
          ORDER BY r.VENC_REC
          )
        WHERE rownum <=1
        ) VENCIMENTO_INICIAL ,
        (SELECT VENC_REC
        FROM
          (SELECT VENC_REC
          FROM receber r
          WHERE r.ctrl_cbr = c.ctrl_cbr
          ORDER BY r.VENC_REC DESC
          )
        WHERE rownum <=1
        ) VENCIMENTO_FINAL
      FROM CABREC C
      INNER JOIN NOTACRC T
      ON T.ctrl_cBR     = C.ctrl_cBR
      WHERE C.SITU_CBR <> 'C'
      ) T ON T.CODI_EMP = CDS.CODI_EMP
    AND T.CODI_TRA      = CDS.CODI_tRA
    AND T.NDOC_NOC      = CDS.CODI_CDS
    AND T.Tdoc_nOC      = 'DZ'
    WHERE (DDZ.TIPO_DDZ = 'NT')
    UNION
    SELECT 'DZNE' TIPO_NF,
      IDD.CODI_EMP LOJA,
      CDS.DATA_CDS EMISSAO_RECBTO,
      CDS.CODI_CDS NF,
      'DZ' SERIE,
      TOP.CODI_TOP COD_OPERACAO,
      TOP.DESC_TOP DESC_OPERACAO,
      TRA.CODI_TRA COD_PARCEIRO,
      TRA.RAZA_TRA RAZAO,
      P.CODI_PES COD_VENDEDOR,
      P.NOME_PES NOME_VENDEDOR,
      CPF_PES CPF_VENDEDOR,
      PSV.CODI_PSV COD_PROD,
      PSV.DESC_PSV DESC_PRODUTO,
      PSV.CODI_GPR COD_GRUPO,
      G.DESC_GPR DESC_GRUPO,
      PSV.CODI_SBG COD_SUBGRUPO,
      S.DESC_SBG DESC_SUBGRUPO,
      CASE
        WHEN f.func_top = 'A'
        THEN IDD.QTDE_IDD
        ELSE IDD.QTDE_IDD * -1
      END QTDE,
      INO.VLIQ_INO VLR_UNIT,
      CASE
        WHEN f.func_top = 'A'
        THEN COALESCE((IDD.TOTA_IDD),0)
        ELSE COALESCE((IDD.TOTA_IDD),0) * -1
      END TOTAL_PRODUTO,
      CASE
        WHEN f.func_top = 'A'
        THEN CDS.TOTA_CDS
        ELSE CDS.TOTA_CDS * -1
      END TOTAL_NF,
      COALESCE(INO.CTAB_INO,0) CUSTO_TAB_UNIT,
      COALESCE(INO.CMVD_INO,0) CUSTO_MED_UNIT,
      F.CODI_PTO,
      T.VENC_REC,
      INO.ITEM_INO,
      N.CODI_CIC,
      CIC.DESC_CIC,
      T.VENCIMENTO_INICIAL,
      T.VENCIMENTO_FINAL,
      FAB.CODI_TRA COD_FABRICANTE,
      FAB.RAZA_TRA FABRICANTE,
      COALESCE(IND.VLOR_VLR,1) VLOR_VLR,
      CON.COND_CON
      || '-'
      || CON.DESC_CON CONDICAO,
      CASE
        WHEN ND.CODI_IND IS NOT NULL
        THEN ND.CODI_IND
          || '-'
          || ND.DESC_IND
        ELSE NULL
      END INDEXADOR,
      INO.CMVD_INO,
      '' CUST_CFO,
      '' DEPC_CFO,
      '' CCFO_CFO,
      '' DESC_CFO,
      EST.TIPO_EST,
      PROP.PROP_PRO,
      PROP.DESC_PRO,
      MUN.CODI_MUN,
      MUN.DESC_MUN,
      MUN.ESTA_MUN,
      TRA.CGC_TRA,
      MUNT.CODI_MUN CODI_MUN_TRA,
      MUNT.DESC_MUN DESC_MUN_TRA,
      MUNT.ESTA_MUN ESTA_MUN_TRA,
      NULL TABE_CTA, NULL DESC_CTA ,
      IDD.QTDE_IDD/
       (SELECT SUM (COALESCE((IDD1.QTDE_IDD),0) ) FROM IDOCDESFAZ IDD1
       WHERE IDD1.CODI_CDS = IDD.CODI_CDS AND
             IDD1.CODI_EMP = IDD.CODI_EMP AND             
             IDD1.CODI_PSV = IDD.CODI_PSV) PERC,
    COALESCE(INO.CCPD_INO,0) CCPD_INO     ,
     INO.empr_ped, 
   INO.pedi_ped, INO.seri_ped, PED.vcto_ped,
   NULL BASE_ICMS,
NULL ALIQ_ICMS,
NULL ICMS,
NULL IPI,
NULL ALIQ_IPI,
NULL BASE_PIS,
NULL ALIQ_PIS,
IDD.VPIS_IDD PIS,
NULL BASE_COFINS,
NULL ALIQ_COFINS,
IDD.VCOF_IDD COFINS,
NULL BASE_ISS,
    NULL ALIQ_ISS,
    NULL ISS,
    null RETO_CFO,
    NULL OBSE_NFE,
     NULL CHAVE_ACESSO,
     NULL CODI_CUL, NULL NOME_CUL,
     NULL NUME_REC, NULL COD_CULTURA_RECEITA, NULL CULTURA_RECEITA
    FROM IDOCDESFAZ IDD
    JOIN DOCDESFAZ DDZ
    ON (DDZ.CODI_EMP  = IDD.CODI_EMP)
    AND (DDZ.CODI_CDS = IDD.CODI_CDS)
    AND (DDZ.CTRL_DDZ = IDD.CTRL_DDZ)
    JOIN CABDESFAZ CDS
    ON (CDS.CODI_EMP  = DDZ.CODI_EMP)
    AND (CDS.CODI_CDS = DDZ.CODI_CDS)
    JOIN TIPOOPER TOP
    ON (CDS.CODI_TOP = TOP.CODI_TOP)
    INNER JOIN FUNCAOTOPER F
    ON (F.CODI_TOP = TOP.CODI_TOP)
    INNER JOIN PRODSERV PSV
    ON (PSV.CODI_PSV = IDD.CODI_PSV)
    LEFT JOIN PRODUTO PRO
    ON (PRO.CODI_PSV = PSV.CODI_PSV)
    LEFT JOIN transac fab
    ON (fab.codi_tra = PRO.codi_tra)
    INNER JOIN GRUPO G
    ON (G.CODI_GPR = PSV.CODI_GPR)
    LEFT JOIN SUBGRUPO S
    ON (S.CODI_SBG = PSV.CODI_SBG
    AND S.CODI_GPR = PSV.CODI_GPR)
    JOIN TRANSAC TRA
    ON (TRA.CODI_TRA = CDS.CODI_TRA)
    JOIN NOTA N
    ON (N.CODI_EMP  = DDZ.CODI_EMP)
    AND (N.NOTA_NOT = DDZ.NDOC_DDZ)
    AND (N.SERI_NOT = DDZ.SERI_DDZ)
    AND (N.CODI_TRA = DDZ.CODI_TRA)
    JOIN INOTA INO
    ON (INO.NPRE_NOT  = N.NPRE_NOT)
    AND (INO.ITEM_INO = IDD.ITEM_IDD)
    LEFT join pedido ped on ped.pedi_ped = ino.pedi_ped and
                             ped.codi_emp = ino.empr_ped and
                             ped.seri_ped = ino.seri_ped
    LEFT JOIN PROPRIED PROP
    ON PROP.PROP_PRO = N.PROP_PRO
    LEFT JOIN MUNICIPIO MUN
    ON MUN.CODI_MUN = PROP.CODI_MUN
    LEFT JOIN MUNICIPIO MUNT
    ON MUNT.CODI_MUN = TRA.CODI_MUN
    LEFT JOIN INDVALOR IND
    ON IND.CODI_IND  = N.CODI_IND
    AND IND.CODI_EMP = N.CODI_EMP
    AND IND.DATA_VLR = N.DATA_VLR
    LEFT JOIN
      (SELECT codi_top,
        tipo_est
      FROM
        (SELECT t.codi_top,
          LISTAGG( t.tipo_est,';') WITHIN GROUP (
        ORDER BY t.tipo_est) tipo_est
        FROM
          ( SELECT DISTINCT t.codi_top,
            CASE
              WHEN tipo_est = '1'
              THEN UPPER ('1-Estoque DisponIvel')
              WHEN tipo_est = '2'
              THEN UPPER ('2-Estoque Pertencente a Empresa')
              WHEN tipo_est = '3'
              THEN UPPER ('3-Estoque da Empresa com Terceiros')
              WHEN tipo_est = '4'
              THEN UPPER ('4-Estoque de Terceiros com a Empresa')
              WHEN tipo_est = '5'
              THEN UPPER ('5-Estoque Disponível Fiscal')
              WHEN tipo_est = '6'
              THEN UPPER ('6-Estoque Físico DisponIvel para Faturamento')
            END tipo_est
          FROM estoque e
          INNER JOIN topctrl t
          ON t.codi_ctr   = e.codi_ctr
          WHERE TIPO_EST <> 0
          ORDER BY 1
          ) T
        GROUP BY t.codi_top
        )
      ) EST ON EST.CODI_TOP = TOP.CODI_TOP
    LEFT JOIN condicao con
    ON con.COND_CON = n.COND_CON
    LEFT JOIN indexador nd
    ON nd.codi_ind = n.codi_ind
    LEFT JOIN PESSOAL P
    ON (P.CODI_PES = N.COD1_PES)
    LEFT JOIN CICLO CIC
    ON CIC.CODI_CIC = N.CODI_CIC
    LEFT JOIN
      (SELECT T.codi_emp,
        T.codi_tra,
        T.ndoc_nOC,
        T.sdoc_nOC,
        T.Tdoc_nOC,
        (SELECT LISTAGG( VENC_REC,';') WITHIN GROUP (
        ORDER BY VENC_REC) VENC_REC
        FROM
          ( SELECT DISTINCT VENC_REC, CTRL_CBR FROM receber rec
          )
        WHERE CTRL_CBR = C.CTRL_CBR
        ) VENC_REC,
        (SELECT VENC_REC
        FROM
          (SELECT VENC_REC
          FROM receber r
          WHERE r.ctrl_cbr = c.ctrl_cbr
          ORDER BY r.VENC_REC
          )
        WHERE rownum <=1
        ) VENCIMENTO_INICIAL ,
        (SELECT VENC_REC
        FROM
          (SELECT VENC_REC
          FROM receber r
          WHERE r.ctrl_cbr = c.ctrl_cbr
          ORDER BY r.VENC_REC DESC
          )
        WHERE rownum <=1
        ) VENCIMENTO_FINAL
      FROM CABREC C
      INNER JOIN NOTACRC T
      ON T.ctrl_cBR     = C.ctrl_cBR
      WHERE C.SITU_CBR <> 'C'
      ) T ON T.CODI_EMP = CDS.CODI_EMP
    AND T.CODI_TRA      = CDS.CODI_tRA
    AND T.NDOC_NOC      = CDS.CODI_CDS
    AND T.Tdoc_nOC      = 'DZ'
    WHERE (DDZ.TIPO_DDZ = 'NE')
    );