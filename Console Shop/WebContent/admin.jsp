<!DOCTYPE html>
<html>
<head>
	<title>Administrator Page</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style type="text/css">
		table, th, td{
 		border: 1px solid;
 		padding: 1%;
 		width: 400px;
		}
	</style>
</head>
<body>

<%@ include file="auth.jsp"%>
<%@ include file="jdbc.jsp" %>
<%@ page import="java.text.NumberFormat" %>

<%
NumberFormat currFormat = NumberFormat.getCurrencyInstance();

//Make connection
String url = "jdbc:sqlserver://sql04.ok.ubc.ca:1433;DatabaseName=db_nmcgee;";
String uid = "nmcgee";
String pw = "75488726";

System.out.println("Connecting to database.");

//Write query to retrieve daily order amounts
String SQL = "SELECT year(orderDate), month(orderDate), day(orderDate), SUM(totalAmount) " 
			+"FROM ordersummary "
			+"GROUP BY day(orderDate), year(orderDate), month(orderDate)";

try ( Connection con = DriverManager.getConnection(url, uid, pw); 
	  PreparedStatement pstmt = con.prepareStatement(SQL);) {
	System.out.println("Connected!");
	
	ResultSet rst = pstmt.executeQuery();
	
	out.println("<h1>Administrator Sales Report by Day</h1>");
	
	// Print out results
	out.println("<table>");
	out.println("<tr><th><b>Order Date</b><th><b>Total Order Amount</b></th></tr>");
	
	while(rst.next()){
		out.println("<tr><td>" + rst.getInt(1) + "-" + rst.getInt(2) + "-" + rst.getInt(3) + "</td><td>" + currFormat.format(rst.getDouble(4)) + "</td></tr>");
	}
	out.println("</table>");
	
	con.close();
	
} catch (SQLException ex) {
	System.err.println("SQLException: " + ex);
}

%>

</body>
</html>