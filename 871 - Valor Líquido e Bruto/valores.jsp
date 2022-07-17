<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="UTF-8" isELIgnored ="false"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<html>
<head>
	<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"
	integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"
	crossorigin="anonymous">

	<title>HTML5 Component</title>
	<link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/css/contatoCSS.css">
	<snk:load/> <!-- essa tag deve ficar nesta posição -->
</head>
<body style="background-image: url('http://192.168.1.248:8380/mge/imagens@IMAGEM@ID=111.dbimage'); background-size: 100%; background-repeat: no-repeat;">

	<snk:query var="mesAtual">
		<%
			String query = 
			"SELECT DESCRICAO,                  "+
			"       'R$ ' || TO_CHAR(VALOR,'FM999G999G999D90') AS VALOR,"+
			"       CMV  || ' %' AS CMV,        "+
			"       ROUND(QTDREG) AS QTDREG		"+
			"  FROM VWO_CVT_FLUXO_VLR_BRU_LIQ   "+    
			" ORDER BY DESCRICAO                ";
			out.println(query);
		%>
	</snk:query>

	<div class="container">
		<div style="padding-top: 120px;">
			<div style="text-align: center; color: #006400;">
				<h3>VALOR BRUTO X LIQUIDOS - PEDIDOS</h3>
			</div>
			
			<table class="table table-bordered">
				<thead>
				<tr style="line-height: 13px;">
					<th scope="col">Descrição</th>
					<th scope="col">Valor</th>
					<th scope="col">CMV</th>
					<th scope="col">Quantidade</th>
				</tr>
				</thead>
				<tbody>
				<c:forEach items="${mesAtual.rows}" var="linha">
					<tr style="line-height: 11px;">
						<td>
							<b><c:out value="${linha.DESCRICAO}" /></b>
						</td>
						<td>
							<c:out value="${linha.VALOR}" />
						</td>
						<td>
							<c:out value="${linha.CMV}" />
						</td>
						<td>
							<c:out value="${linha.QTDREG}" />
						</td>
					</tr>
				</c:forEach>
				</tbody>
			</table>
		</div>
	</div>
</body>
</html>