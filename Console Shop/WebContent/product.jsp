<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
 
<html>
<head>
<title>Nick and Jiv's Grocery - Product Information</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
 
<%@ include file="header.jsp" %>
 
<%
NumberFormat currFormat = NumberFormat.getCurrencyInstance();
 
String url = "jdbc:sqlserver://sql04.ok.ubc.ca:1433;DatabaseName=db_jgrewal;";
String uid = "jgrewal";
String pw = "33360660";
 
System.out.println("Connecting to database.");
 
try ( Connection con = DriverManager.getConnection(url, uid, pw);
      Statement stmt = con.createStatement(); ) {
   
    System.out.println("Connected!");
   
    // Get product name to search for
    String productId = request.getParameter("id");
   
    //Retrieve info for the product
    String SQL = "SELECT productName, productPrice "
                +"FROM product "
                +"WHERE productId = ?";
    PreparedStatement pstmt = con.prepareStatement(SQL);
    pstmt.setString(1, productId);
    ResultSet rst = pstmt.executeQuery();
    rst.next();
   
    // Store product info
    String productName = rst.getString(1);
    String parsedName = productName.replace(" ", "%20");
    Double productPrice = rst.getDouble(2);
    String parsedPrice = Double.toString(productPrice).replace(".", "%2E");  // replace need so it works in the URL
   
    out.println("<h1>" + productName + "</h1>");
   
    // Check if there is a product image
    SQL = "SELECT productImage, productImageURL "
         +"FROM product "
         +"WHERE productId = ?";
    pstmt = con.prepareStatement(SQL);
    pstmt.setString(1, productId);
    rst = pstmt.executeQuery();
   
    while(rst.next()) {
        // Check for productImage
        if(rst.getBinaryStream(1) != null)
            out.println("<img src= displayImage.jsp?id=" + productId + " >");
        // Check for productImageURL
        if(rst.getString(2) != null)
            out.println("<img src=img/" + productId + ".jpg>");
    }
   
    // Print out product info
    out.println("<h3><b>Id:</b>    " + productId + "</h3>");
    out.println("<h3><b>Price:</b> " + currFormat.format(productPrice) + "</h3>");
   
    // Links to add to cart and return to product page
    out.println("<h3><a href = addcart.jsp?id=" + productId + "&name=" + parsedName + "&price=" + parsedPrice + ">Add To Cart" + "</h3>");
    out.println("<h3><a href = listprod.jsp>Return to Shopping</a></h3>");
   
   
} catch (SQLException ex) {
    System.err.println("SQLException: " + ex);
}
 
%>
 
</body>
</html>