<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    Integer userId = (Integer) request.getSession().getAttribute("userId");
    String courseName = request.getParameter("course_name");

    if (userId != null && courseName != null) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            // Database connection details
            String jdbcUrl = "jdbc:mysql://localhost:3306/education"; // Change to your DB
            String dbUser = "root";
            String dbPassword = "root";

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            // Remove course from wishlist
            String sql = "DELETE FROM wishlist WHERE user_id = ? AND course_name = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setString(2, courseName);
            stmt.executeUpdate();

            // Redirect back to the wishlist page after removal
            response.sendRedirect("wishlist.jsp");
        } catch (Exception e) {
            e.printStackTrace(); // For debugging
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    } else {
        response.sendRedirect("wishlist.jsp");
    }
%>
