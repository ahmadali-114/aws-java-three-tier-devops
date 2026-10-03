package com.dpt.demo;

import java.sql.Connection;
import java.sql.PreparedStatement;
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
public class register {
	private static final Logger LOGGER = LoggerFactory.getLogger(register.class);

	@Value("${spring.datasource.url}")
	private String url;

	@Value("${spring.datasource.username}")
	private String databaseUsername;

	@Value("${spring.datasource.password}")
	private String databasePassword;

	private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

	@RequestMapping(value = "register", method = RequestMethod.GET)
	public ModelAndView registerForm() {
		return new ModelAndView("register");
	}

	@RequestMapping(value = "register", method = RequestMethod.POST)
	public ModelAndView register(@RequestParam String firstName, @RequestParam String lastName,
			@RequestParam String email, @RequestParam String userName, @RequestParam String password) {
		if (firstName.isBlank() || lastName.isBlank() || !email.contains("@")
				|| !userName.matches("[A-Za-z0-9_.-]{3,64}") || password.length() < 12) {
			return registrationResult("Enter all fields, a valid username, and a password of at least 12 characters.");
		}

		String sql = "INSERT INTO employees (first_name, last_name, email, username, password_hash) VALUES (?, ?, ?, ?, ?)";
		try (Connection connection = DatabaseConnectionFactory.open(url, databaseUsername, databasePassword);
				PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setString(1, firstName);
			statement.setString(2, lastName);
			statement.setString(3, email);
			statement.setString(4, userName);
			statement.setString(5, passwordEncoder.encode(password));
			statement.executeUpdate();
			return registrationResult("Account created. You can now sign in.");
		} catch (SQLException exception) {
			LOGGER.warn("Registration database operation failed (SQLState={}, errorCode={}): {}",
					exception.getSQLState(), exception.getErrorCode(), exception.getMessage());
			return registrationResult("Account could not be created. The username or email may already exist.");
		}
	}

	private ModelAndView registrationResult(String message) {
		ModelAndView view = new ModelAndView("register");
		view.addObject("message", message);
		return view;
	}
}
