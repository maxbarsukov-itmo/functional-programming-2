defmodule RBSetPropTest do
  @moduledoc """
  Property-testing RBSet
  """

  use ExUnit.Case, async: true
  use Quixir
  import RBSet
  doctest RBSet

  test "check monoid" do
    ptest numbers1: list(of: positive_int(), size: 10),
          numbers2: list(of: positive_int(), size: 10) do
      set1 = RBSet.new(numbers1)
      set2 = RBSet.new(numbers2)
      emp = RBSet.new()

      new_set = set1 ||| emp
      assert RBSet.to_list(set1) == RBSet.to_list(new_set)

      new_set = emp ||| set1
      assert RBSet.to_list(set1) == RBSet.to_list(new_set)

      set12 = set1 ||| set2
      set21 = set2 ||| set1
      assert RBSet.to_list(set12) == RBSet.to_list(set21)
    end
  end

  test "check insert" do
    ptest values: list(size: 10) do
      set = RBSet.new()

      Enum.each(values, fn value ->
        set = RBSet.put(set, value)
        assert RBSet.member?(set, value)
      end)
    end
  end
end
