<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Nick and Jiv's Grocery Order Processing</title>
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

<% 
// Get customer id
String custId = request.getParameter("customerId");
String password = request.getParameter("password");
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

NumberFormat currFormat = NumberFormat.getCurrencyInstance();

// Make connection

String url = "jdbc:sqlserver://sql04.ok.ubc.ca:1433;DatabaseName=db_nmcgee;";
String uid = "nmcgee";
String pw = "75488726";

System.out.println("Connecting to database.");

try ( Connection con = DriverManager.getConnection(url, uid, pw); ) {
	// Save order information to database
	String SQL = "";
	PreparedStatement pstmt;
	ResultSet rst;
	int testId = -1;
	
	// Determine if valid customer id was entered
	// Determine if there are products in the shopping cart
	// If either are not true, display an error message
	try {
		testId = Integer.parseInt(custId);
		
		SQL = "SELECT * "
			 +"FROM customer "
			 +"WHERE customerId = ? and password = ?";
		pstmt = con.prepareStatement(SQL);
		pstmt.setInt(1, testId);
		pstmt.setString(2, password);
		rst = pstmt.executeQuery();
		
		if(!rst.next()){
		    out.println("<tr><td><h1>Invalid customer id or password. Go back to the previous page and try again</h1><");
		    return;
		} 
	} 
	catch (Exception e) {
		out.println("<h1>Invalid customer id or password. Go back to the previous page and try again</h1>");
		return;
	}
	
    Iterator<Map.Entry<String, ArrayList<Object>>> iterator1 = productList.entrySet().iterator();
    if (!iterator1.hasNext()) {
    	out.println("<h1>Empty Cart. Go back and add some items to your cart.</h1>");
    }
	
	// Create new order summary containing customer id and date.
	SQL = "INSERT INTO ordersummary (customerId, orderDate)" +
		  "VALUES (?, ?)";
    pstmt = con.prepareStatement(SQL, Statement.RETURN_GENERATED_KEYS);
    
	pstmt.setInt(1, Integer.parseInt(custId));                            				// customerId
	pstmt.setTimestamp(2, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));	// date time
	pstmt.executeUpdate();
	
	// auto generate a unique orderId key
    ResultSet keys = pstmt.getGeneratedKeys();
    keys.next();
    int orderId = keys.getInt(1);
		
	// Create new orderproduct
    SQL = "INSERT INTO orderproduct VALUES(?, ?, ?, ?)";
    pstmt = con.prepareStatement(SQL);
    
    // initialize values
    double pr = 0;
    int qty = 0;
    String productId = "";
    String productName = "";
    double total = 0;
    
	out.println("<h1>Order Summary</h1>");
	out.print("<th><table><tr><th>Product Id</th>");
	out.println("<th>Product Name</th>");
	out.println("<th>Quantity</th>");
	out.println("<th>Price</th>");
    out.println("<th>Subtotal</th></tr>");
    
    // Each entry in the HashMap is an ArrayList with item 0-id, 1-name, 2-quantity, 3-price
    Iterator<Map.Entry<String, ArrayList<Object>>> iterator2 = productList.entrySet().iterator();
    while (iterator2.hasNext())
    { 
        Map.Entry<String, ArrayList<Object>> entry = iterator2.next();
        ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
        
        // grabs values from shopping cart
        productId = (String) product.get(0);
        productName = (String) product.get(1);
        String price = (String) product.get(2);
        pr = Double.parseDouble(price);
        qty = ((Integer)product.get(3)).intValue();
        
        double subtotal = pr * qty;
        total += subtotal;
        
        // Insert each item into OrderProduct table using OrderId from previous INSERT
        pstmt.setInt(1, orderId);
        pstmt.setInt(2, Integer.parseInt(productId));
        pstmt.setInt(3, qty);
        pstmt.setDouble(4, pr);
        
        pstmt.executeUpdate();
        
        // Output product 
		out.println("<tr><td>" + productId + "</td>"
			       +"<td>" + productName + "</td>"
			       +"<td>" + qty + "</td>"
			       +"<td align=\"right\">" +  currFormat.format(pr) + "</td>"
			       +"<td align=\"right\">" + currFormat.format(subtotal) + "</td></tr>");
    }
    
    out.println("<tr><td colspan=\"4\" align=\"right\"><b>Order Total</b></td>"
			+"<td align=\"right\">"+currFormat.format(total)+"</td></tr>");
	out.println("</table>");
    
    out.println("<h1>Order Complete. Will be shipped soon...");
    out.println("<h1>Your order reference number is: " + orderId + "</h1>");
    
	// get name of customer for printing
	SQL = "SELECT customerId, firstName, lastName " + "FROM customer "
	           + "WHERE customerId LIKE ?";
	pstmt = con.prepareStatement(SQL);
	pstmt.setString(1, "%" + custId + "%");
	rst = pstmt.executeQuery();
    
	rst.next();
    out.println("<tr><td><a href = order.jsp?customerId=" + rst.getInt(1) + "></a>" + 
   			    "<h1>Shipping to customer: " + rst.getInt(1) + " Name: " + rst.getString(2) + " " + rst.getString(3) + 
   			    "</h1><h2><a href = index.jsp>Return to shopping</a></h2></td></tr>");
    
    System.out.println(total);
    
    SQL = "UPDATE ordersummary "
    	 +"SET totalAmount = ? "
         +"WHERE orderId = ?";
    pstmt = con.prepareStatement(SQL);
	pstmt.setDouble(1, total);
	pstmt.setInt(2, orderId);
	pstmt.executeUpdate();
    
	con.close(); 
	
	// Clear cart if order placed successfully
	Iterator<Map.Entry<String, ArrayList<Object>>> iterator3 = productList.entrySet().iterator();
    while (iterator3.hasNext()) {
        Map.Entry<String, ArrayList<Object>> entry = iterator3.next();
    	iterator3.remove();
    }
}

catch (SQLException ex) {
	System.err.println("SQLException: " + ex);
}

%>
</BODY>
</HTML>