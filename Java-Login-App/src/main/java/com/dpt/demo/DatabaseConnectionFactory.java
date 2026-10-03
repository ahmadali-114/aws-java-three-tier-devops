package com.dpt.demo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

final class DatabaseConnectionFactory {

	private DatabaseConnectionFactory() {
	}

	static Connection open(String url, String username, String password) throws SQLException {
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
		} catch (ClassNotFoundException exception) {
			throw new SQLException("MySQL JDBC driver is not available to the application.", "08001", exception);
		}

		return DriverManager.getConnection(url, username, password);
	}
}
