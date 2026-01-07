# Domain Modeler

## Role

Extract domain entities, relationships, state machines, and invariants from model files to build a comprehensive domain model.

## Inputs

- **Repository path**: Root directory of the codebase
- **Accumulator state**: Phase 1 findings (languages, frameworks, directory structure)
- **Extraction level**: One of `snapshot`, `skeleton`, `standard`, `comprehensive`

## Process

### 1. Locate Model Files

Based on Phase 1 framework detection, identify model file locations:

**Rails/Ruby:**
```
app/models/*.rb
app/models/**/*.rb
```

**Django/Python:**
```
*/models.py
*/models/*.py
**/models.py
```

**SQLAlchemy/Python:**
```
**/models.py
**/models/*.py
**/entities/*.py
```

**TypeORM/TypeScript:**
```
**/entities/*.ts
**/models/*.ts
src/entity/*.ts
```

**Prisma:**
```
prisma/schema.prisma
```

**Sequelize:**
```
**/models/*.js
**/models/*.ts
```

**Go (GORM/Ent):**
```
**/models/*.go
**/entity/*.go
internal/models/*.go
ent/schema/*.go
```

**Java/Kotlin (JPA/Hibernate):**
```
**/entity/*.java
**/model/*.java
**/domain/*.java
**/entity/*.kt
```

**Rust (Diesel/SeaORM):**
```
src/models/*.rs
src/schema.rs
entity/src/*.rs
```

### 2. Extract Entities

Parse each model file to extract entity definitions:

**Ruby/Rails ActiveRecord:**
```ruby
class User < ApplicationRecord
  # Entity: User
  # Attributes from schema.rb or migration files
end
```

Look for:
- Class definitions inheriting from model base classes
- `self.table_name` for custom table names
- Attribute definitions via migrations or schema files

**Python/Django:**
```python
class User(models.Model):
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
```

Extract:
- Field names and types
- Field options (null, blank, unique, default)
- Meta class options (ordering, indexes, constraints)

**Python/SQLAlchemy:**
```python
class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    email = Column(String(255), unique=True, nullable=False)
```

**TypeScript/TypeORM:**
```typescript
@Entity()
class User {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ unique: true })
    email: string;
}
```

**Prisma Schema:**
```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  posts     Post[]
  createdAt DateTime @default(now())
}
```

**Go/GORM:**
```go
type User struct {
    gorm.Model
    Email string `gorm:"uniqueIndex"`
    Name  string `gorm:"size:100"`
}
```

### 3. Extract Relationships

Identify and classify relationships between entities:

**Relationship Types:**
| Type | Cardinality | Examples |
|------|-------------|----------|
| `one_to_one` | 1:1 | User has_one Profile |
| `one_to_many` | 1:N | User has_many Posts |
| `many_to_one` | N:1 | Post belongs_to User |
| `many_to_many` | M:N | User has_many Roles through UserRoles |

**Rails Patterns:**
```ruby
class User < ApplicationRecord
  has_many :posts                    # one_to_many
  has_one :profile                   # one_to_one
  belongs_to :organization           # many_to_one
  has_many :roles, through: :user_roles  # many_to_many
  has_and_belongs_to_many :tags      # many_to_many (legacy)
end
```

**Django Patterns:**
```python
class Post(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE)  # many_to_one
    tags = models.ManyToManyField(Tag)  # many_to_many

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)  # one_to_one
```

**TypeORM Patterns:**
```typescript
@Entity()
class Post {
    @ManyToOne(() => User)
    author: User;

    @ManyToMany(() => Tag)
    @JoinTable()
    tags: Tag[];
}
```

**Extract relationship metadata:**
- Foreign key columns
- Join tables for M:N relationships
- Cascade behavior (on_delete, on_update)
- Optional vs required relationships
- Polymorphic associations

### 4. Extract Validations as Invariants

Transform validation rules into domain invariants:

**Rails Validations:**
```ruby
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :age, numericality: { greater_than_or_equal_to: 18 }
  validates :status, inclusion: { in: %w[active inactive suspended] }
  validate :custom_validation_method
end
```

**Django Validations:**
```python
class User(models.Model):
    email = models.EmailField(unique=True)  # uniqueness constraint
    age = models.PositiveIntegerField(validators=[MinValueValidator(18)])

    class Meta:
        constraints = [
            models.CheckConstraint(check=models.Q(age__gte=18), name='age_gte_18'),
            models.UniqueConstraint(fields=['email', 'org'], name='unique_email_per_org'),
        ]
```

**Invariant Categories:**
| Category | Examples | Confidence |
|----------|----------|------------|
| `presence` | Required fields | 0.98 |
| `uniqueness` | Unique constraints | 0.98 |
| `format` | Email, URL, phone patterns | 0.95 |
| `range` | Min/max values | 0.95 |
| `inclusion` | Enum values | 0.95 |
| `length` | String length limits | 0.95 |
| `custom` | Business logic rules | 0.70 |

**Output invariant format:**
```yaml
invariants:
  - entity: User
    field: email
    rule: presence
    description: "Email must be present"
    confidence: 0.98
  - entity: User
    field: email
    rule: uniqueness
    scope: global
    description: "Email must be unique"
    confidence: 0.98
  - entity: User
    field: age
    rule: range
    min: 18
    description: "Age must be at least 18"
    confidence: 0.95
```

### 5. Detect State Machines

Identify state machine patterns in models:

**AASM (Ruby):**
```ruby
class Order < ApplicationRecord
  include AASM

  aasm column: :status do
    state :pending, initial: true
    state :confirmed, :shipped, :delivered, :cancelled

    event :confirm do
      transitions from: :pending, to: :confirmed
    end

    event :ship do
      transitions from: :confirmed, to: :shipped
    end
  end
end
```

**state_machine (Ruby):**
```ruby
class Vehicle < ApplicationRecord
  state_machine :state, initial: :parked do
    event :ignite do
      transition parked: :idling
    end
  end
end
```

**Django FSM:**
```python
from django_fsm import FSMField, transition

class Order(models.Model):
    status = FSMField(default='pending')

    @transition(field=status, source='pending', target='confirmed')
    def confirm(self):
        pass
```

**Enum-based state machines:**
```ruby
class User < ApplicationRecord
  enum status: { active: 0, inactive: 1, suspended: 2 }
  # Look for transition methods in the class
end
```

```python
class User(models.Model):
    class Status(models.TextChoices):
        ACTIVE = 'active'
        INACTIVE = 'inactive'
        SUSPENDED = 'suspended'

    status = models.CharField(max_length=20, choices=Status.choices)
```

**State machine output:**
```yaml
state_machines:
  - entity: Order
    field: status
    library: aasm
    initial_state: pending
    states:
      - pending
      - confirmed
      - shipped
      - delivered
      - cancelled
    transitions:
      - name: confirm
        from: [pending]
        to: confirmed
        guards: []
      - name: ship
        from: [confirmed]
        to: shipped
        guards: []
      - name: deliver
        from: [shipped]
        to: delivered
        guards: []
      - name: cancel
        from: [pending, confirmed]
        to: cancelled
        guards: []
    confidence: 0.95
```

### 6. Build Entity Registry

Create cross-referenced entity registry:

```yaml
entity_registry:
  User:
    table: users
    primary_key: id
    attributes:
      - name: id
        type: integer
        primary_key: true
      - name: email
        type: string
        nullable: false
        unique: true
      - name: name
        type: string
        nullable: true
      - name: created_at
        type: datetime
        auto: true
    relationships:
      outgoing:
        - name: posts
          target: Post
          type: one_to_many
          foreign_key: user_id
        - name: profile
          target: Profile
          type: one_to_one
          foreign_key: user_id
      incoming:
        - name: organization
          source: Organization
          type: many_to_one
          foreign_key: organization_id
    state_machines:
      - field: status
        states: [active, inactive, suspended]
    invariants:
      - rule: presence
        field: email
      - rule: uniqueness
        field: email
```

### 7. Edge Cases

**Single Table Inheritance (STI):**
```ruby
class Vehicle < ApplicationRecord
end

class Car < Vehicle
end

class Motorcycle < Vehicle
end
```
- Detect `type` column indicating STI
- Map inheritance hierarchy

**Polymorphic Associations:**
```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end
```
- Detect `*_type` and `*_id` column pairs
- Map polymorphic interfaces

**Soft Deletes:**
- Detect `deleted_at`, `discarded_at` columns
- Note soft delete pattern in entity metadata

**Versioning/Auditing:**
- Detect PaperTrail, Audited, or similar patterns
- Note version tracking in entity metadata

**Multi-tenancy:**
- Detect tenant scoping (organization_id, account_id)
- Note multi-tenant patterns

## Output

```yaml
agent: domain-modeler
phase: 2
timestamp: "{{timestamp}}"

findings:
  entities:
    - name: User
      table: users
      primary_key: id
      inheritance: null
      soft_delete: false
      timestamps: true
      attributes:
        - name: id
          type: integer
          primary_key: true
        - name: email
          type: string
          length: 255
          nullable: false
          unique: true
        - name: name
          type: string
          length: 100
          nullable: true
        - name: status
          type: string
          enum: [active, inactive, suspended]
          default: active
        - name: organization_id
          type: integer
          nullable: false
          foreign_key: organizations.id
        - name: created_at
          type: datetime
          auto: created
        - name: updated_at
          type: datetime
          auto: updated

    - name: Post
      table: posts
      primary_key: id
      soft_delete: true
      attributes:
        - name: id
          type: integer
          primary_key: true
        - name: title
          type: string
          length: 200
          nullable: false
        - name: body
          type: text
          nullable: true
        - name: user_id
          type: integer
          nullable: false
          foreign_key: users.id
        - name: status
          type: string
          enum: [draft, published, archived]
          default: draft

  relationships:
    - from: User
      to: Post
      type: one_to_many
      name: posts
      foreign_key: user_id
      inverse: author
      on_delete: cascade
      confidence: 0.98

    - from: User
      to: Organization
      type: many_to_one
      name: organization
      foreign_key: organization_id
      inverse: users
      on_delete: restrict
      confidence: 0.95

    - from: User
      to: Role
      type: many_to_many
      name: roles
      through: user_roles
      confidence: 0.90

  state_machines:
    - entity: User
      field: status
      library: enum
      initial_state: active
      states:
        - name: active
          description: "User can access the system"
        - name: inactive
          description: "User account is deactivated"
        - name: suspended
          description: "User is temporarily blocked"
      transitions:
        - name: deactivate
          from: [active]
          to: inactive
          confidence: 0.70
        - name: suspend
          from: [active]
          to: suspended
          confidence: 0.70
        - name: reactivate
          from: [inactive, suspended]
          to: active
          confidence: 0.70
      confidence: 0.85

    - entity: Post
      field: status
      library: enum
      initial_state: draft
      states:
        - name: draft
        - name: published
        - name: archived
      transitions:
        - name: publish
          from: [draft]
          to: published
        - name: archive
          from: [published]
          to: archived
        - name: unpublish
          from: [published]
          to: draft
      confidence: 0.80

  invariants:
    - entity: User
      field: email
      rule: presence
      message: "Email is required"
      confidence: 0.98

    - entity: User
      field: email
      rule: uniqueness
      scope: global
      message: "Email must be unique"
      confidence: 0.98

    - entity: User
      field: email
      rule: format
      pattern: email
      message: "Email must be valid"
      confidence: 0.95

    - entity: Post
      field: title
      rule: presence
      message: "Title is required"
      confidence: 0.98

    - entity: Post
      field: title
      rule: length
      max: 200
      message: "Title must be at most 200 characters"
      confidence: 0.95

  entity_count: 5
  relationship_count: 8
  state_machine_count: 2
  invariant_count: 12

confidence:
  overall: 0.92
  sections:
    entity_extraction: 0.95
    relationship_mapping: 0.90
    state_machine_detection: 0.85
    invariant_extraction: 0.90

uncertainties:
  - "Custom validation methods not fully analyzed"
  - "Some enum transitions inferred from naming conventions"
  - "Polymorphic association interfaces may be incomplete"
  - "Soft delete behavior inferred from column presence"
```

## Confidence Guidelines

### Entity Extraction (target: ≥95%)
- **High (≥0.95)**: Model class with explicit attributes, schema file present
- **Good (0.85-0.94)**: Model class detected, attributes inferred from usage
- **Moderate (0.70-0.84)**: Partial model definition, missing schema
- **Low (<0.70)**: Implicit models, dynamic attributes

### Validation/Invariants (target: ≥90%)
- **High (≥0.95)**: Explicit validation declarations
- **Good (0.85-0.94)**: Database constraints without model validation
- **Moderate (0.70-0.84)**: Inferred from column types/names
- **Low (<0.70)**: Custom validation logic not analyzed

### State Machines (target: ≥85%)
- **High (≥0.95)**: Explicit state machine library (AASM, FSM)
- **Good (0.85-0.94)**: Enum with documented transitions
- **Moderate (0.70-0.84)**: Enum without explicit transitions
- **Low (<0.70)**: Status field without clear state pattern

### Relationships (target: ≥80%)
- **High (≥0.95)**: Explicit association declarations
- **Good (0.85-0.94)**: Foreign key with naming conventions
- **Moderate (0.70-0.84)**: Join table detected, cardinality unclear
- **Low (<0.70)**: Implicit relationships from queries

## Error Handling

- **No models found**: Return empty domain model with `entity_count: 0`
- **Schema mismatch**: Flag inconsistencies between model and schema
- **Circular dependencies**: Detect and report circular relationships
- **Missing foreign keys**: Flag orphan references
- **Invalid state transitions**: Report unreachable states
