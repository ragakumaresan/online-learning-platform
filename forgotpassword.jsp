<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password</title>
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
        .error {
            color: red;
            text-align: center;
        }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        button {
            width: 100%;
            padding: 10px;
            background-color: #f1b814;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        button:hover {
            background-color: #218838;
        }
        .login {
            text-align: center;
            margin-top: 15px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Forgot Password</h2>
        <form method="post" action="resetpassword.jsp">
            <input type="text" name="email" placeholder="Enter your email" required>
            
            <select name="security_question" required>
                <option value="">Select your security question</option>
                <option value="What was the name of your first pet?">What was the name of your first pet?</option>
                <option value="What is your mother's maiden name?">What is your mother's maiden name?</option>
                <option value="What is your favorite book?">What is your favorite book?</option>
            </select>
            
            <input type="text" name="security_answer" placeholder="Enter your answer" required>
            <input type="password" name="new_password" placeholder="Enter your new password" required>
            <button type="submit">Reset Password</button>
        </form>
    </div>
</body>
</html>
