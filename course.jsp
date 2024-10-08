<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*, java.util.ArrayList" %>
<%
    // Retrieve session attributes
    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String courseIdParam = request.getParameter("id");
    String action = request.getParameter("action");
    Integer courseId = (courseIdParam != null) ? Integer.parseInt(courseIdParam) : 1;

    // Redirect to login if user is not authenticated
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Initialize variables
    String courseName = "", instructor = "", description = "", requirements = "", outcomes = "", imageUrl = "", message = "";
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    ArrayList<String> reviews = new ArrayList<>();
    ArrayList<String> lessons = new ArrayList<>();

    try {
        // Database connection setup
        String jdbcUrl = "jdbc:mysql://localhost:3306/education";
        String dbUser = "root";
        String dbPassword = "root";

        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

        // Fetch course details
        String sql = "SELECT course_name, instructor, description, requirements, outcomes, image_url FROM courses WHERE course_id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, courseId);
        rs = stmt.executeQuery();

        if (rs.next()) {
            courseName = rs.getString("course_name");
            instructor = rs.getString("instructor");
            description = rs.getString("description");
            requirements = rs.getString("requirements");
            outcomes = rs.getString("outcomes");
            imageUrl = rs.getString("image_url");
        } else {
            message = "Course not found.";
        }

        // Fetch lessons
        String lessonSql = "SELECT lesson_title, lesson_description, lesson_objective, lesson_topics, lesson_project FROM lessons WHERE course_id = ? ORDER BY lesson_order";
        try (PreparedStatement lessonStmt = conn.prepareStatement(lessonSql)) {
            lessonStmt.setInt(1, courseId);
            try (ResultSet lessonRs = lessonStmt.executeQuery()) {
                while (lessonRs.next()) {
                    String lessonTitle = lessonRs.getString("lesson_title");
                    String lessonDescription = lessonRs.getString("lesson_description");
                    String objective = lessonRs.getString("lesson_objective");
                    String topics = lessonRs.getString("lesson_topics");
                    String project = lessonRs.getString("lesson_project");

                    lessons.add("<strong>" + lessonTitle + "</strong>" +
                        "<p>Description: " + lessonDescription + "</p>" +
                        "<p><em>Objective:</em><ul><li>" + objective.replace(". ", "</li><li>") + "</li></ul></p>" +
                        "<p><em>Topics:</em><ul><li>" + topics.replace(". ", "</li><li>") + "</li></ul></p>" +
                        "<p><em>Project:</em><ul><li>" + project.replace(". ", "</li><li>") + "</li></ul></p><hr>");
                }
            }
        }

        // Fetch reviews
        String reviewSql = "SELECT review_text, reviewer_name FROM reviews WHERE course_id = ?";
        try (PreparedStatement reviewStmt = conn.prepareStatement(reviewSql)) {
            reviewStmt.setInt(1, courseId);
            try (ResultSet reviewRs = reviewStmt.executeQuery()) {
                while (reviewRs.next()) {
                    String reviewText = reviewRs.getString("review_text");
                    String reviewerName = reviewRs.getString("reviewer_name");
                    reviews.add("<strong>" + reviewerName + "</strong><p>" + reviewText + "</p>");
                }
            }
        }

        // Handle "Add to Wishlist" action
        if ("wishlist".equals(action) && courseId != null) {
            String checkSql = "SELECT COUNT(*) FROM wishlist WHERE user_id = ? AND course_name = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, userId);
                checkStmt.setString(2, courseName);
                ResultSet rsCheck = checkStmt.executeQuery();
                rsCheck.next();
                int count = rsCheck.getInt(1);

                if (count > 0) {
                    message = "Course already in your wishlist.";
                } else {
                    String sqlInsert = "INSERT INTO wishlist (user_id, course_name) VALUES (?, ?)";
                    try (PreparedStatement insertStmt = conn.prepareStatement(sqlInsert)) {
                        insertStmt.setInt(1, userId);
                        insertStmt.setString(2, courseName);
                        insertStmt.executeUpdate();
                        message = "Course added to your wishlist.";
                    }
                }
            }
        }
        // Handle "Start Learning" action
        else if ("mylearning".equals(action)) {
            String checkLearningSql = "SELECT COUNT(*) FROM my_learning WHERE user_id = ? AND course_name = ?";
            try (PreparedStatement checkLearningStmt = conn.prepareStatement(checkLearningSql)) {
                checkLearningStmt.setInt(1, userId);
                checkLearningStmt.setString(2, courseName);
                try (ResultSet rsLearningCheck = checkLearningStmt.executeQuery()) {
                    rsLearningCheck.next();
                    int count = rsLearningCheck.getInt(1);

                    if (count > 0) {
                        message = "You have already started this course.";
                        response.sendRedirect("start.jsp?id=" + courseId);
                        return;
                    } else {
                        String sqlLearningInsert = "INSERT INTO my_learning (user_id, course_name) VALUES (?, ?)";
                        try (PreparedStatement insertLearningStmt = conn.prepareStatement(sqlLearningInsert)) {
                            insertLearningStmt.setInt(1, userId);
                            insertLearningStmt.setString(2, courseName);
                            insertLearningStmt.executeUpdate();
                            message = "You have started learning this course.";
                            response.sendRedirect("start.jsp?id=" + courseId);
                            return;
                        }
                        
                    }
                }
            }
        }
    } catch (Exception e) {
        message = "An error occurred: " + e.getMessage();
        e.printStackTrace();
    } finally {
        // Close resources
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= courseName %> by <%= instructor %></title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&family=Montserrat:wght@500&display=swap" rel="stylesheet">
    <style>
        /* Your existing CSS styles */
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            padding: 0;
            background-color: white;
        }
        .container {
            max-width: 1200px;
            margin: auto;
            display: flex;
            padding: 20px;
            opacity: 0;
            animation: fadeIn 1s forwards;
        }
        @keyframes fadeIn {
            to { opacity: 1; }
        }
        .content {
            flex: 3;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-right: 20px;
        }
        .sidebar {
            flex: 1;
            background: #490b3d;
            color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            position: relative; /* Needed for the vertical bar */
        }
        .header {
            text-align: center;
            padding: 20px;
            border-bottom: 2px solid #d76f30;
            margin-bottom: 20px;
        }
        .header h1 {
            margin: 0;
            font-size: 2.5em;
            color: #490b3d;
            background-color: white;
            padding: 10px;
            border-radius: 5px;
            animation: slideIn 0.5s;
        }
        @keyframes slideIn {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .header h3 {
            font-size: 1.5em;
            margin: 5px 0;
            color: #666;
        }
        .header p {
            margin: 5px 0;
            font-size: 1em;
            color: #999;
        }
        .section {
            margin: 30px 0;
        }
        .section h2 {
            font-size: 1.8em;
            margin-bottom: 10px;
            color: white;
            background-color: #bd1e51;
            padding: 10px;
            border-radius: 5px;
            transition: background-color 0.3s;
            animation: bounceIn 0.5s;
        }
        @keyframes bounceIn {
            0% { transform: scale(0.5); opacity: 0; }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); opacity: 1; }
        }
        .section h2:hover {
            background-color: #f1b814;
        }
        ul {
            list-style-type: disc;
            margin-left: 20px;
        }
        button {
            padding: 10px;
            margin: 5px;
            cursor: pointer;
            background-color: #f1b814;
            color: white;
            border: none;
            border-radius: 5px;
            width: calc(100% - 12px);
            font-size: 16px;
            transition: background-color 0.3s, transform 0.2s;
        }
        button:hover {
            background-color: #f1b814;
            transform: scale(1.05);
        }
        .course-image {
            max-width: 100%;
            border-radius: 8px;
            margin-bottom: 15px;
            animation: zoomIn 0.5s;
        }
        @keyframes zoomIn {
            from { transform: scale(0.9); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        .sidebar-content {
            text-align: center;
        }
        /* Vertical Bar */
        .sidebar::before {
            content: "";
            display: block;
            height: 100%;
            width: 5px;
            background-color: #d76f30;
            position: absolute;
            left: -10px;
            top: 0;
            border-radius: 5px;
        }
        /* Modal styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.4);
        }
        .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            animation: modalIn 0.5s;
        }
        @keyframes modalIn {
            from { transform: scale(0.8); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }
        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }
    </style>
    <script>
    window.onload = function() {
        var modal = document.getElementById("myModal");
        <% if (message != null && !message.isEmpty()) { %>
            // Display appropriate messages based on action
            if (message === "Course already in your wishlist.") {
                alert(message);
            } else if (message === "Course added to your wishlist.") {
                modal.style.display = "block";
                document.getElementById("modalMessage").innerText = message;
            } else if (message === "You have already started this course.") {
                alert(message);
            } else if (message === "You have started learning this course.") {
                modal.style.display = "block";
                document.getElementById("modalMessage").innerText = message;
            } else {
                alert(message);
            }

            // Close modal functionality
            var span = document.getElementsByClassName("close")[0];
            span.onclick = function() {
                modal.style.display = "none";
            }
            window.onclick = function(event) {
                if (event.target == modal) {
                    modal.style.display = "none";
                }
            }
        <% } %>
    };
    </script>
</head>
<body>

<div class="container">
    <div class="content">
        <div class="header">
            <h1 class="course-title"><%= courseName %></h1>
            <h3 class="instructor">Instructor: <%= instructor %></h3>
            <p>Bestseller | 1,346,402 students | Last updated: 08/2024</p>
            <p>Languages: English, Arabic [Auto]</p>
        </div>
        <div class="section lessons">
            <h2>Course Lessons</h2>
            <ul>
                <%
                    for (String lesson : lessons) {
                        out.println("<li class='lesson-box'>");
                        out.println(lesson); // Assuming lesson already includes HTML for description, objective, topics, and project.
                        out.println("</li>");
                    }
                %>
            </ul>
        </div>
             
       <div class="section description">
    <h2>Course Description</h2>
    <ul>
        <%
            if(description != null && !description.isEmpty()){
                // Split the description into points based on period followed by space
                String[] descPoints = description.split("\\. ");
                for(String point : descPoints){
                    // Add back the period if it was removed during splitting
                    if(!point.endsWith(".")){
                        point += ".";
                    }
                    // Trim any leading/trailing whitespace and print as list item
                    out.println("<li>" + point.trim() + "</li>");
                }
            }
        %>
    </ul>
</div>
       
        <div class="section requirements">
    <h2>Requirements</h2>
    <ul>
        <%
            if(requirements != null && !requirements.isEmpty()){
                String[] reqPoints = requirements.split("\\. ");
                for(String point : reqPoints){
                    if(!point.endsWith(".")){
                        point += ".";
                    }
                    out.println("<li>" + point.trim() + "</li>");
                }
            }
        %>
    </ul>
</div>
        

       <div class="section outcomes">
    <h2>Expected Outcomes</h2>
    <ul>
        <%
            if(outcomes != null && !outcomes.isEmpty()){
                String[] outPoints = outcomes.split("\\. ");
                for(String point : outPoints){
                    if(!point.endsWith(".")){
                        point += ".";
                    }
                    out.println("<li>" + point.trim() + "</li>");
                }
            }
        %>
    </ul>
</div>
       

               <div class="section reviews">
            <h2>Reviews and Ratings</h2>
            <div class="review-box">
                <div class="rating">★★★★☆</div>
                <p>"Great course! Learned a lot about web development and how to apply it in real-world projects."</p>
            </div>
            <div class="review-box">
                <div class="rating">★★★★★</div>
                <p>"Excellent instructor and very easy to follow. Highly recommend!"</p>
            </div>
            <div class="review-box">
                <div class="rating">★★★★☆</div>
                <p>"The hands-on projects were very beneficial. I feel confident in my skills now!"</p>
            </div>
            <div class="review-box">
                <div class="rating">★★★★★</div>
                <p>"This course exceeded my expectations. The material was well-organized and engaging."</p>
            </div>
        </div>
    </div>
   

    <div class="sidebar">
        <div class="sidebar-content">
            <img src="<%= imageUrl %>" alt="Course Image" class="course-image">
            <h3><%= courseName %></h3>
            <h4>Instructor: <%= instructor %></h4>
            
            <!-- Add to Wishlist Form -->
            <form method="post" action="course.jsp?id=<%= courseId %>">
                <input type="hidden" name="id" value="<%= courseId %>">
                <input type="hidden" name="action" value="wishlist">
                <button type="submit">Add to Wishlist</button>
            </form>
            
            <!-- Start Learning Form -->
            <!-- Start Learning Form -->
<form method="post" action="course.jsp?id=<%= courseId %>">
    <input type="hidden" name="id" value="<%= courseId %>">
    <input type="hidden" name="action" value="mylearning">
    <button type="submit">Start Learning</button>
</form>
            
            
            <!-- Return to Home Page Form -->
            <form method="get" action="account.html"> <!-- Adjust the action to your actual home page URL -->
                <button type="submit">Return to Home Page</button>
            </form>
        </div>
    </div>
</div>

<!-- Modal -->
<div id="myModal" class="modal">
    <div class="modal-content">
        <span class="close">&times;</span>
        <p id="modalMessage"><%= message %></p>
    </div>
</div>

</body>
</html>
