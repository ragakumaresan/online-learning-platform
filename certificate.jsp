<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
// Database connection details

String courseName = request.getParameter("course");
if (courseName == null || courseName.isEmpty()) {
    courseName = "No course selected.";  // Fallback if course name is not provided
}

Integer userId = (Integer) request.getSession().getAttribute("userId");
String studentName = "";
String completionDate = new java.util.Date().toString();  // Current date

if (userId != null) {
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String jdbcUrl = "jdbc:mysql://localhost:3306/education"; // Update with your DB details
        String dbUser = "root";
        String dbPassword = "root";
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

        // Fetch the user's full name
        String userSql = "SELECT first_name, last_name FROM user WHERE id = ?";
        stmt = conn.prepareStatement(userSql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (rs.next()) {
            studentName = rs.getString("first_name") + " " + rs.getString("last_name");
        }
    } catch (Exception e) {
        e.printStackTrace(); // For debugging
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
} else {
    studentName = "Guest"; // Handle case where user is not logged in
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .certificate-container {
            background-color: white;
            width: 800px;
            padding: 50px;
            text-align: center;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
            border: 10px solid #f1b814;
            border-radius: 15px;
        }

        .certificate-container h1 {
            font-size: 40px;
            color: #490b3d;
            margin-bottom: 20px;
        }

        .certificate-container h2 {
            font-size: 25px;
            margin-bottom: 40px;
            color: #555;
        }

        .certificate-container p {
            font-size: 18px;
            margin-bottom: 40px;
            color: #777;
        }

        .certificate-container .name {
            font-size: 30px;
            color: #000;
            margin-bottom: 10px;
        }

        .certificate-container .course-name {
            font-size: 20px;
            font-style: italic;
            color: #444;
            margin-bottom: 40px;
        }

        .certificate-container .date {
            font-size: 18px;
            color: #666;
            margin-top: 20px;
        }

        .certificate-container .website {
            font-size: 22px;
            color: #f1b814;
            margin-bottom: 20px;
        }

        /* Borders */
        .certificate-container {
            position: relative;
        }

        .certificate-container:before, 
        .certificate-container:after {
            content: '';
            position: absolute;
            width: 100%;
            height: 100%;
            border: 10px solid #f1b814;
            top: -20px;
            left: -20px;
            z-index: -1;
        }
    </style>
</head>
<body>

<div class="certificate-container">
    <h1>Learnova</h1>
    <h2>Course Completion Certificate</h2>

    <p>This certificate is presented to</p>

    <div class="name"><%= studentName != null ? studentName : "Student Name" %></div>

    <p>For successfully completing the online course</p>

 <div class="course-name"><%= courseName != null ? courseName : "Course Name" %></div>
    <div class="date"><%= completionDate %></div>
    
    <div class="website">www.learnova.com</div>
</div>

</body>
</html>
