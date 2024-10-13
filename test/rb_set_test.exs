defmodule RBSetTest do
  @moduledoc """
  Testing RBSet
  """

  use ExUnit.Case, async: true

  import RBSet
  doctest RBSet

  setup do
    {:ok, empty_set: RBSet.new(), set_with_elements: RBSet.new([1, 2, 3])}
  end

  test "create a new empty set", %{empty_set: empty_set} do
    assert RBSet.size(empty_set) == 0
  end

  test "create a new set with elements", %{set_with_elements: set_with_elements} do
    assert RBSet.size(set_with_elements) == 3
    assert RBSet.member?(set_with_elements, 1)
    assert RBSet.member?(set_with_elements, 2)
    assert RBSet.member?(set_with_elements, 3)
    refute RBSet.member?(set_with_elements, 5)
  end

  test "create a set from an enumerable via the transformation function" do
    set = RBSet.new([1, 2, 3, 4, 5], fn x -> x * 2 end)
    assert RBSet.member?(set, 10)
  end

  test "add an element to the set", %{empty_set: empty_set} do
    set = RBSet.put(empty_set, 42)
    assert RBSet.size(set) == 1
    assert RBSet.member?(set, 42)
  end

  test "remove an element from the set", %{set_with_elements: set_with_elements} do
    set = RBSet.delete(set_with_elements, 2)
    assert RBSet.size(set) == 2
    refute RBSet.member?(set, 2)
  end

  test "check if an element is a member of the set", %{set_with_elements: set_with_elements} do
    assert RBSet.member?(set_with_elements, 1)
    refute RBSet.member?(set_with_elements, 4)
  end

  test "map set", %{set_with_elements: set_with_elements} do
    assert RBSet.map(set_with_elements, fn x -> x * 10 end) |> member?(20)
  end

  test "filter set", %{set_with_elements: set_with_elements} do
    assert [1, 3] ==
             RBSet.filter(set_with_elements, fn x -> rem(x, 2) == 1 end) |> RBSet.to_list()
  end

  test "fold set" do
    set = RBSet.new([1, 4, 2, 3])
    result_reduce = RBSet.reduce(set, 0, fn x, acc -> acc - x end)
    result_right = RBSet.fold_right(set, 0, fn x, acc -> acc - x end)
    result_left = RBSet.fold_left(set, 0, fn x, acc -> acc - x end)

    assert result_reduce == -10
    assert result_right == -10
    assert result_left == 2
  end

  test "check equality of sets" do
    set1 = RBSet.new([1, 2, 3])
    set2 = RBSet.new([3, 2, 1])
    set3 = RBSet.new([1, 2, 4])

    assert RBSet.equal?(set1, set2)
    refute RBSet.equal?(set1, set3)
  end

  test "intersection of sets" do
    set1 = RBSet.new([1, 2, 3])
    set2 = RBSet.new([3, 4, 5])
    result_set = RBSet.intersection(set1, set2)

    assert RBSet.size(result_set) == 1
    assert RBSet.member?(result_set, 3)
  end

  test "union of sets", %{empty_set: empty_set} do
    set1 = RBSet.new([1, 2, 3])
    set2 = RBSet.new([3, 4, 5])

    assert RBSet.size(set1 ||| set2) == 5
    assert RBSet.size(set1 ||| empty_set) == 3
    assert RBSet.size(empty_set ||| set1) == 3
    assert RBSet.size(RBSet.union(set1, set2)) == 5
    assert Enum.all?([1, 2, 3, 4, 5], &RBSet.member?(RBSet.union(set1, set2), &1))
  end

  test "difference of sets" do
    set1 = RBSet.new([1, 2, 3])
    set2 = RBSet.new([3, 4, 5])

    assert RBSet.size(RBSet.difference(set1, set2)) == 2
    assert [1, 2] == RBSet.difference(set1, set2) |> RBSet.to_list()
    assert [1, 2] == set1 <<< set2 |> RBSet.to_list()
    assert [4, 5] == set1 >>> set2 |> RBSet.to_list()
    assert [4, 5] == set2 <<< set1 |> RBSet.to_list()
    assert [1, 2] == set2 >>> set1 |> RBSet.to_list()
  end

  test "subset check" do
    set1 = RBSet.new([1, 2])
    set2 = RBSet.new([1, 2, 3])

    assert RBSet.subset?(set1, set2)
    assert set1 ~> set2
    assert set2 <~ set1
    refute set2 ~> set1
  end

  test "disjoint sets" do
    set1 = RBSet.new([1, 2])
    set2 = RBSet.new([3, 4])

    assert RBSet.disjoint?(set1, set2)

    set3 = RBSet.new([2, 3])
    refute RBSet.disjoint?(set1, set3)
  end

  test "implements Enumerable" do
    set1 = RBSet.new([1, 2, 3, 3, 4])

    assert Enum.count(set1) == 4
    assert Enum.member?(set1, 1)
    refute Enum.member?(set1, 5)
    assert Enum.reduce(set1, 0, fn el, acc -> acc + el end) == 10
    assert Enum.slice(set1, 1..3) == [2, 3, 4]
  end

  test "collectable into RBSet" do
    assert 5 == Enum.into(RBSet.new([5, 1, 4, 2, 3]), MapSet.new()) |> MapSet.size()

    initial_set = RBSet.new([1, 2, 3])
    elements_to_add = [4, 5, 6]
    result_set = Enum.into(elements_to_add, initial_set)
    expected_set = RBSet.new([1, 2, 3, 4, 5, 6])
    assert result_set == expected_set
  end

  test "collectable into RBSet with duplicates" do
    initial_set = RBSet.new([1, 2, 3])
    elements_to_add = [3, 4, 5, 3]
    result_set = Enum.into(elements_to_add, initial_set)
    expected_set = RBSet.new([1, 2, 3, 4, 5])
    assert result_set == expected_set
  end

  test "collector function directly" do
    initial_set = RBSet.new([1, 2, 3])
    {set, collector_fun} = Collectable.into(initial_set)

    # Test adding an element
    set = collector_fun.(set, {:cont, 4})
    assert set == RBSet.new([1, 2, 3, 4])

    # Test adding a duplicate element
    set = collector_fun.(set, {:cont, 3})
    assert set == RBSet.new([1, 2, 3, 4])

    # Test completing the collection
    final_set = collector_fun.(set, :done)
    assert final_set == RBSet.new([1, 2, 3, 4])

    # Test halting the collection
    halt_result = collector_fun.(set, :halt)
    assert halt_result == :ok
  end

  test "implements Inspect", %{empty_set: empty_set} do
    set1 = RBSet.new([4, 2, 3, 1])

    assert inspect(empty_set) == "RBSet.new([])"
    assert inspect(set1) == "RBSet.new([1, 2, 3, 4])"
  end
end
