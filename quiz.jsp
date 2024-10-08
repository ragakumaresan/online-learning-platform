<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test your Knowledge</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
        }
        h1 {
            color: #333;
        }
        form {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 600px;
            margin: auto;
        }
        .question {
            margin-bottom: 20px;
        }
        .question label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }
        .submit-btn {
            background-color: #4CAF50;
            color: white;
            border: none;
            padding: 10px 20px;
            cursor: pointer;
        }
        .submit-btn:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>

    <h1>Web Development Quiz</h1>

    <form action="result.jsp" method="post">
        <!-- Question 1: HTML -->
        <div class="question">
            <label for="q1">1. What does HTML stand for?</label>
            <input type="radio" name="q1" value="A" required> Hyper Text Markup Language<br>
            <input type="radio" name="q1" value="B"> Home Tool Markup Language<br>
            <input type="radio" name="q1" value="C"> Hyperlinks and Text Markup Language<br>
        </div>

        <!-- Question 2: CSS -->
        <div class="question">
            <label for="q2">2. Which property is used to change the background color in CSS?</label>
            <input type="radio" name="q2" value="A" required> bgcolor<br>
            <input type="radio" name="q2" value="B"> color<br>
            <input type="radio" name="q2" value="C"> background-color<br>
        </div>

        <!-- Question 3: JavaScript -->
        <div class="question">
            <label for="q3">3. How do you create a function in JavaScript?</label>
            <input type="radio" name="q3" value="A" required> function = myFunction()<br>
            <input type="radio" name="q3" value="B"> function myFunction()<br>
            <input type="radio" name="q3" value="C"> function:myFunction()<br>
        </div>

        <!-- Question 4: General -->
        <div class="question">
            <label for="q4">4. What does CSS stand for?</label>
            <input type="radio" name="q4" value="A" required> Creative Style Sheets<br>
            <input type="radio" name="q4" value="B"> Cascading Style Sheets<br>
            <input type="radio" name="q4" value="C"> Computer Style Sheets<br>
        </div>

        <!-- Question 5: Web Development -->
        <div class="question">
            <label for="q5">5. Which of the following is used to connect the front-end and back-end?</label>
            <input type="radio" name="q5" value="A" required> Database<br>
            <input type="radio" name="q5" value="B"> API<br>
            <input type="radio" name="q5" value="C"> CSS<br>
        </div>

        <input type="submit" class="submit-btn" value="Submit Quiz">
    </form>

</body>
</html>