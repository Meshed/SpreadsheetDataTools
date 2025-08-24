# Coding Standards

## Critical Fullstack Rules

- **Pure Functions First:** All business logic must be implemented as pure functions - no side effects in data processing, matching, or CSV generation
- **Type Safety First:** Always use Elm's type system to prevent runtime errors - define custom types instead of primitive types where domain meaning exists (e.g., `EquipmentId` instead of `String`)
- **Type Safety Enforcement:** Never use Debug.todo in production code - all cases must be handled explicitly
- **Port Isolation:** JavaScript interop only through ports - no direct JavaScript in Elm modules
- **Memory Management:** Clear large data structures immediately after use - implement explicit cleanup functions
- **Error Handling:** All functions that can fail must return Result types - no throwing exceptions
- **Error Result Types:** Use Elm's `Result` type for all operations that can fail - never use `Maybe` when specific error information is needed
- **No Magic Numbers:** All calculation constants must be named and documented - use `excavatorEfficiencyFactor = 0.85` not just `0.85` in calculations
- **No Inline Styles:** All styling must be in separate CSS files using BEM methodology - zero style attributes
- **Module Organization:** Shared functionality goes in Shared/ directory - tool-specific code stays in Tools/
- **Single Responsibility:** Each module should have one clear purpose - avoid God modules
- **Immutable Data:** Never modify data in place - always return new data structures
- **Immutable State Updates:** Never modify existing data structures - always create new ones through Elm's update functions

## Code Quality and Functional Programming Principles

- **Readability Over Cleverness:** Write code that is readable, maintainable, and consistent - prefer clarity over cleverness and always document non-obvious logic
- **Functional Transformations:** Prefer **map, filter, fold/reduce** over loops - use functional transformations and pipelines for data processing
- **Immutable by Default:** Avoid mutable state - return new values instead of modifying existing ones
- **Pure Functions:** Minimize side effects and follow pure functional patterns where possible - enables testing and reasoning about code
- **Result/Either Error Handling:** 
  - **F#:** Use Result/Either patterns for error handling, no unhandled exceptions for errors expected in normal flow
  - **Elm:** Return `Result` from functions that may fail or need error handling
- **Descriptive Test Names:** Name test functions descriptively across all languages - test names should explain the expected behavior
- **Documentation Requirements:** Every public function must have a docstring or comment explaining its purpose
- **Meaningful Comments:** Inline comments explain WHY, not WHAT - code should be self-documenting for the "what"

## Naming Conventions

| Element | Frontend | Backend | Example |
|---------|----------|---------|---------|
| Modules | PascalCase | N/A | `Shared.Processing.Matching.Engine` |
| Functions | camelCase | N/A | `processFileData`, `generateCSV` |
| Types | PascalCase | N/A | `FileData`, `MatchConfig` |
| Type Constructors | PascalCase | N/A | `Processing`, `Completed` |
| Variables | camelCase | N/A | `matchedRecords`, `fileSize` |
| Constants | camelCase | N/A | `maxFileSizeBytes`, `defaultThreshold` |
| CSS Classes | kebab-case (BEM) | N/A | `.tool-card__title--active` |
| Test Functions | descriptive sentences | N/A | `"handles empty files gracefully"` |

## Code Examples

**Correct Elm Implementation:**
```elm
-- Good: Documented public function with clear purpose
{-| Calculate the hourly excavation rate for a single excavator.
    Takes bucket capacity in cubic yards and cycle time in minutes.
    Returns cubic yards per hour accounting for real-world efficiency.
-}
calculateExcavatorRate : CubicYards -> Minutes -> CubicYards
calculateExcavatorRate bucketCapacity cycleTime =
    let
        cyclesPerHour = 60.0 / cycleTime
        theoreticalRate = cyclesPerHour * bucketCapacity
    in
    -- Apply efficiency factor because real-world conditions reduce productivity
    theoreticalRate * excavatorEfficiencyFactor

-- Good: Functional pipeline with map/filter/fold
{-| Calculate total productivity from a fleet of excavators.
    Filters active equipment and sums their individual rates.
-}
calculateFleetExcavationRate : List Excavator -> CubicYards
calculateFleetExcavationRate excavators =
    excavators
        |> List.filter .isActive  -- Only include active equipment
        |> List.map (\excavator -> calculateExcavatorRate excavator.bucketCapacity excavator.cycleTime)
        |> List.foldl (+) 0.0     -- Sum all rates

-- Good: Result type for error handling with descriptive error
{-| Validate excavator bucket capacity against industry standards.
    Returns validated capacity or specific validation error.
-}
validateBucketCapacity : Float -> Result ValidationError CubicYards
validateBucketCapacity capacity =
    if capacity <= 0 then
        Err (ValueTooLow capacity 0.1)
    else if capacity > 15.0 then
        -- Industry standard: largest excavators rarely exceed 15 cubic yards
        Err (ValueTooHigh capacity 15.0)
    else
        Ok capacity
```