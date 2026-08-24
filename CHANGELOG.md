# Changelog

## unreleased

## 0.2.0 (2026-08-23)

### Added

- Dots are legal within a field name, so fields can be namespaced:
  `first.second: foo`, `first.second.third: foo`. A dot may not be the first
  character, and a dotted name parses as a single field name — the parser does
  not interpret it as a nested path.
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

Both syntax additions are backward compatible — every query valid in 0.1.0
parses to the same AST.

Because `[`, `]` and `,` remain legal unquoted-value characters, a value that
merely looks like a list keeps parsing as a value: `field:[a]x` is the value
`[a]x`, and an unclosed `field:[a,b` is the value `[a,b`. A bracketed list is
recognised only when nothing else follows the closing bracket. Inside a list, a
literal `,` or `]` must be quoted or escaped, as a literal paren already must be
inside `( ... )`.

## 0.1.0 (2025-11-25)

- Initial release
