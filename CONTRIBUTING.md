# Contributing to Mobility Ops 360

Thank you for your interest in contributing to Mobility Ops 360! 🚖

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Issue Guidelines](#issue-guidelines)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [support@mobility360.jp](mailto:support@mobility360.jp).

## Getting Started

1. **Fork the repository** to your own GitHub account
2. **Clone your fork** to your local machine
3. **Set up the development environment** following the instructions below

## Development Setup

### Prerequisites

- Node.js 18.0+
- Flutter 3.16.0+
- Docker (for local development)
- Make (for CLI commands)

### Quick Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/mobi360.git
cd mobi360

# Initial setup
make onboard

# Start development environment
make dev
```

For detailed setup instructions, see [Development Setup](docs/development-setup.md).

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- 🐛 **Bug Reports**: Found a bug? Let us know!
- 💡 **Feature Requests**: Have an idea for improvement?
- 📖 **Documentation**: Help improve our docs
- 🔧 **Code Contributions**: Bug fixes, new features, improvements
- 🧪 **Testing**: Help us improve test coverage
- 🌐 **Translations**: Help make Mobility Ops 360 more accessible

### Getting Started with Code Contributions

1. **Look for issues** labeled `good first issue` or `help wanted`
2. **Comment on the issue** to let others know you're working on it
3. **Create a feature branch** from `develop`
4. **Make your changes** following our coding standards
5. **Add tests** for your changes
6. **Submit a pull request**

## Pull Request Process

1. **Create a branch** from `develop` (not `main`)
   ```bash
   git checkout develop
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our coding standards

3. **Run tests** to ensure everything works
   ```bash
   make test
   ```

4. **Update documentation** if needed

5. **Commit your changes** with clear, descriptive messages
   ```bash
   git commit -m "feat: add driver location tracking feature"
   ```

6. **Push to your fork** and create a pull request

7. **Fill out the PR template** completely

8. **Wait for review** and address any feedback

### PR Requirements

- ✅ All tests pass
- ✅ Code follows our style guidelines
- ✅ Documentation is updated (if applicable)
- ✅ Changes are tested
- ✅ PR description clearly explains the changes

## Coding Standards

### JavaScript/TypeScript

- Use ES6+ features
- Follow ESLint configuration
- Use meaningful variable names
- Add JSDoc comments for functions
- Maximum line length: 100 characters

### Flutter/Dart

- Follow Flutter style guidelines
- Use meaningful widget names
- Add documentation comments
- Follow project structure conventions

### Git Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): description

feat(driver): add real-time location tracking
fix(api): resolve authentication token expiration
docs(readme): update installation instructions
test(dispatch): add unit tests for AI voice dispatch
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Tests
- `refactor`: Code refactoring
- `chore`: Maintenance tasks

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run specific test suites
cd backend && npm test
cd frontend/mobi360_app && flutter test

# Run E2E tests
npm run test:e2e
```

### Test Coverage

- Maintain minimum 80% test coverage
- Add tests for new features
- Update tests when modifying existing code

### Test Guidelines

- Write descriptive test names
- Use arrange-act-assert pattern
- Mock external dependencies
- Test both success and error cases

## Issue Guidelines

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Use the latest version** of the project
3. **Check documentation** for known solutions

### Bug Reports

Use the bug report template and include:

- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Screenshots (if applicable)

### Feature Requests

Use the feature request template and include:

- Clear description of the feature
- Use case and motivation
- Possible implementation approach
- Alternative solutions considered

## Development Workflow

### Branch Strategy

- `main`: Production-ready code
- `develop`: Development integration branch
- `feature/`: Feature development branches
- `hotfix/`: Critical bug fixes

### Release Process

1. Create release branch from `develop`
2. Update version numbers
3. Update changelog
4. Merge to `main` and tag
5. Deploy to production

## Community

### Getting Help

- 💬 **Discussions**: Use GitHub Discussions for questions
- 🐛 **Issues**: Report bugs and request features
- 📧 **Email**: [support@mobility360.jp](mailto:support@mobility360.jp)
- 💬 **Slack**: Join our community Slack

### Code Reviews

- Be respectful and constructive
- Review for functionality, not style preferences
- Test the changes locally when possible
- Approve changes that meet our standards

## Recognition

Contributors are recognized in our:

- README.md contributors section
- Release notes
- Annual contributor highlights

Thank you for contributing to Mobility Ops 360! 🎉

---

**Questions?** Feel free to ask in our [Discussions](https://github.com/yukihamada/mobi360/discussions) or reach out to [support@mobility360.jp](mailto:support@mobility360.jp).