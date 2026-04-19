# Contributing to ruby-crewai

Thank you for taking the time to contribute. This document covers everything you need to get set up, make changes, and open a pull request.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Running the Tests](#running-the-tests)
- [Commit Discipline](#commit-discipline)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)

---

## Code of Conduct

Everyone interacting with this project is expected to follow the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). Please report unacceptable behaviour to [ranaibtisam1@gmail.com](mailto:ranaibtisam1@gmail.com).

---

## Getting Started

**Requirements:**
- Ruby 3.1+
- Bundler 2+

**Setup:**

```bash
git clone https://github.com/MuhammadIbtisam/ruby-crewai.git
cd ruby-crewai
bundle install
```

Verify everything works:

```bash
bundle exec rspec
```

You should see all examples passing with zero failures.

---

## Running the Tests

The test suite uses **RSpec** and **WebMock** — no live credentials or network access needed.

```bash
# Run the full suite
bundle exec rspec

# Run a single file
bundle exec rspec spec/crewai/client/kickoff_spec.rb

# Run a single example by line number
bundle exec rspec spec/crewai/client/kickoff_spec.rb:10
```

**Coverage expectations:**

Every public method must have:
- A success case
- At least one error case (e.g. 401, 422, 404, 500)
- Edge cases for optional parameters (omitted vs provided)

The suite must be green before opening a pull request.

---

## Commit Discipline

This project follows a **one commit = one intention** rule. Each commit should be reviewable in ~2 minutes.

**Format:**

```
type(scope): short description
```

| Type | When to use |
|------|-------------|
| `feat` | New feature or endpoint |
| `feat(api)` | New API method on `Client` |
| `fix` | Bug fix |
| `refactor` | Internal restructure, no behaviour change |
| `test` | Adding or updating specs only |
| `docs` | README, CHANGELOG, or doc comments |
| `chore` | Gemspec, CI, dependencies, tooling |
| `ci` | GitHub Actions changes |

**Rules:**
- Do not bundle multiple intentions into one commit
- Do not commit a failing test suite
- Update `CHANGELOG.md` in the same commit as the feature or fix it describes

---

## Pull Request Guidelines

1. **One PR = one intention** — same rule as commits
2. **Branch from `main`** — `git checkout -b feat/my-feature`
3. **Write tests first** — or alongside the implementation, never after
4. **Green suite required** — `bundle exec rspec` must pass
5. **Update the CHANGELOG** — add an entry under `[Unreleased]`
6. **Small diffs** — a PR reviewable in ~10 minutes is a good PR

**Adding a new API endpoint:**

Follow the established pattern:
1. Add the method to `lib/crewai/client.rb`
2. Create `spec/crewai/client/<endpoint>_spec.rb`
3. Add a section to `README.md`
4. Update `CHANGELOG.md`
5. One commit: `feat(api): add Client#<method>`

---

## Reporting Bugs

Open an issue on [GitHub](https://github.com/MuhammadIbtisam/ruby-crewai/issues) with:

- Ruby version (`ruby --version`)
- Gem version (`bundle exec gem list ruby-crewai`)
- A minimal reproduction (the smallest code that triggers the bug)
- The full error message and backtrace

---

## Feature Requests

Open an issue describing:

- What you want to do that you currently cannot
- Why it belongs in the gem rather than in your application

We follow the CrewAI AMP API — new endpoints are added as they become available in the API.
