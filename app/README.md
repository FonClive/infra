# Portfolio Landing Page

Professional portfolio website showcasing DevOps & Cloud Engineering experience, built with Node.js and Express.

## About

This is a personal portfolio website for **Fon Clive Fon**, an AWS Solutions Architect and DevOps Engineer with 4+ years of experience in cloud infrastructure, Kubernetes, CI/CD, and automation.

## Features

- 🎨 Modern, responsive design
- 📱 Mobile-first approach
- 🚀 Fast and lightweight Express backend
- 🔒 Secure Docker containerization
- ✅ Automated testing with Jest
- 📊 SonarQube code quality analysis
- 🐳 Multi-stage Docker build
- ☁️ AWS ECR deployment via GitHub Actions

## Sections

- **Hero** - Introduction and call-to-action
- **About** - Professional summary and certifications
- **Skills** - Technical competencies across 6 categories
- **Experience** - Detailed work history with achievements
- **Projects** - Highlighted infrastructure and DevOps projects
- **Contact** - Contact information and location

## Local Development

### Prerequisites

- Node.js 18.x or higher
- npm or yarn

### Installation

```bash
cd app
npm install
```

### Running Locally

```bash
npm start
```

The application will be available at `http://localhost:3000`

### Running Tests

```bash
npm test
```

### Running with Docker

```bash
docker build -t portfolio-landing-page .
docker run -p 3000:3000 portfolio-landing-page
```

## CI/CD Pipeline

The GitHub Actions workflow automatically:

1. **Tests** the application with Jest and generates coverage reports
2. **Analyzes** code quality with SonarQube
3. **Builds** a Docker image with multi-stage optimization
4. **Scans** the image for vulnerabilities with Trivy
5. **Pushes** the image to AWS ECR
6. **Tags** the image with branch name, SHA, and latest (for main branch)

## Environment Variables

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment mode (development/production/test)

## GitHub Secrets Required

Configure these secrets in your GitHub repository:

- `AWS_ACCESS_KEY_ID` - AWS access key for ECR
- `AWS_SECRET_ACCESS_KEY` - AWS secret key for ECR
- `SONAR_TOKEN` - SonarQube authentication token
- `SONAR_HOST_URL` - SonarQube server URL

## Project Structure

```
app/
├── server.js           # Express server
├── public/            # Static assets
│   ├── index.html    # Portfolio page
│   └── styles.css    # Responsive styles
├── Dockerfile        # Multi-stage Docker build
├── package.json      # Dependencies
└── *.test.js         # Tests
```

## Technical Highlights

- **Infrastructure as Code**: Terraform, CloudFormation
- **Container Orchestration**: Kubernetes (EKS), Docker, Helm, ArgoCD
- **CI/CD**: Jenkins, GitHub Actions, GitLab CI
- **Monitoring**: Prometheus, Grafana, ELK Stack
- **Cloud Platforms**: AWS (EC2, VPC, RDS, S3, IAM, EKS)
- **Security**: IAM, NetworkPolicies, TLS, PCI DSS awareness

## Health Check

The application includes a health check endpoint at `/health` that returns:

```json
{
  "status": "healthy",
  "timestamp": "2026-08-05T20:00:00.000Z"
}
```

## Contact

**Fon Clive Fon**
- 📧 Email: chesterClive68@gmail.com
- 📱 Phone: +237 670493388
- 📍 Location: Bamenda, Cameroon

## License

MIT
