<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Database connection details
    String jdbcUrl = "jdbc:mysql://localhost:3306/education"; // Update as needed
    String dbUser = "root"; // Update as needed
    String dbPassword = "root"; // Update as needed

    Integer userId = (Integer) request.getSession().getAttribute("userId");
    String username = null;

    if (userId != null) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            // Fetch username
            String sql = "SELECT username FROM user WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                username = rs.getString("username");
            }
        } catch (Exception e) {
            e.printStackTrace(); // For debugging
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }

    String message = "";
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String password = request.getParameter("password");

        try {
            Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            // Verify the password
            String verifySql = "SELECT password FROM user WHERE id = ?";
            PreparedStatement verifyStmt = conn.prepareStatement(verifySql);
            verifyStmt.setInt(1, userId);
            ResultSet verifyRs = verifyStmt.executeQuery();

            if (verifyRs.next()) {
                String storedPassword = verifyRs.getString("password");

                // Check if the password matches
                if (storedPassword.equals(password)) {
                    // Delete account
                    String deleteSql = "DELETE FROM user WHERE id = ?";
                    PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
                    deleteStmt.setInt(1, userId);
                    int rowsDeleted = deleteStmt.executeUpdate();

                    if (rowsDeleted > 0) {
                        message = "Account deleted successfully.";
                        request.getSession().invalidate(); // Invalidate session
                        response.sendRedirect("home.html");
                        
                    } else {
                        message = "Error deleting account.";
                    }

                    deleteStmt.close();
                } else {
                    message = "Password is incorrect.";
                }
                verifyRs.close();
                verifyStmt.close();
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace(); // For debugging
            message = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Close Account</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
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
            background-color: #490b3d;
            cursor: pointer;
        }
        .container {
            flex: 1;
            padding: 20px;
            background-color: white;
            border-radius: 8px;
            margin-left: 15px;
        }
        h1 {
            text-align: center;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
        }
        input[type="password"] {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        input[type="submit"] {
            background-color: #bd1e51;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #f1b814;
        }
        .message {
            color: green;
            text-align: center;
        }
        .warning {
            color: red;
            margin-bottom: 20px;
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
        <img src="https://www.unisuregroup.com/wp-content/uploads/2024/08/Policyholders-1.png" alt="Account Icon" width="100" height="100"> <!-- Replace with your icon -->
    </div>
    <p><strong><%= username != null ? username : "Username not found" %></strong></p>
    <ul class="options">
    <a href="account.html"><li>Return to Home page</li></a>
       <a href="myaccount.jsp"> <li>My Learning</li></a>
        <li>Wishlist</li>
        <a href="edit.jsp">
        <li>Edit Profile</li></a>
        <a href="deleteAccount.jsp"><li>Close Account</li></a>
        <a href="logout.jsp"><li>Log Out</li></a>
    </ul>
</div>



<div class="container">
    <h1>Close Account</h1>
    <div class="warning">
        Warning: If you close your account, you will be unsubscribed from all of your courses and will lose access to your account and data associated with your account forever, even if you choose to create a new account using the same email address in the future.<br><br>
        Please note, if you want to reinstate your account after submitting a deletion request, you will have 14 days after the initial submission date to reach out to privacy@learnova.com to cancel this request.
    </div>

    <h2>Close your account permanently</h2>

    <% if (!message.isEmpty()) { %>
        <div class="message"><%= message %></div>
    <% } %>

    <form method="POST">
        <div class="form-group">
            <label for="password">Enter your password to confirm:</label>
            <input type="password" id="password" name="password" required>
        </div>
        <input type="submit" value="Close Account">
    </form>
</div>

</body>
</html>
