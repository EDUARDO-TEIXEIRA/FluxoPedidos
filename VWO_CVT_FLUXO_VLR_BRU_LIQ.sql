SELECT DECODE(DESCRICAO, 'TOTAL_LIQUIDO', 'Total Líquido', 'Total Bruto') DESCRICAO,  
        VALOR,                                                                         
        ROUND(QTDREG) AS QTDREG,                                                                        
        DECODE(DESCRICAO, 'TOTAL_LIQUIDO', CMV_LIQ, CMV_BRU) AS CMV,
        ROUND(CMV_VALOR,2) AS CMV_VALOR
   FROM (                                                                              
 SELECT ROUND(SUM(TOTALLIQ),2) AS TOTAL_LIQUIDO,
        ROUND((SUM(CMV) / SUM(TOTALLIQ)),2) * 100 AS CMV_LIQ,                                       
        ROUND(SUM(TOTALBRU),2) AS TOTAL_BRUTO,   
        ROUND((SUM(CMV) / SUM(TOTALBRU)),2) * 100 CMV_BRU, 
        SUM(CMV) AS CMV_VALOR,
        COUNT(DISTINCT NUNOTA) AS QTDREG                                               
   FROM (SELECT  (SELECT SUM(ITE.VLRTOT - ITE.VLRDESC - ITE.VLRREPRED) AS TOTALLIQ     
                    FROM TGFITE ITE                                                    
                   WHERE ITE.NUNOTA = CAB.NUNOTA) AS TOTALLIQ,                         
                 CAB.VLRNOTA AS TOTALBRU,                                              
                 CAB.NUNOTA,                                                           
                 (SELECT SUM(FUN_CVT_CUSTO_MEDIO_COM_ICMS (ITE.CODPROD, CAB.DTFATUR, CAB.CODEMP)
                          * ITE.QTDNEG)                            
                    FROM TGFITE ITE                                                    
                   WHERE ITE.NUNOTA = CAB.NUNOTA) AS CMV                               
           FROM TGFCAB CAB                                                             
          INNER JOIN TGFTOP TOP                                                        
             ON TOP.CODTIPOPER=CAB.CODTIPOPER                                          
            AND TOP.DHALTER=CAB.DHTIPOPER                                              
          WHERE CAB.TIPMOV='P'                                                         
            AND GRUPO IN ('PED.VENDA','TROCA')                                         

            AND TRUNC(TO_CHAR(DTNEG,'YYYYMM')) =  NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                                         FROM TSIPAR 
                                                        WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
            AND CAB.NUNOTA NOT IN (SELECT C2.NUNOTA                                    
                                     FROM TGFCAB C1                                    
                                    INNER JOIN TGFVAR V1                               
                                       ON V1.NUNOTAORIG=C1.NUNOTA                      
                                    INNER JOIN TGFCAB C2                               
                                       ON C2.NUNOTA = V1.NUNOTA                        
                                    INNER JOIN TGFTOP T1                               
                                       ON T1.CODTIPOPER=C1.CODTIPOPER AND T1.DHALTER = C1.DHTIPOPER
                                    INNER JOIN TGFTOP T2                               
                                       ON T2.CODTIPOPER=C2.CODTIPOPER AND T2.DHALTER = C2.DHTIPOPER
                                    WHERE T1.GRUPO IN ('PED.VENDA','TROCA')            
                                      AND T2.GRUPO IN ('PED.VENDA','TROCA')            
                                      AND TO_CHAR(C2.DTNEG,'YYYYMM')= NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                                                                             FROM TSIPAR 
                                                                            WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM'))) 
                                   GROUP BY C2.NUNOTA)                                 
        ))                                                                             

        UNPIVOT (VALOR FOR DESCRICAO IN (TOTAL_LIQUIDO, TOTAL_BRUTO))
