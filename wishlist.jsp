<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    Integer userId = (Integer) request.getSession().getAttribute("userId");
    String username = (String) request.getSession().getAttribute("username");
    String email = (String) request.getSession().getAttribute("email");

    List<String> wishlist = new ArrayList<>();

    if (userId != null) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            // Database connection details
            String jdbcUrl = "jdbc:mysql://localhost:3306/education"; // Change to your DB
            String dbUser = "root";
            String dbPassword = "root";

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            // Fetch wishlist
            String sqlWishlist = "SELECT course_name FROM wishlist WHERE user_id = ?";
            stmt = conn.prepareStatement(sqlWishlist);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();

            while (rs.next()) {
                wishlist.add(rs.getString("course_name"));
            }
        } catch (Exception e) {
            e.printStackTrace(); // For debugging
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Wishlist</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet"> <!-- Google Font -->
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            margin: 0;
            height: 100vh;
            background-color: #f4f4f4;
        }
        .sidebar {
            width: 250px;
            background-color: #490b3d;
            color: white;
            padding: 20px;
            box-shadow: 2px 0 5px rgba(0, 0, 0, 0.1);
        }
        .sidebar h2 {
            text-align: center;
            margin-bottom: 20px;
        }
        .sidebar .icon {
            text-align: center;
            margin-bottom: 20px;
        }
        .sidebar .options {
            list-style: none;
            padding: 0;
        }
        .sidebar .options li {
            padding: 10px;
            transition: background-color 0.3s;
        }
        .sidebar .options li:hover {
            background-color: #f1b814;
            cursor: pointer;
        }
        .content {
            flex: 1;
            padding: 20px;
            background-color: white;
            overflow-y: auto; /* Ensure content is scrollable if it exceeds height */
        }
        .content h1 {
            font-family: 'Roboto', sans-serif; /* Apply the new font to the heading */
            text-align: center;
            font-weight: 700; /* Bold */
        }
        .content ul {
            list-style-type: none;
            padding: 0;
            text-align: center; /* Center list items */
        }
        .content li {
            margin: 10px 0;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .content a {
            color: red; /* Link color for removal */
            text-decoration: none;
        }
        a {
    text-decoration: none;  /* Remove underline */
    color: inherit;         /* Inherit the text color from the surrounding element */
}

/* Optional: You can define a hover state if needed */
a:hover {
    text-decoration: none;  /* Still no underline on hover */
    color: inherit;         /* Prevent color change on hover */
}
    </style>
</head>
<body>

<div class="sidebar">
    <h2>My Account</h2>
    <div class="icon">
        <img src="https://www.unisuregroup.com/wp-content/uploads/2024/08/Policyholders-1.png" alt="Account Icon" width="100" height="100">
    </div>
    <p><strong><%= username != null ? username : "Username not found" %></strong></p>
    <ul class="options">
    <a href="account.html"><li>Return to Home page</li></a>
        <a href="myaccount.jsp"><li>My Learning</li></a>
        <a href="wishlist.jsp"><li>Wishlist</li></a>
        <a href="edit.jsp"><li>Edit Profile</li></a>
        <a href="deleteAccount.jsp"><li>Close Account</li></a>
        <a href="logout.jsp"><li>Log Out</li></a>
    </ul>
</div>

<div class="content">
    <h1>Your Wishlist</h1>
    
    <ul>
    <%
        if (wishlist.isEmpty()) {
            out.println("<li>No items in wishlist.</li>");
        } else {
            for (String course : wishlist) {
    %>
    <li>
        <%= course %>
        <a href="removeFromWishlist.jsp?course_name=<%= course %>">Remove</a>
    </li>
    <%
            }
        }
    %>
</ul>
    
</div>

</body>
</html>
