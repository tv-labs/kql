<!-- badges -->

[![Hex.pm Version](http://img.shields.io/hexpm/v/kql.svg?style=flat&logo=elixir)](https://hex.pm/packages/kql)
[![Hex docs](http://img.shields.io/badge/hexdocs.pm/kql-blue.svg?logo=elixir)](https://hexdocs.pm/kql)
[![License](http://img.shields.io/hexpm/l/kql.svg?style=flat)](./LICENSE)

# KQL

You're reading the main branch's readme. Please visit
[hexdocs](https://hexdocs.pm/kql) for the latest published documentation.

<!-- MDOC !-->

Parser for a simplified version of the [Kibana query language](https://www.elastic.co/docs/explore-analyze/query-filter/languages/kql) into an AST.

## What is supported?

- Comparison operators: `>`, `>=`, `<`, `<=`, `:`
- Quoted and unquoted values, including escape characters: `make:"foo bar"`, `make:foo\ bar`
- Not, and, & or operators: `NOT make:foo`, `make:foo AND model:bar`, `make:foo OR model:bar`
- Grouping expressions with `()`: `make:foo OR (make:bar AND model:bar)`
- UTF-8 values: `make:苹果`
- Glob values: `make:foo*`
- Value lists: `make: (foo OR bar)`, `make: [foo, bar]`
- Dots as ordinary field-name characters: `first.second: foo` parses, yielding
  the field name `"first.second"` — one flat string, no path structure

## What is missing?

- Nested fields. A dotted name is not resolved as a path: the AST carries
  `"field" => "first.second"` and nothing distinguishes it from a field
  literally named `first.second`. Callers that need segments must split it
  themselves.
- Matching multiple fields (glob values in field name): `make*:foo`
- Querying nested fields: `make:{ first: foo and second: bar }`

## Installation

```elixir
def deps do
  [
    {:kql, "~> 0.2.0"}
  ]
end
```

## Examples

```elixir
iex> KQL.parse("make:foo")
{:ok, %{
  "ast" => %{
    "field" => "make",
    "operator" => "=",
    "type" => "comparison",
    "value" => %{
      "type" => "value",
      "term" => "foo",
      "glob" => false,
      "quoted" => false
    }
  },
  "meta" => %{
    "original_query" => "make:foo",
    "version" => "0.2.0"
  }
}}
```

Globs are supported too:

```elixir
iex> KQL.parse("make:A* AND model:*X")
{:ok, %{
  "ast" => %{
    "type" => "and",
    "terms" => [%{
      "type" => "comparison",
      "field" => "make",
      "operator" => "=",
      "value" => %{
        "type" => "value",
        "term" => "A*",
        "glob" => true,
        "quoted" => false
      }
    },
    %{
      "type" => "comparison",
      "field" => "model",
      "operator" => "=",
      "value" => %{
        "type" => "value",
        "term" => "*X",
        "glob" => true,
        "quoted" => false
      }
    }]
  },
  "meta" => %{
    "original_query" => "make:A* AND model:*X",
    "version" => "0.2.0"
  }
}}
```
