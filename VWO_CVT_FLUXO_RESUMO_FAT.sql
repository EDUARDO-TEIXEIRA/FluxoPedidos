WITH VALORES AS (
SELECT VALOR, 
       CMV_VALOR,
       QTDREG
  FROM VWO_CVT_FLUXO_VLR_BRU_LIQ 
WHERE DESCRICAO = 'Total Líquido'),

PEDIDOS_LOG AS (
SELECT DESCRICAO,
           VALOR, 
           CMV_VALOR,
           QTDREG
        FROM VWO_CVT_FLUXO_NOTA_LOG LOG
      WHERE SUBSTR(LOG.DESCRICAO,1,2) IN ('18','19','20', '21','22', '23', '24', '25')
),

PEDIDOS_PENDENTES
    AS (
SELECT  NVL(SUM(VALOR * DECODE(SUBSTR(DESCRICAO,6,1), '-', (-1),1) ),0) AS VALOR,
       NVL(SUM(CMV_VALOR * DECODE(SUBSTR(DESCRICAO,6,1), '-', (-1),1)),0) AS CMV_VALOR,
       
       NVL(SUM(DECODE(SUBSTR(DESCRICAO,6,1),'+',QTDREG) ),0) AS QTDREG
  FROM (
  /*********************************************************************
  | Eduardo Teixeira, 06 de junho de 2022
  | 01. Neste caso são apontado os registros do fluxo administrativo para que
  | seja subtraído ou somado no valor líquido. 
  |
  | 02. Na segunda etapa é colocado os registros do fluxo logístico.
  */
    SELECT DESCRICAO,
           VALOR, 
           CMV_VALOR,
           QTDREG
       FROM VWO_CVT_FLUXO_PED_ADM ADM
      WHERE SUBSTR(ADM.DESCRICAO,1,2) IN ('05','07', '08', '09')
      UNION ALL
    SELECT DESCRICAO,
           VALOR, 
           CMV_VALOR,
           QTDREG
      FROM VWM_CVT_FLUXO_PED_ADM_ANT

     UNION ALL    
    SELECT DESCRICAO,
           VALOR, 
           CMV_VALOR,
           QTDREG
      FROM PEDIDOS_LOG LOG
     WHERE SUBSTR(LOG.DESCRICAO,1,2) IN ('18','22', '23', '24', '25'))

    ),
FATURAMENTO_DEV AS (
SELECT * 
  FROM PEDIDOS_LOG LOG 
 WHERE SUBSTR(LOG.DESCRICAO,1,2) IN ('19', '20', '21')
),

PERC_FAT AS (
SELECT ROUND(((SELECT VALOR 
          FROM PEDIDOS_LOG  
         WHERE SUBSTR(DESCRICAO,1,2) IN ('19')) / 
        (SELECT VALOR
           FROM VALORES )) * 100,2) AS VALOR
FROM DUAL
)

SELECT '26. Venda Líquida' AS DESCRICAO,
       VAL.VALOR AS TOTAL,
       ROUND((VAL.CMV_VALOR / VALOR) * 100,2) AS CMV,
       QTDREG
  FROM VALORES VAL
 UNION ALL 
SELECT '27. (=)Faturamento Máximo' AS DESCRICAO,       
       VALOR + (SELECT VALOR FROM VALORES)  AS VALOR,
       ROUND((CMV_VALOR + (SELECT CMV_VALOR FROM VALORES )) / (VALOR + (SELECT VALOR FROM VALORES)) * 100,2)   AS CMV_VALOR, 
       QTDREG    + (SELECT QTDREG FROM VALORES )     
  FROM PEDIDOS_PENDENTES
 UNION ALL
SELECT REPLACE(
        REPLACE(
         REPLACE(FAT.DESCRICAO, 
                '19. ', '28. '),
                '20. ', '29. '),
                '21. ', '30. ')
                       AS DESCRICAO, 
       FAT.VALOR AS TOTAL,
       CASE WHEN CMV_VALOR > 0 AND FAT.VALOR > 0 THEN 
       ROUND((FAT.CMV_VALOR / FAT.VALOR) * 100,2) ELSE 0 END AS CMV,
       QTDREG
  FROM FATURAMENTO_DEV FAT

 UNION ALL
SELECT '31. Meta de Faturamento' AS DESCRICAO,
        VLRMETA AS TOTAL,
        0 AS CMV_VALOR,
        0 AS QTD
   FROM AD_METAPRINCIPAL META
   WHERE ANO || MES = NVL((SELECT TO_CHAR(DATA, 'YYYYMM') 
                             FROM TSIPAR 
                            WHERE CHAVE = 'MESFATUR_FLUXO'), TRUNC(TO_CHAR(SYSDATE,'YYYYMM')))
UNION ALL
SELECT '32. % De Faturamento (28÷26)' AS DESCRICAO,
       VALOR,
       0,
       0       
  FROM PERC_FAT
