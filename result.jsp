<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz Result</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
        }
        h1 {
            color: #333;
        }
        .result-box {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 600px;
            margin: auto;
        }
    </style>
</head>
<body>

    <h1>Your Quiz Result</h1>

    <div class="result-box">
        <%
            int score = 0;
            String[] correctAnswers = {"A", "C", "B", "B", "B"};

            for (int i = 1; i <= correctAnswers.length; i++) {
                String answer = request.getParameter("q" + i);
                if (answer != null && answer.equals(correctAnswers[i - 1])) {
                    score++;
                }
            }
        %>

        <p>Your score: <%= score %> / 5</p>

        <%
            if (score == 5) {
                out.print("<p>Excellent! You know your web development very well!</p>");
            } else if (score >= 3) {
                out.print("<p>Good job! Keep learning!</p>");
            } else {
                out.print("<p>Don't worry, you can always improve with more practice!</p>");
            }
        %>
    </div>

</body>
</html>