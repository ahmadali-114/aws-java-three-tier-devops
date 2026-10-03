package com.dpt.demo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Controller
public class login {
	private static final Logger LOGGER = LoggerFactory.getLogger(login.class);

	@Value("${spring.datasource.url}")
	private String url;

	@Value("${spring.datasource.username}")
	private String databaseUsername;

	@Value("${spring.datasource.password}")
	private String databasePassword;

	private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

	@RequestMapping(value = "login", method = RequestMethod.POST)
	public ModelAndView login(@RequestParam String userName, @RequestParam String password) {
		if (!userName.matches("[A-Za-z0-9_.-]{3,64}") || password.isBlank()) {
			return loginError("Enter a valid username and password.");
		}

		String query = "SELECT username, password_hash FROM employees WHERE username = ?";
		try (Connection connection = DatabaseConnectionFactory.open(url, databaseUsername, databasePassword);
				PreparedStatement statement = connection.prepareStatement(query)) {
			statement.setString(1, userName);

			try (ResultSet result = statement.executeQuery()) {
				if (result.next() && passwordEncoder.matches(password, result.getString("password_hash"))) {
					ModelAndView view = new ModelAndView("user");
					view.addObject("username", result.getString("username"));
					return view;
				}
			}
		} catch (SQLException exception) {
			LOGGER.warn("Login database operation failed (SQLState={}, errorCode={}): {}",
					exception.getSQLState(), exception.getErrorCode(), exception.getMessage());
			return loginError("Login is temporarily unavailable. Please try again later.");
		}

		return loginError("Invalid username or password.");
	}

	private ModelAndView loginError(String message) {
		ModelAndView view = new ModelAndView("login");
		view.addObject("errorMessage", message);
		return view;
	}

	@RequestMapping(value = "login", method = RequestMethod.GET)
	public ModelAndView loginForm() {
		return new ModelAndView("login");
	}
}
