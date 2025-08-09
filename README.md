# 🚀 CI pipeline with  Automated Semantic Versioning with Jenkins for Spring Boot App


This project demonstrates a Jenkins pipeline that automates Semantic Versioning (SemVer) for a Spring Boot application. The pipeline enables controlled, consistent, and automated version management, ensuring that every release follows the SemVer standard (major.minor.patch). 

## 🧰 Stack Used

- **CI/CD Tools**: Jenkins, GitHub, Maven
- **Containers**: Docker

## ✨ Key Features

- **Automated SemVer Bumping:**  
  Select the type of version bump (`major`, `minor`, or `patch`) as a parameter at build time. The pipeline automatically updates the Maven `pom.xml` version.

- **Branch Protection:**  
  Releases can only be triggered from the `master` or `main` branch, enforcing best practices for production releases.

- **Automated Git Tagging:**  
  Optionally creates and pushes a Git tag for each release, making it easy to track and roll back versions.

- **Docker Image Build & Push:**  
  Builds a Docker image for the new version and pushes it to a Docker registry, ensuring that each release is containerized and ready for deployment.

- **Secure Credential Management:**  
  Uses Jenkins credentials for secure Docker and Git operations.

- **Clean Workspace:**  
  Cleans up the Jenkins workspace and logs out from Docker after each build.


## ⚙️ How It Works

1. **Pre-Release Check:**  
   Ensures the pipeline is running on the correct branch and retrieves the current project version.

2. **Version Increment:**  
   Based on the selected parameter (`major`, `minor`, or `patch`), the pipeline calculates and sets the new version using Maven plugins.

3. **Build Artifacts:**  
   Compiles and packages the Spring Boot application.

4. **Docker Build & Push:**  
   Builds a Docker image tagged with the new version and pushes it to the specified Docker registry.

5. **Git Commit & Tag:**  
   Commits the updated `pom.xml` and optionally creates a Git tag for the release, pushing changes back to the repository.

6. **Post Actions:**  
   Cleans up the workspace and provides a summary of the release.

## 📋 Pipeline Parameters

- `VERSION_TYPE` : Select the type of version bump (`major`, `minor`, `patch`)
- `CREATE_TAG` : Boolean to create a Git tag for the release