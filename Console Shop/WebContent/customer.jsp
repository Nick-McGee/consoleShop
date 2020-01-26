<!DOCTYPE html>
<html>
<head>
	<title>Customer Page</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style type="text/css">
		table, th, td{
 		border: 1px solid;
		}
	</style>
</head>
<body>

<%@ include file="auth.jsp"%>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>

<%
	String userName = (String) session.getAttribute("authenticatedUser");
%>

<%

//Make connection
String url = "jdbc:sqlserver://sql04.ok.ubc.ca:1433;DatabaseName=db_nmcgee;";
String uid = "nmcgee";
String pw = "75488726";

System.out.println("Connecting to database.");

// Write query to retrieve all order summary records
String SQL = "SELECT customerId, firstName, lastName, email, phonenum, address, city, state, postalcode, country " 
			+"FROM customer "
			+"WHERE customer.userid = ?";

try ( Connection con = DriverManager.getConnection(url, uid, pw); 
	  PreparedStatement pstmt = con.prepareStatement(SQL);) {
	System.out.println("Connected!");
	
	pstmt.setString(1, userName);
	ResultSet rst = pstmt.executeQuery();
	rst.next();
	
	// Print out results
	out.println("<h1>Customer Profile</h1>");
	out.println("<table>");
	out.println("<tr><td><b>Id</b></td><td>" + rst.getString(1) + "</td></tr>");
	out.println("<tr><td><b>First Name</b></td><td>" + rst.getString(2) + "</td></tr>");
	out.println("<tr><td><b>Last Name</b></td><td>" + rst.getString(3) + "</td></tr>");
	out.println("<tr><td><b>Email</b></td><td>" + rst.getString(4) + "</td></tr>");
	out.println("<tr><td><b>Phone</b></td><td>" + rst.getString(5) + "</td></tr>");
	out.println("<tr><td><b>Address</b></td><td>" + rst.getString(6) + "</td></tr>");
	out.println("<tr><td><b>City</b></td><td>" + rst.getString(7) + "</td></tr>");
	out.println("<tr><td><b>State</b></td><td>" + rst.getString(8) + "</td></tr>");
	out.println("<tr><td><b>Postal Code</b></td><td>" + rst.getString(9) + "</td></tr>");
	out.println("<tr><td><b>Country</b></td><td>" + rst.getString(10) + "</td></tr>");
	out.println("<tr><td><b>User Id</b></td><td>" + userName + "</td></tr>");
	out.println("</table>");
	
	con.close();
	
} catch (SQLException ex) {
	System.err.println("SQLException: " + ex);
}%>

</body>
</html>

