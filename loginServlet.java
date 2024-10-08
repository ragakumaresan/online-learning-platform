import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class loginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action"); // Detect if this is login or forgot password action
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Database connection
        String jdbcUrl = "jdbc:mysql://localhost:3306/education"; // Update your database URL
        String dbUser = "root"; // Update your database username
        String dbPassword = "root"; // Update your database password

        if ("forgot_password".equals(action)) {
            // Handle forgot password
            String email = request.getParameter("email");

            try (Connection connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword)) {
                String sql = "SELECT id FROM user WHERE email = ?";
                PreparedStatement statement = connection.prepareStatement(sql);
                statement.setString(1, email);
                ResultSet resultSet = statement.executeQuery();

                if (resultSet.next()) {
                    // Redirect to the security questions page
                    HttpSession session = request.getSession();
                    session.setAttribute("userEmail", email); // Store email for further processing
                    response.sendRedirect("reset_password.jsp");
                } else {
                    response.sendRedirect("forgot_password.jsp?error=Email not found");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

        } else {
            // Handle login action
            try (Connection connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword)) {
                String sql = "SELECT * FROM user WHERE username = ? AND password = ?";
                PreparedStatement statement = connection.prepareStatement(sql);
                statement.setString(1, username);
                statement.setString(2, password);
                ResultSet resultSet = statement.executeQuery();

                if (resultSet.next()) {
                    // User found, create session
                    HttpSession userSession = request.getSession();
                    userSession.setAttribute("userId", resultSet.getInt("id"));
                    userSession.setAttribute("username", resultSet.getString("username"));
                    userSession.setAttribute("email", resultSet.getString("email"));

                    // Redirect to My Account page
                    response.sendRedirect("myaccount.jsp");
                } else {
                    // Invalid credentials
                    response.sendRedirect("login.jsp?error=Invalid credentials");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
