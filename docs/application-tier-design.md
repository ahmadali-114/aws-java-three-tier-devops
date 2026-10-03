# Application Tier Design

The development application tier runs one Amazon Linux 2023 EC2 `t3.micro` instance. It is intentionally a learning-environment design, not a highly available production deployment.

## Bootstrap sequence

At launch, Terraform supplies a versioned `user_data` script. The script installs the Java 17 JDK, Maven, MariaDB client tools, AWS CLI dependencies, and Tomcat 9. It then clones the public repository and checks out an explicit Git commit SHA. Terraform records that revision as part of the instance configuration, reads the RDS-managed administrator secret using its instance IAM role, and initializes the application database only when the application credential secret is empty.

It creates the restricted `javaapp` database user and stores that password in the separate application secret. The Java process receives its database URL, username, and password through `/etc/java-3tier.env`; credentials are never committed to Git or Terraform variables.

The system Maven installation produces the WAR and deploys it as `ROOT.war` to Tomcat 9. The service is configured with a systemd drop-in so the environment file is available only to the Tomcat process.

The WAR has `spring-boot-starter-tomcat` with `provided` scope. Tomcat 9 supplies the JSP/Jasper engine at deployment time, so the project does not package a separate legacy `tomcat-jasper` dependency. This avoids version conflicts between the application archive and the operating system's Tomcat service.

## Why Tomcat 9

The application uses Spring Boot 2.7 and `javax.servlet` APIs. Tomcat 9 is compatible with those APIs. Tomcat 10+ uses the renamed Jakarta Servlet APIs and would require an application migration. Amazon Linux 2023 supplies the Tomcat 9 package as `tomcat9`, and its related service and webapp paths use the same name.

## Repair decision

The first instance bootstrap stopped because the script attempted to install a package named `tomcat`, which Amazon Linux 2023 does not provide. The Terraform source now installs `tomcat9` and uses its matching service and deployment paths.

The second bootstrap reached the build stage but stopped because `java-17-amazon-corretto-headless` provides a runtime but not the `javac` compiler. It also relied on Maven Wrapper files that are absent from this repository. The source now installs the Java 17 JDK package (`java-17-amazon-corretto-devel`) and the supported system Maven package, then runs `mvn` directly. This makes the build independent of missing wrapper files.

The third bootstrap reached Maven but found an incomplete legacy `tomcat-jasper` dependency in `pom.xml`: Maven requires every unmanaged dependency to declare a version. The dependency is unnecessary because this design deploys the WAR to an external Tomcat 9 service, which already includes Jasper. Removing it allows Maven to use the Spring Boot-managed, provided Tomcat API without bundling a conflicting server implementation.

`user_data_replace_on_change` is enabled, so applying this change replaces the failed instance with a new one that performs the corrected bootstrap from a clean state. The VPC, security groups, RDS instance, and Secrets Manager secret are not recreated. Because the application database secret was successfully initialized before the failed build, the next bootstrap reuses it rather than generating another application password.

## Release traceability

The application revision is an immutable Git commit SHA passed from the development environment into the application module. A new source commit alone does not change Terraform state; intentionally updating `repository_revision` changes the user-data content and creates a replacement instance. This gives the deployment an auditable source version and prevents an instance from silently deploying a different commit if `main` changes while it is bootstrapping. The bootstrap performs a full clone rather than a shallow clone because a pinned release can be older than the current branch tip; the selected commit must exist locally before Git can check it out.

## Verification after deployment

Use AWS Systems Manager Run Command to verify all of the following without opening SSH:

- `systemctl is-active tomcat9` returns `active`.
- `/var/lib/tomcat9/webapps/ROOT.war` exists.
- `curl -fsS http://localhost:8080/` returns the application response.
- The instance can read the application credential secret but has no unnecessary administrative permissions.
