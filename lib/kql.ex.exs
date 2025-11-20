defmodule KQL do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @version Mix.Project.config()[:version]

  @doc """
  Parses a KQL query into a JSON serializable AST structure.
  """
  def parse(input) when is_binary(input) do
    case parse_query(input) do
      {:ok, [result], "", _, _, _} -> {:ok, transform_ast(result, %{"original_query" => input})}
      {:ok, [_result], remaining, _, _, _} -> {:error, "Unexpected input: #{remaining}"}
      {:error, reason, _rest, _context, _line, _column} -> {:error, reason}
    end
  end

  @doc """
  Same as `parse/1`, but raises an error if the query is invalid.
  """
  def parse!(input) when is_binary(input) do
    case parse(input) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  defp transform_ast(ast, meta) do
    %{
      "meta" => Map.put(meta, "version", @version),
      "ast" => transform_tagged_ast(ast)
    }
  end

  defp transform_tagged_ast({:or, terms}) do
    %{"type" => "or", "terms" => Enum.map(terms, &transform_tagged_ast/1)}
  end

  defp transform_tagged_ast({:and, terms}) do
    %{"type" => "and", "terms" => Enum.map(terms, &transform_tagged_ast/1)}
  end

  defp transform_tagged_ast({:not, [term]}) do
    %{"type" => "not", "term" => transform_tagged_ast(term)}
  end

  defp transform_tagged_ast({:group, [term]}) do
    %{"type" => "group", "term" => transform_tagged_ast(term)}
  end

  defp transform_tagged_ast({:comparison, [{:field, field}, {:operator, operator}, value]}) do
    %{
      "type" => "comparison",
      "field" => field,
      "operator" => to_string(operator),
      "value" => transform_tagged_ast(value)
    }
  end

  defp transform_tagged_ast({:value_list, values}) do
    %{"type" => "value_list", "terms" => Enum.map(values, &transform_tagged_ast/1)}
  end

  defp transform_tagged_ast({:value, [quoted: value]}) do
    %{"type" => "value", "term" => value, "glob" => false, "quoted" => true}
  end

  defp transform_tagged_ast({:value, [unquoted: value]}) do
    %{"type" => "value", "term" => value, "glob" => false, "quoted" => false}
  end

  defp transform_tagged_ast({:value, [glob: value]}) do
    %{"type" => "value", "term" => value, "glob" => true, "quoted" => false}
  end

  defp transform_tagged_ast(other) do
    raise "Unexpected ast node: #{inspect(other)}"
  end

  # parsec:KQL
  import NimbleParsec

  case_insensitive_utf8_match = fn word ->
    word
    |> String.to_charlist()
    |> Enum.reduce(empty(), fn x, acc ->
      utf8_char(acc, [x, x - ?a + ?A])
    end)
    |> wrap()
    |> label(word <> " word")
  end

  whitespace =
    [?\s, ?\t, ?\n, ?\r]
    |> utf8_char()
    |> times(min: 1)
    |> ignore()
    |> label("whitespace")

  optional_whitespace =
    [?\s, ?\t, ?\n, ?\r]
    |> utf8_char()
    |> times(min: 0)
    |> ignore()
    |> label("optional whitespace")

  escaped_character =
    [?\\]
    |> utf8_char()
    |> ignore()
    |> utf8_char([])
    |> label("escaped character")

  # Matches all characters except those needing to be escaped: \():<>"*
  unescaped_character =
    [
      # 33 (!)
      ?!,
      # 35-39 (# $ % & ' - between " and ()
      ?#..?',
      # 43-57 (+ to 9 - skip *, between ) and :)
      ?+..?9,
      # 59 (; - after :)
      ?;,
      # 61 (= - between < and >)
      ?=,
      # 63-91 (? to [ - after > to before \)
      ??..?[,
      # 93+ (] onwards - after \)
      ?]..0x10FFFF
    ]
    |> utf8_char()
    |> label("unescaped character")

  field_name =
    [?0..?9, ?-]
    |> utf8_char()
    |> lookahead_not()
    |> utf8_string([?a..?z, ?A..?Z, ?0..?9, ?_, ?-], min: 1)
    |> unwrap_and_tag(:field)
    |> label("field name")

  quoted_value =
    "\""
    |> string()
    |> ignore()
    |> utf8_string([{:not, ?"}], min: 1)
    |> ignore(string("\""))
    |> unwrap_and_tag(:quoted)
    |> tag(:value)
    |> label("quoted value")

  # Unquoted characters that can appear in glob patterns
  unquoted_char =
    choice([
      escaped_character,
      unescaped_character
    ])

  unquoted_value =
    unquoted_char
    |> times(min: 1)
    |> reduce({List, :to_string, []})
    |> unwrap_and_tag(:unquoted)
    |> tag(:value)
    |> label("unquoted value")

  # Shared pattern for asterisk and non-asterisk chars after initial match
  glob_tail =
    [
      unquoted_char,
      utf8_char([?*])
    ]
    |> choice()
    |> repeat()

  # Matches globs that are a suffix to a value: value*, value*suffix
  suffix_glob =
    unquoted_char
    |> times(min: 1)
    |> utf8_char([?*])
    |> concat(glob_tail)
    |> reduce({List, :to_string, []})

  # Matches globs that are a prefix to a value: *, *value, *value*
  prefix_glob =
    [?*]
    |> utf8_char()
    |> concat(glob_tail)
    |> reduce({List, :to_string, []})

  glob_value =
    [suffix_glob, prefix_glob]
    |> choice()
    |> unwrap_and_tag(:glob)
    |> tag(:value)
    |> label("glob value")

  value =
    [quoted_value, glob_value, unquoted_value]
    |> choice()
    |> label("value")

  value_list =
    "("
    |> string()
    |> ignore()
    |> ignore(optional_whitespace)
    |> concat(value)
    |> times(
      whitespace
      |> ignore()
      |> ignore(case_insensitive_utf8_match.("or"))
      |> ignore(whitespace)
      |> concat(value),
      min: 1
    )
    |> ignore(optional_whitespace)
    |> ignore(string(")"))
    |> tag(:value_list)
    |> label("value list")

  comparison_op =
    [
      ">=" |> string() |> replace(:>=),
      "<=" |> string() |> replace(:<=),
      ">" |> string() |> replace(:>),
      "<" |> string() |> replace(:<),
      ":" |> string() |> replace(:=)
    ]
    |> choice()
    |> unwrap_and_tag(:operator)
    |> label("comparison operator")

  defcombinatorp(
    :base_expr,
    field_name
    |> ignore(optional_whitespace)
    |> concat(comparison_op)
    |> ignore(optional_whitespace)
    |> concat(choice([value_list, value]))
    |> tag(:comparison)
    |> label("comparison")
  )

  defcombinatorp(
    :group_expr,
    choice([
      "("
      |> string()
      |> ignore()
      |> ignore(optional_whitespace)
      |> parsec(:or_expr)
      |> ignore(optional_whitespace)
      |> ignore(string(")"))
      |> tag(:group)
      |> label("group expression"),

      # Not "group" expression, must be field comparison
      parsec(:base_expr)
    ])
  )

  defcombinatorp(
    :not_expr,
    choice([
      "not"
      |> case_insensitive_utf8_match.()
      |> ignore()
      |> ignore(whitespace)
      |> parsec(:not_expr)
      |> tag(:not)
      |> label("not expression"),

      # Not "not" expression, check next expression type in precedence order
      parsec(:group_expr)
    ])
  )

  defcombinatorp(
    :and_expr,
    choice([
      :not_expr
      |> parsec()
      |> times(
        optional_whitespace
        |> ignore()
        |> ignore(case_insensitive_utf8_match.("and"))
        |> ignore(whitespace)
        |> parsec(:not_expr),
        min: 1
      )
      |> tag(:and)
      |> label("and expression"),

      # Not "and" expression, check next expression type in precedence order
      parsec(:not_expr)
    ])
  )

  defcombinatorp(
    :or_expr,
    choice([
      :and_expr
      |> parsec()
      |> times(
        optional_whitespace
        |> ignore()
        |> ignore(case_insensitive_utf8_match.("or"))
        |> ignore(whitespace)
        |> parsec(:and_expr),
        min: 1
      )
      |> tag(:or)
      |> label("or expression"),

      # Not "or" expression, check next expression type in precedence order
      parsec(:and_expr)
    ])
  )

  defparsecp(
    :parse_query,
    optional_whitespace
    |> ignore()
    |> parsec(:or_expr)
    |> ignore(optional_whitespace)
    |> eos()
  )

  # parsec:KQL
end
