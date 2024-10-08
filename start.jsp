<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page import="java.util.ArrayList, java.util.List" %>
<%@ page import="java.net.URLEncoder" %>


<%
    // Retrieve session attributes
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Retrieve courseId from request parameters
    String courseIdParam = request.getParameter("id");
    if (courseIdParam == null || courseIdParam.trim().isEmpty()) {
        response.sendRedirect("courses.jsp");
        return;
    }

    Integer courseId = null;
    try {
        courseId = Integer.parseInt(courseIdParam);
    } catch (NumberFormatException e) {
        response.sendRedirect("course.jsp");
        return;
    }

    String courseName = "", instructor = "", description = "", requirements = "", outcomes = "", imageUrl = "", message = "";
    String selectedLesson = request.getParameter("lesson");
    String videoSrc = "";
    String action = request.getParameter("action") != null ? request.getParameter("action") : "";

    String note = "";
    String noteId = "";
    List<String> postedQuestions = new ArrayList<>();
    boolean isLessonCompleted = false;
    int currentLessonIndex = -1;
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    List<String[]> lessons = new ArrayList<>();

    try {
        String jdbcUrl = "jdbc:mysql://localhost:3306/education";
        String dbUser = "root";
        String dbPassword = "root";

        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

        // Fetch course details
        String courseSql = "SELECT course_name, instructor, description, requirements, outcomes, image_url FROM courses WHERE course_id = ?";
        stmt = conn.prepareStatement(courseSql);
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
        rs.close();
        stmt.close();

        // Fetch lessons
        String lessonsSql = "SELECT l.lesson_id, l.lesson_title, lv.video_url FROM lessons l " +
                            "LEFT JOIN lesson_videos lv ON l.lesson_id = lv.lesson_id " +
                            "WHERE l.course_id = ? ORDER BY l.lesson_order";
        stmt = conn.prepareStatement(lessonsSql);
        stmt.setInt(1, courseId);
        rs = stmt.executeQuery();
        while (rs.next()) {
            int lessonId = rs.getInt("lesson_id");
            String lessonTitle = rs.getString("lesson_title");
            String videoUrl = rs.getString("video_url") != null ? rs.getString("video_url") : "";
            lessons.add(new String[]{String.valueOf(lessonId), lessonTitle, videoUrl});
        }
        rs.close();
        stmt.close();

        // Handle lesson selection and fetch video
        if (selectedLesson != null && !selectedLesson.trim().isEmpty()) {
            for (String[] lesson : lessons) {
                if (lesson[1].equals(selectedLesson)) {
                    videoSrc = lesson[2];
                    break;
                }
            }
        }

     // Fetch existing note
        String fetchSql = "SELECT note, id FROM notes WHERE user_id = ? AND course_name = ?";
        stmt = conn.prepareStatement(fetchSql);
        stmt.setInt(1, userId);
        stmt.setString(2, courseName);
        rs = stmt.executeQuery();
        if (rs.next()) {
            note = rs.getString("note");
            noteId = rs.getString("id");
        }

        // Save note
        if ("saveNote".equals(action)) {
            String noteText = request.getParameter("noteText");
            if (noteText != null) {
                String saveSql;
                if (noteId != null && !noteId.isEmpty()) {
                    saveSql = "UPDATE notes SET note = ? WHERE id = ?";
                    stmt = conn.prepareStatement(saveSql);
                    stmt.setString(1, noteText);
                    stmt.setInt(2, Integer.parseInt(noteId));
                    message = "Note updated successfully!";
                } else {
                    saveSql = "INSERT INTO notes (user_id, course_name, note) VALUES (?, ?, ?)";
                    stmt = conn.prepareStatement(saveSql);
                    stmt.setInt(1, userId);
                    stmt.setString(2, courseName);
                    stmt.setString(3, noteText);
                    message = "Note saved successfully!";
                }
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected == 0) {
                    message = "No changes made to the note.";
                }
            } else {
                message = "Note text cannot be empty!";
            }
        }


     // Save question
        if ("postQuestion".equals(action)) {
            String question = request.getParameter("questionText");
            if (question != null && !question.trim().isEmpty()) {
                String insertQuestionSql = "INSERT INTO questions (user_id, course_name, question) VALUES (?, ?, ?)";
                stmt = conn.prepareStatement(insertQuestionSql);
                stmt.setInt(1, userId);
                stmt.setString(2, courseName);
                stmt.setString(3, question);
                int rowsAffected = stmt.executeUpdate();
                message = (rowsAffected > 0) ? "Question posted successfully!" : "Failed to post question.";
            } else {
                message = "Question cannot be empty!";
            }
        }

        // Fetch posted questions
        String fetchQuestionsSql = "SELECT question FROM questions WHERE user_id = ? AND course_name = ?";
        stmt = conn.prepareStatement(fetchQuestionsSql);
        stmt.setInt(1, userId);
        stmt.setString(2, courseName);
        ResultSet questionRs = stmt.executeQuery();
        while (questionRs.next()) {
            postedQuestions.add(questionRs.getString("question"));
        }
        if ("markComplete".equals(action)) {
            String upsertSql = "INSERT INTO user_courses (user_id, course_name, lesson_name, progress) VALUES (?, ?, ?, 25) ON DUPLICATE KEY UPDATE progress = 25";
            stmt = conn.prepareStatement(upsertSql);
            stmt.setInt(1, userId);
            stmt.setString(2, courseName);
            stmt.setString(3, selectedLesson);
            stmt.executeUpdate();
            message = "Lesson marked as complete!";
            isLessonCompleted = true;
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Learning</title>
    <style>
        body { font-family: 'Helvetica Neue', sans-serif; margin: 0; padding: 0; background-color: #f0f4f8; }
        .container { display: flex; }
        .sidebar { width: 250px; background: white; color: black; padding: 20px; box-shadow: 2px 0 5px rgba(0,0,0,0.2); }
        .sidebar h3 { margin-top: 0; color:black; }
        .sidebar a { color: black; text-decoration: none; }
        .sidebar a:hover { text-decoration: underline; }
        .content { flex: 1; padding: 20px; }
        .header { background-color: #8e44ad; color: white; padding: 15px; text-align: center; border-radius: 5px; }
        .lesson-title { font-size: 24px; margin: 15px 0; }
        .video-container { margin-top: 20px; }
        .actions { display: flex; justify-content: space-between; margin-top: 20px; }
        .action-button { padding: 10px; cursor: pointer; background-color: #f39c12; color: white; border: none; border-radius: 5px; transition: background-color 0.3s; }
        .action-button:hover { background-color: #e67e22; }
        .note-box, .question-box, .posted-questions { margin-top: 20px; padding: 15px; border: 1px solid #bdc3c7; border-radius: 5px; background: white; }
        textarea { width: 100%; padding: 10px; border-radius: 5px; border: 1px solid #bdc3c7; resize: none; }
        .posted-questions ul { padding-left: 20px;
         }
         .course-image {
            max-width: 100%;
            border-radius: 8px;
            margin-bottom: 15px;
            animation: zoomIn 0.5s;
            }
        
        /* New CSS for options */
        .options {
            display: flex;
            justify-content: space-around; /* Space items evenly */
            margin: 20px 0; /* Add some margin */
        }
        .option-button {
            padding: 10px 15px; /* Add some padding */
            text-decoration: none; /* Remove underline */
            color: #8e44ad; /* Change text color */
            font-weight: bold; /* Make text bold */
            transition: color 0.3s; /* Smooth color transition on hover */
        }
        .option-button:hover {
            color: #6c3483; /* Change color on hover */
        }
       
        
    </style>
    <script>

function toggleVisibility(sectionId) {
    // Hide all sections
    const sections = ['noteSection', 'questionSection', 'quizSection'];
    sections.forEach(id => {
        document.getElementById(id).style.display = 'none';
    });
    // Show the selected section
    document.getElementById(sectionId).style.display = 'block';
}

// Ensure to show the notes section by default
window.onload = function() {
    toggleVisibility('noteSection');
}
</script>
</head>
<body>

<div class="container">
    <div class="sidebar">
     <!-- Return to Home Page link -->
    <div class="hbutton">
        <center><a href="account.html" class="action-button">Return to Home Page</a></center>
    </div></br><br>
     <img src="<%= imageUrl %>" alt="Course Image"  class="course-image"/>
        <h3>Lessons</h3>
        <ul>
            <%
                for (String[] lesson : lessons) {
                    String lessonTitle = lesson[1];
                    String lessonVideoUrl = lesson[2];
                    out.print("<li><a href=\"start.jsp?id=" + courseId + "&lesson=" + URLEncoder.encode(lessonTitle, "UTF-8") + "\">" + lessonTitle + "</a></li>");
                }
            %>
        </ul>
    </div>

    <div class="content">
        <div class="header">
            <h1><%= courseName %></h1>
             <p>Instructor: <%= instructor %></p>
        </div>

       
<% if (!videoSrc.isEmpty()) { %>
<div class="video-container">
<%
        if (!videoSrc.isEmpty()) {
            out.print("<iframe width='560' height='315' src='" + videoSrc + "' frameborder='0' allowfullscreen></iframe>");
        } else {
            out.print("<p>No video available for this lesson.</p>");
        }
    %>
</div>

            <div class="actions">
                <form method="post">
                    <input type="hidden" name="action" value="markComplete">
                    <input type="hidden" name="lesson" value="<%= selectedLesson %>">
                    <button class="action-button" type="submit" <%= isLessonCompleted ? "disabled" : "" %>><%= isLessonCompleted ? "Lesson Completed" : "Mark as Complete" %></button>
                </form>
            </div>
        <% } %>
  

       
<div class="options">
    <a href="javascript:void(0);" class="option-button" onclick="toggleVisibility('noteSection')">Take Notes</a>
    <a href="javascript:void(0);" class="option-button" onclick="toggleVisibility('questionSection')">Post Questions</a>
    <a href="javascript:void(0);" class="option-button" onclick="toggleVisibility('quizSection')">Take Quiz</a>
</div>

<div id="noteSection" class="note-box hidden">
    <h3>Your Note</h3>
    <form method="post">
        <textarea name="noteText" rows="5"><%= note != null ? note : "" %></textarea>
        <input type="hidden" name="action" value="saveNote">
        <button class="action-button" type="submit">Save Note</button>
    </form>
    <% if (!message.isEmpty()) { %>
        <p><%= message %></p>
    <% } %>
</div>

<div id="questionSection" class="question-box hidden">
    <h3>Post a Question</h3>
    <form method="post">
        <textarea name="questionText" rows="3" placeholder="Ask your question here..."></textarea>
        <input type="hidden" name="action" value="postQuestion">
        <button class="action-button" type="submit">Post Question</button>
    </form>
    <% if (!message.isEmpty()) { %>
        <p><%= message %></p>
    <% } %>
 <div>
            <h3>Posted Questions</h3>
            
            <ul>
                <% for (String question : postedQuestions) { %>
                    <li><%= question %></li>
                <% } %>
            </ul>
        </div>
        </div>

<div id="quizSection" class="quiz-box hidden">
    <h3><a href="quiz.jsp">Take a Quiz</h3></a>
    <p>This is where the quiz will go.</p>
</div>

    </div>
</div>




</body>
</html>
