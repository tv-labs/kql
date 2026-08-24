# Generated from lib/kql.ex.exs, do not edit.
# Generated at 2026-08-24 00:27:03Z.

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
    base_expr__1(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__1(rest, acc, stack, context, line, offset) do
    base_expr__2(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__2(<<x0::utf8, _::binary>> = rest, _acc, _stack, context, line, offset)
       when (x0 >= 48 and x0 <= 57) or x0 === 45 or x0 === 46 do
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
              x0 === 45 or x0 === 46 do
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
              x0 === 45 or x0 === 46 do
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

  defp base_expr__94(rest, acc, stack, context, line, offset) do
    base_expr__267(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__96(<<"[", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__97(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__96(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__97(rest, acc, stack, context, line, offset) do
    base_expr__98(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__98(rest, acc, stack, context, line, offset) do
    base_expr__99(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__99(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__101(
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

  defp base_expr__99(rest, acc, stack, context, line, offset) do
    base_expr__100(rest, acc, stack, context, line, offset)
  end

  defp base_expr__101(rest, acc, stack, context, line, offset) do
    base_expr__99(rest, acc, stack, context, line, offset)
  end

  defp base_expr__100(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__102(rest, acc, stack, context, line, offset)
  end

  defp base_expr__102(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__103(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__103(rest, acc, stack, context, line, offset) do
    base_expr__157(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__105(rest, acc, stack, context, line, offset) do
    base_expr__106(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__106(rest, acc, stack, context, line, offset) do
    base_expr__107(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__107(rest, acc, stack, context, line, offset) do
    base_expr__108(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__108(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__109(
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

  defp base_expr__108(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__109(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__108(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, _, _, acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__109(rest, acc, stack, context, line, offset) do
    base_expr__111(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__111(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__112(
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

  defp base_expr__111(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__112(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__111(rest, acc, stack, context, line, offset) do
    base_expr__110(rest, acc, stack, context, line, offset)
  end

  defp base_expr__110(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__113(rest, acc, stack, context, line, offset)
  end

  defp base_expr__112(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__111(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__113(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__114(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__114(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__115(
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

  defp base_expr__115(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__116(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__116(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__104(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__117(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__105(rest, [], stack, context, line, offset)
  end

  defp base_expr__118(rest, acc, stack, context, line, offset) do
    base_expr__119(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__119(rest, acc, stack, context, line, offset) do
    base_expr__120(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__120(rest, acc, stack, context, line, offset) do
    base_expr__136(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__122(rest, acc, stack, context, line, offset) do
    base_expr__123(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__123(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__124(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__123(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__117(rest, acc, stack, context, line, offset)
  end

  defp base_expr__124(rest, acc, stack, context, line, offset) do
    base_expr__126(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__126(rest, acc, stack, context, line, offset) do
    base_expr__131(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__128(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__129(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__128(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__125(rest, acc, stack, context, line, offset)
  end

  defp base_expr__129(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__127(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__130(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__128(rest, [], stack, context, line, offset)
  end

  defp base_expr__131(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__132(
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

  defp base_expr__131(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__132(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__131(rest, acc, stack, context, line, offset) do
    base_expr__130(rest, acc, stack, context, line, offset)
  end

  defp base_expr__132(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__127(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__125(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__133(rest, acc, stack, context, line, offset)
  end

  defp base_expr__127(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__126(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__133(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__134(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__134(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__121(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__135(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__122(rest, [], stack, context, line, offset)
  end

  defp base_expr__136(rest, acc, stack, context, line, offset) do
    base_expr__137(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__137(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__138(
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

  defp base_expr__137(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__138(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__137(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__135(rest, acc, stack, context, line, offset)
  end

  defp base_expr__138(rest, acc, stack, context, line, offset) do
    base_expr__140(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__140(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__141(
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

  defp base_expr__140(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__141(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__140(rest, acc, stack, context, line, offset) do
    base_expr__139(rest, acc, stack, context, line, offset)
  end

  defp base_expr__139(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__142(rest, acc, stack, context, line, offset)
  end

  defp base_expr__141(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__140(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__142(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__143(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__142(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__135(rest, acc, stack, context, line, offset)
  end

  defp base_expr__143(rest, acc, stack, context, line, offset) do
    base_expr__145(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__145(rest, acc, stack, context, line, offset) do
    base_expr__150(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__147(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__148(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__147(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__144(rest, acc, stack, context, line, offset)
  end

  defp base_expr__148(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__146(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__149(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__147(rest, [], stack, context, line, offset)
  end

  defp base_expr__150(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__151(
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

  defp base_expr__150(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__151(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__150(rest, acc, stack, context, line, offset) do
    base_expr__149(rest, acc, stack, context, line, offset)
  end

  defp base_expr__151(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__146(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__144(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__152(rest, acc, stack, context, line, offset)
  end

  defp base_expr__146(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__145(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__152(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__153(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__153(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__121(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__121(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__154(
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

  defp base_expr__154(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__155(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__155(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__104(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__156(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__118(rest, [], stack, context, line, offset)
  end

  defp base_expr__157(rest, acc, stack, context, line, offset) do
    base_expr__158(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__158(rest, acc, stack, context, line, offset) do
    base_expr__159(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__159(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__160(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__159(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__156(rest, acc, stack, context, line, offset)
  end

  defp base_expr__160(rest, acc, stack, context, line, offset) do
    base_expr__161(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__161(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__162(
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

  defp base_expr__161(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__156(rest, acc, stack, context, line, offset)
  end

  defp base_expr__162(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__164(
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

  defp base_expr__162(rest, acc, stack, context, line, offset) do
    base_expr__163(rest, acc, stack, context, line, offset)
  end

  defp base_expr__164(rest, acc, stack, context, line, offset) do
    base_expr__162(rest, acc, stack, context, line, offset)
  end

  defp base_expr__163(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__165(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__165(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__166(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__165(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__156(rest, acc, stack, context, line, offset)
  end

  defp base_expr__166(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__167(
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

  defp base_expr__167(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__168(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__168(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__104(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__104(rest, acc, stack, context, line, offset) do
    base_expr__170(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__170(rest, acc, stack, context, line, offset) do
    base_expr__171(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__171(rest, acc, stack, context, line, offset) do
    base_expr__172(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__172(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__174(
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

  defp base_expr__172(rest, acc, stack, context, line, offset) do
    base_expr__173(rest, acc, stack, context, line, offset)
  end

  defp base_expr__174(rest, acc, stack, context, line, offset) do
    base_expr__172(rest, acc, stack, context, line, offset)
  end

  defp base_expr__173(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__175(rest, acc, stack, context, line, offset)
  end

  defp base_expr__175(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__176(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__176(<<",", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__177(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__176(rest, acc, stack, context, line, offset) do
    base_expr__169(rest, acc, stack, context, line, offset)
  end

  defp base_expr__177(rest, acc, stack, context, line, offset) do
    base_expr__178(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__178(rest, acc, stack, context, line, offset) do
    base_expr__179(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__179(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__181(
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

  defp base_expr__179(rest, acc, stack, context, line, offset) do
    base_expr__180(rest, acc, stack, context, line, offset)
  end

  defp base_expr__181(rest, acc, stack, context, line, offset) do
    base_expr__179(rest, acc, stack, context, line, offset)
  end

  defp base_expr__180(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__182(rest, acc, stack, context, line, offset)
  end

  defp base_expr__182(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__183(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__183(rest, acc, stack, context, line, offset) do
    base_expr__237(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__185(rest, acc, stack, context, line, offset) do
    base_expr__186(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__186(rest, acc, stack, context, line, offset) do
    base_expr__187(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__187(rest, acc, stack, context, line, offset) do
    base_expr__188(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__188(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__189(
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

  defp base_expr__188(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__189(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__188(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__169(rest, acc, stack, context, line, offset)
  end

  defp base_expr__189(rest, acc, stack, context, line, offset) do
    base_expr__191(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__191(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__192(
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

  defp base_expr__191(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__192(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__191(rest, acc, stack, context, line, offset) do
    base_expr__190(rest, acc, stack, context, line, offset)
  end

  defp base_expr__190(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__193(rest, acc, stack, context, line, offset)
  end

  defp base_expr__192(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__191(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__193(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__194(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__194(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__195(
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

  defp base_expr__195(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__196(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__196(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__184(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__197(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__185(rest, [], stack, context, line, offset)
  end

  defp base_expr__198(rest, acc, stack, context, line, offset) do
    base_expr__199(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__199(rest, acc, stack, context, line, offset) do
    base_expr__200(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__200(rest, acc, stack, context, line, offset) do
    base_expr__216(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__202(rest, acc, stack, context, line, offset) do
    base_expr__203(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__203(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__204(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__203(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__197(rest, acc, stack, context, line, offset)
  end

  defp base_expr__204(rest, acc, stack, context, line, offset) do
    base_expr__206(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__206(rest, acc, stack, context, line, offset) do
    base_expr__211(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__208(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__209(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__208(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__205(rest, acc, stack, context, line, offset)
  end

  defp base_expr__209(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__207(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__210(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__208(rest, [], stack, context, line, offset)
  end

  defp base_expr__211(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__212(
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

  defp base_expr__211(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__212(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__211(rest, acc, stack, context, line, offset) do
    base_expr__210(rest, acc, stack, context, line, offset)
  end

  defp base_expr__212(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__207(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__205(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__213(rest, acc, stack, context, line, offset)
  end

  defp base_expr__207(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__206(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__213(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__214(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__214(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__201(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__215(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__202(rest, [], stack, context, line, offset)
  end

  defp base_expr__216(rest, acc, stack, context, line, offset) do
    base_expr__217(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__217(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__218(
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

  defp base_expr__217(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__218(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__217(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__215(rest, acc, stack, context, line, offset)
  end

  defp base_expr__218(rest, acc, stack, context, line, offset) do
    base_expr__220(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__220(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__221(
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

  defp base_expr__220(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__221(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__220(rest, acc, stack, context, line, offset) do
    base_expr__219(rest, acc, stack, context, line, offset)
  end

  defp base_expr__219(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__222(rest, acc, stack, context, line, offset)
  end

  defp base_expr__221(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__220(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__222(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__223(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__222(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__215(rest, acc, stack, context, line, offset)
  end

  defp base_expr__223(rest, acc, stack, context, line, offset) do
    base_expr__225(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__225(rest, acc, stack, context, line, offset) do
    base_expr__230(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__227(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__228(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__227(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__224(rest, acc, stack, context, line, offset)
  end

  defp base_expr__228(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__226(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__229(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__227(rest, [], stack, context, line, offset)
  end

  defp base_expr__230(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__231(
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

  defp base_expr__230(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or x0 === 43 or (x0 >= 45 and x0 <= 57) or
              x0 === 59 or
              x0 === 61 or (x0 >= 63 and x0 <= 91) or (x0 >= 94 and x0 <= 1_114_111) do
    base_expr__231(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__230(rest, acc, stack, context, line, offset) do
    base_expr__229(rest, acc, stack, context, line, offset)
  end

  defp base_expr__231(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__226(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__224(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__232(rest, acc, stack, context, line, offset)
  end

  defp base_expr__226(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__225(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__232(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__233(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__233(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__201(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__201(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__234(
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

  defp base_expr__234(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__235(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__235(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__184(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__236(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__198(rest, [], stack, context, line, offset)
  end

  defp base_expr__237(rest, acc, stack, context, line, offset) do
    base_expr__238(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__238(rest, acc, stack, context, line, offset) do
    base_expr__239(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__239(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__240(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__239(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__236(rest, acc, stack, context, line, offset)
  end

  defp base_expr__240(rest, acc, stack, context, line, offset) do
    base_expr__241(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__241(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__242(
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

  defp base_expr__241(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__236(rest, acc, stack, context, line, offset)
  end

  defp base_expr__242(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__244(
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

  defp base_expr__242(rest, acc, stack, context, line, offset) do
    base_expr__243(rest, acc, stack, context, line, offset)
  end

  defp base_expr__244(rest, acc, stack, context, line, offset) do
    base_expr__242(rest, acc, stack, context, line, offset)
  end

  defp base_expr__243(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__245(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__245(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__246(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__245(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__236(rest, acc, stack, context, line, offset)
  end

  defp base_expr__246(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__247(
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

  defp base_expr__247(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__248(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__248(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__184(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__169(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__249(rest, acc, stack, context, line, offset)
  end

  defp base_expr__184(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__170(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__249(rest, acc, stack, context, line, offset) do
    base_expr__250(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__250(rest, acc, stack, context, line, offset) do
    base_expr__251(rest, [], [acc | stack], context, line, offset)
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

  defp base_expr__255(<<"]", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__256(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__255(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__256(rest, acc, stack, context, line, offset) do
    base_expr__257(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__257(rest, acc, stack, context, line, offset) do
    base_expr__263(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__260(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__261(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__260(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__258(rest, acc, stack, context, line, offset)
  end

  defp base_expr__261(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__259(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__262(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__260(rest, [], stack, context, line, offset)
  end

  defp base_expr__263(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__264(
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

  defp base_expr__263(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__264(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__263(rest, acc, stack, context, line, offset) do
    base_expr__262(rest, acc, stack, context, line, offset)
  end

  defp base_expr__264(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__259(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__259(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [_, _, acc | stack] = stack
    base_expr__92(rest, acc, stack, context, line, offset)
  end

  defp base_expr__258(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__265(rest, acc, stack, context, line, offset)
  end

  defp base_expr__265(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__95(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__266(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__96(rest, [], stack, context, line, offset)
  end

  defp base_expr__267(<<"(", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__268(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__267(rest, acc, stack, context, line, offset) do
    base_expr__266(rest, acc, stack, context, line, offset)
  end

  defp base_expr__268(rest, acc, stack, context, line, offset) do
    base_expr__269(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__269(rest, acc, stack, context, line, offset) do
    base_expr__270(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__270(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__272(
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

  defp base_expr__270(rest, acc, stack, context, line, offset) do
    base_expr__271(rest, acc, stack, context, line, offset)
  end

  defp base_expr__272(rest, acc, stack, context, line, offset) do
    base_expr__270(rest, acc, stack, context, line, offset)
  end

  defp base_expr__271(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__273(rest, acc, stack, context, line, offset)
  end

  defp base_expr__273(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__274(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__274(rest, acc, stack, context, line, offset) do
    base_expr__328(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__276(rest, acc, stack, context, line, offset) do
    base_expr__277(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__277(rest, acc, stack, context, line, offset) do
    base_expr__278(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__278(rest, acc, stack, context, line, offset) do
    base_expr__279(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__279(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__280(
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

  defp base_expr__279(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__280(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__279(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__266(rest, acc, stack, context, line, offset)
  end

  defp base_expr__280(rest, acc, stack, context, line, offset) do
    base_expr__282(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__282(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__283(
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

  defp base_expr__282(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__283(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__282(rest, acc, stack, context, line, offset) do
    base_expr__281(rest, acc, stack, context, line, offset)
  end

  defp base_expr__281(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__284(rest, acc, stack, context, line, offset)
  end

  defp base_expr__283(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__282(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__284(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__285(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__285(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__286(
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

  defp base_expr__286(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__287(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__287(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__275(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__288(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__276(rest, [], stack, context, line, offset)
  end

  defp base_expr__289(rest, acc, stack, context, line, offset) do
    base_expr__290(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__290(rest, acc, stack, context, line, offset) do
    base_expr__291(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__291(rest, acc, stack, context, line, offset) do
    base_expr__307(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__293(rest, acc, stack, context, line, offset) do
    base_expr__294(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__294(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__295(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__294(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__288(rest, acc, stack, context, line, offset)
  end

  defp base_expr__295(rest, acc, stack, context, line, offset) do
    base_expr__297(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__297(rest, acc, stack, context, line, offset) do
    base_expr__302(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__299(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__300(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__299(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__296(rest, acc, stack, context, line, offset)
  end

  defp base_expr__300(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__298(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__301(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__299(rest, [], stack, context, line, offset)
  end

  defp base_expr__302(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__303(
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

  defp base_expr__302(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__303(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__302(rest, acc, stack, context, line, offset) do
    base_expr__301(rest, acc, stack, context, line, offset)
  end

  defp base_expr__303(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__298(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__296(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__304(rest, acc, stack, context, line, offset)
  end

  defp base_expr__298(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__297(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__304(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__305(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__305(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__292(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__306(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__293(rest, [], stack, context, line, offset)
  end

  defp base_expr__307(rest, acc, stack, context, line, offset) do
    base_expr__308(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__308(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__309(
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

  defp base_expr__308(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__309(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__308(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__306(rest, acc, stack, context, line, offset)
  end

  defp base_expr__309(rest, acc, stack, context, line, offset) do
    base_expr__311(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__311(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__312(
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

  defp base_expr__311(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__312(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__311(rest, acc, stack, context, line, offset) do
    base_expr__310(rest, acc, stack, context, line, offset)
  end

  defp base_expr__310(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__313(rest, acc, stack, context, line, offset)
  end

  defp base_expr__312(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__311(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__313(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__314(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__313(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__306(rest, acc, stack, context, line, offset)
  end

  defp base_expr__314(rest, acc, stack, context, line, offset) do
    base_expr__316(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__316(rest, acc, stack, context, line, offset) do
    base_expr__321(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__318(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__319(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__318(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__315(rest, acc, stack, context, line, offset)
  end

  defp base_expr__319(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__317(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__320(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__318(rest, [], stack, context, line, offset)
  end

  defp base_expr__321(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__322(
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

  defp base_expr__321(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__322(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__321(rest, acc, stack, context, line, offset) do
    base_expr__320(rest, acc, stack, context, line, offset)
  end

  defp base_expr__322(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__317(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__315(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__323(rest, acc, stack, context, line, offset)
  end

  defp base_expr__317(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__316(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__323(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__324(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__324(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__292(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__292(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__325(
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

  defp base_expr__325(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__326(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__326(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__275(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__327(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__289(rest, [], stack, context, line, offset)
  end

  defp base_expr__328(rest, acc, stack, context, line, offset) do
    base_expr__329(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__329(rest, acc, stack, context, line, offset) do
    base_expr__330(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__330(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__331(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__330(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__327(rest, acc, stack, context, line, offset)
  end

  defp base_expr__331(rest, acc, stack, context, line, offset) do
    base_expr__332(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__332(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__333(
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

  defp base_expr__332(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__327(rest, acc, stack, context, line, offset)
  end

  defp base_expr__333(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__335(
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

  defp base_expr__333(rest, acc, stack, context, line, offset) do
    base_expr__334(rest, acc, stack, context, line, offset)
  end

  defp base_expr__335(rest, acc, stack, context, line, offset) do
    base_expr__333(rest, acc, stack, context, line, offset)
  end

  defp base_expr__334(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__336(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__336(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__337(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__336(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__327(rest, acc, stack, context, line, offset)
  end

  defp base_expr__337(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__338(
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

  defp base_expr__338(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__339(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__339(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__275(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__275(rest, acc, stack, context, line, offset) do
    base_expr__340(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__340(rest, acc, stack, context, line, offset) do
    base_expr__341(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__341(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__342(
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

  defp base_expr__341(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__266(rest, acc, stack, context, line, offset)
  end

  defp base_expr__342(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__344(
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

  defp base_expr__342(rest, acc, stack, context, line, offset) do
    base_expr__343(rest, acc, stack, context, line, offset)
  end

  defp base_expr__344(rest, acc, stack, context, line, offset) do
    base_expr__342(rest, acc, stack, context, line, offset)
  end

  defp base_expr__343(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__345(rest, acc, stack, context, line, offset)
  end

  defp base_expr__345(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__346(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__346(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 111 or x0 === 79) and (x1 === 114 or x1 === 82) do
    base_expr__347(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__346(rest, acc, stack, context, line, offset) do
    base_expr__266(rest, acc, stack, context, line, offset)
  end

  defp base_expr__347(rest, acc, stack, context, line, offset) do
    base_expr__348(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__348(rest, acc, stack, context, line, offset) do
    base_expr__349(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__349(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__350(
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

  defp base_expr__349(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__266(rest, acc, stack, context, line, offset)
  end

  defp base_expr__350(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__352(
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

  defp base_expr__350(rest, acc, stack, context, line, offset) do
    base_expr__351(rest, acc, stack, context, line, offset)
  end

  defp base_expr__352(rest, acc, stack, context, line, offset) do
    base_expr__350(rest, acc, stack, context, line, offset)
  end

  defp base_expr__351(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__353(rest, acc, stack, context, line, offset)
  end

  defp base_expr__353(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__354(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__354(rest, acc, stack, context, line, offset) do
    base_expr__408(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__356(rest, acc, stack, context, line, offset) do
    base_expr__357(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__357(rest, acc, stack, context, line, offset) do
    base_expr__358(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__358(rest, acc, stack, context, line, offset) do
    base_expr__359(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__359(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__360(
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

  defp base_expr__359(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__360(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__359(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__266(rest, acc, stack, context, line, offset)
  end

  defp base_expr__360(rest, acc, stack, context, line, offset) do
    base_expr__362(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__362(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__363(
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

  defp base_expr__362(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__363(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__362(rest, acc, stack, context, line, offset) do
    base_expr__361(rest, acc, stack, context, line, offset)
  end

  defp base_expr__361(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__364(rest, acc, stack, context, line, offset)
  end

  defp base_expr__363(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__362(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__364(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__365(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__365(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__366(
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

  defp base_expr__366(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__367(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__367(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__355(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__368(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__356(rest, [], stack, context, line, offset)
  end

  defp base_expr__369(rest, acc, stack, context, line, offset) do
    base_expr__370(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__370(rest, acc, stack, context, line, offset) do
    base_expr__371(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__371(rest, acc, stack, context, line, offset) do
    base_expr__387(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__373(rest, acc, stack, context, line, offset) do
    base_expr__374(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__374(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__375(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__374(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__368(rest, acc, stack, context, line, offset)
  end

  defp base_expr__375(rest, acc, stack, context, line, offset) do
    base_expr__377(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__377(rest, acc, stack, context, line, offset) do
    base_expr__382(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__379(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__380(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__379(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__376(rest, acc, stack, context, line, offset)
  end

  defp base_expr__380(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__378(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__381(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__379(rest, [], stack, context, line, offset)
  end

  defp base_expr__382(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__383(
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

  defp base_expr__382(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__383(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__382(rest, acc, stack, context, line, offset) do
    base_expr__381(rest, acc, stack, context, line, offset)
  end

  defp base_expr__383(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__378(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__376(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__384(rest, acc, stack, context, line, offset)
  end

  defp base_expr__378(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__377(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__384(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__385(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__385(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__372(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__386(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__373(rest, [], stack, context, line, offset)
  end

  defp base_expr__387(rest, acc, stack, context, line, offset) do
    base_expr__388(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__388(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__389(
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

  defp base_expr__388(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__389(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__388(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__386(rest, acc, stack, context, line, offset)
  end

  defp base_expr__389(rest, acc, stack, context, line, offset) do
    base_expr__391(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__391(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__392(
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

  defp base_expr__391(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__392(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__391(rest, acc, stack, context, line, offset) do
    base_expr__390(rest, acc, stack, context, line, offset)
  end

  defp base_expr__390(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__393(rest, acc, stack, context, line, offset)
  end

  defp base_expr__392(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__391(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__393(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__394(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__393(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__386(rest, acc, stack, context, line, offset)
  end

  defp base_expr__394(rest, acc, stack, context, line, offset) do
    base_expr__396(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__396(rest, acc, stack, context, line, offset) do
    base_expr__401(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__398(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__399(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__398(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__395(rest, acc, stack, context, line, offset)
  end

  defp base_expr__399(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__397(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__400(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__398(rest, [], stack, context, line, offset)
  end

  defp base_expr__401(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__402(
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

  defp base_expr__401(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__402(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__401(rest, acc, stack, context, line, offset) do
    base_expr__400(rest, acc, stack, context, line, offset)
  end

  defp base_expr__402(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__397(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__395(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__403(rest, acc, stack, context, line, offset)
  end

  defp base_expr__397(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__396(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__403(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__404(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__404(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__372(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__372(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__405(
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

  defp base_expr__405(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__406(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__406(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__355(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__407(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__369(rest, [], stack, context, line, offset)
  end

  defp base_expr__408(rest, acc, stack, context, line, offset) do
    base_expr__409(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__409(rest, acc, stack, context, line, offset) do
    base_expr__410(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__410(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__411(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__410(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__407(rest, acc, stack, context, line, offset)
  end

  defp base_expr__411(rest, acc, stack, context, line, offset) do
    base_expr__412(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__412(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__413(
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

  defp base_expr__412(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__407(rest, acc, stack, context, line, offset)
  end

  defp base_expr__413(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__415(
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

  defp base_expr__413(rest, acc, stack, context, line, offset) do
    base_expr__414(rest, acc, stack, context, line, offset)
  end

  defp base_expr__415(rest, acc, stack, context, line, offset) do
    base_expr__413(rest, acc, stack, context, line, offset)
  end

  defp base_expr__414(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__416(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__416(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__417(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__416(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__407(rest, acc, stack, context, line, offset)
  end

  defp base_expr__417(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__418(
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

  defp base_expr__418(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__419(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__419(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__355(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__355(rest, acc, stack, context, line, offset) do
    base_expr__421(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__421(rest, acc, stack, context, line, offset) do
    base_expr__422(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__422(rest, acc, stack, context, line, offset) do
    base_expr__423(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__423(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__424(
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

  defp base_expr__423(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__420(rest, acc, stack, context, line, offset)
  end

  defp base_expr__424(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__426(
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

  defp base_expr__424(rest, acc, stack, context, line, offset) do
    base_expr__425(rest, acc, stack, context, line, offset)
  end

  defp base_expr__426(rest, acc, stack, context, line, offset) do
    base_expr__424(rest, acc, stack, context, line, offset)
  end

  defp base_expr__425(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__427(rest, acc, stack, context, line, offset)
  end

  defp base_expr__427(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__428(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__428(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 111 or x0 === 79) and (x1 === 114 or x1 === 82) do
    base_expr__429(
      rest,
      [] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>) + byte_size(<<x1::utf8>>)
    )
  end

  defp base_expr__428(rest, acc, stack, context, line, offset) do
    base_expr__420(rest, acc, stack, context, line, offset)
  end

  defp base_expr__429(rest, acc, stack, context, line, offset) do
    base_expr__430(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__430(rest, acc, stack, context, line, offset) do
    base_expr__431(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__431(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__432(
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

  defp base_expr__431(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__420(rest, acc, stack, context, line, offset)
  end

  defp base_expr__432(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__434(
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

  defp base_expr__432(rest, acc, stack, context, line, offset) do
    base_expr__433(rest, acc, stack, context, line, offset)
  end

  defp base_expr__434(rest, acc, stack, context, line, offset) do
    base_expr__432(rest, acc, stack, context, line, offset)
  end

  defp base_expr__433(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__435(rest, acc, stack, context, line, offset)
  end

  defp base_expr__435(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__436(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__436(rest, acc, stack, context, line, offset) do
    base_expr__490(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__438(rest, acc, stack, context, line, offset) do
    base_expr__439(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__439(rest, acc, stack, context, line, offset) do
    base_expr__440(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__440(rest, acc, stack, context, line, offset) do
    base_expr__441(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__441(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__442(
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

  defp base_expr__441(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__442(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__441(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__420(rest, acc, stack, context, line, offset)
  end

  defp base_expr__442(rest, acc, stack, context, line, offset) do
    base_expr__444(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__444(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__445(
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

  defp base_expr__444(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__445(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__444(rest, acc, stack, context, line, offset) do
    base_expr__443(rest, acc, stack, context, line, offset)
  end

  defp base_expr__443(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__446(rest, acc, stack, context, line, offset)
  end

  defp base_expr__445(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__444(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__446(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__447(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__447(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__448(
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

  defp base_expr__448(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__449(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__449(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__437(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__450(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__438(rest, [], stack, context, line, offset)
  end

  defp base_expr__451(rest, acc, stack, context, line, offset) do
    base_expr__452(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__452(rest, acc, stack, context, line, offset) do
    base_expr__453(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__453(rest, acc, stack, context, line, offset) do
    base_expr__469(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__455(rest, acc, stack, context, line, offset) do
    base_expr__456(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__456(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__457(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__456(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    base_expr__450(rest, acc, stack, context, line, offset)
  end

  defp base_expr__457(rest, acc, stack, context, line, offset) do
    base_expr__459(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__459(rest, acc, stack, context, line, offset) do
    base_expr__464(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__461(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__462(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__461(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__458(rest, acc, stack, context, line, offset)
  end

  defp base_expr__462(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__460(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__463(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__461(rest, [], stack, context, line, offset)
  end

  defp base_expr__464(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__465(
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

  defp base_expr__464(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__465(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__464(rest, acc, stack, context, line, offset) do
    base_expr__463(rest, acc, stack, context, line, offset)
  end

  defp base_expr__465(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__460(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__458(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__466(rest, acc, stack, context, line, offset)
  end

  defp base_expr__460(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__459(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__466(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__467(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__467(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__454(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__468(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__455(rest, [], stack, context, line, offset)
  end

  defp base_expr__469(rest, acc, stack, context, line, offset) do
    base_expr__470(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__470(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__471(
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

  defp base_expr__470(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__471(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__470(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__468(rest, acc, stack, context, line, offset)
  end

  defp base_expr__471(rest, acc, stack, context, line, offset) do
    base_expr__473(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__473(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__474(
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

  defp base_expr__473(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__474(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__473(rest, acc, stack, context, line, offset) do
    base_expr__472(rest, acc, stack, context, line, offset)
  end

  defp base_expr__472(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__475(rest, acc, stack, context, line, offset)
  end

  defp base_expr__474(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__473(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__475(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__476(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__475(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    base_expr__468(rest, acc, stack, context, line, offset)
  end

  defp base_expr__476(rest, acc, stack, context, line, offset) do
    base_expr__478(rest, [], [{rest, acc, context, line, offset} | stack], context, line, offset)
  end

  defp base_expr__478(rest, acc, stack, context, line, offset) do
    base_expr__483(rest, [], [{rest, context, line, offset}, acc | stack], context, line, offset)
  end

  defp base_expr__480(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 42 do
    base_expr__481(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__480(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__477(rest, acc, stack, context, line, offset)
  end

  defp base_expr__481(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__479(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__482(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__480(rest, [], stack, context, line, offset)
  end

  defp base_expr__483(
         <<x0::utf8, x1::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 92 do
    base_expr__484(
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

  defp base_expr__483(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 33 or (x0 >= 35 and x0 <= 39) or (x0 >= 43 and x0 <= 57) or x0 === 59 or
              x0 === 61 or
              (x0 >= 63 and x0 <= 91) or (x0 >= 93 and x0 <= 1_114_111) do
    base_expr__484(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp base_expr__483(rest, acc, stack, context, line, offset) do
    base_expr__482(rest, acc, stack, context, line, offset)
  end

  defp base_expr__484(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__479(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__477(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__485(rest, acc, stack, context, line, offset)
  end

  defp base_expr__479(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__478(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__485(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__486(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__486(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__454(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__454(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__487(
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

  defp base_expr__487(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__488(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__488(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__437(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__489(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    base_expr__451(rest, [], stack, context, line, offset)
  end

  defp base_expr__490(rest, acc, stack, context, line, offset) do
    base_expr__491(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__491(rest, acc, stack, context, line, offset) do
    base_expr__492(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__492(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__493(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__492(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__489(rest, acc, stack, context, line, offset)
  end

  defp base_expr__493(rest, acc, stack, context, line, offset) do
    base_expr__494(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__494(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__495(
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

  defp base_expr__494(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    base_expr__489(rest, acc, stack, context, line, offset)
  end

  defp base_expr__495(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 34 do
    base_expr__497(
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

  defp base_expr__495(rest, acc, stack, context, line, offset) do
    base_expr__496(rest, acc, stack, context, line, offset)
  end

  defp base_expr__497(rest, acc, stack, context, line, offset) do
    base_expr__495(rest, acc, stack, context, line, offset)
  end

  defp base_expr__496(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__498(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__498(<<"\"", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__499(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__498(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    base_expr__489(rest, acc, stack, context, line, offset)
  end

  defp base_expr__499(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__500(
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

  defp base_expr__500(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__501(rest, [value: :lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp base_expr__501(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__437(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__420(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    base_expr__502(rest, acc, stack, context, line, offset)
  end

  defp base_expr__437(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    base_expr__421(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp base_expr__502(rest, acc, stack, context, line, offset) do
    base_expr__503(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__503(rest, acc, stack, context, line, offset) do
    base_expr__504(rest, [], [acc | stack], context, line, offset)
  end

  defp base_expr__504(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 32 or x0 === 9 or x0 === 10 or x0 === 13 do
    base_expr__506(
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

  defp base_expr__504(rest, acc, stack, context, line, offset) do
    base_expr__505(rest, acc, stack, context, line, offset)
  end

  defp base_expr__506(rest, acc, stack, context, line, offset) do
    base_expr__504(rest, acc, stack, context, line, offset)
  end

  defp base_expr__505(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__507(rest, acc, stack, context, line, offset)
  end

  defp base_expr__507(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    base_expr__508(rest, [] ++ acc, stack, context, line, offset)
  end

  defp base_expr__508(<<")", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    base_expr__509(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp base_expr__508(rest, acc, stack, context, line, offset) do
    base_expr__266(rest, acc, stack, context, line, offset)
  end

  defp base_expr__509(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__95(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__95(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__510(
      rest,
      [value_list: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__510(rest, acc, [_, previous_acc | stack], context, line, offset) do
    base_expr__25(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp base_expr__25(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    base_expr__511(
      rest,
      [comparison: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp base_expr__511(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end
end
