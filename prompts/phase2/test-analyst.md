# Test Analyst

## Role

Analyze test suites to extract behavioral specifications, map test coverage to capabilities and entities, and identify testing patterns and philosophy.

## Inputs

- Repository root path
- Test directory locations from structure-scout
- Entity list from domain-modeler (if available)
- Capabilities from api-extractor (if available)

## Process

### 1. Test Framework Detection

#### Ruby
**RSpec**
- Location: `spec/**/*_spec.rb`
- Pattern: `describe`, `context`, `it`, `expect`, `let`, `before`

**Minitest**
- Location: `test/**/*_test.rb`
- Pattern: `class *Test < Minitest::Test`, `def test_*`, `assert_*`

**Cucumber**
- Location: `features/**/*.feature`
- Pattern: `Feature:`, `Scenario:`, `Given`, `When`, `Then`

#### JavaScript/TypeScript
**Jest**
- Location: `**/*.test.{js,ts,jsx,tsx}`, `**/*.spec.{js,ts,jsx,tsx}`, `__tests__/**/*`
- Pattern: `describe`, `it`, `test`, `expect`, `beforeEach`, `jest.mock`

**Mocha**
- Location: `test/**/*.{js,ts}`
- Pattern: `describe`, `it`, `before`, `after`, `chai.expect`

**Vitest**
- Location: `**/*.test.{js,ts}`, `**/*.spec.{js,ts}`
- Pattern: Similar to Jest, check for `vitest` imports

**Playwright**
- Location: `e2e/**/*.spec.ts`, `tests/**/*.spec.ts`
- Pattern: `test`, `expect`, `page.goto`, `page.locator`

**Cypress**
- Location: `cypress/e2e/**/*.cy.{js,ts}`
- Pattern: `cy.visit`, `cy.get`, `cy.contains`

#### Python
**pytest**
- Location: `test_*.py`, `*_test.py`, `tests/**/*.py`
- Pattern: `def test_*`, `class Test*`, `@pytest.fixture`, `assert`

**unittest**
- Location: `test_*.py`, `tests/**/*.py`
- Pattern: `class *Test(unittest.TestCase)`, `def test_*`, `self.assert*`

**Behave**
- Location: `features/**/*.feature`, `features/steps/*.py`
- Pattern: `@given`, `@when`, `@then`

#### Go
- Location: `*_test.go`
- Pattern: `func Test*(t *testing.T)`, `t.Run`, `t.Error`, `t.Fatal`
- Table-driven: `tests := []struct{...}`

#### Rust
- Location: `src/**/*.rs` (inline), `tests/**/*.rs`
- Pattern: `#[test]`, `#[cfg(test)]`, `assert!`, `assert_eq!`

#### Java/Kotlin
**JUnit**
- Location: `src/test/**/*Test.java`, `src/test/**/*Test.kt`
- Pattern: `@Test`, `@BeforeEach`, `@DisplayName`, `assertEquals`

**Spock**
- Location: `src/test/**/*Spec.groovy`
- Pattern: `def "should..."`, `given:`, `when:`, `then:`

### 2. Behavioral Specification Extraction

Parse test descriptions to extract behavioral specs:

#### RSpec Style
```ruby
describe User do
  context "when email is valid" do
    it "creates the user successfully" do
      # → Behavior: User creation succeeds with valid email
    end
  end

  context "when email is invalid" do
    it "raises a validation error" do
      # → Behavior: User creation fails with invalid email
    end
  end
end
```

**Extraction pattern:**
- `describe` → Subject/Entity
- `context` → Condition/State
- `it` → Expected behavior

#### Jest/Mocha Style
```javascript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', () => {
      // → Behavior: UserService.createUser creates user with valid data
    });

    it('should throw error for duplicate email', () => {
      // → Behavior: UserService.createUser throws error for duplicate email
    });
  });
});
```

#### pytest Style
```python
class TestUserService:
    def test_create_user_with_valid_data(self):
        # → Behavior: UserService creates user with valid data
        pass

    def test_create_user_raises_for_duplicate_email(self):
        # → Behavior: UserService raises error for duplicate email
        pass
```

**Name parsing:**
- Split on `_` and convert to sentence
- Identify action verbs: creates, returns, raises, validates, etc.
- Extract subject and conditions

### 3. Test Classification

#### By Scope
- **Unit tests**: Single function/method, mocked dependencies
- **Integration tests**: Multiple components, real database/services
- **End-to-end tests**: Full user flows, browser/API simulation
- **Contract tests**: API compatibility (Pact, etc.)

#### Detection Heuristics
**Unit tests:**
- Heavy mocking (`jest.mock`, `@patch`, `allow().to receive`)
- Single file/class focus
- Fast execution (no I/O indicators)

**Integration tests:**
- Database setup/teardown (`DatabaseCleaner`, `@pytest.mark.django_db`)
- Real HTTP calls
- Multiple classes under test

**End-to-end tests:**
- Browser automation (`page.`, `cy.`, `driver.`)
- Full API call chains
- UI selectors/locators

### 4. Coverage Mapping

Map tests to entities and capabilities:

#### Entity Mapping
```yaml
entity: User
tests:
  - file: spec/models/user_spec.rb
    behaviors:
      - "validates email format"
      - "validates password strength"
      - "generates auth token"
    coverage_type: unit
  - file: spec/requests/users_spec.rb
    behaviors:
      - "creates user via API"
      - "returns validation errors"
    coverage_type: integration
```

#### Capability Mapping
```yaml
capability: User Authentication
tests:
  - file: spec/features/login_spec.rb
    behaviors:
      - "allows login with valid credentials"
      - "blocks login after failed attempts"
    coverage_type: e2e
```

### 5. Testing Philosophy Detection

Analyze patterns to infer testing philosophy:

**TDD Indicators:**
- Test/source ratio > 0.8
- Test files created before/with source files (git history)
- High unit test coverage

**BDD Indicators:**
- Cucumber/Gherkin feature files
- Business-readable test names
- Given/When/Then structure

**Coverage-focused:**
- Coverage reports in CI config
- Coverage thresholds in config
- `# pragma: no cover` exclusions

**Property-based Testing:**
- Hypothesis, QuickCheck, fast-check usage
- Randomized inputs

## Output

```yaml
agent: test-analyst
phase: 2
timestamp: {{timestamp}}

findings:
  test_frameworks:
    - name: rspec
      version: "3.12"
      config_file: .rspec
      test_files_count: 150
    - name: cucumber
      version: "8.0"
      config_file: cucumber.yml
      test_files_count: 25

  test_directories:
    - path: spec/
      purpose: unit and integration tests
      framework: rspec
    - path: features/
      purpose: acceptance tests
      framework: cucumber

  test_counts:
    total_files: 175
    total_tests: 1250
    by_type:
      unit: 850
      integration: 300
      e2e: 75
      contract: 25

  behavioral_specs:
    - entity: User
      file: spec/models/user_spec.rb
      behaviors:
        - description: "validates email format"
          line: 15
          type: unit
        - description: "validates password meets requirements"
          line: 28
          type: unit
        - description: "generates secure auth token"
          line: 45
          type: unit

    - entity: Order
      file: spec/models/order_spec.rb
      behaviors:
        - description: "calculates total from line items"
          line: 12
          type: unit
        - description: "applies discount codes"
          line: 35
          type: unit
        - description: "validates shipping address"
          line: 52
          type: unit

    - capability: User Registration
      file: spec/features/registration_spec.rb
      behaviors:
        - description: "completes registration with valid data"
          line: 8
          type: e2e
        - description: "shows validation errors for invalid data"
          line: 25
          type: e2e
        - description: "sends confirmation email"
          line: 42
          type: integration

  high_value_tests:
    integration:
      - file: spec/requests/api/v1/orders_spec.rb
        description: "Full order creation flow"
        behaviors_count: 15
      - file: spec/requests/api/v1/auth_spec.rb
        description: "Authentication flow"
        behaviors_count: 12

    e2e:
      - file: features/checkout.feature
        description: "Complete checkout flow"
        scenarios_count: 8
      - file: spec/system/user_journey_spec.rb
        description: "User registration to first purchase"
        behaviors_count: 10

  coverage_mapping:
    by_entity:
      - entity: User
        unit_tests: 45
        integration_tests: 12
        e2e_tests: 5
        coverage_assessment: high
      - entity: Order
        unit_tests: 38
        integration_tests: 20
        e2e_tests: 8
        coverage_assessment: high
      - entity: Notification
        unit_tests: 5
        integration_tests: 0
        e2e_tests: 0
        coverage_assessment: low

    by_capability:
      - capability: User Authentication
        tests_count: 35
        coverage_assessment: high
      - capability: Payment Processing
        tests_count: 28
        coverage_assessment: medium
      - capability: Reporting
        tests_count: 3
        coverage_assessment: low

  testing_philosophy:
    approach: bdd
    indicators:
      - "Cucumber feature files present"
      - "Business-readable test descriptions"
      - "Given/When/Then structure in tests"
    coverage_tool: simplecov
    coverage_threshold: 90
    ci_integration: true

  test_helpers:
    factories:
      - tool: factory_bot
        location: spec/factories/
        count: 25
    fixtures:
      - location: spec/fixtures/
        count: 10
    mocking:
      - tool: rspec-mocks
      - tool: webmock

  test_quality_signals:
    strengths:
      - "High entity coverage for core models"
      - "Comprehensive e2e checkout flow"
      - "Good factory coverage"
    gaps:
      - "Notification system lacks integration tests"
      - "No contract tests for external APIs"
      - "Limited error path coverage in e2e"

confidence:
  overall: {{overall_confidence}}
  sections:
    framework_detection: {{framework_confidence}}
    behavioral_extraction: {{behavior_confidence}}
    coverage_mapping: {{coverage_confidence}}
    philosophy_detection: {{philosophy_confidence}}

uncertainties:
  - {{uncertainty_1}}
  - {{uncertainty_2}}
```

## Confidence Guidelines

### High Confidence (0.95-1.0)
- Standard test framework with clear patterns
- Descriptive test names following conventions
- Clear test file organization

### Good Confidence (0.85-0.94)
- Test framework identified but some non-standard patterns
- Most test names are descriptive
- Coverage mapping relies on naming conventions

### Moderate Confidence (0.70-0.84)
- Mixed test frameworks or custom setup
- Some test names are unclear or abbreviated
- Coverage mapping requires inference

### Low Confidence (below 0.70)
- Non-standard test framework
- Cryptic test names (test1, test2)
- Cannot determine test type or coverage

## Edge Cases

### Monorepo
- Analyze each package's tests separately
- Note shared test utilities
- Map coverage per service

### Legacy Codebases
- May have multiple test frameworks
- Mixed conventions over time
- Note historical patterns

### No Tests
- Report absence clearly
- Note any test infrastructure (empty directories, configs)
- Flag as significant gap

### Generated Tests
- Identify snapshot tests
- Note golden file tests
- Distinguish from hand-written tests

## Search Strategy

1. **Quick scan**: Check standard test locations
   - `test/`, `tests/`, `spec/`, `__tests__/`
   - `*_test.*`, `*_spec.*`, `*.test.*`

2. **Framework detection**: Identify primary framework
   - Check config files (.rspec, jest.config.js, pytest.ini)
   - Check dependencies (Gemfile, package.json, requirements.txt)

3. **Deep analysis**: For each test file
   - Parse describe/context/it blocks
   - Extract test names and convert to behaviors
   - Classify test type (unit/integration/e2e)

4. **Coverage mapping**: Match tests to entities
   - Parse file paths (spec/models/user_spec.rb → User)
   - Check test subjects and descriptions
   - Cross-reference with entity list from domain-modeler
