defmodule KQLTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest KQL

  property "parses valid queries into JSON serializable ast and metadata" do
    check all(query <- valid_query_generator()) do
      assert {:ok, result} = KQL.parse(query)
      JSON.encode!(result)
      assert %{"ast" => _ast, "meta" => _meta} = result
    end
  end

  test "provides error message on invalid query" do
    assert {:error, "expected comparison operator" <> _} = KQL.parse("foobar")
    assert {:error, "expected end of string"} = KQL.parse("make:foo AND (model: bar")
    assert {:error, "expected end of string"} = KQL.parse("make:foo AND ")
  end

  describe "metadata" do
    test "includes original query" do
      assert {:ok, %{"meta" => %{"original_query" => "make:foo and model:bar"}}} =
               KQL.parse("make:foo and model:bar")
    end

    test "includes parser version" do
      assert {:ok, %{"meta" => %{"version" => _}}} = KQL.parse("make:foo")
    end
  end

  describe "utf-8 support" do
    test "supports utf-8 values" do
      utf8_value = "字段值"
      unquoted_query = ~s|make:#{utf8_value}|
      quoted_query = ~s|make:"#{utf8_value}"|

      assert {:ok,
              %{
                "ast" => %{
                  "field" => "make",
                  "operator" => "=",
                  "type" => "comparison",
                  "value" => %{
                    "type" => "value",
                    "term" => ^utf8_value,
                    "glob" => false,
                    "quoted" => false
                  }
                }
              }} =
               KQL.parse(unquoted_query)

      assert {:ok,
              %{
                "ast" => %{
                  "field" => "make",
                  "operator" => "=",
                  "type" => "comparison",
                  "value" => %{
                    "type" => "value",
                    "term" => ^utf8_value,
                    "glob" => false,
                    "quoted" => true
                  }
                }
              }} =
               KQL.parse(quoted_query)
    end
  end

  describe "operator precedence" do
    test "is correct for ambiguous query (A OR B AND C OR D)" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("make:A OR make:B AND make:C OR make:D")

      assert ast == %{
               "terms" => [
                 %{
                   "field" => "make",
                   "operator" => "=",
                   "type" => "comparison",
                   "value" => %{
                     "glob" => false,
                     "quoted" => false,
                     "term" => "A",
                     "type" => "value"
                   }
                 },
                 %{
                   "terms" => [
                     %{
                       "field" => "make",
                       "operator" => "=",
                       "type" => "comparison",
                       "value" => %{
                         "glob" => false,
                         "quoted" => false,
                         "term" => "B",
                         "type" => "value"
                       }
                     },
                     %{
                       "field" => "make",
                       "operator" => "=",
                       "type" => "comparison",
                       "value" => %{
                         "glob" => false,
                         "quoted" => false,
                         "term" => "C",
                         "type" => "value"
                       }
                     }
                   ],
                   "type" => "and"
                 },
                 %{
                   "field" => "make",
                   "operator" => "=",
                   "type" => "comparison",
                   "value" => %{
                     "glob" => false,
                     "quoted" => false,
                     "term" => "D",
                     "type" => "value"
                   }
                 }
               ],
               "type" => "or"
             }
    end

    test "is correct for ambiguous query (A AND B OR C AND D)" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("make:A AND make:B OR make:C AND make:D")

      assert ast == %{
               "terms" => [
                 %{
                   "terms" => [
                     %{
                       "field" => "make",
                       "operator" => "=",
                       "type" => "comparison",
                       "value" => %{
                         "glob" => false,
                         "quoted" => false,
                         "term" => "A",
                         "type" => "value"
                       }
                     },
                     %{
                       "field" => "make",
                       "operator" => "=",
                       "type" => "comparison",
                       "value" => %{
                         "glob" => false,
                         "quoted" => false,
                         "term" => "B",
                         "type" => "value"
                       }
                     }
                   ],
                   "type" => "and"
                 },
                 %{
                   "terms" => [
                     %{
                       "field" => "make",
                       "operator" => "=",
                       "type" => "comparison",
                       "value" => %{
                         "glob" => false,
                         "quoted" => false,
                         "term" => "C",
                         "type" => "value"
                       }
                     },
                     %{
                       "field" => "make",
                       "operator" => "=",
                       "type" => "comparison",
                       "value" => %{
                         "glob" => false,
                         "quoted" => false,
                         "term" => "D",
                         "type" => "value"
                       }
                     }
                   ],
                   "type" => "and"
                 }
               ],
               "type" => "or"
             }
    end
  end

  describe "glob patterns" do
    test "are parsed correctly" do
      cases = [
        "A*",
        "Acme*",
        "A*B*",
        "*A",
        "*Acme",
        "*A*",
        "*Acme*",
        "*A*B*",
        "A*B*C",
        "*A*B*C*",
        "*",
        "**",
        "***",
        "A**",
        "**A"
      ]

      for pattern <- cases do
        assert {:ok,
                %{
                  "ast" => %{
                    "field" => "make",
                    "operator" => "=",
                    "type" => "comparison",
                    "value" => %{"glob" => true, "quoted" => false, "term" => ^pattern}
                  }
                }} =
                 KQL.parse("make:#{pattern}"),
               "Failed for pattern: #{pattern}"
      end
    end

    test "treat escaped asterisks as literals" do
      cases = [
        {~S|A\*|, "A*"},
        {~S|\*A|, "*A"},
        {~S|A\*B|, "A*B"},
        {~S|\*A\*|, "*A*"},
        {~S|A\*\*|, "A**"}
      ]

      for {pattern, expected_value} <- cases do
        assert {:ok,
                %{
                  "ast" => %{
                    "field" => "make",
                    "operator" => "=",
                    "type" => "comparison",
                    "value" => %{"glob" => false, "quoted" => false, "term" => ^expected_value}
                  }
                }} =
                 KQL.parse("make:#{pattern}"),
               "Failed for pattern: #{pattern}"
      end
    end

    test "treat quoted asterisks as literals" do
      cases = [
        {~S|"A*"|, "A*"},
        {~S|"*A"|, "*A"},
        {~S|"A*B*C"|, "A*B*C"},
        {~S|"*"|, "*"}
      ]

      for {pattern, expected_value} <- cases do
        assert {:ok,
                %{
                  "ast" => %{
                    "field" => "make",
                    "operator" => "=",
                    "type" => "comparison",
                    "value" => %{"glob" => false, "quoted" => true, "term" => ^expected_value}
                  }
                }} =
                 KQL.parse("make:#{pattern}"),
               "Failed for quoted pattern: #{pattern}"
      end
    end

    test "are parsed correctly in complex queries" do
      assert {:ok,
              %{
                "ast" => %{
                  "type" => "and",
                  "terms" => [
                    %{
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
                    }
                  ]
                }
              }} = KQL.parse("make:A* AND model:*X")

      assert {:ok,
              %{
                "ast" => %{
                  "type" => "and",
                  "terms" => [
                    %{
                      "type" => "comparison",
                      "field" => "year",
                      "operator" => ">",
                      "value" => %{
                        "type" => "value",
                        "term" => "2020",
                        "glob" => false,
                        "quoted" => false
                      }
                    },
                    %{
                      "type" => "comparison",
                      "field" => "make",
                      "operator" => "=",
                      "value" => %{
                        "type" => "value",
                        "term" => "*google*",
                        "glob" => true,
                        "quoted" => false
                      }
                    }
                  ]
                }
              }} = KQL.parse("year>2020 AND make:*google*")

      assert {:ok,
              %{
                "ast" => %{
                  "type" => "or",
                  "terms" => [
                    %{
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
                      "field" => "make",
                      "operator" => "=",
                      "value" => %{
                        "type" => "value",
                        "term" => "B*",
                        "glob" => true,
                        "quoted" => false
                      }
                    }
                  ]
                }
              }} = KQL.parse("make:A* OR make:B*")

      assert {:ok,
              %{
                "ast" => %{
                  "type" => "or",
                  "terms" => [
                    %{
                      "type" => "comparison",
                      "field" => "model",
                      "operator" => "=",
                      "value" => %{
                        "type" => "value",
                        "term" => "*phone",
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
                        "term" => "*TV",
                        "glob" => true,
                        "quoted" => false
                      }
                    }
                  ]
                }
              }} = KQL.parse("model:*phone OR model:*TV")

      assert {:ok,
              %{
                "ast" => %{
                  "type" => "not",
                  "term" => %{
                    "type" => "comparison",
                    "field" => "make",
                    "operator" => "=",
                    "value" => %{
                      "type" => "value",
                      "term" => "A*",
                      "glob" => true,
                      "quoted" => false
                    }
                  }
                }
              }} = KQL.parse("NOT make:A*")

      assert {:ok,
              %{
                "ast" => %{
                  "type" => "not",
                  "term" => %{
                    "type" => "comparison",
                    "field" => "model",
                    "operator" => "=",
                    "value" => %{
                      "type" => "value",
                      "term" => "*X*",
                      "glob" => true,
                      "quoted" => false
                    }
                  }
                }
              }} = KQL.parse("NOT model:*X*")

      assert {:ok,
              %{
                "ast" => %{
                  "type" => "and",
                  "terms" => [
                    %{
                      "type" => "not",
                      "term" => %{
                        "type" => "comparison",
                        "field" => "make",
                        "operator" => "=",
                        "value" => %{
                          "type" => "value",
                          "term" => "A*",
                          "glob" => true,
                          "quoted" => false
                        }
                      }
                    },
                    %{
                      "type" => "comparison",
                      "field" => "year",
                      "operator" => ">",
                      "value" => %{
                        "type" => "value",
                        "term" => "2020",
                        "glob" => false,
                        "quoted" => false
                      }
                    }
                  ]
                }
              }} = KQL.parse("NOT make:A* AND year>2020")

      assert {:ok,
              %{
                "ast" => %{
                  "type" => "and",
                  "terms" => [
                    %{
                      "type" => "group",
                      "term" => %{
                        "type" => "or",
                        "terms" => [
                          %{
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
                            "field" => "make",
                            "operator" => "=",
                            "value" => %{
                              "type" => "value",
                              "term" => "B*",
                              "glob" => true,
                              "quoted" => false
                            }
                          }
                        ]
                      }
                    },
                    %{
                      "type" => "comparison",
                      "field" => "year",
                      "operator" => "=",
                      "value" => %{
                        "type" => "value",
                        "term" => "2023",
                        "glob" => false,
                        "quoted" => false
                      }
                    }
                  ]
                }
              }} = KQL.parse("(make:A* OR make:B*) AND year:2023")

      assert {:ok,
              %{
                "ast" => %{
                  "type" => "and",
                  "terms" => [
                    %{
                      "type" => "comparison",
                      "field" => "make",
                      "operator" => "=",
                      "value" => %{
                        "type" => "value",
                        "term" => "Apple",
                        "glob" => false,
                        "quoted" => false
                      }
                    },
                    %{
                      "type" => "comparison",
                      "field" => "model",
                      "operator" => "=",
                      "value" => %{
                        "type" => "value",
                        "term" => "i*",
                        "glob" => true,
                        "quoted" => false
                      }
                    }
                  ]
                }
              }} = KQL.parse("make:Apple AND model:i*")

      assert {:ok,
              %{
                "ast" => %{
                  "type" => "or",
                  "terms" => [
                    %{
                      "type" => "comparison",
                      "field" => "color",
                      "operator" => "=",
                      "value" => %{
                        "type" => "value",
                        "term" => "Red",
                        "glob" => false,
                        "quoted" => true
                      }
                    },
                    %{
                      "type" => "comparison",
                      "field" => "color",
                      "operator" => "=",
                      "value" => %{
                        "type" => "value",
                        "term" => "*Blue*",
                        "glob" => true,
                        "quoted" => false
                      }
                    }
                  ]
                }
              }} = KQL.parse(~S|color:"Red" OR color:*Blue*|)
    end
  end

  describe "unquoted dotted field names" do
    test "nest, one level per dot" do
      assert {:ok, %{"ast" => ast}} = KQL.parse(~S|car.make:"Alfa Romeo"|)

      assert %{
               "type" => "nested",
               "path" => "car",
               "term" => %{
                 "type" => "comparison",
                 "field" => "make",
                 "operator" => "=",
                 "value" => %{"type" => "value", "term" => "Alfa Romeo", "quoted" => true}
               }
             } = ast
    end

    test "nest once per additional segment" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("car.engine.cylinders:6")

      assert %{
               "type" => "nested",
               "path" => "car",
               "term" => %{
                 "type" => "nested",
                 "path" => "engine",
                 "term" => %{"type" => "comparison", "field" => "cylinders"}
               }
             } = ast
    end

    test "an undotted field is an ordinary comparison, unchanged" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("make:alfa")
      assert ast["type"] == "comparison"
      assert ast["field"] == "make"
      refute Map.has_key?(ast, "path")
    end

    test "nest inside the operators that already recurse" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("not car.make:alfa")

      assert %{
               "type" => "not",
               "term" => %{"type" => "nested", "path" => "car"}
             } = ast
    end

    test "carry non-equality operators down to the leaf" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("car.engine.litres>=2")

      assert %{
               "type" => "nested",
               "term" => %{
                 "type" => "nested",
                 "term" => %{"type" => "comparison", "field" => "litres", "operator" => ">="}
               }
             } = ast
    end

    test "cannot start with a dot" do
      assert {:error, _} = KQL.parse(".make:alfa")
    end

    test "cannot start with a digit or dash, as before" do
      assert {:error, _} = KQL.parse("14.0.0:alfa")
      assert {:error, _} = KQL.parse("-make:alfa")
    end

    test "reject an empty segment" do
      assert {:error, _} = KQL.parse("car.:alfa")
      assert {:error, _} = KQL.parse("car..make:alfa")
    end

    test "leave dots inside values alone" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("version:14.0.0")
      assert ast["type"] == "comparison"
      assert ast["field"] == "version"
      assert ast["value"]["term"] == "14.0.0"
    end
  end

  describe "quoted field names" do
    test "are literal, so dots do not nest" do
      assert {:ok, %{"ast" => ast}} = KQL.parse(~S|"car.make":alfa|)

      assert %{
               "type" => "comparison",
               "field" => "car.make",
               "operator" => "=",
               "value" => %{"term" => "alfa"}
             } = ast
    end

    test "distinguish a literal dotted name from a path" do
      assert {:ok, %{"ast" => literal}} = KQL.parse(~S|"car.make":alfa|)
      assert {:ok, %{"ast" => path}} = KQL.parse("car.make:alfa")

      assert literal["type"] == "comparison"
      assert path["type"] == "nested"
    end

    test "allow characters an unquoted name cannot hold" do
      assert {:ok, %{"ast" => ast}} = KQL.parse(~S|"engine litres":2|)
      assert ast["field"] == "engine litres"
    end

    test "work with every operator" do
      assert {:ok, %{"ast" => ast}} = KQL.parse(~S|"car.year">=2020|)
      assert ast["field"] == "car.year"
      assert ast["operator"] == ">="
    end
  end

  describe "bracketed value lists" do
    test "are equivalent to a parenthesised OR list" do
      assert {:ok, %{"ast" => bracketed}} = KQL.parse("color:[red,blue]")
      assert {:ok, %{"ast" => parens}} = KQL.parse("color:(red or blue)")

      assert bracketed["value"]["type"] == "value_list"
      assert bracketed["value"] == parens["value"]
    end

    test "accept whitespace around the comma" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("color:[red, blue]")
      assert Enum.map(ast["value"]["terms"], & &1["term"]) == ["red", "blue"]
    end

    test "accept quoted elements" do
      assert {:ok, %{"ast" => ast}} = KQL.parse(~S|color:["red","blue"]|)
      assert Enum.map(ast["value"]["terms"], & &1["term"]) == ["red", "blue"]
    end

    test "accept more than two elements" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("color:[red,blue,green]")
      assert Enum.map(ast["value"]["terms"], & &1["term"]) == ["red", "blue", "green"]
    end

    test "accept globs as elements" do
      assert {:ok, %{"ast" => ast}} = KQL.parse("color:[red*,blue]")

      assert [
               %{"term" => "red*", "glob" => true},
               %{"term" => "blue", "glob" => false}
             ] = ast["value"]["terms"]
    end

    test "treat a quoted comma as a literal" do
      assert {:ok, %{"ast" => ast}} = KQL.parse(~S|color:["red,blue"]|)
      assert Enum.map(ast["value"]["terms"], & &1["term"]) == ["red,blue"]
    end

    test "treat an escaped comma as a literal" do
      assert {:ok, %{"ast" => ast}} = KQL.parse(~S|color:[red\,blue]|)
      assert Enum.map(ast["value"]["terms"], & &1["term"]) == ["red,blue"]
    end

    test "fall back to an ordinary value when a value character follows the list" do
      # `[`, `]` and `,` remain legal unquoted-value characters, so `[a]x` is a
      # value that merely looks like a list with a suffix. It parsed as a value
      # before lists existed and must keep doing so, or every value with a
      # list-shaped prefix would start erroring.
      for query <- ["color:[a]x", "color:[a,b]c", "color:[a]*", "color:[a],b"] do
        assert {:ok, %{"ast" => ast}} = KQL.parse(query), "#{query} failed to parse"
        assert ast["value"]["type"] == "value", "#{query} should be a value, not a list"
      end
    end

    test "fall back to an ordinary value when the bracket is unclosed" do
      # Known limitation. `[` and `]` are legal `unescaped_character`s, so an
      # unclosed list is still a valid unquoted value and parses as one.
      # Rejecting it would mean forbidding an unquoted value from starting with
      # `[`, which would stop queries that parse today from parsing at all.
      assert {:ok, %{"ast" => ast}} = KQL.parse("color:[red,blue")
      assert ast["value"]["type"] == "value"
      assert ast["value"]["term"] == "[red,blue"
    end

    test "still parse a lone bracket as an ordinary value character" do
      # `[` and `]` remain legal inside an unquoted value, so a value that
      # merely contains one is unaffected.
      assert {:ok, %{"ast" => ast}} = KQL.parse("color:red[1]")
      assert ast["value"]["term"] == "red[1]"
      assert ast["value"]["type"] == "value"
    end
  end

  @max_query_depth 5

  defp valid_query_generator(depth \\ 0)

  defp valid_query_generator(depth) when depth >= @max_query_depth do
    valid_comparison_generator()
  end

  defp valid_query_generator(depth) do
    one_of([
      valid_comparison_generator(),
      and_query_generator(depth),
      or_query_generator(depth),
      not_query_generator(depth),
      grouped_query_generator(depth)
    ])
  end

  defp and_query_generator(depth) do
    gen all(
          left <- valid_query_generator(depth + 1),
          right <- valid_query_generator(depth + 1),
          and_word <- member_of(["AND", "and"])
        ) do
      Enum.join([left, and_word, right], " ")
    end
  end

  defp or_query_generator(depth) do
    gen all(
          left <- valid_query_generator(depth + 1),
          right <- valid_query_generator(depth + 1),
          or_word <- member_of(["OR", "or"])
        ) do
      Enum.join([left, or_word, right], " ")
    end
  end

  defp not_query_generator(depth) do
    gen all(
          term <- valid_query_generator(depth + 1),
          not_word <- member_of(["NOT", "not"])
        ) do
      Enum.join([not_word, term], " ")
    end
  end

  defp grouped_query_generator(depth) do
    gen all(
          inner <-
            one_of([
              valid_comparison_generator(),
              and_query_generator(depth + 1),
              or_query_generator(depth + 1)
            ])
        ) do
      "(" <> inner <> ")"
    end
  end

  defp valid_comparison_generator do
    gen all(
          field <- valid_field_name_generator(),
          operator <- member_of([":", ">", ">=", "<", "<="]),
          value <- valid_value_generator(),
          space <- member_of(["", " "])
        ) do
      Enum.join([field, operator, value], space)
    end
  end

  # Dotted and quoted names are generated too, so both field forms get property
  # coverage rather than only the examples above.
  defp valid_field_name_generator do
    one_of([
      valid_unquoted_field_name_generator(),
      valid_quoted_field_name_generator()
    ])
  end

  # Each segment starts with a letter or underscore, which keeps the whole name
  # from starting with a dot or a digit and guarantees no empty segments.
  defp valid_unquoted_field_name_generator do
    gen all(segments <- list_of(valid_field_segment_generator(), min_length: 1, max_length: 3)) do
      Enum.join(segments, ".")
    end
  end

  defp valid_quoted_field_name_generator do
    all_printable_chars_except_quote = Enum.to_list(32..126) -- [?"]

    gen all(value <- string(all_printable_chars_except_quote, min_length: 1)) do
      ~S(") <> value <> ~S(")
    end
  end

  defp valid_field_segment_generator do
    gen all(
          first_char <-
            member_of(Enum.map(?a..?z, &<<&1>>) ++ Enum.map(?A..?Z, &<<&1>>) ++ ["_"]),
          rest_chars <- string([?a..?z, ?A..?Z, ?0..?9, ?_, ?-])
        ) do
      first_char <> rest_chars
    end
  end

  defp valid_value_generator do
    one_of([
      valid_uncombined_value_generator(),
      valid_combined_value_generator()
    ])
  end

  defp valid_uncombined_value_generator do
    one_of([
      valid_unquoted_value_generator(),
      valid_quoted_value_generator(),
      valid_glob_value_generator()
    ])
  end

  defp valid_combined_value_generator do
    one_of([
      valid_paren_list_generator(),
      valid_bracket_list_generator()
    ])
  end

  defp valid_paren_list_generator do
    gen all(
          terms <- list_of(valid_uncombined_value_generator(), min_length: 2, max_length: 5),
          space1 <- member_of(["", " "]),
          space2 <- member_of(["", " "])
        ) do
      "(" <> space1 <> Enum.join(terms, " OR ") <> space2 <> ")"
    end
  end

  defp valid_bracket_list_generator do
    gen all(
          terms <- list_of(valid_bracket_element_generator(), min_length: 1, max_length: 5),
          space <- member_of(["", " "])
        ) do
      "[" <> Enum.join(terms, "," <> space) <> "]"
    end
  end

  defp valid_bracket_element_generator do
    one_of([
      valid_quoted_value_generator(),
      valid_glob_value_generator(),
      valid_bracket_unquoted_value_generator()
    ])
  end

  # `,` and `]` delimit a bracketed list, so an unquoted element must escape
  # them in addition to everything the parenthesised form escapes.
  defp valid_bracket_unquoted_value_generator do
    gen all(value <- string(:ascii, min_length: 1)) do
      escape_symbols(value, ["\\", "(", ")", ":", "<", ">", "\"", "*", " ", "=", ",", "]"])
    end
  end

  defp valid_unquoted_value_generator do
    gen all(value <- string(:ascii, min_length: 1)) do
      # Although = does not need to be escaped, it is included here
      # to avoid any issues with it being interpreted as part of the comparison operator
      escape_symbols(value, ["\\", "(", ")", ":", "<", ">", "\"", "*", " ", "="])
    end
  end

  defp escape_symbols(value, symbols) do
    Enum.reduce(symbols, value, fn symbol, acc ->
      String.replace(acc, symbol, "\\" <> symbol)
    end)
  end

  defp valid_quoted_value_generator do
    all_printable_chars_except_quote = Enum.to_list(32..126) -- [?"]

    gen all(value <- string(all_printable_chars_except_quote, min_length: 1)) do
      ~S(") <> value <> ~S(")
    end
  end

  defp valid_glob_value_generator do
    one_of([
      constant("*"),
      prefix_glob_generator(),
      suffix_glob_generator(),
      wrapping_glob_generator(),
      wrapped_glob_generator()
    ])
  end

  defp prefix_glob_generator do
    gen all(value <- string(:alphanumeric, min_length: 1)) do
      "*" <> value
    end
  end

  defp suffix_glob_generator do
    gen all(value <- string(:alphanumeric, min_length: 1)) do
      value <> "*"
    end
  end

  defp wrapping_glob_generator do
    gen all(value <- string(:alphanumeric, min_length: 1)) do
      "*" <> value <> "*"
    end
  end

  defp wrapped_glob_generator do
    gen all(
          prefix <- string(:alphanumeric, min_length: 1),
          suffix <- string(:alphanumeric, min_length: 1)
        ) do
      prefix <> "*" <> suffix
    end
  end
end
