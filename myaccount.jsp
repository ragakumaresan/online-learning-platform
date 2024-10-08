<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>


<%
Integer userId = (Integer) request.getSession().getAttribute("userId");
String username = (String) request.getSession().getAttribute("username");
String email = (String) request.getSession().getAttribute("email");

List<String> courses = new ArrayList<>();
List<Integer> progress = new ArrayList<>();

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

        // Fetch user courses and sum the progress of same courses
        String sql = "SELECT course_name, SUM(progress) AS total_progress " +
                     "FROM user_courses WHERE user_id = ? " +
                     "GROUP BY course_name";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();

        while (rs.next()) {
            courses.add(rs.getString("course_name"));
            progress.add(rs.getInt("total_progress")); // Aggregated progress
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
    <title>My Account</title>
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
        }
        .account-info {
             /* Light gray background for account info */
            padding: 20px;
            border-radius: 8px;
            text-align: center; /* Center content */
            margin-bottom: 20px; /* Space between account info and courses */
        }
        .content h1 {
            text-align: center;
        }
        .content table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .content table, th, td {
            border: 1px solid #ccc;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #490b3d; /* Sidebar color for header */
            color: white; /* White text for contrast */
        }
        tr:nth-child(even) {
            background-color: #f9f9f9; /* Light background for even rows */
        }
        tr:hover {
            background-color: #f1b814; /* Highlight on row hover */
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
        <a href="wishlist.jsp"><li>Wishlist</li></a>
        <a href="edit.jsp">
        <li>Edit Profile</li></a>
        <a href="deleteAccount.jsp"><li>Close Account</li></a>
        <a href="logout.jsp"><li>Log Out</li></a>
    </ul>
</div>

<div class="content">
    <div class="account-info">
        <img src="https://www.unisuregroup.com/wp-content/uploads/2024/08/Policyholders-1.png" alt="Account Icon" width="80" height="80"> <!-- Account image -->
        <p><strong><%= username != null ? username : "Username not found" %></strong></p>
        <p>Email: <%= email != null ? email : "Email not found" %></p>
    </div>
    
    <h1>Your Ongoing Courses</h1>
    
    <table>
        <thead>
            <tr>
                <th>Course Name</th>
                <th>Progress (%)</th>
            </tr>
        </thead>
      <tbody>
<%
    if (courses.isEmpty()) {
        out.println("<tr><td colspan='2'>No courses found.</td></tr>");
    } else {
        for (int i = 0; i < courses.size(); i++) {
            String course = courses.get(i);
            int prog = progress.get(i);
%>
<tr>
    <td>
        <%= course %> 
        <%
            if (prog == 100) {
                // Link to the certificate page, passing the course name or ID if necessary
                String certificateLink = "certificate.jsp?course=" + URLEncoder.encode(course, "UTF-8");
        %>
                <a href="<%= certificateLink %>" style="color: green;"> - Get your certificate</a>
        <%
            }
        %>
    </td>
    <td><%= prog %>%</td>
</tr>
<%
        }
    }
%>
</tbody>
      
      
    </table>
</div>

</body>
</html>
