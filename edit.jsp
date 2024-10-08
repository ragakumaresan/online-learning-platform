<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.Date" %>

<%
    // Database connection details
    String jdbcUrl = "jdbc:mysql://localhost:3306/education"; // Change to your DB
    String dbUser = "root"; // Update as needed
    String dbPassword = "root"; // Update as needed

    Integer userId = (Integer) request.getSession().getAttribute("userId");
    String username = null;
    String email = null;
    String firstName = null;
    String lastName = null;
    String role = null;
    java.sql.Date dob = null; // Using java.sql.Date

    if (userId != null) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            // Fetch user details
            String sql = "SELECT username, email, first_name, last_name, role, dob FROM user WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();

            if (rs.next()) {
                username = rs.getString("username");
                email = rs.getString("email");
                firstName = rs.getString("first_name");
                lastName = rs.getString("last_name");
                role = rs.getString("role");
                dob = rs.getDate("dob");
            }
        } catch (Exception e) {
            e.printStackTrace(); // For debugging
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }

    // Handle form submission to update user details
    String message = "";
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String newUsername = request.getParameter("username");
        String newEmail = request.getParameter("email");
        String newFirstName = request.getParameter("first_name");
        String newLastName = request.getParameter("last_name");
        String newPassword = request.getParameter("password");
        String oldPassword = request.getParameter("old_password");
        java.sql.Date newDob = java.sql.Date.valueOf(request.getParameter("dob")); // Using java.sql.Date

        try {
            Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            // Verify old password before updating
            String verifySql = "SELECT password FROM user WHERE id = ?";
            PreparedStatement verifyStmt = conn.prepareStatement(verifySql);
            verifyStmt.setInt(1, userId);
            ResultSet verifyRs = verifyStmt.executeQuery();

            if (verifyRs.next()) {
                String storedPassword = verifyRs.getString("password");

                // Check if the old password matches the stored password
                if (storedPassword.equals(oldPassword)) {
                    String updateSql = "UPDATE user SET username = ?, email = ?, first_name = ?, last_name = ?, password = ?, dob = ? WHERE id = ?";
                    PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                    updateStmt.setString(1, newUsername);
                    updateStmt.setString(2, newEmail);
                    updateStmt.setString(3, newFirstName);
                    updateStmt.setString(4, newLastName);
                    updateStmt.setString(5, newPassword); // Make sure to hash the password before storing it
                    updateStmt.setDate(6, newDob);
                    updateStmt.setInt(7, userId);

                    int rowsUpdated = updateStmt.executeUpdate();
                    if (rowsUpdated > 0) {
                        message = "Profile updated successfully.";
                    } else {
                        message = "Error updating profile.";
                    }

                    updateStmt.close();
                } else {
                    message = "Old password is incorrect.";
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
    <title>Edit Profile</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
        }
        .sidebar {
            width: 250px;
            background-color:#490b3d;
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
        input[type="text"], input[type="email"], input[type="password"], input[type="date"] {
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
    <h1>Edit Profile</h1>
    <% if (!message.isEmpty()) { %>
        <div class="message"><%= message %></div>
    <% } %>
    <form method="POST">
        <div class="form-group">
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" value="<%= username != null ? username : "" %>" required>
        </div>
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" value="<%= email != null ? email : "" %>" required>
        </div>
        <div class="form-group">
            <label for="first_name">First Name:</label>
            <input type="text" id="first_name" name="first_name" value="<%= firstName != null ? firstName : "" %>" required>
        </div>
        <div class="form-group">
            <label for="last_name">Last Name:</label>
            <input type="text" id="last_name" name="last_name" value="<%= lastName != null ? lastName : "" %>" required>
        </div>
        <div class="form-group">
            <label for="old_password">Old Password:</label>
            <input type="password" id="old_password" name="old_password" required>
        </div>
        <div class="form-group">
            <label for="password">New Password:</label>
            <input type="password" id="password" name="password" required>
        </div>
        <div class="form-group">
            <label for="dob">Date of Birth:</label>
            <input type="date" id="dob" name="dob" value="<%= dob != null ? dob.toString() : "" %>" required>
        </div>
        <input type="submit" value="Update Profile">
    </form>
</div>

</body>
</html>
