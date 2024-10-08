<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String message = "";

    if (email != null && password != null) {
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

            // Use prepared statement to prevent SQL injection
            String sql = "SELECT id, username, email, password FROM user WHERE email = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("password");
                // Compare plaintext passwords (not secure for real apps)
                if (storedPassword.equals(password)) {
                    // Successful login, set session
                    request.getSession().setAttribute("userId", rs.getInt("id"));
                    request.getSession().setAttribute("username", rs.getString("username"));
                    request.getSession().setAttribute("email", rs.getString("email"));
                    response.sendRedirect("account.html"); // Redirect to account page
                    return; // Exit to avoid further processing
                } else {
                    message = "Invalid email or password.";
                }
            } else {
                message = "Invalid email or password.";
            }
            
        } catch (Exception e) {
            message = "An error occurred. Please try again."; 
            e.printStackTrace(); // For debugging, consider logging instead
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
    <title>Login</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color:  #490b3d;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h2 {
            text-align: center;
        }
        .error {
            color: red;
            text-align: center;
        }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        button {
            width: 100%;
            padding: 10px;
            background-color: #f1b814;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        button:hover {
            background-color: #218838;
        }
        .signup {
            text-align: center;
            margin-top: 15px;
        }
        .signup a {
            color: #007bff;
            text-decoration: none;
        }
        .signup a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Login</h2>
    <form method="post" action="login.jsp">
        <input type="text" name="email" placeholder="Email" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit">Login</button>
    </form>
    <div class="error"><%= message %></div>
    
    <div class="signup">
        <p>Don't have an account? <a href="signup.jsp">Sign up here</a></p>
       
    <p><a href="forgotpassword.jsp">Forgot Password?</a></p>

        
    </div>
</div>

</body>
</html>
