<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Nick And Jiv's Grocery Products</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<h1>Search for the products you want to buy:</h1>

<form method="get" action="listprod.jsp">
<input type="text" name="productName" size="50">
<input type="submit" value="Submit"><input type="reset" value="Reset"> (Leave blank for all products)
</form>

<% // Get product name to search for
String name = request.getParameter("productName");
//name = "chai";
		
//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

NumberFormat currFormat = NumberFormat.getCurrencyInstance();

// Variable name now contains the search string the user entered
// Use it to build a query and print out the resultset.  Make sure to use PreparedStatement!

// Make the connection

String url = "jdbc:sqlserver://sql04.ok.ubc.ca:1433;DatabaseName=db_nmcgee;";
String uid = "nmcgee";
String pw = "75488726";

System.out.println("Connecting to database.");

try ( Connection con = DriverManager.getConnection(url, uid, pw); 
	  Statement stmt = con.createStatement(); ) {	
	
	System.out.println("Connected!");
	
	String SQL = "";
	PreparedStatement pstmt;
	
	if(name == null || name == "") {
		SQL = "SELECT productname, productprice, productid " 
			 +"FROM product";
		
		pstmt = con.prepareStatement(SQL);
	} else {
		SQL = "SELECT productname, productprice, productid " 
			 +"FROM product "
			 +"WHERE productname LIKE ?";
		
		pstmt = con.prepareStatement(SQL);
		pstmt.setString(1, "%" + name + "%");
	}
	
	ResultSet rst = pstmt.executeQuery();
	
	out.print("<th><table><tr><th> </th>");
	out.println("<th>Product Name</th>");
    out.println("<th>Price</th></tr>");
    
 // For each product create a link of the form
 // Print out the ResultSet
	while(rst.next()){
		String productName = rst.getString(1); 
		String parsedName = productName.replace(" ", "%20");  					// spaces don't work in the URL, so the %20 character must be used
		double productPrice = rst.getDouble(2);
		String parsedPrice = Double.toString(productPrice).replace(".", "%2E"); // periods don't work in URL, so the %2E character must be used
		int productId = rst.getInt(3);
				
		out.println("<tr><td><a href = addcart.jsp?id=" + productId + "&name=" + parsedName + "&price=" + parsedPrice + "> Add To Cart" + "</td>"
                   +"<td><a href = product.jsp?id=" + productId +">" + productName + "</td>" + "<td>" + currFormat.format(productPrice) + "</td></tr>");
	}
	
	// Close connection
	out.println("</table></th>");
	con.close();
	name = null;
}
catch (SQLException ex) {
	System.err.println("SQLException: " + ex);
}

%>

</body>
</html>