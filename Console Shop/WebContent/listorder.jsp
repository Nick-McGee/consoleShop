<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
	<title>Nick And Jiv's Grocery Order List</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
	<style type="text/css">
	table, th, td{
	 border: 1px solid;
	}
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<h1>Order List</h1>

<%
//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
	System.out.println("driver loaded");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

// Useful code for formatting currency values:
NumberFormat currFormat = NumberFormat.getCurrencyInstance();
// out.println(currFormat.format(5.0);  // Prints $5.00

// Make connection
String url = "jdbc:sqlserver://sql04.ok.ubc.ca:1433;DatabaseName=db_nmcgee;";
String uid = "nmcgee";
String pw = "75488726";

System.out.println("Connecting to database.");

try ( Connection con = DriverManager.getConnection(url, uid, pw); 
	  Statement stmt = con.createStatement(); ) {
	// Write query to retrieve all order summary records
	System.out.println("Connected!");
	
	ResultSet rst = stmt.executeQuery("SELECT orderId, orderDate, customer.customerId, firstName, lastName, totalAmount "
									 +"FROM orderSummary, customer "
									 +"WHERE orderSummary.customerId = customer.customerId");
	
	out.print("<table><tr><th>Order Id</th>");
	out.println("<th>Order Date</th>");
	out.println("<th>Customer Id</th>");
	out.println("<th>Customer Name</th>");
	out.println("<th>Total Amount</th></tr>");
	
	while(rst.next()) {
		int orderId = rst.getInt(1);
		
		out.println("<tr><td>" + orderId + "</td>"
				       +"<td>" + rst.getDate(2) + "  " + rst.getTime(2) + "</td>"
				       +"<td>" + rst.getInt(3) + "</td>"
				       +"<td>" + rst.getString(4) + " " + rst.getString(5) + "</td>"
				       +"<td>" + currFormat.format(rst.getDouble(6)) + "</td></tr>");
		
		String SQL = "SELECT productId, quantity, price "
					+"FROM orderproduct "
					+"WHERE orderId = ?";
		
		PreparedStatement pstmt = con.prepareStatement(SQL);
		pstmt.setInt(1, orderId);
		ResultSet rst2 = pstmt.executeQuery();
		
		out.print("<th><table><tr><th>Product Id</th>");
		out.println("<th>Quantity</th>");
		out.println("<th>Price</th></tr>");
		
		while(rst2.next()) {
			out.println("<tr><td>" + rst2.getInt(1) + "</td>"
						   +"<td>" + rst2.getInt(2) + "</td>"
						   +"<td>" + currFormat.format(rst2.getDouble(3)) + "</td></tr>");
		}
		out.println("</table></th>");
	}
	
	out.println("</table>");
	con.close();
	
} catch (SQLException ex) {
	System.err.println("SQLException: " + ex);
}

// Close connection
%>

</body>
</html>

