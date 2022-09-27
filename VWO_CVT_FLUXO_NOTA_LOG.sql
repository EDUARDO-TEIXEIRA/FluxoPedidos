SELECT QRY."DESCRICAO",
       QRY."VALOR",
       QRY."CMV",
       QRY."QTDREG",
       NVL(CMV_VALOR,0) AS CMV_VALOR,
       'ATUAL' AS PERIODO
  FROM (
/*****************************************************************************
| Aguardando Formação de Carga 
*****************************************************************************/

SELECT '15. Aguardando Formação de Carga' DESCRICAO,
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
        NVL(ROUND((SUM(CMV) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        SUM(CMV) AS CMV_VALOR
   FROM (
 SELECT (ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) AS VALOR,
         FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)* (ITE.QTDNEG - ITE.QTDENTREGUE) AS CMV,
        CAB.NUNOTA
  FROM TGFCAB CAB 
 INNER JOIN TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER=CAB.CODTIPOPER 
   AND TOP.DHALTER=CAB.DHTIPOPER 
 WHERE CAB.STATUSNOTA = 'L'
   AND TOP.GRUPO IN ('PED.VENDA','TROCA')
   AND TOP.TIPMOV = 'P'
   AND CAB.PENDENTE = 'S'
   AND TO_CHAR(CAB.DTNEG,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM'))) 
   AND NOT EXISTS(SELECT 1
                FROM VGWSEPSITUACAO VSEP 
               WHERE VSEP.NUNOTA = CAB.NUNOTA)
    ) 
 UNION ALL
/*****************************************************************************
| Processo de Separação de Carga  
*****************************************************************************/

SELECT '16. Processo de Separação' DESCRICAO,
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
        NVL(ROUND((SUM(CMV) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        SUM(CMV) AS CMV_VALOR
   FROM (
 SELECT (ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) AS VALOR,
         FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)* (ITE.QTDNEG - ITE.QTDENTREGUE) AS CMV,
        CAB.NUNOTA 
  FROM TGFCAB CAB 
 INNER JOIN TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER=CAB.CODTIPOPER 
   AND TOP.DHALTER=CAB.DHTIPOPER 
 WHERE CAB.TIPMOV = 'P' 
   AND CAB.PENDENTE = 'S'
   AND TOP.GRUPO IN ('PED.VENDA','TROCA')
   AND TO_CHAR(CAB.DTNEG,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM'))) 

   AND EXISTS(SELECT 1
                FROM VGWSEPSITUACAO VSEP 
               WHERE VSEP.NUNOTA = CAB.NUNOTA 
                 AND VSEP.COD_SITUACAO NOT IN (9,16))
        )

/*****************************************************************************
|  Liberados para Faturamento  
*****************************************************************************/
 UNION ALL 
SELECT '17. Liberado para Faturamento' DESCRICAO,
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
        NVL(ROUND((SUM(CMV) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        SUM(CMV) AS CMV_VALOR
   FROM (
 SELECT (ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) AS VALOR,

         FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)* (ITE.QTDNEG - ITE.QTDENTREGUE) AS CMV,
        CAB.NUNOTA 
  FROM TGFCAB CAB 
 INNER JOIN TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER=CAB.CODTIPOPER 
   AND TOP.DHALTER=CAB.DHTIPOPER 
 WHERE CAB.STATUSNOTA <> 'L' 
   AND NOT EXISTS (SELECT 1 FROM TSILIB LIB WHERE LIB.NUCHAVE = CAB.NUNOTA)
   AND TOP.GRUPO IN ('PED.VENDA','TROCA')
   AND TO_CHAR(CAB.DTNEG,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM'))) 
    ) 

/*****************************************************************************
| Notas Denegadas  
*****************************************************************************/
UNION ALL
 SELECT '18. (-) Notas Denegadas' DESCRICAO,
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
        NVL(ROUND((SUM(CMV) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        SUM(CMV) AS CMV_VALOR
   FROM (
 SELECT (ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) AS VALOR,

         FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)* (ITE.QTDNEG - ITE.QTDENTREGUE) AS CMV,
        CAB.NUNOTA 
  FROM TGFCAB CAB
 INNER JOIN  TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER 
 WHERE TO_CHAR(DTFATUR,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM'))) 
   AND CAB.STATUSNFE  = 'D'
   AND CAB.TIPMOV     = 'V'
   AND CAB.STATUSNOTA = 'L')

/*****************************************************************************
| Faturamento
| Notas de Devolução  
*****************************************************************************/
UNION ALL

 SELECT '19. Faturamento', 
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
        NVL(ROUND((SUM(CMV) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        SUM(CMV) AS CMV_VALOR
   FROM (
 SELECT  NVL(((ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) * 
              CASE WHEN TOP.BONIFICACAO = 'S' 
                    AND TOP.GRUPO = 'DEV.VENDAS'
                   THEN 0 
                   ELSE 1 
                    END),0) AS VALOR, 
         FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)* (ITE.QTDNEG - ITE.QTDENTREGUE) AS CMV,
         ITE.NUNOTA
  FROM TGFCAB CAB
 INNER JOIN  TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER 
 WHERE TOP.GOLSINAL = -1 AND
       TO_CHAR(DTFATUR,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM'))) 
   AND CAB.STATUSNOTA = 'L'
   AND TOP.GRUPO IN('VENDAS'))

UNION ALL

SELECT '20. Devolução' AS DESCRICAO, 
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
        NVL(ROUND((SUM(CMV) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        SUM(CMV) AS CMV_VALOR
   FROM (
 SELECT NVL(((ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) * 
              CASE WHEN TOP.BONIFICACAO = 'S' 
                    AND TOP.GRUPO = 'DEV.VENDAS'
                   THEN 0 
                   ELSE 1 
                    END),0) AS VALOR, 
         FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)* (ITE.QTDNEG - ITE.QTDENTREGUE) AS CMV,
         ITE.NUNOTA
  FROM TGFCAB CAB
 INNER JOIN  TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER 
 WHERE TOP.GOLSINAL = -1 AND
       TO_CHAR(DTFATUR,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM'))) 
   AND CAB.STATUSNOTA = 'L'
   AND TOP.GRUPO IN('DEV.VENDAS'))

/*****************************************************************************
| Faturamento - Devolução
*****************************************************************************/    
 UNION ALL
 SELECT '21. Faturamento - Devolução ' AS DESCRICAO,
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
         NVL(ROUND(((SUM(CMVVENDA) - SUM(CMVDEV)) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        (NVL(SUM(CMVVENDA),0) - NVL(SUM(CMVDEV),0)) AS CMV_VALOR
   FROM (
 SELECT 
            CASE WHEN TOP.GRUPO = 'VENDAS' THEN 
                      ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED 
                 ELSE (ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) * 
                      CASE WHEN TOP.BONIFICACAO = 'S' 
                            AND TOP.GRUPO = 'DEV.VENDAS'
                           THEN 0 
                           ELSE 1 
                            END * -1
                  END AS VALOR, 
         CASE WHEN  TOP.GRUPO = 'VENDAS' THEN 
         (FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * (ITE.QTDNEG)) 
           END  AS CMVVENDA,
         CASE WHEN  TOP.GRUPO = 'DEV.VENDAS' THEN 
         (FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * (ITE.QTDNEG)) 
           END  AS CMVDEV,
         DECODE(TOP.GRUPO, 'VENDAS', ITE.NUNOTA) AS NUNOTA
  FROM TGFCAB CAB
 INNER JOIN  TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER 
 WHERE TOP.GOLSINAL = -1 AND
       TO_CHAR(DTFATUR,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))  
   AND CAB.STATUSNOTA = 'L'
   AND TOP.GRUPO IN('VENDAS', 'DEV.VENDAS'))

   ) QRY

 /************************************************************************************************************/
  UNION ALL  
 SELECT AWS."DESCRICAO",
        AWS."VALOR",
        AWS."CMV",
        AWS."QTDREG",
       NVL(CMV_VALOR,0) AS CMV_VALOR,
       'ANTERIOR' AS PERIODO
  FROM (
/*****************************************************************************
| Aguardando Formação de Carga 
*****************************************************************************/

SELECT '22. (+)Aguardando Formação de Carga' DESCRICAO,
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
        NVL(ROUND((SUM(CMV) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        SUM(CMV) AS CMV_VALOR
   FROM (
 SELECT (ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) AS VALOR,
         FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)* (ITE.QTDNEG - ITE.QTDENTREGUE) AS CMV,
        CAB.NUNOTA
  FROM TGFCAB CAB 
 INNER JOIN TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER=CAB.CODTIPOPER 
   AND TOP.DHALTER=CAB.DHTIPOPER 
 WHERE CAB.STATUSNOTA = 'L'
   AND TOP.GRUPO IN ('PED.VENDA','TROCA')
   AND TOP.TIPMOV = 'P'
   AND ITE.PENDENTE = 'S'
   AND TO_CHAR(CAB.DTNEG,'YYYYMM') < NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
   AND NOT EXISTS(SELECT 1
                FROM VGWSEPSITUACAO VSEP 
               WHERE VSEP.NUNOTA = CAB.NUNOTA)
    ) 
 UNION ALL
/*****************************************************************************
| Processo de Separação de Carga  
*****************************************************************************/

SELECT '23. (+)Processo de Separação' DESCRICAO,
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
        NVL(ROUND((SUM(CMV) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        SUM(CMV) AS CMV_VALOR
   FROM (
 SELECT 
         (ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) AS VALOR,
         FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)* (ITE.QTDNEG - ITE.QTDENTREGUE) AS CMV,
        CAB.NUNOTA 
  FROM TGFCAB CAB 
 INNER JOIN TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER=CAB.CODTIPOPER 
   AND TOP.DHALTER=CAB.DHTIPOPER 
 WHERE CAB.TIPMOV = 'P' 
   AND ITE.PENDENTE = 'S'
   AND TOP.GRUPO IN ('PED.VENDA','TROCA')
   AND TO_CHAR(CAB.DTNEG,'YYYYMM') < NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))

   AND EXISTS(SELECT 1
                FROM VGWSEPSITUACAO VSEP 
               WHERE VSEP.NUNOTA = CAB.NUNOTA 
                 AND VSEP.COD_SITUACAO NOT IN (9,16))
        )
        
/*****************************************************************************
|  Liberados para Faturamento  
*****************************************************************************/
 UNION ALL 
SELECT '24. (+)Liberado para Faturamento' DESCRICAO, 
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
        NVL(ROUND((SUM(CMV) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        SUM(CMV) AS CMV_VALOR
   FROM (
 SELECT (ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) AS VALOR,
         FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)* (ITE.QTDNEG - ITE.QTDENTREGUE) AS CMV,
        CAB.NUNOTA 
  FROM TGFCAB CAB 
 INNER JOIN TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER=CAB.CODTIPOPER 
   AND TOP.DHALTER=CAB.DHTIPOPER 
 WHERE CAB.STATUSNOTA <> 'L' 
   AND NOT EXISTS (SELECT 1 FROM TSILIB LIB WHERE LIB.NUCHAVE = CAB.NUNOTA)
   AND TOP.GRUPO IN ('PED.VENDA','TROCA')
   AND TO_CHAR(CAB.DTNEG,'YYYYMM') < NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
    ) 


/*****************************************************************************
| Faturamento
| Notas de Devolução  
*****************************************************************************/
UNION ALL

 SELECT '25. (+)Faturamento', 
        NVL(ROUND(SUM(VALOR),2),0) AS VALOR,
         NVL(ROUND(((SUM(CMVVENDA) - SUM(CMVDEV)) /  SUM(VALOR)) * 100,2),0) AS CMV,
        NVL(COUNT(DISTINCT NUNOTA),0) AS QTDREG,
        (NVL(SUM(CMVVENDA),0) - NVL(SUM(CMVDEV),0)) AS CMV_VALOR
   FROM (
 SELECT  NVL(((ITE.VLRTOT - ITE.VLRDESC-ITE.VLRREPRED) * 
              CASE WHEN TOP.BONIFICACAO = 'S' 
                    AND TOP.GRUPO = 'DEV.VENDAS'
                   THEN 0 
                   ELSE 1 
                    END),0) AS VALOR, 
         CASE WHEN  TOP.GRUPO = 'VENDAS' THEN 
         (FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * (ITE.QTDNEG)) 
           END  AS CMVVENDA,
         CASE WHEN  TOP.GRUPO = 'DEV.VENDAS' THEN 
         (FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * (ITE.QTDNEG)) 
           END  AS CMVDEV,
         ITE.NUNOTA
  FROM TGFCAB CAB
 INNER JOIN  TGFITE ITE
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER 
 WHERE TOP.GOLSINAL = -1 AND
       TO_CHAR(DTFATUR,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM'))) 
   AND CAB.STATUSNOTA = 'L'
   AND TOP.GRUPO IN('VENDAS')
      AND EXISTS (SELECT 1 
                 FROM TGFVAR VAR
                 INNER JOIN TGFCAB PED
                   ON PED.NUNOTA = VAR.NUNOTAORIG
                WHERE PED.TIPMOV = 'P'
                  AND TO_CHAR(DTFATUR,'YYYYMM') < NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                                         FROM TSIPAR 
                                                       WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
                  AND VAR.NUNOTA = CAB.NUNOTA))
   
   ) AWS
