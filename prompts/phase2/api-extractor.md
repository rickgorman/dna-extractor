# API Extractor

## Role

Trace execution paths from entry points discovered in Phase 1, extracting input/output shapes, validation rules, and side effects for each API endpoint.

## Inputs

- Entry points from entry-point-scout (Phase 1)
- Entity registry from domain-modeler (Phase 1/2)
- Schema definitions from schema-scout (Phase 1)
- Repository root path

## Process

### 1. Trace Execution Paths

For each HTTP route from entry-point-scout, trace the handler:

**Controller → Service → Repository Pattern**
```
Route → Controller#action → Service.method → Repository.query → Entity
```

**Direct Handler Pattern**
```
Route → Handler function → Database/External calls → Response
```

**Middleware Chain**
```
Route → Auth middleware → Validation middleware → Handler → Response middleware
```

### 2. Extract Input Shapes

#### Request Parameters

**Path Parameters**
- Pattern: `/users/:id`, `/posts/{slug}`, `<int:user_id>`
- Extract: name, type constraint, validation rules

**Query Parameters**
- Rails: `params[:page]`, `params.permit(:sort, :filter)`
- Express: `req.query.page`, `req.query`
- FastAPI: `@app.get("/items", query: Query(...))`
- Go: `r.URL.Query().Get("page")`

**Request Body**
- JSON: Look for body parsing, schema validation
- Form: `multipart/form-data`, `application/x-www-form-urlencoded`
- GraphQL: Query/mutation variables

#### Input Validation

**Rails (Strong Parameters)**
```ruby
params.require(:user).permit(:name, :email)
```

**Express (Joi, Zod, express-validator)**
```javascript
body('email').isEmail()
Joi.object({ name: Joi.string().required() })
z.object({ name: z.string() })
```

**FastAPI (Pydantic)**
```python
class UserCreate(BaseModel):
    name: str
    email: EmailStr
```

**Django (Serializers)**
```python
class UserSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100)
```

**Go (struct tags)**
```go
type User struct {
    Name  string `json:"name" validate:"required"`
    Email string `json:"email" validate:"email"`
}
```

**Spring Boot (Bean Validation)**
```java
public class UserDTO {
    @NotNull @Size(min=1) String name;
    @Email String email;
}
```

### 3. Extract Output Shapes

#### Response Structure

**Success Responses**
- HTTP 200/201/204 response bodies
- Pagination wrappers: `{ data: [], meta: { page, total } }`
- Envelope patterns: `{ success: true, data: {...} }`

**Error Responses**
- Validation errors: field-level error messages
- Business errors: error codes, messages
- System errors: 500-level responses

#### Response Serialization

**Rails (ActiveModel Serializers, JBuilder, Blueprinter)**
```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email
  has_many :posts
end
```

**Express (direct JSON)**
```javascript
res.json({ id, name, email, posts })
```

**FastAPI (Pydantic)**
```python
class UserResponse(BaseModel):
    id: int
    name: str

@app.get("/users/{id}", response_model=UserResponse)
```

**Django REST Framework**
```python
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'name', 'email']
```

**Go (struct tags)**
```go
type UserResponse struct {
    ID   int    `json:"id"`
    Name string `json:"name"`
}
```

### 4. Identify Side Effects

#### Database Operations

- **Creates**: `INSERT`, `Model.create()`, `save()`
- **Updates**: `UPDATE`, `Model.update()`, `save()`
- **Deletes**: `DELETE`, `Model.destroy()`, `delete()`
- **Transactions**: `transaction do`, `BEGIN/COMMIT`

#### External Service Calls

**Email**
- Rails: `ActionMailer`, `deliver_later`
- Node: `nodemailer`, `sendgrid`
- Python: `smtplib`, `django.core.mail`

**Background Jobs**
- Sidekiq: `perform_async`, `perform_later`
- Celery: `delay()`, `apply_async()`
- Bull: `queue.add()`

**HTTP Calls**
- `Net::HTTP`, `HTTParty`, `Faraday` (Ruby)
- `axios`, `fetch`, `got` (Node)
- `requests`, `httpx`, `aiohttp` (Python)
- `http.Client` (Go)

**Message Queues**
- RabbitMQ: `channel.basic_publish`
- Kafka: `producer.send`
- SQS: `sqs.send_message`
- Redis pub/sub: `publish`

**File Storage**
- S3: `put_object`, `upload_file`
- Local: `File.write`, `fs.writeFile`

**Cache Operations**
- Redis: `set`, `del`, `expire`
- Memcached: `set`, `delete`

#### Webhooks & Notifications

- Outbound webhooks: `POST` to external URLs
- Push notifications: Firebase, APNs
- SMS: Twilio, Plivo

### 5. Link to Entity Registry

For each endpoint, identify:

1. **Primary Entity**: The main resource being operated on
2. **Related Entities**: Entities loaded or modified as side effects
3. **Operation Type**: CRUD classification

```yaml
endpoint: POST /api/orders
primary_entity: Order
related_entities:
  - User (read - owner lookup)
  - Product (read - inventory check)
  - Inventory (write - decrement stock)
  - Payment (write - charge customer)
operation: create
```

## Output

```yaml
agent: api-extractor
phase: 2
timestamp: {{timestamp}}

endpoints:
  - route:
      method: POST
      path: /api/users
      handler: UsersController#create
      file: app/controllers/users_controller.rb
      line: 28

    input:
      path_params: []
      query_params: []
      body:
        content_type: application/json
        schema:
          name:
            type: string
            required: true
            validation: "length 2-100"
          email:
            type: string
            required: true
            validation: "format: email, unique"
          password:
            type: string
            required: true
            validation: "length >= 8"
        example:
          name: "John Doe"
          email: "john@example.com"
          password: "********"

    output:
      success:
        status: 201
        content_type: application/json
        schema:
          id:
            type: integer
          name:
            type: string
          email:
            type: string
          created_at:
            type: datetime
        example:
          id: 123
          name: "John Doe"
          email: "john@example.com"
          created_at: "2024-01-15T10:30:00Z"
      errors:
        - status: 422
          condition: "validation failed"
          schema:
            errors:
              type: object
              description: "field → error messages"
        - status: 409
          condition: "email already exists"
          schema:
            error:
              type: string

    side_effects:
      database:
        - operation: insert
          entity: User
          table: users
      async_jobs:
        - job: WelcomeEmailJob
          queue: mailers
          trigger: after_create
      external_calls:
        - service: Stripe
          operation: create_customer
          conditional: "if subscription plan selected"

    entity_links:
      primary: User
      related:
        - entity: Organization
          operation: read
          reason: "lookup for association"

    middleware:
      - name: authenticate
        type: auth
        skipped: false
      - name: rate_limit
        type: throttle
        config: "100 req/min"

  - route:
      method: GET
      path: /api/users/:id
      handler: UsersController#show
      file: app/controllers/users_controller.rb
      line: 15

    input:
      path_params:
        - name: id
          type: integer
          required: true
      query_params:
        - name: include
          type: string
          required: false
          values: ["posts", "comments", "all"]
      body: null

    output:
      success:
        status: 200
        content_type: application/json
        schema:
          id:
            type: integer
          name:
            type: string
          email:
            type: string
          posts:
            type: array
            items: Post
            conditional: "if include=posts"
      errors:
        - status: 404
          condition: "user not found"

    side_effects:
      database:
        - operation: read
          entity: User
          table: users

    entity_links:
      primary: User
      related:
        - entity: Post
          operation: read
          reason: "eager load if requested"

    middleware:
      - name: authenticate
        type: auth

summary:
  total_endpoints: {{endpoint_count}}
  by_method:
    GET: {{get_count}}
    POST: {{post_count}}
    PUT: {{put_count}}
    PATCH: {{patch_count}}
    DELETE: {{delete_count}}
  with_side_effects: {{side_effect_count}}
  entities_touched:
    - User (5 endpoints)
    - Post (3 endpoints)
    - Comment (2 endpoints)

confidence:
  overall: {{overall_confidence}}
  sections:
    input_shapes: {{input_confidence}}
    output_shapes: {{output_confidence}}
    side_effects: {{side_effect_confidence}}
    entity_links: {{entity_confidence}}

uncertainties:
  - {{uncertainty_1}}
  - {{uncertainty_2}}
```

## Confidence Guidelines

### High Confidence (0.95-1.0)
- Strong typing via Pydantic, TypeScript, struct tags
- Explicit serializers with documented fields
- Clear validation decorators/annotations
- Side effects use well-known patterns (ActiveJob, Celery)

### Good Confidence (0.85-0.94)
- Types inferred from usage patterns
- Some dynamic response construction
- Side effects visible but not all paths traced
- Entity relationships clear from code

### Moderate Confidence (0.70-0.84)
- Duck typing, dynamic languages without type hints
- Response built from multiple sources
- Some external calls use generic HTTP clients
- Entity links inferred from naming conventions

### Low Confidence (below 0.70)
- Highly dynamic response generation
- Metaprogramming obscures actual shapes
- Side effects triggered by callbacks/observers
- Cannot determine full execution path

## Edge Cases

### GraphQL APIs
- Single `/graphql` endpoint
- Extract shapes from resolvers, not routes
- Input: query variables, output: resolver return types
- Side effects in mutations only

### gRPC Services
- Input/output from `.proto` definitions
- Side effects same as REST handlers
- Map RPC methods to endpoint equivalents

### WebSocket Endpoints
- Messages replace request/response
- Document message types in both directions
- Side effects may span multiple messages

### File Uploads
- Input includes file metadata (name, size, type)
- Side effects: storage writes, virus scanning
- May trigger async processing jobs

### Pagination
- Document pagination parameters (page, limit, cursor)
- Response includes pagination metadata
- Note if cursor-based or offset-based

### Batch Endpoints
- Input is array of items
- Response may be partial success
- Side effects multiplied per item

## Tracing Strategy

1. **Start from entry points**: Use Phase 1 route list
2. **Follow the handler**: Controller → Service → Repository
3. **Extract at boundaries**:
   - Input: where request is parsed/validated
   - Output: where response is serialized
   - Side effects: external calls, job enqueues, writes
4. **Map to entities**: Use schema-scout and domain-modeler output
5. **Document uncertainty**: When paths branch or are conditional
