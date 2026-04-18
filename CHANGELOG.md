# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.0] - 2026-04-18

### Added

- `CrewAI::Client` with four AMP operations:
  - `#inputs` — `GET /inputs` — list required input keys
  - `#kickoff` — `POST /kickoff` — start a crew run asynchronously; accepts `inputs`, optional `meta`, and optional camelCase webhook URLs (`taskWebhookUrl`, `stepWebhookUrl`, `crewWebhookUrl`)
  - `#status` — `GET /{kickoff_id}/status` — poll run status
  - `#resume` — `POST /resume` — continue a human-in-the-loop step
- `CrewAI.configure` DSL and per-client `configuration:` keyword for flexible credential management
- Faraday 2.x HTTP transport with Bearer auth, JSON middleware, configurable open/read/write timeouts, and `User-Agent` header
- Error class hierarchy: `AuthenticationError`, `InvalidRequestError`, `NotFoundError`, `ServerError`, `TimeoutError`, `ConnectionError`, `HTTPError`
- `lib/ruby-crewai.rb` hyphenated require shim so `require "ruby-crewai"` works for host apps using `Bundler.require`
- Full WebMock-based RSpec test suite (31 examples) — no live credentials required
- CI matrix via GitHub Actions: Ruby 3.1 and latest stable

[0.1.0]: https://github.com/MuhammadIbtisam/ruby-crewai/releases/tag/v0.1.0
