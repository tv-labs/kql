# Generated from lib/kql.ex.exs, do not edit.
# Generated at 2026-08-24 13:03:36Z.

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

  defp transform_tagged_ast({:comparison, [{:field, segments}, {:operator, operator}, value]}) do
    {leaf, path} = List.pop_at(segments, -1)
    nest_path(path, comparison(leaf, operator, value))
  end

  # `field:{ ... }` is the same nesting the dotted form produces, with the whole
  # inner expression at the leaf instead of a single comparison — so
  # `a:{b:c}` and `a.b:c` are the same AST.
  defp transform_tagged_ast({:nested_group, [{:field, segments}, inner]}) do
    nest_path(segments, transform_tagged_ast(inner))
  end

  defp transform_tagged_ast({:nested_group, [{:quoted_field, path}, inner]}) do
    nest_path([path], transform_tagged_ast(inner))
  end

  defp transform_tagged_ast({:comparison, [{:quoted_field, field}, {:operator, operator}, value]}) do
    comparison(field, operator, value)
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

  # Every leading segment of an unquoted dotted field name becomes a `nested`
  # node wrapping the rest, so the comparison always sits at the leaf and the
  # operator travels down with it. Recursing through "term" is the convention
  # `not` and `group` already use, so a walker that handles those descends this
  # without changes. A quoted field name skips all of it and stays literal.
  defp nest_path([], term), do: term

  defp nest_path([path | rest], term) do
    %{"type" => "nested", "path" => path, "term" => nest_path(rest, term)}
  end

  defp comparison(field, operator, value) do
    %{
      "type" => "comparison",
      "field" => field,
      "operator" => to_string(operator),
      "value" => transform_tagged_ast(value)
    }
  end

  @spec parse_query(binary, keyword) ::
          {:ok, [term], rest, context, line, byte_offset}
          | {:error, reason, rest, context, line, byte_offset}
        when line: {pos_integer, byte_offset},
             byte_offset: non_neg_integer,
             rest: binary,
             reason: String.t(),
             context: map
  defp parse_query(binary, opts \\ []) when is_binary(binary) do
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
    base_expr__5(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__2(rest, acc, stack, context, line, offset) do
    case comparison_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        base_expr__3(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp base_expr__3(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__4(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__2(rest, [], stack, context, line, offset)
  end

  defp base_expr__5(rest, acc, stack, context, line, offset) do
    case nested_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        base_expr__6(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = _error ->
        base_expr__4(rest, acc, stack, context, line, offset)
    end
  end

  defp base_expr__6(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__1(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end

  defp comparison_expr__0(rest, acc, stack, context, line, offset) do
    comparison_expr__1(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__1(rest, acc, stack, context, line, offset) do
    comparison_expr__22(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__3(rest, acc, stack, context, line, offset) do
    comparison_expr__4(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__4(<<x0::utf8, _::binary>> = rest, _acc, _stack, context, line, offset)
       when (x0 >= 48 and x0 <= 57) or x0 === 45 do
    {:error, "did not expect field name while processing comparison", rest, context, line, offset}
  end

  defp comparison_expr__4(rest, acc, stack, context, line, offset) do
    comparison_expr__5(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__5(rest, acc, stack, context, line, offset) do
    comparison_expr__6(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__6(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    comparison_expr__7(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__6(rest, _acc, _stack, context, line, offset) do
    {:error, "expected field name while processing comparison", rest, context, line, offset}
  end

  defp comparison_expr__7(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    comparison_expr__9(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__7(rest, acc, stack, context, line, offset) do
    comparison_expr__8(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__9(rest, acc, stack, context, line, offset) do
    comparison_expr__7(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__8(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__10(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__10(rest, acc, stack, context, line, offset) do
    comparison_expr__12(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__12(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__13(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__12(rest, acc, stack, context, line, offset) do
    comparison_expr__11(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__13(rest, acc, stack, context, line, offset) do
    comparison_expr__14(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__14(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    comparison_expr__15(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__14(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__11(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__15(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    comparison_expr__17(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__15(rest, acc, stack, context, line, offset) do
    comparison_expr__16(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__17(rest, acc, stack, context, line, offset) do
    comparison_expr__15(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__16(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__18(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__11(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__19(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__18(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__12(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__19(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__20(
      rest,
      [field: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__20(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__2(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__21(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__3(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__22(rest, acc, stack, context, line, offset) do
    comparison_expr__23(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__23(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__24(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__23(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__21(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__24(rest, acc, stack, context, line, offset) do
    comparison_expr__25(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__25(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__26(
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

  defp comparison_expr__25(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__21(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__26(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__28(
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

  defp comparison_expr__26(rest, acc, stack, context, line, offset) do
    comparison_expr__27(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__28(rest, acc, stack, context, line, offset) do
    comparison_expr__26(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__27(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__29(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__29(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__30(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__29(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__21(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__30(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__31(
      rest,
      [
        quoted_field:
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

  defp comparison_expr__31(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__2(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__2(rest, acc, stack, context, line, offset) do
    comparison_expr__32(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__32(rest, acc, stack, context, line, offset) do
    comparison_expr__33(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__33(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__35(
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

  defp comparison_expr__33(rest, acc, stack, context, line, offset) do
    comparison_expr__34(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__35(rest, acc, stack, context, line, offset) do
    comparison_expr__33(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__34(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__36(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__36(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__37(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__37(rest, acc, stack, context, line, offset) do
    comparison_expr__38(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__38(<<">=", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__39(rest, [:>=] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp comparison_expr__38(<<"<=", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__39(rest, [:<=] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp comparison_expr__38(<<">", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__39(rest, [:>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__38(<<"<", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__39(rest, [:<] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__38(<<":", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__39(rest, [:=] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__38(rest, _acc, _stack, context, line, offset) do
    {:error, "expected comparison operator while processing comparison", rest, context, line,
     offset}
  end

  defp comparison_expr__39(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__40(
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

  defp comparison_expr__40(rest, acc, stack, context, line, offset) do
    comparison_expr__41(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__41(rest, acc, stack, context, line, offset) do
    comparison_expr__42(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__42(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__44(
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

  defp comparison_expr__42(rest, acc, stack, context, line, offset) do
    comparison_expr__43(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__44(rest, acc, stack, context, line, offset) do
    comparison_expr__42(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__43(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__45(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__45(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__46(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__46(rest, acc, stack, context, line, offset) do
    comparison_expr__115(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__48(rest, acc, stack, context, line, offset) do
    comparison_expr__102(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__50(rest, acc, stack, context, line, offset) do
    comparison_expr__51(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__51(rest, acc, stack, context, line, offset) do
    comparison_expr__52(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__52(rest, acc, stack, context, line, offset) do
    comparison_expr__53(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__53(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__54(
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

  defp comparison_expr__53(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__54(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__53(rest, _acc, _stack, context, line, offset) do
    {:error, "expected unquoted value while processing value inside comparison", rest, context,
     line, offset}
  end

  defp comparison_expr__54(rest, acc, stack, context, line, offset) do
    comparison_expr__56(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__56(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__57(
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

  defp comparison_expr__56(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__57(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__56(rest, acc, stack, context, line, offset) do
    comparison_expr__55(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__55(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__58(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__57(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__56(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__58(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__59(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__59(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__60(
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

  defp comparison_expr__60(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__61(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__61(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__49(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__62(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__50(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__63(rest, acc, stack, context, line, offset) do
    comparison_expr__64(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__64(rest, acc, stack, context, line, offset) do
    comparison_expr__65(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__65(rest, acc, stack, context, line, offset) do
    comparison_expr__81(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__67(rest, acc, stack, context, line, offset) do
    comparison_expr__68(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__68(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__69(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__68(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__62(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__69(rest, acc, stack, context, line, offset) do
    comparison_expr__71(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__71(rest, acc, stack, context, line, offset) do
    comparison_expr__76(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__73(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__74(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__73(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__70(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__74(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__72(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__75(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__73(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__76(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__77(
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

  defp comparison_expr__76(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__77(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__76(rest, acc, stack, context, line, offset) do
    comparison_expr__75(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__77(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__72(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__70(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__78(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__72(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__71(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__78(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__79(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__79(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__66(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__80(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__67(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__81(rest, acc, stack, context, line, offset) do
    comparison_expr__82(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__82(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__83(
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

  defp comparison_expr__82(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__83(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__82(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__80(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__83(rest, acc, stack, context, line, offset) do
    comparison_expr__85(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__85(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__86(
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

  defp comparison_expr__85(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__86(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__85(rest, acc, stack, context, line, offset) do
    comparison_expr__84(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__84(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__87(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__86(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__85(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__87(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__88(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__87(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__80(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__88(rest, acc, stack, context, line, offset) do
    comparison_expr__90(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__90(rest, acc, stack, context, line, offset) do
    comparison_expr__95(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__92(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__93(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__92(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__89(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__93(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__91(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__94(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__92(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__95(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__96(
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

  defp comparison_expr__95(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__96(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__95(rest, acc, stack, context, line, offset) do
    comparison_expr__94(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__96(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__91(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__89(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__97(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__91(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__90(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__97(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__98(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__98(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__66(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__66(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__99(
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

  defp comparison_expr__99(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__100(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__100(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__49(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__101(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__63(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__102(rest, acc, stack, context, line, offset) do
    comparison_expr__103(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__103(rest, acc, stack, context, line, offset) do
    comparison_expr__104(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__104(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__105(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__104(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__101(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__105(rest, acc, stack, context, line, offset) do
    comparison_expr__106(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__106(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__107(
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

  defp comparison_expr__106(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    comparison_expr__101(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__107(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__109(
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

  defp comparison_expr__107(rest, acc, stack, context, line, offset) do
    comparison_expr__108(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__109(rest, acc, stack, context, line, offset) do
    comparison_expr__107(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__108(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__110(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__110(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__111(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__110(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__101(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__111(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__112(
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

  defp comparison_expr__112(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__113(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__113(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__49(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__49(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__47(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__114(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__48(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__115(rest, acc, stack, context, line, offset) do
    comparison_expr__116(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__116(rest, acc, stack, context, line, offset) do
    comparison_expr__289(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__118(<<"[", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__119(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__118(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    comparison_expr__114(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__119(rest, acc, stack, context, line, offset) do
    comparison_expr__120(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__120(rest, acc, stack, context, line, offset) do
    comparison_expr__121(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__121(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__123(
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

  defp comparison_expr__121(rest, acc, stack, context, line, offset) do
    comparison_expr__122(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__123(rest, acc, stack, context, line, offset) do
    comparison_expr__121(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__122(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__124(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__124(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__125(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__125(rest, acc, stack, context, line, offset) do
    comparison_expr__179(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__127(rest, acc, stack, context, line, offset) do
    comparison_expr__128(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__128(rest, acc, stack, context, line, offset) do
    comparison_expr__129(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__129(rest, acc, stack, context, line, offset) do
    comparison_expr__130(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__130(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__131(
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

  defp comparison_expr__130(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__131(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__130(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, _, _, acc | stack] = stack
    comparison_expr__114(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__131(rest, acc, stack, context, line, offset) do
    comparison_expr__133(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__133(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__134(
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

  defp comparison_expr__133(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__134(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__133(rest, acc, stack, context, line, offset) do
    comparison_expr__132(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__132(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__135(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__134(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__133(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__135(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__136(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__136(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__137(
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

  defp comparison_expr__137(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__138(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__138(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__126(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__139(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__127(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__140(rest, acc, stack, context, line, offset) do
    comparison_expr__141(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__141(rest, acc, stack, context, line, offset) do
    comparison_expr__142(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__142(rest, acc, stack, context, line, offset) do
    comparison_expr__158(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__144(rest, acc, stack, context, line, offset) do
    comparison_expr__145(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__145(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__146(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__145(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__139(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__146(rest, acc, stack, context, line, offset) do
    comparison_expr__148(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__148(rest, acc, stack, context, line, offset) do
    comparison_expr__153(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__150(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__151(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__150(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__147(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__151(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__149(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__152(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__150(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__153(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__154(
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

  defp comparison_expr__153(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__154(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__153(rest, acc, stack, context, line, offset) do
    comparison_expr__152(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__154(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__149(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__147(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__155(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__149(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__148(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__155(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__156(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__156(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__143(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__157(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__144(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__158(rest, acc, stack, context, line, offset) do
    comparison_expr__159(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__159(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__160(
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

  defp comparison_expr__159(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__160(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__159(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__157(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__160(rest, acc, stack, context, line, offset) do
    comparison_expr__162(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__162(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__163(
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

  defp comparison_expr__162(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__163(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__162(rest, acc, stack, context, line, offset) do
    comparison_expr__161(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__161(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__164(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__163(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__162(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__164(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__165(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__164(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__157(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__165(rest, acc, stack, context, line, offset) do
    comparison_expr__167(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__167(rest, acc, stack, context, line, offset) do
    comparison_expr__172(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__169(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__170(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__169(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__166(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__170(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__168(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__171(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__169(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__172(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__173(
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

  defp comparison_expr__172(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__173(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__172(rest, acc, stack, context, line, offset) do
    comparison_expr__171(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__173(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__168(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__166(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__174(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__168(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__167(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__174(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__175(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__175(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__143(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__143(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__176(
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

  defp comparison_expr__176(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__177(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__177(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__126(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__178(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__140(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__179(rest, acc, stack, context, line, offset) do
    comparison_expr__180(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__180(rest, acc, stack, context, line, offset) do
    comparison_expr__181(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__181(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__182(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__181(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__178(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__182(rest, acc, stack, context, line, offset) do
    comparison_expr__183(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__183(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__184(
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

  defp comparison_expr__183(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    comparison_expr__178(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__184(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__186(
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

  defp comparison_expr__184(rest, acc, stack, context, line, offset) do
    comparison_expr__185(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__186(rest, acc, stack, context, line, offset) do
    comparison_expr__184(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__185(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__187(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__187(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__188(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__187(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__178(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__188(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__189(
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

  defp comparison_expr__189(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__190(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__190(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__126(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__126(rest, acc, stack, context, line, offset) do
    comparison_expr__192(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__192(rest, acc, stack, context, line, offset) do
    comparison_expr__193(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__193(rest, acc, stack, context, line, offset) do
    comparison_expr__194(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__194(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__196(
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

  defp comparison_expr__194(rest, acc, stack, context, line, offset) do
    comparison_expr__195(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__196(rest, acc, stack, context, line, offset) do
    comparison_expr__194(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__195(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__197(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__197(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__198(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__198(<<",", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__199(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__198(rest, acc, stack, context, line, offset) do
    comparison_expr__191(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__199(rest, acc, stack, context, line, offset) do
    comparison_expr__200(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__200(rest, acc, stack, context, line, offset) do
    comparison_expr__201(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__201(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__203(
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

  defp comparison_expr__201(rest, acc, stack, context, line, offset) do
    comparison_expr__202(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__203(rest, acc, stack, context, line, offset) do
    comparison_expr__201(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__202(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__204(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__204(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__205(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__205(rest, acc, stack, context, line, offset) do
    comparison_expr__259(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__207(rest, acc, stack, context, line, offset) do
    comparison_expr__208(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__208(rest, acc, stack, context, line, offset) do
    comparison_expr__209(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__209(rest, acc, stack, context, line, offset) do
    comparison_expr__210(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__210(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__211(
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

  defp comparison_expr__210(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__211(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__210(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__191(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__211(rest, acc, stack, context, line, offset) do
    comparison_expr__213(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__213(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__214(
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

  defp comparison_expr__213(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__214(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__213(rest, acc, stack, context, line, offset) do
    comparison_expr__212(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__212(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__215(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__214(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__213(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__215(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__216(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__216(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__217(
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

  defp comparison_expr__217(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__218(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__218(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__206(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__219(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__207(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__220(rest, acc, stack, context, line, offset) do
    comparison_expr__221(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__221(rest, acc, stack, context, line, offset) do
    comparison_expr__222(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__222(rest, acc, stack, context, line, offset) do
    comparison_expr__238(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__224(rest, acc, stack, context, line, offset) do
    comparison_expr__225(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__225(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__226(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__225(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__219(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__226(rest, acc, stack, context, line, offset) do
    comparison_expr__228(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__228(rest, acc, stack, context, line, offset) do
    comparison_expr__233(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__230(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__231(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__230(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__227(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__231(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__229(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__232(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__230(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__233(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__234(
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

  defp comparison_expr__233(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__234(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__233(rest, acc, stack, context, line, offset) do
    comparison_expr__232(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__234(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__229(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__227(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__235(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__229(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__228(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__235(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__236(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__236(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__223(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__237(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__224(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__238(rest, acc, stack, context, line, offset) do
    comparison_expr__239(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__239(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__240(
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

  defp comparison_expr__239(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__240(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__239(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__237(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__240(rest, acc, stack, context, line, offset) do
    comparison_expr__242(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__242(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__243(
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

  defp comparison_expr__242(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__243(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__242(rest, acc, stack, context, line, offset) do
    comparison_expr__241(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__241(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__244(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__243(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__242(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__244(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__245(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__244(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__237(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__245(rest, acc, stack, context, line, offset) do
    comparison_expr__247(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__247(rest, acc, stack, context, line, offset) do
    comparison_expr__252(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__249(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__250(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__249(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__246(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__250(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__248(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__251(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__249(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__252(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__253(
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

  defp comparison_expr__252(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__253(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__252(rest, acc, stack, context, line, offset) do
    comparison_expr__251(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__253(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__248(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__246(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__254(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__248(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__247(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__254(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__255(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__255(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__223(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__223(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__256(
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

  defp comparison_expr__256(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__257(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__257(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__206(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__258(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__220(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__259(rest, acc, stack, context, line, offset) do
    comparison_expr__260(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__260(rest, acc, stack, context, line, offset) do
    comparison_expr__261(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__261(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__262(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__261(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__258(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__262(rest, acc, stack, context, line, offset) do
    comparison_expr__263(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__263(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__264(
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

  defp comparison_expr__263(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    comparison_expr__258(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__264(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__266(
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

  defp comparison_expr__264(rest, acc, stack, context, line, offset) do
    comparison_expr__265(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__266(rest, acc, stack, context, line, offset) do
    comparison_expr__264(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__265(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__267(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__267(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__268(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__267(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__258(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__268(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__269(
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

  defp comparison_expr__269(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__270(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__270(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__206(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__191(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__271(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__206(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__192(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__271(rest, acc, stack, context, line, offset) do
    comparison_expr__272(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__272(rest, acc, stack, context, line, offset) do
    comparison_expr__273(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__273(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__275(
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

  defp comparison_expr__273(rest, acc, stack, context, line, offset) do
    comparison_expr__274(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__275(rest, acc, stack, context, line, offset) do
    comparison_expr__273(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__274(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__276(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__276(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__277(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__277(<<"]", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__278(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__277(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    comparison_expr__114(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__278(rest, acc, stack, context, line, offset) do
    comparison_expr__279(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__279(rest, acc, stack, context, line, offset) do
    comparison_expr__285(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__282(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__283(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__282(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__280(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__283(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__281(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__284(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__282(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__285(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__286(
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

  defp comparison_expr__285(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__286(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__285(rest, acc, stack, context, line, offset) do
    comparison_expr__284(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__286(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__281(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__281(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [_, _, acc | stack] = stack
    comparison_expr__114(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__280(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__287(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__287(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__117(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__288(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__118(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__289(<<"(", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__290(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__289(rest, acc, stack, context, line, offset) do
    comparison_expr__288(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__290(rest, acc, stack, context, line, offset) do
    comparison_expr__291(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__291(rest, acc, stack, context, line, offset) do
    comparison_expr__292(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__292(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__294(
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

  defp comparison_expr__292(rest, acc, stack, context, line, offset) do
    comparison_expr__293(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__294(rest, acc, stack, context, line, offset) do
    comparison_expr__292(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__293(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__295(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__295(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__296(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__296(rest, acc, stack, context, line, offset) do
    comparison_expr__350(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__298(rest, acc, stack, context, line, offset) do
    comparison_expr__299(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__299(rest, acc, stack, context, line, offset) do
    comparison_expr__300(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__300(rest, acc, stack, context, line, offset) do
    comparison_expr__301(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__301(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__302(
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

  defp comparison_expr__301(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__302(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__301(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__288(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__302(rest, acc, stack, context, line, offset) do
    comparison_expr__304(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__304(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__305(
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

  defp comparison_expr__304(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__305(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__304(rest, acc, stack, context, line, offset) do
    comparison_expr__303(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__303(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__306(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__305(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__304(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__306(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__307(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__307(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__308(
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

  defp comparison_expr__308(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__309(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__309(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__297(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__310(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__298(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__311(rest, acc, stack, context, line, offset) do
    comparison_expr__312(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__312(rest, acc, stack, context, line, offset) do
    comparison_expr__313(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__313(rest, acc, stack, context, line, offset) do
    comparison_expr__329(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__315(rest, acc, stack, context, line, offset) do
    comparison_expr__316(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__316(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__317(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__316(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__310(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__317(rest, acc, stack, context, line, offset) do
    comparison_expr__319(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__319(rest, acc, stack, context, line, offset) do
    comparison_expr__324(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__321(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__322(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__321(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__318(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__322(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__320(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__323(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__321(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__324(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__325(
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

  defp comparison_expr__324(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__325(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__324(rest, acc, stack, context, line, offset) do
    comparison_expr__323(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__325(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__320(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__318(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__326(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__320(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__319(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__326(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__327(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__327(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__314(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__328(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__315(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__329(rest, acc, stack, context, line, offset) do
    comparison_expr__330(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__330(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__331(
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

  defp comparison_expr__330(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__331(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__330(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__328(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__331(rest, acc, stack, context, line, offset) do
    comparison_expr__333(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__333(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__334(
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

  defp comparison_expr__333(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__334(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__333(rest, acc, stack, context, line, offset) do
    comparison_expr__332(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__332(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__335(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__334(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__333(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__335(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__336(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__335(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__328(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__336(rest, acc, stack, context, line, offset) do
    comparison_expr__338(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__338(rest, acc, stack, context, line, offset) do
    comparison_expr__343(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__340(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__341(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__340(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__337(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__341(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__339(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__342(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__340(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__343(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__344(
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

  defp comparison_expr__343(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__344(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__343(rest, acc, stack, context, line, offset) do
    comparison_expr__342(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__344(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__339(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__337(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__345(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__339(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__338(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__345(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__346(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__346(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__314(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__314(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__347(
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

  defp comparison_expr__347(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__348(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__348(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__297(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__349(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__311(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__350(rest, acc, stack, context, line, offset) do
    comparison_expr__351(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__351(rest, acc, stack, context, line, offset) do
    comparison_expr__352(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__352(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__353(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__352(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__349(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__353(rest, acc, stack, context, line, offset) do
    comparison_expr__354(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__354(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__355(
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

  defp comparison_expr__354(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    comparison_expr__349(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__355(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__357(
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

  defp comparison_expr__355(rest, acc, stack, context, line, offset) do
    comparison_expr__356(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__357(rest, acc, stack, context, line, offset) do
    comparison_expr__355(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__356(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__358(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__358(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__359(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__358(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__349(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__359(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__360(
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

  defp comparison_expr__360(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__361(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__361(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__297(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__297(rest, acc, stack, context, line, offset) do
    comparison_expr__362(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__362(rest, acc, stack, context, line, offset) do
    comparison_expr__363(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__363(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__364(
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

  defp comparison_expr__363(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__288(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__364(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__366(
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

  defp comparison_expr__364(rest, acc, stack, context, line, offset) do
    comparison_expr__365(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__366(rest, acc, stack, context, line, offset) do
    comparison_expr__364(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__365(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__367(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__367(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__368(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__368(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 111 or x0 === 79) and (x1 === 114 or x1 === 82) do
    comparison_expr__369(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp comparison_expr__368(rest, acc, stack, context, line, offset) do
    comparison_expr__288(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__369(rest, acc, stack, context, line, offset) do
    comparison_expr__370(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__370(rest, acc, stack, context, line, offset) do
    comparison_expr__371(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__371(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__372(
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

  defp comparison_expr__371(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__288(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__372(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__374(
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

  defp comparison_expr__372(rest, acc, stack, context, line, offset) do
    comparison_expr__373(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__374(rest, acc, stack, context, line, offset) do
    comparison_expr__372(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__373(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__375(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__375(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__376(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__376(rest, acc, stack, context, line, offset) do
    comparison_expr__430(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__378(rest, acc, stack, context, line, offset) do
    comparison_expr__379(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__379(rest, acc, stack, context, line, offset) do
    comparison_expr__380(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__380(rest, acc, stack, context, line, offset) do
    comparison_expr__381(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__381(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__382(
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

  defp comparison_expr__381(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__382(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__381(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__288(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__382(rest, acc, stack, context, line, offset) do
    comparison_expr__384(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__384(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__385(
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

  defp comparison_expr__384(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__385(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__384(rest, acc, stack, context, line, offset) do
    comparison_expr__383(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__383(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__386(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__385(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__384(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__386(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__387(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__387(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__388(
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

  defp comparison_expr__388(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__389(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__389(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__377(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__390(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__378(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__391(rest, acc, stack, context, line, offset) do
    comparison_expr__392(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__392(rest, acc, stack, context, line, offset) do
    comparison_expr__393(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__393(rest, acc, stack, context, line, offset) do
    comparison_expr__409(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__395(rest, acc, stack, context, line, offset) do
    comparison_expr__396(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__396(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__397(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__396(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__390(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__397(rest, acc, stack, context, line, offset) do
    comparison_expr__399(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__399(rest, acc, stack, context, line, offset) do
    comparison_expr__404(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__401(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__402(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__401(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__398(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__402(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__400(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__403(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__401(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__404(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__405(
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

  defp comparison_expr__404(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__405(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__404(rest, acc, stack, context, line, offset) do
    comparison_expr__403(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__405(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__400(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__398(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__406(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__400(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__399(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__406(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__407(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__407(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__394(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__408(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__395(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__409(rest, acc, stack, context, line, offset) do
    comparison_expr__410(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__410(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__411(
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

  defp comparison_expr__410(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__411(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__410(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__408(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__411(rest, acc, stack, context, line, offset) do
    comparison_expr__413(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__413(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__414(
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

  defp comparison_expr__413(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__414(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__413(rest, acc, stack, context, line, offset) do
    comparison_expr__412(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__412(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__415(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__414(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__413(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__415(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__416(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__415(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__408(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__416(rest, acc, stack, context, line, offset) do
    comparison_expr__418(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__418(rest, acc, stack, context, line, offset) do
    comparison_expr__423(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__420(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__421(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__420(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__417(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__421(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__419(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__422(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__420(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__423(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__424(
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

  defp comparison_expr__423(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__424(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__423(rest, acc, stack, context, line, offset) do
    comparison_expr__422(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__424(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__419(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__417(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__425(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__419(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__418(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__425(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__426(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__426(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__394(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__394(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__427(
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

  defp comparison_expr__427(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__428(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__428(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__377(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__429(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__391(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__430(rest, acc, stack, context, line, offset) do
    comparison_expr__431(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__431(rest, acc, stack, context, line, offset) do
    comparison_expr__432(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__432(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__433(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__432(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__429(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__433(rest, acc, stack, context, line, offset) do
    comparison_expr__434(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__434(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__435(
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

  defp comparison_expr__434(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    comparison_expr__429(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__435(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__437(
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

  defp comparison_expr__435(rest, acc, stack, context, line, offset) do
    comparison_expr__436(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__437(rest, acc, stack, context, line, offset) do
    comparison_expr__435(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__436(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__438(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__438(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__439(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__438(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__429(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__439(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__440(
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

  defp comparison_expr__440(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__441(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__441(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__377(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__377(rest, acc, stack, context, line, offset) do
    comparison_expr__443(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__443(rest, acc, stack, context, line, offset) do
    comparison_expr__444(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__444(rest, acc, stack, context, line, offset) do
    comparison_expr__445(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__445(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__446(
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

  defp comparison_expr__445(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__442(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__446(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__448(
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

  defp comparison_expr__446(rest, acc, stack, context, line, offset) do
    comparison_expr__447(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__448(rest, acc, stack, context, line, offset) do
    comparison_expr__446(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__447(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__449(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__449(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__450(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__450(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 111 or x0 === 79) and (x1 === 114 or x1 === 82) do
    comparison_expr__451(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp comparison_expr__450(rest, acc, stack, context, line, offset) do
    comparison_expr__442(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__451(rest, acc, stack, context, line, offset) do
    comparison_expr__452(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__452(rest, acc, stack, context, line, offset) do
    comparison_expr__453(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__453(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__454(
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

  defp comparison_expr__453(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__442(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__454(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__456(
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

  defp comparison_expr__454(rest, acc, stack, context, line, offset) do
    comparison_expr__455(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__456(rest, acc, stack, context, line, offset) do
    comparison_expr__454(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__455(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__457(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__457(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__458(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__458(rest, acc, stack, context, line, offset) do
    comparison_expr__512(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__460(rest, acc, stack, context, line, offset) do
    comparison_expr__461(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__461(rest, acc, stack, context, line, offset) do
    comparison_expr__462(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__462(rest, acc, stack, context, line, offset) do
    comparison_expr__463(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__463(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__464(
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

  defp comparison_expr__463(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__464(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__463(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__442(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__464(rest, acc, stack, context, line, offset) do
    comparison_expr__466(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__466(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__467(
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

  defp comparison_expr__466(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__467(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__466(rest, acc, stack, context, line, offset) do
    comparison_expr__465(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__465(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__468(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__467(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__466(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__468(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__469(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__469(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__470(
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

  defp comparison_expr__470(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__471(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__471(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__459(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__472(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__460(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__473(rest, acc, stack, context, line, offset) do
    comparison_expr__474(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__474(rest, acc, stack, context, line, offset) do
    comparison_expr__475(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__475(rest, acc, stack, context, line, offset) do
    comparison_expr__491(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__477(rest, acc, stack, context, line, offset) do
    comparison_expr__478(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__478(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__479(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__478(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    comparison_expr__472(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__479(rest, acc, stack, context, line, offset) do
    comparison_expr__481(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__481(rest, acc, stack, context, line, offset) do
    comparison_expr__486(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__483(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__484(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__483(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__480(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__484(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__482(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__485(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__483(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__486(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__487(
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

  defp comparison_expr__486(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__487(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__486(rest, acc, stack, context, line, offset) do
    comparison_expr__485(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__487(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__482(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__480(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__488(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__482(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__481(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__488(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__489(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__489(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__476(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__490(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__477(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__491(rest, acc, stack, context, line, offset) do
    comparison_expr__492(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__492(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__493(
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

  defp comparison_expr__492(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__493(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__492(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__490(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__493(rest, acc, stack, context, line, offset) do
    comparison_expr__495(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__495(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__496(
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

  defp comparison_expr__495(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__496(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__495(rest, acc, stack, context, line, offset) do
    comparison_expr__494(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__494(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__497(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__496(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__495(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__497(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__498(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__497(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    comparison_expr__490(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__498(rest, acc, stack, context, line, offset) do
    comparison_expr__500(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__500(rest, acc, stack, context, line, offset) do
    comparison_expr__505(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp comparison_expr__502(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 42 do
    comparison_expr__503(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__502(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__499(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__503(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__501(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__504(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__502(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__505(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    comparison_expr__506(
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

  defp comparison_expr__505(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 122) or x0 === 124 or
              (x0 >= 126 and x0 <= 1_114_111) do
    comparison_expr__506(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp comparison_expr__505(rest, acc, stack, context, line, offset) do
    comparison_expr__504(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__506(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__501(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__499(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__507(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__501(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__500(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__507(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__508(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__508(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__476(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__476(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__509(
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

  defp comparison_expr__509(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__510(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__510(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__459(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__511(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    comparison_expr__473(rest, [], stack, context, line, offset)
  end

  defp comparison_expr__512(rest, acc, stack, context, line, offset) do
    comparison_expr__513(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__513(rest, acc, stack, context, line, offset) do
    comparison_expr__514(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__514(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__515(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__514(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__511(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__515(rest, acc, stack, context, line, offset) do
    comparison_expr__516(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__516(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__517(
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

  defp comparison_expr__516(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    comparison_expr__511(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__517(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 34 do
    comparison_expr__519(
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

  defp comparison_expr__517(rest, acc, stack, context, line, offset) do
    comparison_expr__518(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__519(rest, acc, stack, context, line, offset) do
    comparison_expr__517(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__518(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__520(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__520(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__521(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__520(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    comparison_expr__511(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__521(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__522(
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

  defp comparison_expr__522(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__523(
      rest,
      [value: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__523(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__459(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__442(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    comparison_expr__524(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__459(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    comparison_expr__443(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp comparison_expr__524(rest, acc, stack, context, line, offset) do
    comparison_expr__525(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__525(rest, acc, stack, context, line, offset) do
    comparison_expr__526(rest, [], [acc | stack], context, line, offset)
  end

  defp comparison_expr__526(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    comparison_expr__528(
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

  defp comparison_expr__526(rest, acc, stack, context, line, offset) do
    comparison_expr__527(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__528(rest, acc, stack, context, line, offset) do
    comparison_expr__526(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__527(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__529(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__529(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    comparison_expr__530(rest, [] ++ acc, stack, context, line, offset)
  end

  defp comparison_expr__530(<<")", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    comparison_expr__531(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp comparison_expr__530(rest, acc, stack, context, line, offset) do
    comparison_expr__288(rest, acc, stack, context, line, offset)
  end

  defp comparison_expr__531(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__117(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__117(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__532(
      rest,
      [value_list: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__532(rest, acc, [_, previous_acc | stack], context, line, offset) do
    comparison_expr__47(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp comparison_expr__47(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    comparison_expr__533(
      rest,
      [comparison: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp comparison_expr__533(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end

  defp nested_expr__0(rest, acc, stack, context, line, offset) do
    nested_expr__1(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__1(rest, acc, stack, context, line, offset) do
    nested_expr__22(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp nested_expr__3(rest, acc, stack, context, line, offset) do
    nested_expr__4(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__4(<<x0::utf8, _::binary>> = rest, _acc, _stack, context, line, offset)
       when (x0 >= 48 and x0 <= 57) or x0 === 45 do
    {:error, "did not expect field name while processing nested expression", rest, context, line,
     offset}
  end

  defp nested_expr__4(rest, acc, stack, context, line, offset) do
    nested_expr__5(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__5(rest, acc, stack, context, line, offset) do
    nested_expr__6(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__6(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    nested_expr__7(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp nested_expr__6(rest, _acc, _stack, context, line, offset) do
    {:error, "expected field name while processing nested expression", rest, context, line,
     offset}
  end

  defp nested_expr__7(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    nested_expr__9(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp nested_expr__7(rest, acc, stack, context, line, offset) do
    nested_expr__8(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__9(rest, acc, stack, context, line, offset) do
    nested_expr__7(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__8(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    nested_expr__10(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp nested_expr__10(rest, acc, stack, context, line, offset) do
    nested_expr__12(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp nested_expr__12(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    nested_expr__13(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp nested_expr__12(rest, acc, stack, context, line, offset) do
    nested_expr__11(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__13(rest, acc, stack, context, line, offset) do
    nested_expr__14(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__14(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    nested_expr__15(
      rest,
      [<<x0::utf8>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp nested_expr__14(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    nested_expr__11(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__15(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or
              x0 === 45 do
    nested_expr__17(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp nested_expr__15(rest, acc, stack, context, line, offset) do
    nested_expr__16(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__17(rest, acc, stack, context, line, offset) do
    nested_expr__15(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__16(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    nested_expr__18(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp nested_expr__11(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    nested_expr__19(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__18(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    nested_expr__12(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp nested_expr__19(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    nested_expr__20(rest, [field: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp nested_expr__20(rest, acc, [_, previous_acc | stack], context, line, offset) do
    nested_expr__2(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp nested_expr__21(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    nested_expr__3(rest, [], stack, context, line, offset)
  end

  defp nested_expr__22(rest, acc, stack, context, line, offset) do
    nested_expr__23(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__23(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    nested_expr__24(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp nested_expr__23(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    nested_expr__21(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__24(rest, acc, stack, context, line, offset) do
    nested_expr__25(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__25(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    nested_expr__26(
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

  defp nested_expr__25(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    nested_expr__21(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__26(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    nested_expr__28(
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

  defp nested_expr__26(rest, acc, stack, context, line, offset) do
    nested_expr__27(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__28(rest, acc, stack, context, line, offset) do
    nested_expr__26(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__27(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    nested_expr__29(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp nested_expr__29(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    nested_expr__30(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp nested_expr__29(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    nested_expr__21(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__30(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    nested_expr__31(
      rest,
      [
        quoted_field:
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

  defp nested_expr__31(rest, acc, [_, previous_acc | stack], context, line, offset) do
    nested_expr__2(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp nested_expr__2(rest, acc, stack, context, line, offset) do
    nested_expr__32(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__32(rest, acc, stack, context, line, offset) do
    nested_expr__33(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__33(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    nested_expr__35(
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

  defp nested_expr__33(rest, acc, stack, context, line, offset) do
    nested_expr__34(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__35(rest, acc, stack, context, line, offset) do
    nested_expr__33(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__34(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    nested_expr__36(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__36(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    nested_expr__37(rest, [] ++ acc, stack, context, line, offset)
  end

  defp nested_expr__37(<<":", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    nested_expr__38(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp nested_expr__37(rest, _acc, _stack, context, line, offset) do
    {:error, "expected nested expression", rest, context, line, offset}
  end

  defp nested_expr__38(rest, acc, stack, context, line, offset) do
    nested_expr__39(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__39(rest, acc, stack, context, line, offset) do
    nested_expr__40(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__40(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    nested_expr__42(
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

  defp nested_expr__40(rest, acc, stack, context, line, offset) do
    nested_expr__41(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__42(rest, acc, stack, context, line, offset) do
    nested_expr__40(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__41(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    nested_expr__43(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__43(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    nested_expr__44(rest, [] ++ acc, stack, context, line, offset)
  end

  defp nested_expr__44(<<"{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    nested_expr__45(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp nested_expr__44(rest, _acc, _stack, context, line, offset) do
    {:error, "expected nested expression", rest, context, line, offset}
  end

  defp nested_expr__45(rest, acc, stack, context, line, offset) do
    nested_expr__46(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__46(rest, acc, stack, context, line, offset) do
    nested_expr__47(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__47(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    nested_expr__49(
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

  defp nested_expr__47(rest, acc, stack, context, line, offset) do
    nested_expr__48(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__49(rest, acc, stack, context, line, offset) do
    nested_expr__47(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__48(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    nested_expr__50(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__50(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    nested_expr__51(rest, [] ++ acc, stack, context, line, offset)
  end

  defp nested_expr__51(rest, acc, stack, context, line, offset) do
    case or_expr__0(rest, acc, [], context, line, offset) do
      {:ok, acc, rest, context, line, offset} ->
        nested_expr__52(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp nested_expr__52(rest, acc, stack, context, line, offset) do
    nested_expr__53(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__53(rest, acc, stack, context, line, offset) do
    nested_expr__54(rest, [], [acc | stack], context, line, offset)
  end

  defp nested_expr__54(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    nested_expr__56(
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

  defp nested_expr__54(rest, acc, stack, context, line, offset) do
    nested_expr__55(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__56(rest, acc, stack, context, line, offset) do
    nested_expr__54(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__55(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    nested_expr__57(rest, acc, stack, context, line, offset)
  end

  defp nested_expr__57(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    nested_expr__58(rest, [] ++ acc, stack, context, line, offset)
  end

  defp nested_expr__58(<<"}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    nested_expr__59(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp nested_expr__58(rest, _acc, _stack, context, line, offset) do
    {:error, "expected nested expression", rest, context, line, offset}
  end

  defp nested_expr__59(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    nested_expr__60(
      rest,
      [nested_group: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp nested_expr__60(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end
end
