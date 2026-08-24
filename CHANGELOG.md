# Changelog

## unreleased

## 0.2.0 (2026-08-23)

### Added

- Nested fields. An unquoted dotted field name is a path: `first.second: foo`
  yields one `nested` node per dot, wrapping the comparison at the leaf, and the
  operator travels down with it.

  ```elixir
  %{"type" => "nested", "path" => "first",
    "term" => %{"type" => "comparison", "field" => "second", "operator" => "=", ...}}
  ```

  `nested` recurses through `"term"`, the same convention `not` and `group`
  already use, so an existing walker descends it without changes. Empty segments
  are rejected (`a.`, `a..b`), and a leading dot or digit still cannot start a
  field name.

- Quoted field names: `"first.second": foo`. Quoting makes the name literal —
  its dots are characters, not separators — so it stays a plain `comparison`
  with `"field" => "first.second"`. This is how you address a field whose name
  genuinely contains dots, and it also allows characters an unquoted name
  cannot hold, such as spaces.
- Bracketed value lists: `field:[a,b]` is equivalent to `field:(a OR b)` and
  produces the same `value_list` AST. Whitespace around the comma is optional,
  elements may be quoted or globs, and a single-element list (`field:[a]`) is
  valid.

### Fixed

- Underscored the unused `error` and `acc` bindings in the generated parser.
  Regenerating `lib/kql.ex` emitted nine warnings, which
  `mix compile --warnings-as-errors` rejects. These are reapplied by hand after
  each `mix compile.nimble` run.

### Notes

Every query valid in 0.1.0 parses to the same AST. Neither dotted nor quoted
field names parsed at all in 0.1.0, so the `nested` node cannot appear for any
query that previously worked: an undotted `make:foo` is still a bare
`comparison`.

Because `[`, `]` and `,` remain legal unquoted-value characters, a value that
merely looks like a list keeps parsing as a value: `field:[a]x` is the value
`[a]x`, and an unclosed `field:[a,b` is the value `[a,b`. A bracketed list is
recognised only when nothing else follows the closing bracket. Inside a list, a
literal `,` or `]` must be quoted or escaped, as a literal paren already must be
inside `( ... )`.

## 0.1.0 (2025-11-25)

- Initial release
