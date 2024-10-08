<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #490b3d;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 170vh; /* Ensure enough height */
        }

        .signup-container {
            background-color: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
            box-sizing: border-box;
        }

        .signup-container h2 {
            text-align: center;
            margin-bottom: 20px;
            color: #333;
            font-size: 24px;
        }

        form {
            display: flex;
            flex-direction: column;
        }

        .form-group {
            margin-bottom: 15px;
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-weight: bold;
            margin-bottom: 5px;
            color: #555;
        }

        .form-group input, select {
            width: 100%;
            padding: 10px;
            font-size: 14px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus, select:focus {
            border-color: #0066cc;
            outline: none;
        }

        .signup-btn {
            background-color: #f1b814;
            color: white;
            padding: 12px;
            font-size: 16px;
            width: 100%;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 10px;
            transition: background-color 0.3s ease;
        }

        .signup-btn:hover {
            background-color: #004080;
        }

        .login-link {
            text-align: center;
            margin-top: 15px;
            color: #555;
        }

        .login-link a {
            color: #0066cc;
            text-decoration: none;
        }

        .login-link a:hover {
            text-decoration: underline;
        }

        .form-group input::placeholder {
            color: #aaa;
        }
    </style>
</head>
<body>
    <div class="signup-container">
        <h2>Create an Account</h2>
        
        <% 
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String firstName = request.getParameter("first_name");
            String lastName = request.getParameter("last_name");
            String password = request.getParameter("password");
            String dob = request.getParameter("dob");
            String role = request.getParameter("role");
            String securityQuestion = request.getParameter("security_question");
            String securityAnswer = request.getParameter("security_answer");

            if (username != null && email != null && password != null && firstName != null && lastName != null && dob != null && role != null && securityQuestion != null && securityAnswer != null) {
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost/education", "root", "root");

                    // Insert user details into 'user' table
                    String sqlUser = "INSERT INTO user (username, email, password, first_name, last_name, role, dob) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement stmtUser = con.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
                    stmtUser.setString(1, username);
                    stmtUser.setString(2, email);
                    stmtUser.setString(3, password);
                    stmtUser.setString(4, firstName);
                    stmtUser.setString(5, lastName);
                    stmtUser.setString(6, role);
                    stmtUser.setDate(7, Date.valueOf(dob));

                    int rowsInserted = stmtUser.executeUpdate();

                    if (rowsInserted > 0) {
                        ResultSet generatedKeys = stmtUser.getGeneratedKeys();
                        if (generatedKeys.next()) {
                            int userId = generatedKeys.getInt(1);

                            // Insert security question and answer into 'user_security' table
                            String sqlSecurity = "INSERT INTO user_security (user_id, security_question, security_answer) VALUES (?, ?, ?)";
                            PreparedStatement stmtSecurity = con.prepareStatement(sqlSecurity);
                            stmtSecurity.setInt(1, userId);
                            stmtSecurity.setString(2, securityQuestion);
                            stmtSecurity.setString(3, securityAnswer);
                            stmtSecurity.executeUpdate();

                            response.sendRedirect("login.jsp");
                        }
                    } else {
                        out.println("<p style='text-align:center; color:red;'>Error during sign-up. Please try again.</p>");
                    }

                    con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<p style='text-align:center; color:red;'>Error: " + e.getMessage() + "</p>");
                }
            }
        %>
        
        <form action="signup.jsp" method="POST">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" placeholder="Enter your username" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" placeholder="Enter your email" required>
            </div>
            
            <div class="form-group">
                <label for="first_name">First Name</label>
                <input type="text" id="first_name" name="first_name" placeholder="Enter your first name" required>
            </div>
            
            <div class="form-group">
                <label for="last_name">Last Name</label>
                <input type="text" id="last_name" name="last_name" placeholder="Enter your last name" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Enter your password" required>
            </div>
            
            <div class="form-group">
                <label for="dob">Date of Birth</label>
                <input type="date" id="dob" name="dob" required>
            </div>
            
            <div class="form-group">
                <label for="role">Role</label>
                <input type="text" id="role" name="role" placeholder="Enter your role" required>
            </div>

            <div class="form-group">
                <label for="security_question">Security Question</label>
                <select id="security_question" name="security_question" required>
                    <option value="">Select a security question</option>
                    <option value="What was the name of your first pet?">What was the name of your first pet?</option>
                    <option value="What is your mother's maiden name?">What is your mother's maiden name?</option>
                    <option value="What is your favorite book?">What is your favorite book?</option>
                </select>
            </div>

            <div class="form-group">
                <label for="security_answer">Security Answer</label>
                <input type="text" id="security_answer" name="security_answer" placeholder="Enter your answer" required>
            </div>
            
            <button type="submit" class="signup-btn">Sign Up</button>
        </form>

        <div class="login-link">
            <p>Already have an account? <a href="login.jsp">Log in here</a></p>
        </div>
    </div>
</body>
</html>
