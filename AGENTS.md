# Agents

## Project Overview

KQL is an Elixir library that parses a simplified version of the Kibana Query Language (KQL) into a JSON-serializable AST. The parser handles comparison operators, logical operators (AND, OR, NOT), grouping, glob patterns, and value lists.

## Architecture

### Parser Generation with NimbleParsec

The core parser is built using NimbleParsec, a parser combinator library. The parser definition lives in two files:

- `lib/kql.ex.exs` - Source file containing NimbleParsec combinators that define the grammar
- `lib/kql.ex` - Generated parser code (*NEVER* EDIT and  *NEVER* READ, this is generated code)

The parser uses a recursive descent approach with the following operator precedence (highest to lowest):
1. Grouping with `()`
2. NOT expressions
3. AND expressions
4. OR expressions

### AST Structure

The parser produces a tagged tuple AST that is then transformed into a JSON-serializable map structure with:
- `meta` - Contains `original_query` and `version`
- `ast` - The parsed query tree with nodes like `comparison`, `and`, `or`, `not`, `group`, `value`, `value_list`

## Development Commands

### Compiling the Parser

When you modify the parser grammar in `lib/kql.ex.exs`, you must regenerate the parser code:

```bash
mix compile.nimble
```

This runs `nimble_parsec.compile lib/kql.ex.exs` and then formats the generated `lib/kql.ex` file.

Reference parser logic: https://raw.githubusercontent.com/elastic/kibana/refs/heads/main/src/platform/packages/shared/kbn-es-query/src/kuery/grammar/grammar.peggy

### Running Tests

```bash
# Run all tests
mix test

# Run a specific test file
mix test test/kql_test.exs

# Run tests matching a pattern
mix test --only glob_patterns
```

The test suite uses property-based testing with StreamData to generate random valid queries and ensure they parse successfully.

### Linting and Formatting

```bash
# Format code
mix format

# Check formatting
mix format --check-formatted
```

## Parser Modification Guidelines

When modifying the parser grammar in `lib/kql.ex.exs`:

1. **Never edit or read `lib/kql.ex` directly** - it's generated code
2. After changes, run `mix compile.nimble` to regenerate the parser
3. The grammar uses `defcombinatorp` for internal parsers and `defparsecp` for the entry point
4. Use `label/2` to provide better error messages
5. Remember to update the `transform_tagged_ast/1` function if you add new AST node types
6. Add comprehensive test cases including property-based tests
7. **Always** use tidewave MCP tools for documentation and exploration

### Parser Structure

The parser is organized in layers:
- **base_expr**: Field comparisons (e.g., `make:foo`)
- **group_expr**: Parenthesized expressions or base expressions
- **not_expr**: NOT operations or group expressions
- **and_expr**: AND operations or not expressions
- **or_expr**: OR operations (lowest precedence) or and expressions
- **parse_query**: Entry point that wraps or_expr with whitespace handling

## Testing Strategy

The project uses a dual testing approach:

1. **Unit tests**: Explicit test cases for specific features and edge cases
2. **Property-based tests**: Generates random valid queries to ensure the parser never crashes on valid input

The property-based generator respects a maximum depth (`@max_query_depth = 5`) to prevent generating extremely deep nested queries.
