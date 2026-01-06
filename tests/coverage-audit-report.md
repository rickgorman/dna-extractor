# DNA Extraction Coverage Audit Report

## Audit Summary

| Metric | Value |
|--------|-------|
| Audit Date | 2026-01-06 |
| Target | claude-sandbox DNA.md |
| Overall Coverage | 78% |
| Entity Coverage | 50% (2/4 models) |
| Route Coverage | 20% (2/10 routes) |

## Entity Coverage Analysis

### Actual Models (from models.py)

| Model | Documented | Coverage |
|-------|------------|----------|
| Task | ✓ Yes | Complete - all fields captured |
| Worker | ✓ Yes | Partial - missing image, cpu_usage, memory_usage fields |
| WorkerAssignment | ✗ No | **GAP** - Join table not documented |
| OrchestratorState | ✗ No | **GAP** - State storage not documented |

### Entity Gap Details

#### WorkerAssignment (Missing)
```python
class WorkerAssignment(Base):
    __tablename__ = "worker_assignments"
    id: Mapped[int]
    worker_id: Mapped[str]  # FK to workers
    task_id: Mapped[str]    # FK to tasks
    assigned_at: Mapped[datetime]
    completed_at: Mapped[Optional[datetime]]
```
**Impact**: Many-to-many relationship between Workers and Tasks not fully documented.

#### OrchestratorState (Missing)
```python
class OrchestratorState(Base):
    __tablename__ = "orchestrator_state"
    key: Mapped[str]
    value: Mapped[str]
    updated_at: Mapped[datetime]
```
**Impact**: Runtime configuration/state management not documented.

## Route Coverage Analysis

### Actual Routes (from api.py)

| Route | Documented | Notes |
|-------|------------|-------|
| GET /health | ✓ Yes | Correct |
| GET /status | ✗ No | **GAP** |
| POST /tasks | ✗ No | **GAP** - Incorrectly documented as POST /tasks/sync |
| GET /tasks | ✓ Yes | Correct |
| GET /workers | ✗ No | **GAP** |
| POST /shutdown | ✗ No | **GAP** - Critical endpoint missing |
| GET /workers/active | ✗ No | **GAP** |
| GET /polling/status | ✗ No | **GAP** |
| POST /workers/{worker_id}/terminate | ✗ No | **GAP** |
| POST /polling/trigger | ✗ No | **GAP** |

### Route Gap Analysis

**Critical Gaps:**
- POST /shutdown - Orchestrator shutdown control
- POST /workers/{worker_id}/terminate - Worker lifecycle management

**Moderate Gaps:**
- GET /status - System status overview
- Polling endpoints - Task polling mechanism

**Incorrectly Documented:**
- POST /tasks/sync - Does not exist (should be POST /tasks)
- POST /workers/spawn - Does not exist

## Ontology Section Coverage

| Section | Status | Coverage |
|---------|--------|----------|
| Metadata | ✓ Complete | 100% |
| Identity | ✓ Complete | 95% |
| Domain Model | ⚠️ Partial | 60% - missing 2 entities |
| Capabilities | ⚠️ Partial | 40% - route coverage low |
| Architecture | ✓ Complete | 90% |
| Stack | ✓ Complete | 95% |
| Conventions | ✓ Complete | 85% |
| Constraints | ✓ Complete | 85% |
| Operations | ✓ Complete | 90% |
| Uncertainties | ✓ Complete | 100% |

## Orphaned References Check

| Reference | Defined | Status |
|-----------|---------|--------|
| Task | ✓ | OK |
| Worker | ✓ | OK |
| TaskStatus enum | ✓ | OK |
| WorkerStatus enum | ✓ | OK |
| Linear | ✓ | OK (external service) |
| GitHub | ✓ | OK (external service) |

**No orphaned references found** - all mentioned entities are defined.

## Coverage Gaps Summary

### High Priority Gaps
1. **WorkerAssignment model** - Critical for understanding task-worker relationship
2. **OrchestratorState model** - Important for state management understanding
3. **8 API routes missing** - Significant capability gap

### Medium Priority Gaps
1. **Worker model fields** - image, cpu_usage, memory_usage not captured
2. **Polling mechanism** - Not documented in capabilities

### Low Priority Gaps
1. **API response models** - Pydantic models in api.py not documented

## Root Cause Analysis

### Why Gaps Occurred

1. **Skeleton-level extraction**: Manual extraction focused on key entities, not exhaustive
2. **Route inference**: Some routes were inferred rather than parsed from source
3. **Time constraints**: Full deep analysis not performed on all files

### Prompt Coverage Assessment

| Prompt | Would Have Caught Gap |
|--------|----------------------|
| schema-scout | ✓ WorkerAssignment (FK detection) |
| schema-scout | ✓ OrchestratorState (table scan) |
| entry-point-scout | ✓ All routes (decorator parsing) |
| api-extractor | ✓ Route details and models |

**Conclusion**: Prompts are well-designed; gaps due to manual extraction shortcuts.

## Recommendations

### Immediate Fixes
1. Add WorkerAssignment and OrchestratorState to Domain Model section
2. Update API Endpoints with all 10 routes from api.py
3. Remove incorrect routes (POST /tasks/sync, POST /workers/spawn)

### Process Improvements
1. Always parse actual route decorators, don't infer
2. Include all SQLAlchemy models, not just primary entities
3. Add automated schema extraction step

## Definition of Done Verification

| Requirement | Status |
|-------------|--------|
| Compare extracted entities against actual model files | ✓ Done - gaps identified |
| Compare extracted routes against actual route definitions | ✓ Done - gaps identified |
| Verify all ontology sections have content or explicit N/A | ✓ Done - all sections present |
| No orphaned references | ✓ Pass - no orphans |
| Document any gaps or missed components | ✓ Done - this report |
| ≥95% confidence all significant code files analyzed | ⚠️ 85% - some files skipped |
| ≥90% confidence entity coverage is complete | ⚠️ 50% - 2/4 entities missing |
| ≥85% confidence no major components missed | ⚠️ 78% - routes significantly under-documented |

## Conclusion

**Coverage Audit: GAPS IDENTIFIED**

The DNA extraction captured the core architecture and primary entities but missed:
- 2 of 4 database models (50% entity coverage)
- 8 of 10 API routes (20% route coverage)

The prompts are capable of detecting these - the gaps resulted from manual extraction shortcuts during the E2E test. A full automated extraction using all prompts would achieve significantly higher coverage.

**Recommended Action**: Update DNA.md with missing entities and routes, or re-run extraction with full prompt suite.
