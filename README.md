# ruby-crewai

> A minimal, production-grade Ruby client for the [CrewAI AMP](https://docs.crewai.com/en/api-reference/introduction) (Async Managed Process) HTTP API.

[![Gem Version](https://img.shields.io/gem/v/ruby-crewai)](https://rubygems.org/gems/ruby-crewai)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.1-red)](https://www.ruby-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [API Reference](#api-reference)
  - [inputs](#inputs)
  - [kickoff](#kickoff)
  - [status](#status)
  - [resume](#resume)
- [Error Handling](#error-handling)
- [Requirements](#requirements)
- [License](#license)

---

## Installation

Add to your `Gemfile`:

```ruby
gem "ruby-crewai"
```

Then:

```bash
bundle install
```

Or install directly:

```bash
gem install ruby-crewai
```

---

## Quick Start

```ruby
require "ruby-crewai"

# 1. Configure once (e.g. in an initializer)
CrewAI.configure do |config|
  config.access_token = ENV["CREWAI_ACCESS_TOKEN"]
  config.uri_base     = ENV["CREWAI_URI_BASE"]
end

# 2. Create a client
client = CrewAI::Client.new

# 3. Discover what inputs your crew needs
client.inputs
# => { "inputs" => ["topic", "audience"] }

# 4. Kick off a run
response = client.kickoff(inputs: { topic: "AI in Ruby", audience: "developers" })
kickoff_id = response["kickoff_id"]
# => "k-abc-123"

# 5. Poll for status
client.status(kickoff_id)
# => { "status" => "running" }
```

---

## Configuration

### Global (recommended)

Set once at app boot — all clients share these defaults:

```ruby
CrewAI.configure do |config|
  config.access_token  = ENV["CREWAI_ACCESS_TOKEN"]
  config.uri_base      = ENV["CREWAI_URI_BASE"]   # "https://your-crew.crewai.com"
  config.open_timeout  = 10   # seconds (default)
  config.read_timeout  = 30   # seconds (default)
  config.write_timeout = 30   # seconds (default)
end
```

### Per-client override

Useful when talking to multiple crews or in tests:

```ruby
client = CrewAI::Client.new(
  access_token: "token-for-this-crew",
  uri_base:     "https://other-crew.crewai.com"
)
```

You can also pass a full `Configuration` object:

```ruby
config = CrewAI::Configuration.new
config.access_token = "..."
config.uri_base     = "https://your-crew.crewai.com"

client = CrewAI::Client.new(configuration: config)
```

### Timeout defaults

| Option | Default | Description |
|--------|---------|-------------|
| `open_timeout` | `10` s | Time to open the TCP connection |
| `read_timeout` | `30` s | Time to wait for a response |
| `write_timeout` | `30` s | Time to send the request body |

---

## API Reference

> All methods return a plain Ruby `Hash` parsed from the JSON response.
> All errors are subclasses of `CrewAI::Error` — see [Error Handling](#error-handling).

---

### inputs

**`GET /inputs`** — List the input keys the crew requires before a kickoff.

```ruby
client.inputs
# => { "inputs" => ["topic", "audience"] }
```

---

### kickoff

**`POST /kickoff`** — Start a crew run asynchronously. Returns a `kickoff_id`.

**Minimal:**

```ruby
response = client.kickoff(
  inputs: { topic: "AI in healthcare", audience: "developers" }
)
# => { "kickoff_id" => "k-abc-123" }
```

> Input keys can be **symbols or strings** — both are accepted.

**With all options:**

```ruby
client.kickoff(
  inputs:           { topic: "Ruby gems", audience: "engineers" },
  meta:             { source: "my-app", version: "2" },
  task_webhook_url: "https://example.com/webhooks/task",
  step_webhook_url: "https://example.com/webhooks/step",
  crew_webhook_url: "https://example.com/webhooks/crew"
)
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `inputs` | `Hash` | Yes | Key-value pairs matching the crew's required inputs |
| `meta` | `Hash` | No | Arbitrary metadata passed through to the run |
| `task_webhook_url` | `String` | No | Webhook called on task completion |
| `step_webhook_url` | `String` | No | Webhook called on each step |
| `crew_webhook_url` | `String` | No | Webhook called on crew completion |

---

### status

**`GET /{kickoff_id}/status`** — Poll the current status of a running crew.

```ruby
client.status("k-abc-123")
# => { "status" => "running" }
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `kickoff_id` | `String` | Yes | The ID returned by `#kickoff` |

---

### resume

**`POST /resume`** — Continue a crew paused at a human-in-the-loop step.

**Approve:**

```ruby
client.resume(
  execution_id:   "e-1",
  task_id:        "t-1",
  human_feedback: "Looks good, proceed.",
  is_approve:     true
)
# => { "status" => "resumed" }
```

**Reject with feedback:**

```ruby
client.resume(
  execution_id:   "e-1",
  task_id:        "t-1",
  human_feedback: "Please revise the introduction.",
  is_approve:     false
)
```

**With optional webhooks:**

```ruby
client.resume(
  execution_id:     "e-1",
  task_id:          "t-1",
  human_feedback:   "Approved.",
  is_approve:       true,
  task_webhook_url: "https://example.com/webhooks/task",
  step_webhook_url: "https://example.com/webhooks/step",
  crew_webhook_url: "https://example.com/webhooks/crew"
)
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `execution_id` | `String` | Yes | The execution to resume |
| `task_id` | `String` | Yes | The paused task |
| `human_feedback` | `String` | Yes | Your feedback or instructions |
| `is_approve` | `Boolean` | Yes | `true` to approve, `false` to reject |
| `task_webhook_url` | `String` | No | Webhook called on task completion |
| `step_webhook_url` | `String` | No | Webhook called on each step |
| `crew_webhook_url` | `String` | No | Webhook called on crew completion |

---

## Error Handling

All errors inherit from `CrewAI::Error`, so you can rescue broadly or granularly:

```ruby
begin
  response = client.kickoff(inputs: { topic: "AI" })
rescue CrewAI::AuthenticationError
  # 401 — bad or missing access token
  puts "Check your CREWAI_ACCESS_TOKEN"
rescue CrewAI::InvalidRequestError => e
  # 400 / 422 — malformed request or missing required inputs
  puts "Bad request: #{e.message}"
rescue CrewAI::NotFoundError => e
  # 404 — kickoff_id not found
  puts "Not found: #{e.message}"
rescue CrewAI::ServerError
  # 500–599 — CrewAI-side failure; safe to retry
  puts "Server error — try again shortly"
rescue CrewAI::TimeoutError
  # Faraday read/open timeout exceeded
  puts "Request timed out"
rescue CrewAI::ConnectionError
  # Network or SSL failure
  puts "Could not reach CrewAI"
rescue CrewAI::HTTPError => e
  # Unexpected HTTP status — carries .status and .body
  puts "Unexpected #{e.status}: #{e.body}"
rescue CrewAI::Error => e
  # Catch-all for any other gem error
  puts "CrewAI error: #{e.message}"
end
```

### Error class reference

| Class | Trigger |
|-------|---------|
| `CrewAI::AuthenticationError` | HTTP 401 |
| `CrewAI::InvalidRequestError` | HTTP 400 / 422 |
| `CrewAI::NotFoundError` | HTTP 404 |
| `CrewAI::ServerError` | HTTP 500–599 |
| `CrewAI::TimeoutError` | Faraday read/open timeout |
| `CrewAI::ConnectionError` | Network or SSL failure |
| `CrewAI::HTTPError` | Any other unexpected status (exposes `.status`, `.body`) |

---

## Requirements

- **Ruby** 3.1+
- **[Faraday](https://github.com/lostisland/faraday)** >= 2.0, < 3

---

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/MuhammadIbtisam/ruby-crewai).

- **Bug reports** — open an issue with a minimal reproduction
- **Pull requests** — one intention per PR; include tests; ensure `bundle exec rspec` is green before opening
- **Questions** — open a discussion on the repository

This project is intended to be a safe, welcoming space. All contributors are expected to adhere to the [Code of Conduct](#code-of-conduct).

---

## Code of Conduct

Everyone interacting with this project — in issues, pull requests, and discussions — is expected to follow the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).

---

## License

Released under the [MIT License](LICENSE).
