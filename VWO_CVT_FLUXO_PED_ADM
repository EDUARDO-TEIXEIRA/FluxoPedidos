SELECT QRY."DESCRICAO",
       QRY.VALOR,
       QRY.CMV,
       ROUND(QRY.QTDREG) AS QTDREG, 
       NVL(CMV_VALOR,0) AS CMV_VALOR,
       'ATUAL' AS PERIODO 
 FROM (    
 /*****************************************************************************
 | Aguardando Confirmação
 *****************************************************************************/
 SELECT '01. Aguardando Confirmação' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
       ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
       CAB.NUNOTA AS QTDREG
   FROM TGFCAB CAB
  INNER JOIN TGFTOP TOP 
     ON TOP.CODTIPOPER = CAB.CODTIPOPER 
    AND TOP.DHALTER    = CAB.DHTIPOPER 
  INNER JOIN TGFITE ITE 
     ON ITE.NUNOTA = CAB.NUNOTA
 WHERE (GRUPO IN ('PED.VENDA','TROCA') 
	     AND CAB.STATUSNOTA<>'L' AND NOT EXISTS (SELECT 1 FROM TSILIB LIB WHERE LIB.NUCHAVE = CAB.NUNOTA)                                             
	     AND TRUNC(TO_CHAR(DTNEG,'YYYY'))= NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                               FROM TSIPAR 
                                              WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
         OR CAB.NUNOTA IN (SELECT C.NUNOTA
                                FROM TGFCAB C
                                INNER JOIN TGFTOP T ON (T.CODTIPOPER = C.CODTIPOPER AND T.DHALTER = C.DHTIPOPER) 
                                WHERE C.TIPMOV = 'P'
                                AND C.STATUSNOTA <> 'L'
                                AND T.GRUPO IN ('PED.VENDA','TROCA')
                                AND DTFATUR >= '01/01/2020'
                                AND C.NUNOTA NOT IN (
                                                        SELECT AUX.NUNOTA
                                                        FROM TGFCAB AUX
                                                        INNER JOIN TSILIB LIB ON (LIB.NUCHAVE = AUX.NUNOTA)
                                                        INNER JOIN TGFTOP TOP ON (TOP.CODTIPOPER = AUX.CODTIPOPER AND TOP.DHALTER = AUX.DHTIPOPER) 
                                                        WHERE LIB.TABELA = 'TGFCAB'
                                                        AND TOP.GRUPO IN ('PED.VENDA','TROCA'))))  )
    

 /*****************************************************************************
 | Troca de SKU - Liberação Pendente 
 *****************************************************************************/
 UNION ALL  
  SELECT '02. Troca de SKU-Liberação Pendente' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
       ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
       CAB.NUNOTA AS QTDREG
  FROM TGFCAB CAB
 INNER JOIN TGFITE ITE 
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER
 WHERE TOP.GRUPO IN ('PED.VENDA','TROCA') 
   AND TO_CHAR(CAB.DTFATUR,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
   AND CAB.NUNOTA IN (SELECT LIB.NUCHAVE
                        FROM TSILIB LIB
                        LEFT JOIN AD_EVELIB EVE
                          ON EVE.EVENTO = LIB.EVENTO
                         AND NVL(EVE.NURNG,1) = NVL(LIB.NURNG,1)
                       WHERE LIB.TABELA IN ('TGFITE', 'TGFCAB')
                         AND LIB.DHLIB IS NULL
                         AND EVE.SETOR = 'E')
        )

 /*****************************************************************************
 | Comercial - Liberação Pendente
 *****************************************************************************/
  UNION ALL  
SELECT  '03. Comercial-Liberação Pendente' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
       ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
       CAB.NUNOTA AS QTDREG
  FROM TGFCAB CAB
 INNER JOIN TGFITE ITE 
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER
 WHERE TOP.GRUPO IN ('PED.VENDA','TROCA') 
   AND CAB.PENDENTE = 'S'
   AND TO_CHAR(CAB.DTFATUR,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
   AND CAB.NUNOTA IN (SELECT LIB.NUCHAVE
                        FROM TSILIB LIB
                        LEFT JOIN AD_EVELIB EVE
                          ON EVE.EVENTO = LIB.EVENTO
                         AND NVL(EVE.NURNG,1) = NVL(LIB.NURNG,1)
                       WHERE LIB.TABELA IN ('TGFITE', 'TGFCAB')
                         AND LIB.DHLIB IS NULL
                         AND EVE.SETOR = 'C'
                         AND 0 = (SELECT MAX(VLR)
                                    FROM (SELECT COUNT(1) AS VLR
                                            FROM TSILIB LIV
                                            LEFT JOIN AD_EVELIB EVV
                                              ON EVV.EVENTO  = LIV.EVENTO
                                             AND NVL(EVV.NURNG,1)   = NVL(LIV.NURNG,1)
                                          
                                           WHERE LIV.NUCHAVE = LIB.NUCHAVE
                                             AND LIV.DHLIB IS NULL
                                             AND EVV.SETOR    IN ('E')
                                            
                                           UNION ALL 
                                    
                                          SELECT 0 VLR FROM DUAL))  
                        
                     )
        )
 /*****************************************************************************
 | Financeiro - Liberação Pendente
 *****************************************************************************/
 UNION ALL  
SELECT  '04. Financeiro - Liberação Pendente' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR            
  FROM (
SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
       ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
       CAB.NUNOTA AS QTDREG
  FROM TGFCAB CAB
 INNER JOIN TGFITE ITE 
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER
 WHERE TOP.GRUPO IN ('PED.VENDA','TROCA') 
   AND CAB.PENDENTE = 'S'
   AND TO_CHAR(CAB.DTFATUR,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
   AND CAB.NUNOTA IN (SELECT LIB.NUCHAVE
                        FROM TSILIB LIB
                        LEFT JOIN AD_EVELIB EVE
                          ON EVE.EVENTO = LIB.EVENTO
                         AND NVL(EVE.NURNG,1) = NVL(LIB.NURNG,1)
                       WHERE LIB.TABELA IN ('TGFITE', 'TGFCAB')
                         AND LIB.DHLIB IS NULL
                         AND EVE.SETOR = 'F'
                         AND 0 = (SELECT MAX(VLR)
                                    FROM (SELECT COUNT(1) AS VLR
                                            FROM TSILIB LIV
                                            LEFT JOIN AD_EVELIB EVV
                                              ON EVV.EVENTO  = LIV.EVENTO
                                             AND NVL(EVV.NURNG,1)   = NVL(LIV.NURNG,1)
                                          
                                           WHERE LIV.NUCHAVE = LIB.NUCHAVE
                                             AND LIV.DHLIB IS NULL
                                             AND EVV.SETOR    IN ('E','C')
                                            
                                           UNION ALL 
                                    
                                          SELECT 0 VLR FROM DUAL))  
                        
                     )
        )
/*****************************************************************************
 | Negados nas Análises
 *****************************************************************************/
 UNION ALL  
 SELECT '05. (-)Negado nas Análises' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
 SELECT 
         ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
         ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
         CAB.NUNOTA AS QTDREG
    FROM TGFCAB CAB
   INNER JOIN TGFITE ITE 
      ON ITE.NUNOTA = CAB.NUNOTA
   INNER JOIN TGFTOP TOP 
      ON TOP.CODTIPOPER = CAB.CODTIPOPER 
     AND TOP.DHALTER = CAB.DHTIPOPER
   WHERE TOP.GRUPO IN ('PED.VENDA','TROCA')
     AND TO_CHAR(CAB.DTNEG,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
     AND EXISTS (SELECT 1 FROM TSILIB LIB WHERE CAB.NUNOTA = LIB.NUCHAVE AND REPROVADO = 'S'))
    

 /*****************************************************************************
 | Confirmado sem Restrição  
 *****************************************************************************/ 

  UNION ALL  
 SELECT '06. Confirmados sem Restrição' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
 SELECT 
         ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
         ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
         CAB.NUNOTA AS QTDREG
    FROM TGFCAB CAB
   INNER JOIN TGFITE ITE 
      ON ITE.NUNOTA = CAB.NUNOTA
   INNER JOIN TGFTOP TOP 
      ON TOP.CODTIPOPER = CAB.CODTIPOPER 
     AND TOP.DHALTER = CAB.DHTIPOPER
   WHERE TOP.GRUPO IN ('PED.VENDA','TROCA')
     AND TO_CHAR(CAB.DTNEG,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))

     AND CAB.STATUSNOTA    = 'L'
     AND AD_PEDIDOCORTE IS NULL
     AND NOT EXISTS (SELECT 1 FROM TSILIB LIB WHERE CAB.NUNOTA = LIB.NUCHAVE AND LIB.TABELA IN ('TGFCAB', 'TGFITE'))) 
    
 /*****************************************************************************
 | Programados  
 *****************************************************************************/ 
 UNION ALL
 SELECT '07. (-)Programados' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
 SELECT 
         ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
         ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
         CAB.NUNOTA AS QTDREG

  FROM TGFCAB CAB
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND CAB.DHTIPOPER = TOP.DHALTER
 INNER JOIN TGFITE ITE 
    ON ITE.NUNOTA = CAB.NUNOTA
 WHERE EXISTS (SELECT 1 FROM TSILIB LIB 
                WHERE LIB.NUCHAVE = CAB.NUNOTA
                  AND LIB.TABELA = 'TGFCAB'
                  AND LIB.DHLIB IS NULL)
                  
   AND CAB.AD_DTPEDIDOPROGRAMADO IS NOT NULL
   AND TOP.GRUPO IN ('PED.VENDA','TROCA')
   AND TO_CHAR(CAB.DTNEG,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                            FROM TSIPAR 
                                           WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM'))))
   
 /*****************************************************************************
 | Cortes Gerados - Pendentes      
 *****************************************************************************/ 
-- AD_PEDIDOS_COM_CORTE (PENDENTE = 'S')
 UNION ALL  
 SELECT '08. (-)Ruptura de Venda-Pendente' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
 SELECT
         ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
         ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
         CAB.NUNOTA AS QTDREG 
   FROM TGFCAB CAB
  INNER JOIN TGFITE ITE
     ON ITE.NUNOTA = CAB.NUNOTA
  WHERE CAB.PENDENTE = 'S'
    AND TO_CHAR(CAB.DTNEG,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
    AND EXISTS (SELECT 1 FROM AD_PEDIDOS_COM_CORTE C WHERE C.NUNOTA = CAB.NUNOTA))
  
 /*****************************************************************************
 | Cortes Gerados - Cancelados      
 *****************************************************************************/ 

 UNION ALL
 SELECT '09. (-)Ruptura de Venda-Cancelado' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
 SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
        ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
        CAB.NUNOTA AS QTDREG  
   FROM TGFCAB CAB
  INNER JOIN TGFITE ITE 
     ON (ITE.NUNOTA = CAB.NUNOTA)
  INNER JOIN TGFTOP TOP 
     ON TOP.CODTIPOPER = CAB.CODTIPOPER 
    AND CAB.DHTIPOPER = TOP.DHALTER
  WHERE CAB.PENDENTE = 'N'
    AND TO_CHAR(CAB.DTNEG,'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                             FROM TSIPAR 
                                            WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
    AND EXISTS (SELECT 1 FROM AD_PEDIDOS_COM_CORTE C WHERE C.NUNOTA = CAB.NUNOTA))
   
    ) QRY

  UNION ALL

SELECT AWS."DESCRICAO",
       AWS."VALOR",
       AWS."CMV",
       ROUND(AWS."QTDREG") AS QTDREG, 
       NVL(CMV_VALOR,0) AS CMV_VALOR,
       'ANTERIOR' AS PERIODO 
FROM (
 SELECT '10. (+)Aguardando Confirmação' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
       ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
       CAB.NUNOTA AS QTDREG
   FROM TGFCAB CAB
  INNER JOIN TGFTOP TOP 
     ON TOP.CODTIPOPER = CAB.CODTIPOPER 
    AND TOP.DHALTER    = CAB.DHTIPOPER 
  INNER JOIN TGFITE ITE 
     ON ITE.NUNOTA = CAB.NUNOTA
 WHERE (GRUPO IN ('PED.VENDA','TROCA') 
	     AND CAB.STATUSNOTA<>'L' AND NOT EXISTS (SELECT 1 FROM TSILIB LIB WHERE LIB.NUCHAVE = CAB.NUNOTA)                                             
	     AND TRUNC(TO_CHAR(DTNEG,'YYYY'))< NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                               FROM TSIPAR 
                                              WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
         OR CAB.NUNOTA IN (SELECT C.NUNOTA
                                FROM TGFCAB C
                                INNER JOIN TGFTOP T ON (T.CODTIPOPER = C.CODTIPOPER AND T.DHALTER = C.DHTIPOPER) 
                                WHERE C.TIPMOV = 'P'
                                AND C.STATUSNOTA <> 'L'
                                AND T.GRUPO IN ('PED.VENDA','TROCA')
                                AND DTFATUR >= '01/01/2020'
                                AND C.NUNOTA NOT IN (
                                                        SELECT AUX.NUNOTA
                                                        FROM TGFCAB AUX
                                                        INNER JOIN TSILIB LIB ON (LIB.NUCHAVE = AUX.NUNOTA)
                                                        INNER JOIN TGFTOP TOP ON (TOP.CODTIPOPER = AUX.CODTIPOPER AND TOP.DHALTER = AUX.DHTIPOPER) 
                                                        WHERE LIB.TABELA = 'TGFCAB'
                                                        AND TOP.GRUPO IN ('PED.VENDA','TROCA'))))  )
UNION ALL
  SELECT '11. (+)Troca de SKU-Liberação Pendente' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
       ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
       CAB.NUNOTA AS QTDREG
  FROM TGFCAB CAB
 INNER JOIN TGFITE ITE 
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER
 WHERE TOP.GRUPO IN ('PED.VENDA','TROCA') 
   AND TO_CHAR(CAB.DTFATUR,'YYYYMM') < NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
   AND CAB.NUNOTA IN (SELECT LIB.NUCHAVE
                        FROM TSILIB LIB
                        LEFT JOIN AD_EVELIB EVE
                          ON EVE.EVENTO = LIB.EVENTO
                         AND NVL(EVE.NURNG,1) = NVL(LIB.NURNG,1)
                       WHERE LIB.TABELA IN ('TGFITE', 'TGFCAB')
                         AND LIB.DHLIB IS NULL
                         AND EVE.SETOR = 'E')
        )

 /*****************************************************************************
 | Comercial - Liberação Pendente
 *****************************************************************************/
  UNION ALL  
SELECT  '12. (+)Comercial-Liberação Pendente' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR
  FROM (
SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
       ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
       CAB.NUNOTA AS QTDREG
  FROM TGFCAB CAB
 INNER JOIN TGFITE ITE 
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER
 WHERE TOP.GRUPO IN ('PED.VENDA','TROCA') 
   AND CAB.PENDENTE = 'S'
   AND TO_CHAR(CAB.DTFATUR,'YYYYMM') < NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
   AND CAB.NUNOTA IN (SELECT LIB.NUCHAVE
                        FROM TSILIB LIB
                        LEFT JOIN AD_EVELIB EVE
                          ON EVE.EVENTO = LIB.EVENTO
                         AND NVL(EVE.NURNG,1) = NVL(LIB.NURNG,1)
                       WHERE LIB.TABELA IN ('TGFITE', 'TGFCAB')
                         AND LIB.DHLIB IS NULL
                         AND EVE.SETOR = 'C'
                         AND 0 = (SELECT MAX(VLR)
                                    FROM (SELECT COUNT(1) AS VLR
                                            FROM TSILIB LIV
                                            LEFT JOIN AD_EVELIB EVV
                                              ON EVV.EVENTO  = LIV.EVENTO
                                             AND NVL(EVV.NURNG,1)   = NVL(LIV.NURNG,1)
                                          
                                           WHERE LIV.NUCHAVE = LIB.NUCHAVE
                                             AND LIV.DHLIB IS NULL
                                             AND EVV.SETOR    IN ('E')
                                            
                                           UNION ALL 
                                    
                                          SELECT 0 VLR FROM DUAL))  
                        
                     )
        )
 /*****************************************************************************
 | Financeiro - Liberação Pendente
 *****************************************************************************/
 UNION ALL  
SELECT  '13. (+)Financeiro - Liberação Pendente' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR            
  FROM (
SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
       ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
       CAB.NUNOTA AS QTDREG
  FROM TGFCAB CAB
 INNER JOIN TGFITE ITE 
    ON ITE.NUNOTA = CAB.NUNOTA
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND TOP.DHALTER = CAB.DHTIPOPER
 WHERE TOP.GRUPO IN ('PED.VENDA','TROCA') 
   AND CAB.PENDENTE = 'S'
   AND TO_CHAR(CAB.DTFATUR,'YYYYMM') < NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
   AND CAB.NUNOTA IN (SELECT LIB.NUCHAVE
                        FROM TSILIB LIB
                        LEFT JOIN AD_EVELIB EVE
                          ON EVE.EVENTO = LIB.EVENTO
                         AND NVL(EVE.NURNG,1) = NVL(LIB.NURNG,1)
                       WHERE LIB.TABELA IN ('TGFITE', 'TGFCAB')
                         AND LIB.DHLIB IS NULL
                         AND EVE.SETOR = 'F'
                         AND 0 = (SELECT MAX(VLR)
                                    FROM (SELECT COUNT(1) AS VLR
                                            FROM TSILIB LIV
                                            LEFT JOIN AD_EVELIB EVV
                                              ON EVV.EVENTO  = LIV.EVENTO
                                             AND NVL(EVV.NURNG,1)   = NVL(LIV.NURNG,1)
                                          
                                           WHERE LIV.NUCHAVE = LIB.NUCHAVE
                                             AND LIV.DHLIB IS NULL
                                             AND EVV.SETOR    IN ('E','C')
                                            
                                           UNION ALL 
                                    
                                          SELECT 0 VLR FROM DUAL))  
                        
                     )
        )
    
 /*****************************************************************************
 | Programados  
 *****************************************************************************/ 
 UNION ALL
SELECT  '14. (+)Programados' AS DESCRICAO,
        NVL(SUM(VALOR),0) AS VALOR,                                                                         
        NVL(COUNT(DISTINCT QTDREG),0) AS QTDREG,                                                                        
        NVL(ROUND((SUM(CMV) / SUM(VALOR)) * 100,2),0) AS CMV,
        SUM(CMV) AS CMV_VALOR  
  FROM (
 SELECT ROUND((FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * ITE.QTDNEG),2) AS CMV,
         ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED AS VALOR,
         CAB.NUNOTA AS QTDREG

  FROM TGFCAB CAB
 INNER JOIN TGFTOP TOP 
    ON TOP.CODTIPOPER = CAB.CODTIPOPER 
   AND CAB.DHTIPOPER = TOP.DHALTER
 INNER JOIN TGFITE ITE 
    ON ITE.NUNOTA = CAB.NUNOTA
 WHERE TO_CHAR(CAB.AD_DTPEDIDOPROGRAMADO, 'YYYYMM') = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                              FROM TSIPAR 
                                             WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
   AND TOP.GRUPO IN ('PED.VENDA','TROCA')
   AND EXISTS (SELECT 1 FROM TSILIB LIB 
                WHERE LIB.NUCHAVE = CAB.NUNOTA
                  AND LIB.TABELA = 'TGFCAB'
                  AND LIB.DHLIB IS NULL))
 
 
    ) AWS
