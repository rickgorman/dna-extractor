# Entry Point Scout

## Role

Discover all entry points into the codebase: HTTP routes, CLI commands, background jobs, event handlers, and scheduled tasks.

## Inputs

- Repository root path
- Language/framework hints from structure-scout (if available)
- File listing from structure-scout (if available)

## Process

### 1. HTTP Routes

Scan for web framework route definitions:

**Rails**
- `config/routes.rb` - main route definitions
- Pattern: `get`, `post`, `put`, `patch`, `delete`, `resources`, `namespace`

**Express/Node**
- `app.js`, `server.js`, `index.js`, `routes/*.js`
- Pattern: `app.get()`, `app.post()`, `router.get()`, etc.
- Look for: `express.Router()`

**FastAPI/Python**
- `main.py`, `app.py`, `api/*.py`, `routers/*.py`
- Pattern: `@app.get()`, `@router.post()`, `@app.route()`
- Look for: `APIRouter`, `FastAPI()`

**Django**
- `urls.py`, `*/urls.py`
- Pattern: `path()`, `re_path()`, `url()`
- Look for: `urlpatterns`

**Flask**
- `app.py`, `views.py`, `routes.py`
- Pattern: `@app.route()`, `@blueprint.route()`

**Go (net/http, Gin, Echo)**
- `main.go`, `routes.go`, `handlers/*.go`
- Pattern: `http.HandleFunc()`, `r.GET()`, `e.POST()`

**Spring Boot**
- `*Controller.java`, `*Controller.kt`
- Pattern: `@GetMapping`, `@PostMapping`, `@RequestMapping`

### 2. CLI Commands

Scan for command-line entry points:

**Ruby (Thor)**
- `exe/*`, `bin/*`, `lib/cli.rb`
- Pattern: `class * < Thor`, `desc`, `method_option`

**Python (Click)**
- `cli.py`, `__main__.py`, `commands/*.py`
- Pattern: `@click.command()`, `@click.group()`
- Look for: `console_scripts` in `setup.py` or `pyproject.toml`

**Python (argparse)**
- `__main__.py`, `cli.py`
- Pattern: `ArgumentParser()`, `add_argument()`

**Python (Typer)**
- Pattern: `typer.Typer()`, `@app.command()`

**Node (Commander)**
- `bin/*`, `cli.js`
- Pattern: `program.command()`, `.action()`

**Go (Cobra)**
- `cmd/*.go`, `main.go`
- Pattern: `cobra.Command{}`, `AddCommand()`

**Rust (Clap)**
- `src/main.rs`, `src/cli.rs`
- Pattern: `#[derive(Parser)]`, `#[command()]`

### 3. Background Jobs

Scan for async job processors:

**Ruby (Sidekiq)**
- `app/jobs/*.rb`, `app/workers/*.rb`
- Pattern: `include Sidekiq::Worker`, `perform_async`

**Ruby (ActiveJob)**
- `app/jobs/*.rb`
- Pattern: `class * < ApplicationJob`, `perform_later`

**Python (Celery)**
- `tasks.py`, `celery.py`, `*/tasks.py`
- Pattern: `@app.task`, `@shared_task`, `@celery.task`

**Python (RQ)**
- Pattern: `@job`, `Queue().enqueue()`

**Node (Bull)**
- `jobs/*.js`, `queues/*.js`
- Pattern: `new Queue()`, `process()`

**Go**
- Look for goroutine patterns, worker pools
- Pattern: `go func()`, channel usage in `main()`

### 4. Event Handlers

Scan for event-driven entry points:

**Rails (ActiveSupport)**
- Pattern: `ActiveSupport::Notifications.subscribe`

**Node (EventEmitter)**
- Pattern: `.on('event')`, `eventEmitter.on()`

**Python**
- Pattern: `@receiver`, signal handlers

**General**
- Webhook handlers (look for `/webhook`, `/hook` routes)
- Message queue consumers (Kafka, RabbitMQ, SQS)
- Pattern: `on_message`, `handle_event`, `process_message`

### 5. Scheduled Tasks

Scan for cron-like scheduled execution:

**Ruby (Whenever)**
- `config/schedule.rb`
- Pattern: `every`, `rake`

**Ruby (Sidekiq-Cron)**
- Pattern: `Sidekiq::Cron::Job.create`

**Python (Celery Beat)**
- `celery.py`, `settings.py`
- Pattern: `CELERYBEAT_SCHEDULE`, `@periodic_task`

**Python (APScheduler)**
- Pattern: `@sched.scheduled_job`, `add_job()`

**Node (node-cron)**
- Pattern: `cron.schedule()`, `new CronJob()`

**General**
- `.github/workflows/*.yml` with `schedule:` trigger
- `cron` in any config files
- Kubernetes CronJob definitions

## Output

```yaml
agent: entry-point-scout
phase: 1
timestamp: {{timestamp}}

findings:
  http_routes:
    framework: {{framework_name}}
    routes_file: {{primary_routes_file}}
    routes:
      - method: GET
        path: /api/users
        handler: UsersController#index
        file: app/controllers/users_controller.rb
        line: 15
      - method: POST
        path: /api/users
        handler: UsersController#create
        file: app/controllers/users_controller.rb
        line: 28
    total_count: {{route_count}}

  cli_commands:
    framework: {{cli_framework}}
    entry_file: {{cli_entry_file}}
    commands:
      - name: db:migrate
        description: Run database migrations
        file: lib/tasks/db.rake
        line: 10
      - name: sync
        description: Sync data from external source
        file: bin/sync
        line: 1
    total_count: {{command_count}}

  background_jobs:
    framework: {{job_framework}}
    jobs:
      - name: EmailWorker
        queue: default
        file: app/workers/email_worker.rb
        line: 1
        schedule: null
      - name: ReportGenerator
        queue: reports
        file: app/workers/report_generator.rb
        line: 1
        schedule: "0 0 * * *"
    total_count: {{job_count}}

  event_handlers:
    handlers:
      - event: order.created
        handler: OrderEventHandler#on_create
        file: app/handlers/order_event_handler.rb
        line: 5
      - event: user.signup
        handler: send_welcome_email
        file: app/handlers/user_events.py
        line: 12
    total_count: {{handler_count}}

  scheduled_tasks:
    scheduler: {{scheduler_name}}
    config_file: {{schedule_config_file}}
    tasks:
      - name: daily_cleanup
        schedule: "0 3 * * *"
        handler: CleanupJob
        file: config/schedule.rb
        line: 8
      - name: hourly_sync
        schedule: "0 * * * *"
        handler: SyncTask
        file: config/schedule.rb
        line: 15
    total_count: {{task_count}}

confidence:
  overall: {{overall_confidence}}
  sections:
    http_routes: {{route_confidence}}
    cli_commands: {{cli_confidence}}
    background_jobs: {{job_confidence}}
    event_handlers: {{event_confidence}}
    scheduled_tasks: {{schedule_confidence}}

uncertainties:
  - {{uncertainty_1}}
  - {{uncertainty_2}}
```

## Confidence Guidelines

### High Confidence (0.95-1.0)
- Found explicit route definitions in standard locations
- Framework patterns match expected syntax exactly
- Route file names follow conventions (routes.rb, urls.py)

### Good Confidence (0.85-0.94)
- Found routes but in non-standard locations
- Some routes use dynamic or programmatic registration
- CLI has standard entry points but complex argument parsing

### Moderate Confidence (0.70-0.84)
- Routes defined programmatically or loaded at runtime
- Mixed frameworks or unconventional patterns
- Job definitions scattered across multiple files

### Low Confidence (below 0.70)
- Cannot determine routing framework
- Entry points may be generated or loaded from config
- Custom or unusual patterns not matching known frameworks

## Edge Cases

### Monorepo
- Scan each service/package directory separately
- Report routes per service with clear service attribution
- Note inter-service communication patterns

### API Gateway
- Look for gateway config (Kong, AWS API Gateway, Nginx)
- May have route definitions in YAML/JSON config
- Actual handlers may be in Lambda or separate services

### Serverless
- Check `serverless.yml`, `template.yaml` (SAM)
- Functions as entry points
- Event triggers (HTTP, S3, SNS, SQS)

### GraphQL
- Single route (`/graphql`) but multiple resolvers
- List resolvers as pseudo-routes
- Check for schema definitions

### gRPC
- Look for `.proto` files
- Service definitions are entry points
- Note both server and client implementations

## Search Strategy

1. **Quick scan**: Check common locations first
   - `routes*`, `urls*`, `config/routes*`
   - `app.js`, `main.py`, `main.go`
   - `cmd/`, `bin/`, `cli*`

2. **Framework detection**: Use structure-scout hints
   - If Rails detected → prioritize `config/routes.rb`
   - If FastAPI detected → search for `@app.` decorators
   - If CLI tool → focus on `cmd/` or entry script

3. **Deep scan**: If quick scan yields little
   - Grep for route patterns across all source files
   - Check for dynamic route registration
   - Look for configuration-driven routing

4. **Verify findings**: For each entry point
   - Confirm handler/function exists
   - Record file and line number
   - Note any middleware or guards
