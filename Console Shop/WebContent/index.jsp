<!DOCTYPE html>
<html>
<head>
	<title>Nick and Jiv's Grocery Main Page</title>
	<link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<% 
	String userName = (String) session.getAttribute("authenticatedUser"); 
%>

<%@ include file="header.jsp" %>

<h1 align="center">Welcome to Nick And Jiv's Grocery</h1>

<h2 align="center"><a href="login.jsp">Login</a></h2>

<h2 align="center"><a href="listprod.jsp">Begin Shopping</a></h2>

<h2 align="center"><a href="listorder.jsp">List All Orders</a></h2>

<h2 align="center"><a href="customer.jsp">Customer Info</a></h2>

<h2 align="center"><a href="admin.jsp">Administrators</a></h2>

<h2 align="center"><a href="logout.jsp">Log out</a></h2>

<%

if(userName != null) {
	out.println("<h3 align='center'>Logged in as: " + userName + "</h3>");
}

%>
</body>
</head>


