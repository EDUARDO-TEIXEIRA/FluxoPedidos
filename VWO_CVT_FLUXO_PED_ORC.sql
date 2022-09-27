WITH 
REGISTROS AS (
 SELECT CAB.NUNOTA,                                                                
        TOP.CODTIPOPER ,
        AD_TIPOPEDIDOAPP,
        CAB.CODVEND,
        CAB.AD_CODVEND,                                                  
        CAB.DTNEG,
        NVL(((ITE.VLRUNIT * ITE.QTDNEG) - ITE.VLRDESC - ITE.VLRREPRED),0) AS VALOR,
        FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP) * (ITE.QTDNEG) AS CMV,  
        CASE WHEN TRUNC(CAB.DTNEG , 'MONTH') = (SELECT TRUNC(DATA, 'MONTH')
                                                  FROM TSIPAR 
                                                 WHERE CHAVE = 'MESFATUR_FLUXO')
        
             THEN 'ATUAL' ELSE 'ANTERIOR' END AS PERIODO
  FROM TGFCAB CAB                                                          
 INNER JOIN TGFITE ITE                                                     
    ON ITE.NUNOTA = CAB.NUNOTA                                              
 INNER JOIN VGFCAB VCA                                                      
    ON VCA.NUNOTA=CAB.NUNOTA                                                
 INNER JOIN TGFTOP TOP                                                      
    ON TOP.CODTIPOPER=CAB.CODTIPOPER                                        
   AND TOP.DHALTER=CAB.DHTIPOPER                                            
 WHERE 'S' = CASE WHEN TOP.CODTIPOPER = 1010 THEN 
                       CAB.PENDENTE 
                  ELSE ITE.PENDENTE END
   AND CAB.CODTIPOPER IN (1000, 1010)
   )   

SELECT DESCRICAO,
       MAX(VALOR) AS VALOR,
       MAX(CMV) AS CMV,
       MAX(QTDREG) AS QTDREG,
       PERIODO
  FROM (
SELECT 'Orçamentos Não Transmitidos (App e Pedido Web)' AS DESCRICAO,
       ROUND(SUM(VALOR),2) AS VALOR,         
       ROUND(((SUM(CMV) / SUM(VALOR)) * 100),2) AS CMV,                    
       ROUND(COUNT(DISTINCT NUNOTA)) AS QTDREG,
       PERIODO
  FROM REGISTROS 
 WHERE CODTIPOPER = 1010                                     
   AND AD_TIPOPEDIDOAPP = 'OV'
 GROUP BY PERIODO
 
  UNION ALL 
 
SELECT 'Pedidos Não Transmitidos (Appe e Pedido Web)' AS DESCRICAO,
       ROUND(SUM(VALOR),2) AS VALOR,         
       ROUND(((SUM(CMV) / SUM(VALOR)) * 100),2) AS CMV,                    
       ROUND(COUNT(DISTINCT NUNOTA)) AS QTDREG,
       PERIODO
  FROM REGISTROS
 WHERE CODTIPOPER = 1010                                     
   AND AD_TIPOPEDIDOAPP = 'PV'
 GROUP BY PERIODO 

UNION ALL
SELECT 'Orçamentos Representante Comercial' AS DESCRICAO,
       ROUND(SUM(VALOR),2) AS VALOR,         
       ROUND(((SUM(CMV) / SUM(VALOR)) * 100),2) AS CMV,                    
       ROUND(COUNT(DISTINCT NUNOTA)) AS QTDREG,
       PERIODO
  FROM REGISTROS
 WHERE CODTIPOPER = 1000
   AND AD_CODVEND = CODVEND
 GROUP BY PERIODO 
 
 UNION ALL 
 
SELECT 'Orçamento Central de Negócios' AS DESCRICAO,
       ROUND(SUM(VALOR),2) AS VALOR,         
       ROUND(((SUM(CMV) / SUM(VALOR)) * 100),2) AS CMV,                    
       ROUND(COUNT(DISTINCT NUNOTA)) AS QTDREG,
       PERIODO
  FROM REGISTROS
 WHERE CODTIPOPER = 1000                                     
   AND AD_CODVEND <> CODVEND
 GROUP BY PERIODO
  
  UNION ALL
  SELECT 'Orçamentos Não Transmitidos (App e Pedido Web)' AS DESCRICAO,
        0,
        0,
        0,
        'ATUAL' AS PERIODO
   FROM DUAL
  UNION ALL
 SELECT 'Orçamentos Não Transmitidos (App e Pedido Web)' AS DESCRICAO,
        0,
        0,
        0,
        'ANTERIOR' AS PERIODO
   FROM DUAL 
  UNION ALL
 SELECT 'Pedidos Não Transmitidos (Appe e Pedido Web)' AS DESCRICAO,
        0,
        0,
        0,
        'ATUAL' AS PERIODO
   FROM DUAL
  UNION ALL
 SELECT 'Pedidos Não Transmitidos (Appe e Pedido Web)' AS DESCRICAO,
        0,
        0,
        0,
        'ANTERIOR' AS PERIODO
   FROM DUAL
   UNION ALL
 
 SELECT 'Orçamentos Representante Comercial' AS DESCRICAO,
        0,
        0,
        0,
        'ATUAL' AS PERIODO
   FROM DUAL
  UNION ALL
 SELECT 'Orçamentos Representante Comercial' AS DESCRICAO,
        0,
        0,
        0,
        'ANTERIOR' AS PERIODO
   FROM DUAL
  UNION ALL
 SELECT 'Orçamento Central de Negócios' AS DESCRICAO,
        0,
        0,
        0,
        'ATUAL' AS PERIODO
   FROM DUAL
  UNION ALL
 SELECT 'Orçamento Central de Negócios' AS DESCRICAO,
        0,
        0,
        0,
        'ANTERIOR' AS PERIODO
   FROM DUAL
 )

 GROUP BY DESCRICAO,
          PERIODO
