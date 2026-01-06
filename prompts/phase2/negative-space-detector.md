# Negative Space Detector

## Role

Identify what's expected but missing from the codebase: features that should exist given the project type, deliberate exclusions, and architectural gaps. Document the "negative space" - what the system deliberately doesn't do.

## Inputs

- Repository root path
- Project type from structure-scout
- Capabilities from api-extractor
- Domain model from domain-modeler
- Framework hints from structure-scout

## Process

### 1. Project Type Identification

Classify the project to load appropriate expectations:

#### E-commerce
**Signals:**
- Product/Item models
- Cart/Basket functionality
- Payment integrations
- Order management

**Expected features:**
- Product catalog
- Shopping cart
- Checkout flow
- Payment processing
- Order history
- Inventory management
- Shipping calculation
- Tax calculation
- Discount/coupon system
- User accounts
- Wishlist
- Reviews/ratings

#### SaaS Application
**Signals:**
- User/Account models
- Subscription/Plan models
- Multi-tenancy patterns
- Billing integrations

**Expected features:**
- User authentication
- Team/organization management
- Role-based access control
- Subscription management
- Billing/invoicing
- Usage tracking/metering
- Admin dashboard
- API access
- Webhooks
- Audit logging
- Data export

#### Content Management
**Signals:**
- Post/Article/Page models
- Author/Editor roles
- Publishing workflows
- Media management

**Expected features:**
- Content CRUD
- Rich text editing
- Media library
- Categories/tags
- Publishing workflow (draft → review → publish)
- SEO metadata
- Versioning/history
- Comments
- Search
- RSS/feeds

#### API Service
**Signals:**
- API versioning
- Rate limiting
- API documentation
- Token authentication

**Expected features:**
- Authentication (API keys, OAuth)
- Rate limiting
- Versioning strategy
- Documentation (OpenAPI)
- Error handling standards
- Pagination
- Filtering/sorting
- Webhooks
- Health checks
- Metrics/monitoring

#### Mobile Backend
**Signals:**
- Push notification setup
- Device registration
- Offline sync patterns

**Expected features:**
- Push notifications
- Device management
- Offline sync
- Background jobs
- File upload/download
- Deep linking support
- App versioning/force update

#### Data Pipeline
**Signals:**
- ETL patterns
- Scheduling
- Data transformations
- Multiple data sources

**Expected features:**
- Data ingestion
- Transformation logic
- Scheduling/orchestration
- Error handling/retry
- Data validation
- Monitoring/alerting
- Backfill capability
- Idempotency

### 2. Feature Presence Check

For each expected feature, check for presence:

#### Detection Methods

**Model/Entity Check:**
```
Expected: Shopping Cart
Check: Cart model, LineItem model, session cart storage
Result: PRESENT | ABSENT | PARTIAL
```

**Route/Endpoint Check:**
```
Expected: Checkout Flow
Check: /checkout, /cart, /payment routes
Result: PRESENT | ABSENT | PARTIAL
```

**Dependency Check:**
```
Expected: Payment Processing
Check: stripe, braintree, paypal in dependencies
Result: PRESENT | ABSENT
```

**Configuration Check:**
```
Expected: Email Notifications
Check: SMTP config, mailer setup, email templates
Result: PRESENT | ABSENT | PARTIAL
```

### 3. Absence Classification

For each absent feature, classify the reason:

#### Deliberate Exclusion
**Evidence types:**
- Comments explaining why feature is excluded
- Tests asserting feature doesn't exist
- Documentation stating limitations
- Rejected PRs/issues discussing feature
- Architecture Decision Records (ADRs)

**Example evidence:**
```ruby
# We deliberately don't support guest checkout
# All purchases require authentication for fraud prevention
validates :user_id, presence: true
```

```javascript
// NOTE: We intentionally don't implement soft delete
// Data retention policy requires hard delete after 30 days
```

#### Not Yet Implemented
**Evidence types:**
- TODO comments mentioning feature
- Open issues/tickets for feature
- Stub implementations
- Feature flags disabled
- Placeholder routes returning 501

**Example evidence:**
```python
def export_data(self):
    # TODO: Implement data export (ticket #1234)
    raise NotImplementedError("Coming in v2.0")
```

#### Unknown/Unclear
**No evidence found for:**
- Why feature is missing
- Whether it's planned
- Whether it was considered

### 4. Evidence Collection

For each finding, collect supporting evidence:

#### Code Evidence
```yaml
evidence:
  - type: comment
    file: app/models/order.rb
    line: 45
    content: "# Guest checkout disabled for compliance"
  - type: validation
    file: app/models/order.rb
    line: 12
    content: "validates :user_id, presence: true"
  - type: test
    file: spec/models/order_spec.rb
    line: 78
    content: "it 'requires a user' do..."
```

#### Documentation Evidence
```yaml
evidence:
  - type: readme
    file: README.md
    section: "Limitations"
    content: "This system does not support..."
  - type: adr
    file: docs/adr/0005-no-guest-checkout.md
    decision: "We will not implement guest checkout"
    rationale: "Fraud prevention requirements"
```

### 5. Gap Analysis

Identify architectural gaps beyond feature checklist:

#### Common Gaps

**Observability:**
- Logging strategy
- Metrics collection
- Distributed tracing
- Error tracking

**Resilience:**
- Circuit breakers
- Retry logic
- Timeout handling
- Graceful degradation

**Security:**
- Input validation gaps
- Missing rate limiting
- Audit logging gaps
- Secret rotation

**Operations:**
- Health checks
- Graceful shutdown
- Configuration management
- Feature flags

**Data Management:**
- Backup strategy
- Data retention
- GDPR compliance
- Data migration path

### 6. Negative Requirements Documentation

Document what the system explicitly doesn't do:

```yaml
negative_requirements:
  - requirement: "System does not store credit card numbers"
    reason: "PCI compliance - uses tokenization"
    evidence:
      - "No card_number field in any model"
      - "Stripe token storage only"
    confidence: 0.95

  - requirement: "System does not support multi-currency"
    reason: "US-only business decision"
    evidence:
      - "All prices in USD"
      - "No currency conversion logic"
      - "Comment in pricing.rb: 'USD only for v1'"
    confidence: 0.90

  - requirement: "System does not allow account deletion"
    reason: "Legal data retention requirement"
    evidence:
      - "No delete endpoint for users"
      - "Soft delete only (deactivated flag)"
      - "ADR-003: Data retention policy"
    confidence: 0.95
```

## Output

```yaml
agent: negative-space-detector
phase: 2
timestamp: {{timestamp}}

findings:
  project_classification:
    primary_type: e-commerce
    secondary_types:
      - saas
    confidence: 0.92
    signals:
      - "Product and Cart models present"
      - "Stripe integration configured"
      - "Subscription model present (SaaS signal)"

  feature_analysis:
    expected_features:
      present:
        - name: Product Catalog
          implementation: complete
          evidence:
            - "Product model with full CRUD"
            - "/products routes"

        - name: Shopping Cart
          implementation: complete
          evidence:
            - "Cart model with LineItems"
            - "CartController with add/remove"

        - name: User Authentication
          implementation: complete
          evidence:
            - "Devise integration"
            - "User model with authentication"

      partial:
        - name: Payment Processing
          implementation: partial
          present:
            - "Stripe integration"
            - "Credit card payments"
          missing:
            - "PayPal support"
            - "Apple Pay"
            - "Refund automation"
          evidence:
            - "Only Stripe in dependencies"
            - "TODO: Add PayPal (issue #234)"

        - name: Inventory Management
          implementation: partial
          present:
            - "Stock quantity field"
          missing:
            - "Low stock alerts"
            - "Backorder handling"
            - "Multi-warehouse support"
          evidence:
            - "Simple integer stock_count"
            - "No Inventory model"

      absent:
        - name: Guest Checkout
          classification: deliberate_exclusion
          evidence:
            - type: comment
              file: app/models/order.rb
              line: 15
              content: "# Guest checkout disabled - fraud prevention"
            - type: validation
              file: app/models/order.rb
              line: 8
              content: "validates :user_id, presence: true"
            - type: test
              file: spec/models/order_spec.rb
              line: 45
              content: "it 'requires authenticated user'"
          confidence: 0.95

        - name: Wishlist
          classification: not_yet_implemented
          evidence:
            - type: todo
              file: app/controllers/products_controller.rb
              line: 78
              content: "# TODO: Add wishlist feature (Q2 roadmap)"
            - type: issue
              reference: "GitHub issue #456"
              status: open
          confidence: 0.88

        - name: Product Reviews
          classification: unknown
          evidence: []
          notes: "No evidence of consideration or rejection"
          confidence: 0.60

        - name: Multi-currency
          classification: deliberate_exclusion
          evidence:
            - type: adr
              file: docs/adr/0007-single-currency.md
              decision: "USD only for initial launch"
              rationale: "Simplify pricing, US market focus"
          confidence: 0.95

  negative_requirements:
    - id: NR-001
      statement: "System does not support guest checkout"
      category: business_rule
      reason: "Fraud prevention and order tracking"
      evidence:
        - "User required for all orders"
        - "No anonymous cart persistence"
      impact: "All customers must create account"
      confidence: 0.95

    - id: NR-002
      statement: "System does not store raw credit card numbers"
      category: compliance
      reason: "PCI DSS compliance"
      evidence:
        - "Stripe tokenization only"
        - "No card fields in database"
      impact: "Dependent on Stripe availability"
      confidence: 0.98

    - id: NR-003
      statement: "System does not support real-time inventory sync"
      category: technical_limitation
      reason: "Batch sync with warehouse system"
      evidence:
        - "Nightly inventory sync job"
        - "No webhook integration"
      impact: "Stock may be slightly out of date"
      confidence: 0.85

    - id: NR-004
      statement: "System does not allow order modification after payment"
      category: business_rule
      reason: "Payment finality, accounting simplicity"
      evidence:
        - "No edit action on completed orders"
        - "Cancel and re-order workflow"
      impact: "Customer must cancel and reorder"
      confidence: 0.90

  architectural_gaps:
    observability:
      - gap: "No distributed tracing"
        severity: medium
        evidence: "No tracing library in dependencies"
      - gap: "Limited error context"
        severity: low
        evidence: "Basic error logging only"

    resilience:
      - gap: "No circuit breakers for external services"
        severity: medium
        evidence: "Direct API calls without fallback"
      - gap: "Missing retry logic on Stripe calls"
        severity: high
        evidence: "Single attempt payment processing"

    operations:
      - gap: "No feature flags"
        severity: low
        evidence: "No feature flag library"
      - gap: "No graceful shutdown handling"
        severity: medium
        evidence: "No SIGTERM handler"

  deliberate_constraints:
    - constraint: "Single-tenant architecture"
      reason: "Simplicity for MVP"
      implications:
        - "No data isolation between customers"
        - "Single database schema"
      future_consideration: "Multi-tenancy planned for enterprise tier"

    - constraint: "Synchronous payment processing"
      reason: "Simpler user flow"
      implications:
        - "User waits during payment"
        - "No webhook-based confirmation"
      future_consideration: "Async processing for high volume"

confidence:
  overall: {{overall_confidence}}
  sections:
    project_classification: {{classification_confidence}}
    feature_analysis: {{feature_confidence}}
    negative_requirements: {{negative_confidence}}
    gap_analysis: {{gap_confidence}}

uncertainties:
  - {{uncertainty_1}}
  - {{uncertainty_2}}
```

## Confidence Guidelines

### High Confidence (0.95-1.0)
- Explicit documentation of exclusion (ADR, comments)
- Tests asserting feature doesn't exist
- Clear architectural decisions

### Good Confidence (0.85-0.94)
- Comments explaining absence
- TODO notes for future implementation
- Consistent patterns suggesting intentional design

### Moderate Confidence (0.70-0.84)
- Absence inferred from project type expectations
- No explicit evidence either way
- Patterns suggest gap but no confirmation

### Low Confidence (below 0.70)
- Pure speculation based on project type
- Cannot determine if deliberate or oversight
- Limited codebase understanding

## Edge Cases

### Microservices
- Feature may exist in another service
- Check for service references before marking absent
- Note service boundaries

### In-Development Projects
- Many features may be planned but not implemented
- Weight TODO evidence higher
- Check project roadmap if available

### Minimal/Focused Projects
- Not all "expected" features are truly expected
- Adjust expectations based on stated scope
- Don't penalize intentional simplicity

### Legacy Systems
- May have deprecated features
- Check for feature removal evidence
- Note technical debt

## Search Strategy

1. **Classify project**: Determine type from signals
   - Check models, routes, dependencies
   - Load appropriate expectation set

2. **Feature scan**: Check each expected feature
   - Model presence, route presence, config presence
   - Mark as present/partial/absent

3. **Evidence hunt**: For absent features
   - Search for explanatory comments
   - Check TODOs and FIXMEs
   - Look for ADRs or documentation
   - Check git history for removals

4. **Gap analysis**: Beyond feature checklist
   - Check operational concerns
   - Evaluate architectural patterns
   - Note missing best practices
