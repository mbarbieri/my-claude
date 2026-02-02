---
name: spock
description: Use when writing or refactoring Spock tests in Java projects - enforces data-driven testing with where blocks, proper mock/stub placement, and descriptive test names following Spock best practices
---

# Spock Testing

## Overview

Write maintainable Spock tests using data-driven testing, proper block structure, and clear naming. **Core principle:** Similar tests with different inputs = one parameterized test with `where:` block.

## When to Use

- Writing new Spock tests
- Refactoring existing Spock tests
- Reviewing Spock test code
- About to write your 3rd similar test method

## The Iron Rule: Data-Driven Testing

```
Writing 3+ similar tests = You MUST use where: block
```

**No exceptions:**

- Not "I'll refactor later"
- Not "Copy-paste is faster"
- Not "These are slightly different"
- Not "I'm under time pressure"

**Why:** Refactoring to `where:` takes 2 minutes. Maintaining 10 separate tests takes hours.

## Red Flags - STOP and Use where: Block

You're about to violate the Iron Rule if:

- "I'm writing my 3rd test with same structure"
- "Just need to change the input value"
- "Copy-paste-modify is fastest"
- "Each test is simple enough"
- "I'll consolidate later"

**All of these mean: Use where: block NOW.**

## Before/After Pattern

### ❌ BAD: Separate Tests

```groovy
def "should calculate 20% discount for premium"() {
    when:
    def result = calculator.calculateDiscount(new BigDecimal("100"), CustomerType.PREMIUM)
    then:
    result == new BigDecimal("20.00")
}

def "should calculate 10% discount for regular"() {
    when:
    def result = calculator.calculateDiscount(new BigDecimal("100"), CustomerType.REGULAR)
    then:
    result == new BigDecimal("10.00")
}

def "should calculate 5% discount for new"() {
    when:
    def result = calculator.calculateDiscount(new BigDecimal("100"), CustomerType.NEW)
    then:
    result == new BigDecimal("5.00")
}

def "should calculate no discount for guest"() {
    when:
    def result = calculator.calculateDiscount(new BigDecimal("100"), CustomerType.GUEST)
    then:
    result == BigDecimal.ZERO
}
```

**Problems:** 4 test methods, 20+ lines, duplicated structure, hard to see pattern

### ✅ GOOD: Data-Driven Test

```groovy
def "should calculate #expectedDiscount discount for #customerType customer"() {
    expect:
    calculator.calculateDiscount(orderAmount, customerType) == expectedDiscount

    where:
    customerType         | orderAmount         | expectedDiscount
    CustomerType.PREMIUM | new BigDecimal(100) | new BigDecimal("20.00")
    CustomerType.REGULAR | new BigDecimal(100) | new BigDecimal("10.00")
    CustomerType.NEW     | new BigDecimal(100) | new BigDecimal("5.00")
    CustomerType.GUEST   | new BigDecimal(100) | BigDecimal.ZERO
}
```

**Benefits:** 1 test method, 10 lines, pattern obvious, easy to add cases

## Quick Reference

### Spock Block Structure

| Block | Purpose | Example |
|-------|---------|---------|
| `given:` | Setup, stubs | `repository.findById(1) >> Optional.of(user)` |
| `when:` | Execute action | `service.processOrder(orderId)` |
| `then:` | Assertions, mock verification | `1 * service.save(_)` |
| `expect:` | Single-line assertion | `calculator.add(2, 3) == 5` |
| `where:` | Data table for parameters | `a \| b \| sum` |

### Mock vs Stub

- **Stub** → Return fake data → Goes in `given:` → Use `>>`

  ```groovy
  given:
  repository.findById(1) >> Optional.of(user)  // Stub
  ```

- **Mock** → Verify interaction → Goes in `then:` → Use `*`

  ```groovy
  then:
  1 * emailService.sendWelcome(user)  // Mock verification
  ```

### where: Block Syntax

```groovy
where:
columnA | columnB | expected
value1  | value2  | result1
value3  | value4  | result2
```

Use `#variable` in test names to show which parameter is tested:

```groovy
def "should validate #email as #validity"() {
    expect:
    validator.isValid(email) == isValid

    where:
    email              | validity | isValid
    "user@example.com" | "valid"  | true
    "invalid"          | "invalid"| false
}
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Writing 3+ similar tests | Use `where:` block |
| Stub in `then:` block | Move to `given:` |
| Mock verification in `given:` | Move to `then:` |
| Test name: `testCalculate()` | Use full sentence: `"should calculate discount for premium customer"` |
| Hardcoded timestamps | Use `LocalDateTime.of(2025, 1, 15, 10, 30)` |
| Magic numbers | Use named variables or data table columns |

## Testing Strategy

### Integration Tests

- Test **only happy path** with typical example
- Focus on external interfaces
- Keep mocking minimal

### Unit Tests

- Cover **edge cases, errors, boundaries**
- Use `where:` blocks for variations
- One behavior per test

### Validation Example

```groovy
def "should reject invalid email: #reason"() {
    expect:
    !validator.isValid(email)

    where:
    email              | reason
    null               | "null"
    ""                 | "empty"
    "no-at-sign"       | "missing @"
    "a" * 255 + "@x"   | "too long"
}

def "should accept valid email: #email"() {
    expect:
    validator.isValid(email)

    where:
    email << ["user@example.com", "a@b.co", "user+tag@example.com"]
}
```

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Copy-paste is faster" | Refactoring takes 2 min, maintaining duplicates takes hours |
| "I'll consolidate later" | Later never comes, duplication stays |
| "These are slightly different" | Different inputs = perfect for `where:` block |
| "I'm under time pressure" | Bad tests slow you down more than writing good ones |
| "Each test is simple" | Simple + duplicated = maintenance nightmare |
| "I need more coverage" | 10 separate tests ≠ better than 1 parameterized test |

## Red Flags Checklist

Before writing a test, check:

- [ ] Am I testing similar behavior with different inputs?
- [ ] Does this look like my previous 2 tests?
- [ ] Am I about to copy-paste-modify?
- [ ] Could these be rows in a data table?

**If ANY are true → Use where: block**

## Real-World Impact

**Before data-driven testing:**

- 47 test methods for validation logic
- 800+ lines of test code
- 3 hours to add new validation rule

**After data-driven testing:**

- 8 test methods (6x consolidation)
- 200 lines of test code
- 15 minutes to add new validation rule

Data-driven testing isn't optional. It's the difference between maintainable and unmaintainable test suites.
