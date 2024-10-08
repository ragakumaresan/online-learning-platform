<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Invalidate the session to log the user out
    request.getSession().invalidate();

    // Redirect to the home page or login page
    response.sendRedirect("home.html"); // Change this to your desired redirection page
%>
