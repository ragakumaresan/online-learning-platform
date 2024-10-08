<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    // Fetching logged-in user details from the session
    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");

    if (userId == null) {
        // Redirect to login if the user is not logged in
        response.sendRedirect("login.jsp");
        return;
    }

    String courseName = "TModern React with Redux [2024 Update]";
    String instructor = "Stephen Grider";

    String action = request.getParameter("action");
    String message = "";

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        // Database connection details
        String jdbcUrl = "jdbc:mysql://localhost:3306/education"; // Change to your DB
        String dbUser = "root";
        String dbPassword = "root";

        // Load MySQL JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

        // Check the action to perform
        if ("wishlist".equals(action)) {
            // Check if the course is already in the wishlist
            String checkSql = "SELECT COUNT(*) FROM wishlist WHERE user_id = ? AND course_name = ?";
            stmt = conn.prepareStatement(checkSql);
            stmt.setInt(1, userId);
            stmt.setString(2, courseName);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);

            if (count > 0) {
                message = "Course already in your wishlist.";
            } else {
                // Insert into wishlist
                String sql = "INSERT INTO wishlist (user_id, course_name) VALUES (?, ?)";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, userId);
                stmt.setString(2, courseName);
                stmt.executeUpdate();
                message = "Course added to your wishlist.";
            }
        } else if ("mylearning".equals(action)) {
            // Check if the course is already in My Learning
            String checkSql = "SELECT COUNT(*) FROM my_learning WHERE user_id = ? AND course_name = ?";
            stmt = conn.prepareStatement(checkSql);
            stmt.setInt(1, userId);
            stmt.setString(2, courseName);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);

            if (count > 0) {
                message = "Course already in your My Learning section.";
            } else {
                // Insert into My Learning
                String sql = "INSERT INTO my_learning (user_id, course_name) VALUES (?, ?)";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, userId);
                stmt.setString(2, courseName);
                stmt.executeUpdate();
                message = "Course added to your learning.";
            }
            // Redirect to start.jsp after processing
            response.sendRedirect("start.jsp?message=" + message);
            return; // Ensure no further processing
        }
    } catch (Exception e) {
        message = "An error occurred: " + e.getMessage();
        e.printStackTrace(); // Print the error for debugging
    } finally {
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }

    // Only render HTML if not redirecting
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= courseName %> by <%= instructor %></title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&family=Montserrat:wght@500&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            padding: 0;
            background-color: white; /* Background color */
        }
        .container {
            max-width: 1200px;
            margin: auto;
            display: flex;
            padding: 20px;
            opacity: 0; /* Start hidden for animation */
            animation: fadeIn 1s forwards; /* Fade-in animation */
        }
        @keyframes fadeIn {
            to {
                opacity: 1; /* Fade to visible */
            }
        }
        .content {
            flex: 3;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-right: 20px; /* Add some space between content and sidebar */
        }
        .sidebar {
            flex: 1;
            background: #490b3d; /* Sidebar color */
            color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        .header {
            text-align: center;
            padding: 20px;
            border-bottom: 2px solid #d76f30; /* Header border color */
            margin-bottom: 20px; /* Add spacing below header */
        }
        .header h1 {
            margin: 0;
            font-size: 2.5em;
            color: #490b3d; /* Heading color */
            background-color: white; /* Background color for the header */
            padding: 10px;
            border-radius: 5px;
            animation: slideIn 0.5s; /* Slide-in animation */
        }
        @keyframes slideIn {
            from {
                transform: translateY(-20px);
                opacity: 0; /* Start hidden */
            }
            to {
                transform: translateY(0);
                opacity: 1; /* Fade to visible */
            }
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
            background-color: #bd1e51; /* Background color for section headings */
            padding: 10px;
            border-radius: 5px;
            transition: background-color 0.3s; /* Smooth transition */
            animation: bounceIn 0.5s; /* Bounce-in animation */
        }
        @keyframes bounceIn {
            0% {
                transform: scale(0.5);
                opacity: 0; /* Start hidden */
            }
            50% {
                transform: scale(1.1); /* Bounce effect */
            }
            100% {
                transform: scale(1); /* Return to original size */
                opacity: 1; /* Fade to visible */
            }
        }
        .section h2:hover {
            background-color: #f1b814; /* Change color on hover */
        }
        ul {
            list-style-type: disc;
            margin-left: 20px;
        }
        button {
            padding: 10px;
            margin: 5px;
            cursor: pointer;
            background-color: #f1b814; /* Button color */
            color: white;
            border: none;
            border-radius: 5px;
            width: calc(100% - 12px);
            font-size: 16px;
            transition: background-color 0.3s, transform 0.2s; /* Added transform transition */
        }
        button:hover {
            background-color: #f1b814; /* Button hover color */
            transform: scale(1.05); /* Scale on hover */
        }
        .course-image {
            max-width: 100%;
            border-radius: 8px;
            margin-bottom: 15px;
            animation: zoomIn 0.5s; /* Zoom-in animation */
        }
        @keyframes zoomIn {
            from {
                transform: scale(0.9);
                opacity: 0; /* Start hidden */
            }
            to {
                transform: scale(1);
                opacity: 1; /* Fade to visible */
            }
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
            background-color: #d76f30; /* Vertical bar color */
            position: absolute;
            left: -10px; /* Adjust position */
            top: 0;
            border-radius: 5px;
        }
        /* Modal styles */
        .modal {
            display: none; /* Hidden by default */
            position: fixed; /* Stay in place */
            z-index: 1; /* Sit on top */
            left: 0;
            top: 0;
            width: 100%; /* Full width */
            height: 100%; /* Full height */
            overflow: auto; /* Enable scroll if needed */
            background-color: rgba(0, 0, 0, 0.4); /* Black w/ opacity */
        }

        .modal-content {
            background-color: #fefefe;
            margin: 15% auto; /* 15% from the top and centered */
            padding: 20px;
            border: 1px solid #888;
            width: 80%; /* Could be more or less, depending on screen size */
            animation: modalIn 0.5s; /* Modal animation */
        }
        @keyframes modalIn {
            from {
                transform: scale(0.8);
                opacity: 0; /* Start hidden */
            }
            to {
                transform: scale(1);
                opacity: 1; /* Fade to visible */
            }
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
        <% if (request.getParameter("message") != null) { %>
            var message = "<%= request.getParameter("message") %>";
            if (message === "Course already in your wishlist.") {
                alert(message); // Show alert if the course is already in the wishlist
            } else {
                modal.style.display = "block";
                document.getElementById("modalMessage").innerText = message;
            }
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

        <div class="section lesson">
    <h2>Course Content</h2>
    <ul>
        <li>
            <h3>Lesson 1: Introduction to HTML, CSS, and JavaScript</h3>
            <p><strong>Objective:</strong> Understand the basics of web development with HTML for structure, CSS for styling, and JavaScript for interactivity.</p>
            <p><strong>Topics:</strong></p>
            <ul>
                <li>Setting up a simple webpage.</li>
                <li>HTML elements and structure (headings, paragraphs, links, images, etc.).</li>
                <li>CSS styling basics (selectors, colors, fonts, margins, padding, etc.).</li>
                <li>JavaScript basics (variables, functions, loops, and DOM manipulation).</li>
            </ul>
            <p><strong>Project:</strong> Create a personal portfolio webpage.</p>
        </li>
        <li>
            <h3>Lesson 2: Responsive Design with CSS Grid and Flexbox</h3>
            <p><strong>Objective:</strong> Learn to make websites responsive using CSS Grid and Flexbox to ensure layouts adapt to various screen sizes.</p>
            <p><strong>Topics:</strong></p>
            <ul>
                <li>Introduction to responsive web design.</li>
                <li>Media queries for device-based styling.</li>
                <li>Building flexible layouts with Flexbox and CSS Grid.</li>
                <li>Best practices for mobile-first design.</li>
            </ul>
            <p><strong>Project:</strong> Build a responsive landing page for a product or service.</p>
        </li>
        <li>
            <h3>Lesson 3: Introduction to Frontend Frameworks: React.js</h3>
            <p><strong>Objective:</strong> Understand the basics of React.js to build dynamic, interactive user interfaces.</p>
            <p><strong>Topics:</strong></p>
            <ul>
                <li>Setting up a React project using <code>create-react-app</code>.</li>
                <li>React components, JSX, and props.</li>
                <li>State management and lifecycle methods.</li>
                <li>Introduction to React hooks (<code>useState</code>, <code>useEffect</code>).</li>
            </ul>
            <p><strong>Project:</strong> Build a to-do list app using React.js.</p>
        </li>
        <li>
            <h3>Lesson 4: Backend Development with Node.js and Express</h3>
            <p><strong>Objective:</strong> Learn server-side development using Node.js and Express.js to create a fully functional backend.</p>
            <p><strong>Topics:</strong></p>
            <ul>
                <li>Setting up a Node.js project.</li>
                <li>Introduction to Express for routing and handling HTTP requests.</li>
                <li>Connecting to a database (MongoDB, MySQL, etc.).</li>
                <li>Authentication and security basics (JWT, session management).</li>
            </ul>
            <p><strong>Project:</strong> Build a full-stack application (e.g., a blog platform) with a working backend, database, and user authentication.</p>
        </li>
    </ul>
</div>
       
        <div class="section requirements">
            <h2>Requirements</h2>
            <ul>
                <li>A computer with internet access</li>
                <li>No prior programming experience needed</li>
                <li>A desire to learn web development</li>
            </ul>
        </div>

        <div class="section outcomes">
            <h2>Expected Outcomes</h2>
            <ul>
                <li>Build dynamic and responsive websites using HTML, CSS, and JavaScript.</li>
                <li>Understand the fundamentals of backend development and APIs.</li>
                <li>Create and manage databases using MongoDB.</li>
                <li>Deploy web applications to cloud platforms.</li>
                <li>Gain practical experience through hands-on projects.</li>
                <li>Be prepared for a career in web development or enhance your current skill set.</li>
            </ul>
        </div>

        <div class="section description">
            <h2>Course Description</h2>
            <p>This comprehensive course will teach you everything you need to know to become a full-stack web developer. You will learn HTML, CSS, JavaScript, Node.js, React, Express.js, and MongoDB. Each module is designed to build upon the previous one, ensuring a smooth learning experience.</p>
            <p>Through hands-on projects and practical exercises, you will gain real-world skills that are in high demand in today's job market. Whether you are a complete beginner or looking to enhance your existing knowledge, this course is designed for you!</p>
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
            <img src="https://img-c.udemycdn.com/course/240x135/1565838_e54e_18.jpg" alt="Course Image" class="course-image">
            <h3><%= courseName %></h3>
            <h4>Instructor: <%= instructor %></h4>
            <form method="post" action="course.jsp">
                <input type="hidden" name="action" value="wishlist">
                <button type="submit">Add to Wishlist</button>
            </form>
            <form method="post" action="course.jsp">
                <input type="hidden" name="action" value="mylearning">
                <button type="submit">Start Learning</button>
            </form>
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
