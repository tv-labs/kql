# Generated from lib/kql.ex.exs, do not edit.
# Generated at 2025-11-19 21:26:12Z.

defmodule KQL do
  @moduledoc """
  Parser for a simplified version of the [Kibana query language](https://www.elastic.co/docs/explore-analyze/query-filter/languages/kql) into an AST.

  ## What is supported?

  - Comparison operators: `>`, `>=`, `<`, `<=`, `:`
  - Quoted and unquoted values, including escape characters: `make:"foo bar"`, `make:foo\ bar`
  - Not, and, & or operators: `NOT make:foo`, `make:foo AND model:bar`, `make:foo OR model:bar`
  - Grouping expressions with `()`: `make:foo OR (make:bar AND model:bar)`
  - UTF-8 values: `make:苹果`
  - Glob values: `make:foo*`
  - Value lists: `make: (foo OR bar)`

  ## What is missing?

  - Nested fields: `first.second: foo`
  - Matching multiple fields (glob values in field name): `make*:foo`
  - Querying nested fields: `make:{ first: foo and second: bar }`
  """

  @version 1

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

  @doc """
  Parses the given `binary` as parse_query.

  Returns `{:ok, [token], rest, context, position, byte_offset}` or
  `{:error, reason, rest, context, line, byte_offset}` where `position`
  describes the location of the parse_query (start position) as `{line, offset_to_start_of_line}`.

  To column where the error occurred can be inferred from `byte_offset - offset_to_start_of_line`.

  ## Options

    * `:byte_offset` - the byte offset for the whole binary, defaults to 0
    * `:line` - the line and the byte offset into that line, defaults to `{1, byte_offset}`
    * `:context` - the initial context value. It will be converted to a map

  """
  @spec parse_query(binary, keyword) ::
          {:ok, [term], rest, context, line, byte_offset}
          | {:error, reason, rest, context, line, byte_offset}
        when line: {pos_integer, byte_offset},
             byte_offset: non_neg_integer,
             rest: binary,
             reason: String.t(),
             context: map
  def parse_query(binary, opts \\ []) when is_binary(binary) do
    context = Map.new(Keyword.get(opts, :context, []))
    byte_offset = Keyword.get(opts, :byte_offset, 0)

    line =
      case Keyword.get(opts, :line, 1) do
        {_, _} = line -> line
        line -> {line, byte_offset}
      end

    case parse_query__0(binary, [], [], context, line, byte_offset) do
      {:ok, acc, rest, context, line, offset} ->
        {:ok, :lists.reverse(acc), rest, context, line, offset}

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp parse_query__0(rest, acc, stack, context, line, offset) do
    parse_query__1(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_query__1(rest, acc, stack, context, line, offset) do
    parse_query__2(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_query__2(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    parse_query__4(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_query__2(rest, acc, stack, context, line, offset) do
    parse_query__3(rest, acc, stack, context, line, offset)
  end

  defp parse_query__4(rest, acc, stack, context, line, offset) do
    parse_query__2(rest, acc, stack, context, line, offset)
  end

  defp parse_query__3(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_query__5(rest, acc, stack, context, line, offset)
  end

  defp parse_query__5(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_query__6(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_query__6(rest, acc, stack, context, line, offset) do
    case or_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        parse_query__7(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp parse_query__7(rest, acc, stack, context, line, offset) do
    parse_query__8(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_query__8(rest, acc, stack, context, line, offset) do
    parse_query__9(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_query__9(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    parse_query__11(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_query__9(rest, acc, stack, context, line, offset) do
    parse_query__10(rest, acc, stack, context, line, offset)
  end

  defp parse_query__11(rest, acc, stack, context, line, offset) do
    parse_query__9(rest, acc, stack, context, line, offset)
  end

  defp parse_query__10(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_query__12(rest, acc, stack, context, line, offset)
  end

  defp parse_query__12(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_query__13(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_query__13(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_query__14("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp parse_query__13(rest, _acc, _stack, context, line, offset) do
    {:error, "expected end of string", rest, context, line, offset}
  end

  defp parse_query__14(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end

  defp or_expr__0(rest, acc, stack, context, line, offset) do
    or_expr__5(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp or_expr__2(rest, acc, stack, context, line, offset) do
    case and_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        or_expr__3(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp or_expr__3(rest, acc, [_, previous_acc | stack], context, line, offset) do
    or_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp or_expr__4(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    or_expr__2(rest, [], stack, context, line, offset)
  end

  defp or_expr__5(rest, acc, stack, context, line, offset) do
    or_expr__6(rest, [], [acc | stack], context, line, offset)
  end

  defp or_expr__6(rest, acc, stack, context, line, offset) do
    case and_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        or_expr__7(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = _error ->
        [acc | stack] = stack
        or_expr__4(rest, acc, stack, context, line, offset)
    end
  end

  defp or_expr__7(rest, acc, stack, context, line, offset) do
    or_expr__8(rest, [], [acc | stack], context, line, offset)
  end

  defp or_expr__8(rest, acc, stack, context, line, offset) do
    or_expr__9(rest, [], [acc | stack], context, line, offset)
  end

  defp or_expr__9(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    or_expr__11(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp or_expr__9(rest, acc, stack, context, line, offset) do
    or_expr__10(rest, acc, stack, context, line, offset)
  end

  defp or_expr__11(rest, acc, stack, context, line, offset) do
    or_expr__9(rest, acc, stack, context, line, offset)
  end

  defp or_expr__10(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    or_expr__12(rest, acc, stack, context, line, offset)
  end

  defp or_expr__12(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    or_expr__13(rest, [] ++ acc, stack, context, line, offset)
  end

  defp or_expr__13(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 111 or x0 === 79) and (x1 === 114 or x1 === 82) do
    or_expr__14(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp or_expr__13(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    or_expr__4(rest, acc, stack, context, line, offset)
  end

  defp or_expr__14(rest, acc, stack, context, line, offset) do
    or_expr__15(rest, [], [acc | stack], context, line, offset)
  end

  defp or_expr__15(rest, acc, stack, context, line, offset) do
    or_expr__16(rest, [], [acc | stack], context, line, offset)
  end

  defp or_expr__16(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    or_expr__17(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp or_expr__16(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    or_expr__4(rest, acc, stack, context, line, offset)
  end

  defp or_expr__17(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    or_expr__19(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp or_expr__17(rest, acc, stack, context, line, offset) do
    or_expr__18(rest, acc, stack, context, line, offset)
  end

  defp or_expr__19(rest, acc, stack, context, line, offset) do
    or_expr__17(rest, acc, stack, context, line, offset)
  end

  defp or_expr__18(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    or_expr__20(rest, acc, stack, context, line, offset)
  end

  defp or_expr__20(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    or_expr__21(rest, [] ++ acc, stack, context, line, offset)
  end

  defp or_expr__21(rest, acc, stack, context, line, offset) do
    case and_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        or_expr__22(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = _error ->
        [acc | stack] = stack
        or_expr__4(rest, acc, stack, context, line, offset)
    end
  end

  defp or_expr__22(rest, acc, stack, context, line, offset) do
    or_expr__24(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp or_expr__24(rest, acc, stack, context, line, offset) do
    or_expr__25(rest, [], [acc | stack], context, line, offset)
  end

  defp or_expr__25(rest, acc, stack, context, line, offset) do
    or_expr__26(rest, [], [acc | stack], context, line, offset)
  end

  defp or_expr__26(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    or_expr__28(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp or_expr__26(rest, acc, stack, context, line, offset) do
    or_expr__27(rest, acc, stack, context, line, offset)
  end

  defp or_expr__28(rest, acc, stack, context, line, offset) do
    or_expr__26(rest, acc, stack, context, line, offset)
  end

  defp or_expr__27(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    or_expr__29(rest, acc, stack, context, line, offset)
  end

  defp or_expr__29(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    or_expr__30(rest, [] ++ acc, stack, context, line, offset)
  end

  defp or_expr__30(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 111 or x0 === 79) and (x1 === 114 or x1 === 82) do
    or_expr__31(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp or_expr__30(rest, acc, stack, context, line, offset) do
    or_expr__23(rest, acc, stack, context, line, offset)
  end

  defp or_expr__31(rest, acc, stack, context, line, offset) do
    or_expr__32(rest, [], [acc | stack], context, line, offset)
  end

  defp or_expr__32(rest, acc, stack, context, line, offset) do
    or_expr__33(rest, [], [acc | stack], context, line, offset)
  end

  defp or_expr__33(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    or_expr__34(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp or_expr__33(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    or_expr__23(rest, acc, stack, context, line, offset)
  end

  defp or_expr__34(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    or_expr__36(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp or_expr__34(rest, acc, stack, context, line, offset) do
    or_expr__35(rest, acc, stack, context, line, offset)
  end

  defp or_expr__36(rest, acc, stack, context, line, offset) do
    or_expr__34(rest, acc, stack, context, line, offset)
  end

  defp or_expr__35(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    or_expr__37(rest, acc, stack, context, line, offset)
  end

  defp or_expr__37(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    or_expr__38(rest, [] ++ acc, stack, context, line, offset)
  end

  defp or_expr__38(rest, acc, stack, context, line, offset) do
    case and_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        or_expr__39(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = _error ->
        or_expr__23(rest, acc, stack, context, line, offset)
    end
  end

  defp or_expr__23(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    or_expr__40(rest, acc, stack, context, line, offset)
  end

  defp or_expr__39(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    or_expr__24(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp or_expr__40(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    or_expr__41(rest, [or: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp or_expr__41(rest, acc, [_, previous_acc | stack], context, line, offset) do
    or_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp or_expr__1(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end

  defp and_expr__0(rest, acc, stack, context, line, offset) do
    and_expr__5(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp and_expr__2(rest, acc, stack, context, line, offset) do
    case not_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        and_expr__3(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp and_expr__3(rest, acc, [_, previous_acc | stack], context, line, offset) do
    and_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp and_expr__4(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    and_expr__2(rest, [], stack, context, line, offset)
  end

  defp and_expr__5(rest, acc, stack, context, line, offset) do
    and_expr__6(rest, [], [acc | stack], context, line, offset)
  end

  defp and_expr__6(rest, acc, stack, context, line, offset) do
    case not_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        and_expr__7(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = _error ->
        [acc | stack] = stack
        and_expr__4(rest, acc, stack, context, line, offset)
    end
  end

  defp and_expr__7(rest, acc, stack, context, line, offset) do
    and_expr__8(rest, [], [acc | stack], context, line, offset)
  end

  defp and_expr__8(rest, acc, stack, context, line, offset) do
    and_expr__9(rest, [], [acc | stack], context, line, offset)
  end

  defp and_expr__9(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    and_expr__11(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp and_expr__9(rest, acc, stack, context, line, offset) do
    and_expr__10(rest, acc, stack, context, line, offset)
  end

  defp and_expr__11(rest, acc, stack, context, line, offset) do
    and_expr__9(rest, acc, stack, context, line, offset)
  end

  defp and_expr__10(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    and_expr__12(rest, acc, stack, context, line, offset)
  end

  defp and_expr__12(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    and_expr__13(rest, [] ++ acc, stack, context, line, offset)
  end

  defp and_expr__13(
         <<x0::utf8, x1::utf8, x2::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 97 or x0 === 65) and (x1 === 110 or x1 === 78) and (x2 === 100 or x2 === 68) do
    and_expr__14(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>) + byte_size(<<x2::utf8>>)
    )
  end

  defp and_expr__13(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    and_expr__4(rest, acc, stack, context, line, offset)
  end

  defp and_expr__14(rest, acc, stack, context, line, offset) do
    and_expr__15(rest, [], [acc | stack], context, line, offset)
  end

  defp and_expr__15(rest, acc, stack, context, line, offset) do
    and_expr__16(rest, [], [acc | stack], context, line, offset)
  end

  defp and_expr__16(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    and_expr__17(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp and_expr__16(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    and_expr__4(rest, acc, stack, context, line, offset)
  end

  defp and_expr__17(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    and_expr__19(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp and_expr__17(rest, acc, stack, context, line, offset) do
    and_expr__18(rest, acc, stack, context, line, offset)
  end

  defp and_expr__19(rest, acc, stack, context, line, offset) do
    and_expr__17(rest, acc, stack, context, line, offset)
  end

  defp and_expr__18(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    and_expr__20(rest, acc, stack, context, line, offset)
  end

  defp and_expr__20(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    and_expr__21(rest, [] ++ acc, stack, context, line, offset)
  end

  defp and_expr__21(rest, acc, stack, context, line, offset) do
    case not_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        and_expr__22(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = _error ->
        [acc | stack] = stack
        and_expr__4(rest, acc, stack, context, line, offset)
    end
  end

  defp and_expr__22(rest, acc, stack, context, line, offset) do
    and_expr__24(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp and_expr__24(rest, acc, stack, context, line, offset) do
    and_expr__25(rest, [], [acc | stack], context, line, offset)
  end

  defp and_expr__25(rest, acc, stack, context, line, offset) do
    and_expr__26(rest, [], [acc | stack], context, line, offset)
  end

  defp and_expr__26(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    and_expr__28(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp and_expr__26(rest, acc, stack, context, line, offset) do
    and_expr__27(rest, acc, stack, context, line, offset)
  end

  defp and_expr__28(rest, acc, stack, context, line, offset) do
    and_expr__26(rest, acc, stack, context, line, offset)
  end

  defp and_expr__27(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    and_expr__29(rest, acc, stack, context, line, offset)
  end

  defp and_expr__29(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    and_expr__30(rest, [] ++ acc, stack, context, line, offset)
  end

  defp and_expr__30(
         <<x0::utf8, x1::utf8, x2::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 97 or x0 === 65) and (x1 === 110 or x1 === 78) and (x2 === 100 or x2 === 68) do
    and_expr__31(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>) + byte_size(<<x2::utf8>>)
    )
  end

  defp and_expr__30(rest, acc, stack, context, line, offset) do
    and_expr__23(rest, acc, stack, context, line, offset)
  end

  defp and_expr__31(rest, acc, stack, context, line, offset) do
    and_expr__32(rest, [], [acc | stack], context, line, offset)
  end

  defp and_expr__32(rest, acc, stack, context, line, offset) do
    and_expr__33(rest, [], [acc | stack], context, line, offset)
  end

  defp and_expr__33(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    and_expr__34(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp and_expr__33(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    and_expr__23(rest, acc, stack, context, line, offset)
  end

  defp and_expr__34(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    and_expr__36(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp and_expr__34(rest, acc, stack, context, line, offset) do
    and_expr__35(rest, acc, stack, context, line, offset)
  end

  defp and_expr__36(rest, acc, stack, context, line, offset) do
    and_expr__34(rest, acc, stack, context, line, offset)
  end

  defp and_expr__35(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    and_expr__37(rest, acc, stack, context, line, offset)
  end

  defp and_expr__37(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    and_expr__38(rest, [] ++ acc, stack, context, line, offset)
  end

  defp and_expr__38(rest, acc, stack, context, line, offset) do
    case not_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        and_expr__39(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = _error ->
        and_expr__23(rest, acc, stack, context, line, offset)
    end
  end

  defp and_expr__23(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    and_expr__40(rest, acc, stack, context, line, offset)
  end

  defp and_expr__39(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    and_expr__24(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp and_expr__40(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    and_expr__41(rest, [and: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp and_expr__41(rest, acc, [_, previous_acc | stack], context, line, offset) do
    and_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp and_expr__1(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end

  defp not_expr__0(rest, acc, stack, context, line, offset) do
    not_expr__5(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp not_expr__2(rest, acc, stack, context, line, offset) do
    case group_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        not_expr__3(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp not_expr__3(rest, acc, [_, previous_acc | stack], context, line, offset) do
    not_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp not_expr__4(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    not_expr__2(rest, [], stack, context, line, offset)
  end

  defp not_expr__5(rest, acc, stack, context, line, offset) do
    not_expr__6(rest, [], [acc | stack], context, line, offset)
  end

  defp not_expr__6(
         <<x0::utf8, x1::utf8, x2::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 110 or x0 === 78) and (x1 === 111 or x1 === 79) and (x2 === 116 or x2 === 84) do
    not_expr__7(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>) + byte_size(<<x2::utf8>>)
    )
  end

  defp not_expr__6(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    not_expr__4(rest, acc, stack, context, line, offset)
  end

  defp not_expr__7(rest, acc, stack, context, line, offset) do
    not_expr__8(rest, [], [acc | stack], context, line, offset)
  end

  defp not_expr__8(rest, acc, stack, context, line, offset) do
    not_expr__9(rest, [], [acc | stack], context, line, offset)
  end

  defp not_expr__9(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    not_expr__10(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp not_expr__9(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    not_expr__4(rest, acc, stack, context, line, offset)
  end

  defp not_expr__10(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    not_expr__12(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp not_expr__10(rest, acc, stack, context, line, offset) do
    not_expr__11(rest, acc, stack, context, line, offset)
  end

  defp not_expr__12(rest, acc, stack, context, line, offset) do
    not_expr__10(rest, acc, stack, context, line, offset)
  end

  defp not_expr__11(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    not_expr__13(rest, acc, stack, context, line, offset)
  end

  defp not_expr__13(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    not_expr__14(rest, [] ++ acc, stack, context, line, offset)
  end

  defp not_expr__14(rest, acc, stack, context, line, offset) do
    case not_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        not_expr__15(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = _error ->
        [acc | stack] = stack
        not_expr__4(rest, acc, stack, context, line, offset)
    end
  end

  defp not_expr__15(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    not_expr__16(rest, [not: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp not_expr__16(rest, acc, [_, previous_acc | stack], context, line, offset) do
    not_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp not_expr__1(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end

  defp group_expr__0(rest, acc, stack, context, line, offset) do
    group_expr__5(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp group_expr__2(rest, acc, stack, context, line, offset) do
    case base_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        group_expr__3(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp group_expr__3(rest, acc, [_, previous_acc | stack], context, line, offset) do
    group_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp group_expr__4(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    group_expr__2(rest, [], stack, context, line, offset)
  end

  defp group_expr__5(rest, acc, stack, context, line, offset) do
    group_expr__6(rest, [], [acc | stack], context, line, offset)
  end

  defp group_expr__6(<<"(", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    group_expr__7(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp group_expr__6(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    group_expr__4(rest, acc, stack, context, line, offset)
  end

  defp group_expr__7(rest, acc, stack, context, line, offset) do
    group_expr__8(rest, [], [acc | stack], context, line, offset)
  end

  defp group_expr__8(rest, acc, stack, context, line, offset) do
    group_expr__9(rest, [], [acc | stack], context, line, offset)
  end

  defp group_expr__9(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    group_expr__11(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp group_expr__9(rest, acc, stack, context, line, offset) do
    group_expr__10(rest, acc, stack, context, line, offset)
  end

  defp group_expr__11(rest, acc, stack, context, line, offset) do
    group_expr__9(rest, acc, stack, context, line, offset)
  end

  defp group_expr__10(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    group_expr__12(rest, acc, stack, context, line, offset)
  end

  defp group_expr__12(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    group_expr__13(rest, [] ++ acc, stack, context, line, offset)
  end

  defp group_expr__13(rest, acc, stack, context, line, offset) do
    case or_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        group_expr__14(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = _error ->
        [acc | stack] = stack
        group_expr__4(rest, acc, stack, context, line, offset)
    end
  end

  defp group_expr__14(rest, acc, stack, context, line, offset) do
    group_expr__15(rest, [], [acc | stack], context, line, offset)
  end

  defp group_expr__15(rest, acc, stack, context, line, offset) do
    group_expr__16(rest, [], [acc | stack], context, line, offset)
  end

  defp group_expr__16(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    group_expr__18(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp group_expr__16(rest, acc, stack, context, line, offset) do
    group_expr__17(rest, acc, stack, context, line, offset)
  end

  defp group_expr__18(rest, acc, stack, context, line, offset) do
    group_expr__16(rest, acc, stack, context, line, offset)
  end

  defp group_expr__17(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    group_expr__19(rest, acc, stack, context, line, offset)
  end

  defp group_expr__19(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    group_expr__20(rest, [] ++ acc, stack, context, line, offset)
  end

  defp group_expr__20(<<")", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    group_expr__21(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp group_expr__20(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    group_expr__4(rest, acc, stack, context, line, offset)
  end

  defp group_expr__21(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    group_expr__22(rest, [group: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp group_expr__22(rest, acc, [_, previous_acc | stack], context, line, offset) do
    group_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp group_expr__1(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end

  defp base_expr__0(rest, acc, stack, context, line, offset) do
    base_expr__1(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__1(rest, acc, stack, context, line, offset) do
    base_expr__2(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__2(<<x0::utf8, _::binary>> = rest, _acc, _stack, context, line, offset)
       when (x0 >= 48 and x0 <= 57) or x0 === 45 do
    {:error, "did not expect field name while processing comparison", rest, context, line, offset}
  end

  defp base_expr__2(rest, acc, stack, context, line, offset) do
    base_expr__3(rest, acc, stack, context, line, offset)
  end

  defp base_expr__3(rest, acc, stack, context, line, offset) do
    base_expr__4(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__4(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    base_expr__5(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__4(rest, _acc, _stack, context, line, offset) do
    {:error, "expected field name while processing comparison", rest, context, line, offset}
  end

  defp base_expr__5(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    base_expr__7(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__5(rest, acc, stack, context, line, offset) do
    base_expr__6(rest, acc, stack, context, line, offset)
  end

  defp base_expr__7(rest, acc, stack, context, line, offset) do
    base_expr__5(rest, acc, stack, context, line, offset)
  end

  defp base_expr__6(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__8(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__8(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__9(
      rest,
      [
        field:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__9(rest, acc, stack, context, line, offset) do
    base_expr__10(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__10(rest, acc, stack, context, line, offset) do
    base_expr__11(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__11(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__13(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__11(rest, acc, stack, context, line, offset) do
    base_expr__12(rest, acc, stack, context, line, offset)
  end

  defp base_expr__13(rest, acc, stack, context, line, offset) do
    base_expr__11(rest, acc, stack, context, line, offset)
  end

  defp base_expr__12(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__14(rest, acc, stack, context, line, offset)
  end

  defp base_expr__14(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__15(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__15(rest, acc, stack, context, line, offset) do
    base_expr__16(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__16(<<">=", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__17(rest, [:>=] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp base_expr__16(<<"<=", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__17(rest, [:<=] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp base_expr__16(<<">", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__17(rest, [:>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__16(<<"<", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__17(rest, [:<] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__16(<<":", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__17(rest, [:=] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__16(rest, _acc, _stack, context, line, offset) do
    {:error, "expected comparison operator while processing comparison", rest, context, line,
     offset}
  end

  defp base_expr__17(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__18(
      rest,
      [
        operator:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__18(rest, acc, stack, context, line, offset) do
    base_expr__19(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__19(rest, acc, stack, context, line, offset) do
    base_expr__20(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__20(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__22(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__20(rest, acc, stack, context, line, offset) do
    base_expr__21(rest, acc, stack, context, line, offset)
  end

  defp base_expr__22(rest, acc, stack, context, line, offset) do
    base_expr__20(rest, acc, stack, context, line, offset)
  end

  defp base_expr__21(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__23(rest, acc, stack, context, line, offset)
  end

  defp base_expr__23(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__24(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__24(rest, acc, stack, context, line, offset) do
    base_expr__93(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__26(rest, acc, stack, context, line, offset) do
    base_expr__80(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__28(rest, acc, stack, context, line, offset) do
    base_expr__29(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__29(rest, acc, stack, context, line, offset) do
    base_expr__30(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__30(rest, acc, stack, context, line, offset) do
    base_expr__31(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__31(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__32(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__31(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__32(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__31(rest, _acc, _stack, context, line, offset) do
    {:error, "expected unquoted value while processing value inside comparison", rest, context,
     line, offset}
  end

  defp base_expr__32(rest, acc, stack, context, line, offset) do
    base_expr__34(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__34(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__35(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__34(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__35(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__34(rest, acc, stack, context, line, offset) do
    base_expr__33(rest, acc, stack, context, line, offset)
  end

  defp base_expr__33(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__36(rest, acc, stack, context, line, offset)
  end

  defp base_expr__35(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__34(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__36(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__37(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__37(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__38(
      rest,
      [
        unquoted:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__38(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__39(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__39(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__27(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__40(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__28(rest, [], stack, context, line, offset)
  end

  defp base_expr__41(rest, acc, stack, context, line, offset) do
    base_expr__42(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__42(rest, acc, stack, context, line, offset) do
    base_expr__43(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__43(rest, acc, stack, context, line, offset) do
    base_expr__59(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__45(rest, acc, stack, context, line, offset) do
    base_expr__46(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__46(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__47(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__46(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__40(rest, acc, stack, context, line, offset)
  end

  defp base_expr__47(rest, acc, stack, context, line, offset) do
    base_expr__49(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__49(rest, acc, stack, context, line, offset) do
    base_expr__54(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__51(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__52(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__51(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__48(rest, acc, stack, context, line, offset)
  end

  defp base_expr__52(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__50(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__53(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__51(rest, [], stack, context, line, offset)
  end

  defp base_expr__54(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__55(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__54(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__55(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__54(rest, acc, stack, context, line, offset) do
    base_expr__53(rest, acc, stack, context, line, offset)
  end

  defp base_expr__55(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__50(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__48(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__56(rest, acc, stack, context, line, offset)
  end

  defp base_expr__50(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__49(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__56(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__57(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__57(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__44(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__58(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__45(rest, [], stack, context, line, offset)
  end

  defp base_expr__59(rest, acc, stack, context, line, offset) do
    base_expr__60(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__60(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__61(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__60(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__61(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__60(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__58(rest, acc, stack, context, line, offset)
  end

  defp base_expr__61(rest, acc, stack, context, line, offset) do
    base_expr__63(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__63(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__64(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__63(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__64(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__63(rest, acc, stack, context, line, offset) do
    base_expr__62(rest, acc, stack, context, line, offset)
  end

  defp base_expr__62(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__65(rest, acc, stack, context, line, offset)
  end

  defp base_expr__64(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__63(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__65(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__66(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__65(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__58(rest, acc, stack, context, line, offset)
  end

  defp base_expr__66(rest, acc, stack, context, line, offset) do
    base_expr__68(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__68(rest, acc, stack, context, line, offset) do
    base_expr__73(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__70(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__71(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__70(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__67(rest, acc, stack, context, line, offset)
  end

  defp base_expr__71(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__69(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__72(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__70(rest, [], stack, context, line, offset)
  end

  defp base_expr__73(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__74(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__73(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__74(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__73(rest, acc, stack, context, line, offset) do
    base_expr__72(rest, acc, stack, context, line, offset)
  end

  defp base_expr__74(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__69(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__67(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__75(rest, acc, stack, context, line, offset)
  end

  defp base_expr__69(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__68(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__75(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__76(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__76(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__44(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__44(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__77(
      rest,
      [
        glob:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__77(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__78(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__78(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__27(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__79(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__41(rest, [], stack, context, line, offset)
  end

  defp base_expr__80(rest, acc, stack, context, line, offset) do
    base_expr__81(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__81(rest, acc, stack, context, line, offset) do
    base_expr__82(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__82(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__83(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__82(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__79(rest, acc, stack, context, line, offset)
  end

  defp base_expr__83(rest, acc, stack, context, line, offset) do
    base_expr__84(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__84(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__85(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__84(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__79(rest, acc, stack, context, line, offset)
  end

  defp base_expr__85(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__87(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__85(rest, acc, stack, context, line, offset) do
    base_expr__86(rest, acc, stack, context, line, offset)
  end

  defp base_expr__87(rest, acc, stack, context, line, offset) do
    base_expr__85(rest, acc, stack, context, line, offset)
  end

  defp base_expr__86(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__88(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__88(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__89(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__88(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__79(rest, acc, stack, context, line, offset)
  end

  defp base_expr__89(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__90(
      rest,
      [
        quoted:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__90(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__91(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__91(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__27(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__27(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__25(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__92(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__26(rest, [], stack, context, line, offset)
  end

  defp base_expr__93(rest, acc, stack, context, line, offset) do
    base_expr__94(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__94(<<"(", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__95(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__94(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__95(rest, acc, stack, context, line, offset) do
    base_expr__96(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__96(rest, acc, stack, context, line, offset) do
    base_expr__97(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__97(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__99(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__97(rest, acc, stack, context, line, offset) do
    base_expr__98(rest, acc, stack, context, line, offset)
  end

  defp base_expr__99(rest, acc, stack, context, line, offset) do
    base_expr__97(rest, acc, stack, context, line, offset)
  end

  defp base_expr__98(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__100(rest, acc, stack, context, line, offset)
  end

  defp base_expr__100(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__101(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__101(rest, acc, stack, context, line, offset) do
    base_expr__155(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__103(rest, acc, stack, context, line, offset) do
    base_expr__104(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__104(rest, acc, stack, context, line, offset) do
    base_expr__105(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__105(rest, acc, stack, context, line, offset) do
    base_expr__106(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__106(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__107(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__106(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__107(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__106(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__107(rest, acc, stack, context, line, offset) do
    base_expr__109(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__109(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__110(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__109(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__110(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__109(rest, acc, stack, context, line, offset) do
    base_expr__108(rest, acc, stack, context, line, offset)
  end

  defp base_expr__108(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__111(rest, acc, stack, context, line, offset)
  end

  defp base_expr__110(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__109(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__111(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__112(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__112(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__113(
      rest,
      [
        unquoted:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__113(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__114(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__114(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__102(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__115(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__103(rest, [], stack, context, line, offset)
  end

  defp base_expr__116(rest, acc, stack, context, line, offset) do
    base_expr__117(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__117(rest, acc, stack, context, line, offset) do
    base_expr__118(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__118(rest, acc, stack, context, line, offset) do
    base_expr__134(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__120(rest, acc, stack, context, line, offset) do
    base_expr__121(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__121(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__122(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__121(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__115(rest, acc, stack, context, line, offset)
  end

  defp base_expr__122(rest, acc, stack, context, line, offset) do
    base_expr__124(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__124(rest, acc, stack, context, line, offset) do
    base_expr__129(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__126(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__127(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__126(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__123(rest, acc, stack, context, line, offset)
  end

  defp base_expr__127(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__125(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__128(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__126(rest, [], stack, context, line, offset)
  end

  defp base_expr__129(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__130(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__129(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__130(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__129(rest, acc, stack, context, line, offset) do
    base_expr__128(rest, acc, stack, context, line, offset)
  end

  defp base_expr__130(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__125(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__123(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__131(rest, acc, stack, context, line, offset)
  end

  defp base_expr__125(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__124(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__131(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__132(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__132(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__119(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__133(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__120(rest, [], stack, context, line, offset)
  end

  defp base_expr__134(rest, acc, stack, context, line, offset) do
    base_expr__135(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__135(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__136(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__135(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__136(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__135(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__133(rest, acc, stack, context, line, offset)
  end

  defp base_expr__136(rest, acc, stack, context, line, offset) do
    base_expr__138(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__138(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__139(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__138(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__139(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__138(rest, acc, stack, context, line, offset) do
    base_expr__137(rest, acc, stack, context, line, offset)
  end

  defp base_expr__137(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__140(rest, acc, stack, context, line, offset)
  end

  defp base_expr__139(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__138(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__140(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__141(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__140(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__133(rest, acc, stack, context, line, offset)
  end

  defp base_expr__141(rest, acc, stack, context, line, offset) do
    base_expr__143(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__143(rest, acc, stack, context, line, offset) do
    base_expr__148(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__145(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__146(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__145(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__142(rest, acc, stack, context, line, offset)
  end

  defp base_expr__146(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__144(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__147(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__145(rest, [], stack, context, line, offset)
  end

  defp base_expr__148(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__149(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__148(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__149(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__148(rest, acc, stack, context, line, offset) do
    base_expr__147(rest, acc, stack, context, line, offset)
  end

  defp base_expr__149(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__144(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__142(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__150(rest, acc, stack, context, line, offset)
  end

  defp base_expr__144(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__143(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__150(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__151(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__151(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__119(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__119(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__152(
      rest,
      [
        glob:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__152(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__153(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__153(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__102(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__154(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__116(rest, [], stack, context, line, offset)
  end

  defp base_expr__155(rest, acc, stack, context, line, offset) do
    base_expr__156(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__156(rest, acc, stack, context, line, offset) do
    base_expr__157(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__157(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__158(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__157(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__154(rest, acc, stack, context, line, offset)
  end

  defp base_expr__158(rest, acc, stack, context, line, offset) do
    base_expr__159(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__159(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__160(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__159(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__154(rest, acc, stack, context, line, offset)
  end

  defp base_expr__160(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__162(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__160(rest, acc, stack, context, line, offset) do
    base_expr__161(rest, acc, stack, context, line, offset)
  end

  defp base_expr__162(rest, acc, stack, context, line, offset) do
    base_expr__160(rest, acc, stack, context, line, offset)
  end

  defp base_expr__161(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__163(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__163(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__164(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__163(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__154(rest, acc, stack, context, line, offset)
  end

  defp base_expr__164(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__165(
      rest,
      [
        quoted:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__165(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__166(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__166(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__102(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__102(rest, acc, stack, context, line, offset) do
    base_expr__167(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__167(rest, acc, stack, context, line, offset) do
    base_expr__168(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__168(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__169(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__168(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__169(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__171(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__169(rest, acc, stack, context, line, offset) do
    base_expr__170(rest, acc, stack, context, line, offset)
  end

  defp base_expr__171(rest, acc, stack, context, line, offset) do
    base_expr__169(rest, acc, stack, context, line, offset)
  end

  defp base_expr__170(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__172(rest, acc, stack, context, line, offset)
  end

  defp base_expr__172(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__173(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__173(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 111 or x0 === 79) and (x1 === 114 or x1 === 82) do
    base_expr__174(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__173(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__174(rest, acc, stack, context, line, offset) do
    base_expr__175(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__175(rest, acc, stack, context, line, offset) do
    base_expr__176(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__176(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__177(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__176(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__177(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__179(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__177(rest, acc, stack, context, line, offset) do
    base_expr__178(rest, acc, stack, context, line, offset)
  end

  defp base_expr__179(rest, acc, stack, context, line, offset) do
    base_expr__177(rest, acc, stack, context, line, offset)
  end

  defp base_expr__178(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__180(rest, acc, stack, context, line, offset)
  end

  defp base_expr__180(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__181(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__181(rest, acc, stack, context, line, offset) do
    base_expr__235(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__183(rest, acc, stack, context, line, offset) do
    base_expr__184(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__184(rest, acc, stack, context, line, offset) do
    base_expr__185(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__185(rest, acc, stack, context, line, offset) do
    base_expr__186(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__186(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__187(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__186(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__187(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__186(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__187(rest, acc, stack, context, line, offset) do
    base_expr__189(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__189(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__190(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__189(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__190(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__189(rest, acc, stack, context, line, offset) do
    base_expr__188(rest, acc, stack, context, line, offset)
  end

  defp base_expr__188(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__191(rest, acc, stack, context, line, offset)
  end

  defp base_expr__190(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__189(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__191(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__192(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__192(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__193(
      rest,
      [
        unquoted:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__193(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__194(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__194(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__182(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__195(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__183(rest, [], stack, context, line, offset)
  end

  defp base_expr__196(rest, acc, stack, context, line, offset) do
    base_expr__197(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__197(rest, acc, stack, context, line, offset) do
    base_expr__198(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__198(rest, acc, stack, context, line, offset) do
    base_expr__214(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__200(rest, acc, stack, context, line, offset) do
    base_expr__201(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__201(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__202(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__201(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__195(rest, acc, stack, context, line, offset)
  end

  defp base_expr__202(rest, acc, stack, context, line, offset) do
    base_expr__204(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__204(rest, acc, stack, context, line, offset) do
    base_expr__209(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__206(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__207(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__206(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__203(rest, acc, stack, context, line, offset)
  end

  defp base_expr__207(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__205(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__208(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__206(rest, [], stack, context, line, offset)
  end

  defp base_expr__209(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__210(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__209(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__210(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__209(rest, acc, stack, context, line, offset) do
    base_expr__208(rest, acc, stack, context, line, offset)
  end

  defp base_expr__210(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__205(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__203(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__211(rest, acc, stack, context, line, offset)
  end

  defp base_expr__205(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__204(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__211(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__212(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__212(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__199(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__213(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__200(rest, [], stack, context, line, offset)
  end

  defp base_expr__214(rest, acc, stack, context, line, offset) do
    base_expr__215(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__215(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__216(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__215(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__216(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__215(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__213(rest, acc, stack, context, line, offset)
  end

  defp base_expr__216(rest, acc, stack, context, line, offset) do
    base_expr__218(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__218(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__219(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__218(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__219(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__218(rest, acc, stack, context, line, offset) do
    base_expr__217(rest, acc, stack, context, line, offset)
  end

  defp base_expr__217(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__220(rest, acc, stack, context, line, offset)
  end

  defp base_expr__219(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__218(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__220(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__221(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__220(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__213(rest, acc, stack, context, line, offset)
  end

  defp base_expr__221(rest, acc, stack, context, line, offset) do
    base_expr__223(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__223(rest, acc, stack, context, line, offset) do
    base_expr__228(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__225(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__226(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__225(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__222(rest, acc, stack, context, line, offset)
  end

  defp base_expr__226(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__224(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__227(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__225(rest, [], stack, context, line, offset)
  end

  defp base_expr__228(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__229(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__228(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__229(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__228(rest, acc, stack, context, line, offset) do
    base_expr__227(rest, acc, stack, context, line, offset)
  end

  defp base_expr__229(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__224(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__222(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__230(rest, acc, stack, context, line, offset)
  end

  defp base_expr__224(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__223(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__230(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__231(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__231(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__199(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__199(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__232(
      rest,
      [
        glob:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__232(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__233(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__233(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__182(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__234(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__196(rest, [], stack, context, line, offset)
  end

  defp base_expr__235(rest, acc, stack, context, line, offset) do
    base_expr__236(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__236(rest, acc, stack, context, line, offset) do
    base_expr__237(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__237(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__238(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__237(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__234(rest, acc, stack, context, line, offset)
  end

  defp base_expr__238(rest, acc, stack, context, line, offset) do
    base_expr__239(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__239(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__240(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__239(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__234(rest, acc, stack, context, line, offset)
  end

  defp base_expr__240(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__242(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__240(rest, acc, stack, context, line, offset) do
    base_expr__241(rest, acc, stack, context, line, offset)
  end

  defp base_expr__242(rest, acc, stack, context, line, offset) do
    base_expr__240(rest, acc, stack, context, line, offset)
  end

  defp base_expr__241(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__243(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__243(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__244(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__243(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__234(rest, acc, stack, context, line, offset)
  end

  defp base_expr__244(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__245(
      rest,
      [
        quoted:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__245(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__246(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__246(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__182(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__182(rest, acc, stack, context, line, offset) do
    base_expr__248(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__248(rest, acc, stack, context, line, offset) do
    base_expr__249(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__249(rest, acc, stack, context, line, offset) do
    base_expr__250(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__250(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__251(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__250(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__247(rest, acc, stack, context, line, offset)
  end

  defp base_expr__251(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__253(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__251(rest, acc, stack, context, line, offset) do
    base_expr__252(rest, acc, stack, context, line, offset)
  end

  defp base_expr__253(rest, acc, stack, context, line, offset) do
    base_expr__251(rest, acc, stack, context, line, offset)
  end

  defp base_expr__252(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__254(rest, acc, stack, context, line, offset)
  end

  defp base_expr__254(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__255(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__255(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 111 or x0 === 79) and (x1 === 114 or x1 === 82) do
    base_expr__256(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__255(rest, acc, stack, context, line, offset) do
    base_expr__247(rest, acc, stack, context, line, offset)
  end

  defp base_expr__256(rest, acc, stack, context, line, offset) do
    base_expr__257(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__257(rest, acc, stack, context, line, offset) do
    base_expr__258(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__258(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__259(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__258(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__247(rest, acc, stack, context, line, offset)
  end

  defp base_expr__259(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__261(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__259(rest, acc, stack, context, line, offset) do
    base_expr__260(rest, acc, stack, context, line, offset)
  end

  defp base_expr__261(rest, acc, stack, context, line, offset) do
    base_expr__259(rest, acc, stack, context, line, offset)
  end

  defp base_expr__260(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__262(rest, acc, stack, context, line, offset)
  end

  defp base_expr__262(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__263(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__263(rest, acc, stack, context, line, offset) do
    base_expr__317(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__265(rest, acc, stack, context, line, offset) do
    base_expr__266(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__266(rest, acc, stack, context, line, offset) do
    base_expr__267(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__267(rest, acc, stack, context, line, offset) do
    base_expr__268(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__268(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__269(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__268(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__269(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__268(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__247(rest, acc, stack, context, line, offset)
  end

  defp base_expr__269(rest, acc, stack, context, line, offset) do
    base_expr__271(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__271(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__272(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__271(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__272(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__271(rest, acc, stack, context, line, offset) do
    base_expr__270(rest, acc, stack, context, line, offset)
  end

  defp base_expr__270(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__273(rest, acc, stack, context, line, offset)
  end

  defp base_expr__272(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__271(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__273(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__274(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__274(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__275(
      rest,
      [
        unquoted:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__275(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__276(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__276(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__264(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__277(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__265(rest, [], stack, context, line, offset)
  end

  defp base_expr__278(rest, acc, stack, context, line, offset) do
    base_expr__279(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__279(rest, acc, stack, context, line, offset) do
    base_expr__280(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__280(rest, acc, stack, context, line, offset) do
    base_expr__296(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__282(rest, acc, stack, context, line, offset) do
    base_expr__283(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__283(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__284(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__283(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__277(rest, acc, stack, context, line, offset)
  end

  defp base_expr__284(rest, acc, stack, context, line, offset) do
    base_expr__286(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__286(rest, acc, stack, context, line, offset) do
    base_expr__291(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__288(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__289(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__288(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__285(rest, acc, stack, context, line, offset)
  end

  defp base_expr__289(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__287(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__290(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__288(rest, [], stack, context, line, offset)
  end

  defp base_expr__291(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__292(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__291(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__292(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__291(rest, acc, stack, context, line, offset) do
    base_expr__290(rest, acc, stack, context, line, offset)
  end

  defp base_expr__292(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__287(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__285(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__293(rest, acc, stack, context, line, offset)
  end

  defp base_expr__287(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__286(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__293(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__294(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__294(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__281(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__295(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__282(rest, [], stack, context, line, offset)
  end

  defp base_expr__296(rest, acc, stack, context, line, offset) do
    base_expr__297(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__297(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__298(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__297(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__298(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__297(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__295(rest, acc, stack, context, line, offset)
  end

  defp base_expr__298(rest, acc, stack, context, line, offset) do
    base_expr__300(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__300(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__301(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__300(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__301(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__300(rest, acc, stack, context, line, offset) do
    base_expr__299(rest, acc, stack, context, line, offset)
  end

  defp base_expr__299(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__302(rest, acc, stack, context, line, offset)
  end

  defp base_expr__301(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__300(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__302(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__303(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__302(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__295(rest, acc, stack, context, line, offset)
  end

  defp base_expr__303(rest, acc, stack, context, line, offset) do
    base_expr__305(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__305(rest, acc, stack, context, line, offset) do
    base_expr__310(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__307(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__308(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__307(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__304(rest, acc, stack, context, line, offset)
  end

  defp base_expr__308(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__306(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__309(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__307(rest, [], stack, context, line, offset)
  end

  defp base_expr__310(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__311(
      rest,
      [x1] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x1 do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__310(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__311(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__310(rest, acc, stack, context, line, offset) do
    base_expr__309(rest, acc, stack, context, line, offset)
  end

  defp base_expr__311(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__306(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__304(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__312(rest, acc, stack, context, line, offset)
  end

  defp base_expr__306(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__305(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__312(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__313(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__313(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__281(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__281(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__314(
      rest,
      [
        glob:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__314(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__315(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__315(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__264(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__316(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__278(rest, [], stack, context, line, offset)
  end

  defp base_expr__317(rest, acc, stack, context, line, offset) do
    base_expr__318(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__318(rest, acc, stack, context, line, offset) do
    base_expr__319(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__319(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__320(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__319(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__316(rest, acc, stack, context, line, offset)
  end

  defp base_expr__320(rest, acc, stack, context, line, offset) do
    base_expr__321(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__321(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__322(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__321(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__316(rest, acc, stack, context, line, offset)
  end

  defp base_expr__322(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__324(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__322(rest, acc, stack, context, line, offset) do
    base_expr__323(rest, acc, stack, context, line, offset)
  end

  defp base_expr__324(rest, acc, stack, context, line, offset) do
    base_expr__322(rest, acc, stack, context, line, offset)
  end

  defp base_expr__323(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__325(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__325(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__326(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__325(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__316(rest, acc, stack, context, line, offset)
  end

  defp base_expr__326(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__327(
      rest,
      [
        quoted:
          case :lists.reverse(user_acc) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__327(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__328(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__328(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__264(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__247(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__329(rest, acc, stack, context, line, offset)
  end

  defp base_expr__264(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__248(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__329(rest, acc, stack, context, line, offset) do
    base_expr__330(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__330(rest, acc, stack, context, line, offset) do
    base_expr__331(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__331(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__333(
      rest,
      acc,
      stack,
      context,
      (
        line = comb__line

        case x0 do
          10 -> {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}
          _ -> line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__331(rest, acc, stack, context, line, offset) do
    base_expr__332(rest, acc, stack, context, line, offset)
  end

  defp base_expr__333(rest, acc, stack, context, line, offset) do
    base_expr__331(rest, acc, stack, context, line, offset)
  end

  defp base_expr__332(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__334(rest, acc, stack, context, line, offset)
  end

  defp base_expr__334(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__335(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__335(<<")", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__336(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__335(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__336(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__337(
      rest,
      [value_list: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__337(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__25(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__25(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__338(
      rest,
      [comparison: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__338(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end
end
