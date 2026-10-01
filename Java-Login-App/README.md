# Java Login Application

This is the application tier for the AWS three-tier deployment. It is packaged as a WAR and deployed to Apache Tomcat on EC2.

## Runtime configuration

The application requires these environment variables at runtime:

```text
DB_URL=jdbc:mysql://<private-rds-endpoint>:3306/javaapp
DB_USERNAME=<database-username>
DB_PASSWORD=<database-password>
```

No database endpoint or credentials belong in `application.properties`, source code, Maven settings, or GitHub.

## Database schema

Run `../database/schema.sql` against the RDS `javaapp` database before accepting user registrations.

## Security controls

- Parameterized `PreparedStatement` queries prevent SQL injection.
- BCrypt hashes passwords before they are stored.
- Login checks the BCrypt hash rather than comparing plain-text passwords.
- Browser responses do not expose database error details.
- The application uses the current MySQL Connector/J driver class: `com.mysql.cj.jdbc.Driver`.
