<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%
    String email = request.getParameter("email");
    String securityQuestion = request.getParameter("security_question");
    String securityAnswer = request.getParameter("security_answer");
    String newPassword = request.getParameter("new_password");
    String message = "";

    if (email != null && securityQuestion != null && securityAnswer != null && newPassword != null) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            // Database connection details
            String jdbcUrl = "jdbc:mysql://localhost:3306/education"; // Update to your DB
            String dbUser = "root";
            String dbPassword = "root";

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            // Verify security question and answer
            String sql = "SELECT id FROM user u JOIN user_security us ON u.id = us.user_id WHERE u.email = ? AND us.security_question = ? AND us.security_answer = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, securityQuestion);
            stmt.setString(3, securityAnswer);
            rs = stmt.executeQuery();

            if (rs.next()) {
                int userId = rs.getInt("id");

                // Update password
                String updateSql = "UPDATE user SET password = ? WHERE id = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, newPassword);
                updateStmt.setInt(2, userId);
                int rowsUpdated = updateStmt.executeUpdate();

                if (rowsUpdated > 0) {
                    message = "Password reset successful! Please <a href='login.jsp'>login</a>.";
                } else {
                    message = "Error updating password. Please try again.";
                }
            } else {
                message = "Security question/answer incorrect or user not found.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "An error occurred. Please try again.";
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
    <title>Reset Password</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #490b3d;
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
        .message {
            color: green;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Password Reset</h2>
        <div class="message"><%= message %></div>
    </div>
</body>
</html>
