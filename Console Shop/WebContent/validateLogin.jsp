<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ include file="jdbc.jsp" %>
<%
	String authenticatedUser = null;
	session = request.getSession(true);

	try {
		authenticatedUser = validateLogin(out,request,session);
	} catch(IOException e)
	{	System.err.println(e); }

	if(authenticatedUser != null)
		response.sendRedirect("index.jsp");		// Successful login
	else
		response.sendRedirect("login.jsp");		// Failed login - redirect back to login page with a message 
%>


<%!
	String validateLogin(JspWriter out,HttpServletRequest request, HttpSession session) throws IOException
	{
		//Make connection
		String url = "jdbc:sqlserver://sql04.ok.ubc.ca:1433;DatabaseName=db_nmcgee;";
		String uid = "nmcgee";
		String pw = "75488726";
		
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String retStr = null;

		if(username == null || password == null)
				return null;
		if((username.length() == 0) || (password.length() == 0))
				return null;

		try 
		{
			getConnection();
			System.out.println("Connecting to database.");
			Connection con = DriverManager.getConnection(url, uid, pw);
			System.out.println("Connected!");
			
			String SQL = "SELECT * FROM customer WHERE userId = ? AND password = ?";
			PreparedStatement pstmt = con.prepareStatement(SQL);
			pstmt.setString(1, username);
			pstmt.setString(2, password);
			ResultSet rst = pstmt.executeQuery();
			
			if(!rst.next()) 
				retStr = null;	
			else
				retStr = username;
					
		} 
		catch (SQLException ex) {
			out.println(ex);
		}
		finally
		{
			closeConnection();
		}	
		
		if(retStr != null)
		{	session.removeAttribute("loginMessage");
			session.setAttribute("authenticatedUser",username);
		}
		else
			session.setAttribute("loginMessage","Could not connect to the system using that username/password.");

		return retStr;
	}
%>

