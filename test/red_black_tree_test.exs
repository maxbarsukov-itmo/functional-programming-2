defmodule RedBlackTreeTest do
  @moduledoc """
  Testing Red-Black Tree
  """

  use ExUnit.Case, async: true
  alias RedBlackTree.Node
  doctest RedBlackTree

  setup do
    tree = RedBlackTree.new()
    {:ok, tree: tree}
  end

  test "initializing a red black tree" do
    assert %RedBlackTree{} == RedBlackTree.new()
    assert %RedBlackTree{} == RedBlackTree.empty()
    assert 0 == RedBlackTree.new().size
    assert 0 == RedBlackTree.empty().size

    assert [{1, 1}, {2, 2}, {:c, :c}] == RedBlackTree.to_list(RedBlackTree.new([1, 2, :c]))
    assert [{1, 1}, {2, 2}, {:c, :c}] == RedBlackTree.to_list(RedBlackTree.new([1, 2, :c]))
  end

  test "to_list" do
    empty_tree = RedBlackTree.new()
    bigger_tree = RedBlackTree.new(d: 1, b: 2, c: 3, a: 4)
    assert [] == RedBlackTree.to_list(empty_tree)

    # It should return the elements in order
    assert [{:a, 4}, {:b, 2}, {:c, 3}, {:d, 1}] == RedBlackTree.to_list(bigger_tree)
    assert 4 == bigger_tree.size
  end

  test "insert" do
    red_black_tree = RedBlackTree.insert(RedBlackTree.new(), 1, :bubbles)
    assert [{1, :bubbles}] == RedBlackTree.to_list(red_black_tree)
    assert 1 == red_black_tree.size

    red_black_tree = RedBlackTree.insert(red_black_tree, 0, :walrus)
    assert [{0, :walrus}, {1, :bubbles}] == RedBlackTree.to_list(red_black_tree)
    assert 2 == red_black_tree.size
  end

  test "strict equality" do
    tree = RedBlackTree.new([{1, :bubbles}])
    updated = RedBlackTree.insert(tree, 1.0, :walrus)

    assert 2 == RedBlackTree.size(updated)

    # Deletes
    # We convert to lists so that the comparison ignores node colors
    assert RedBlackTree.to_list(RedBlackTree.new([{1, :bubbles}])) ==
             RedBlackTree.to_list(RedBlackTree.delete(updated, 1.0))

    assert RedBlackTree.to_list(RedBlackTree.new([{1.0, :walrus}])) ==
             RedBlackTree.to_list(RedBlackTree.delete(updated, 1))

    # Search
    assert :walrus == RedBlackTree.get(updated, 1.0)
    assert :bubbles == RedBlackTree.get(updated, 1)

    assert true == RedBlackTree.has_key?(updated, 1.0)
    assert true == RedBlackTree.has_key?(updated, 1)
  end

  test "get" do
    tree = RedBlackTree.new(d: 1, b: 2, f: 3, g: 4, c: 5, a: 6, e: 7)

    assert 2 == RedBlackTree.get(tree, :b)
    assert 6 == RedBlackTree.get(tree, :a)
    assert 3 == RedBlackTree.get(tree, :f)
    assert 1 == RedBlackTree.get(tree, :d)
    assert 7 == RedBlackTree.get(tree, :e)
    assert 4 == RedBlackTree.get(tree, :g)
    assert 5 == RedBlackTree.get(tree, :c)
    assert 100_500 == RedBlackTree.get(tree, :no_such_key, 100_500)
  end

  test "delete" do
    initial_tree = RedBlackTree.new(d: 1, b: 2, c: 3, a: 4)
    pruned_tree = RedBlackTree.delete(initial_tree, :c)

    assert 3 == pruned_tree.size
    assert [{:a, 4}, {:b, 2}, {:d, 1}] == RedBlackTree.to_list(pruned_tree)

    assert 2 == RedBlackTree.delete(pruned_tree, :a).size
    assert [{:b, 2}, {:d, 1}] == RedBlackTree.to_list(RedBlackTree.delete(pruned_tree, :a))

    assert [] == RedBlackTree.to_list(RedBlackTree.delete(RedBlackTree.new(), :b))
  end

  test "delete depth" do
    initial_tree = RedBlackTree.new(d: 1, b: 2, f: 3, g: 4, c: 5, a: 6, e: 7)

    depth_aggregator = fn %Node{key: key, depth: depth}, acc ->
      Map.put(acc, key, depth)
    end

    altered_tree = RedBlackTree.delete(initial_tree, :b)

    assert %{a: 2, c: 3, d: 1, e: 3, f: 2, g: 3} ==
             RedBlackTree.reduce_nodes(altered_tree, %{}, depth_aggregator)

    unchanged_tree = RedBlackTree.delete(initial_tree, :banana)

    assert %{a: 3, b: 2, c: 3, d: 1, e: 3, f: 2, g: 3} ==
             RedBlackTree.reduce_nodes(unchanged_tree, %{}, depth_aggregator)
  end

  test "insert and get", %{tree: tree} do
    tree = RedBlackTree.insert(tree, :a, 1)
    tree = RedBlackTree.insert(tree, :c)
    assert RedBlackTree.get(tree, :a) == 1
    assert RedBlackTree.get(tree, :b) == nil
    assert RedBlackTree.get(tree, :c) == nil
  end

  test "insert and member?", %{tree: tree} do
    tree = RedBlackTree.insert(tree, :a, 1)
    assert RedBlackTree.member?(tree, :a) == true
    assert RedBlackTree.member?(tree, :b) == false
  end

  test "insert for floats" do
    tree = RedBlackTree.new() |> RedBlackTree.insert(1, :bubbles)
    updated = RedBlackTree.insert(tree, 1.0, :walrus)
    assert RedBlackTree.size(updated) == 2
  end

  test "pop", %{tree: tree} do
    tree = RedBlackTree.insert(tree, :a, 1)
    {value, new_tree} = RedBlackTree.pop(tree, :a)
    assert value == 1
    assert RedBlackTree.member?(new_tree, :a) == false
  end

  test "reduce", %{tree: tree} do
    assert RedBlackTree.reduce(RedBlackTree.new(), 100, fn el, acc -> el + acc end) == 100

    tree = RedBlackTree.insert(tree, :a, 1) |> RedBlackTree.insert(:b, 2)
    result = RedBlackTree.reduce(tree, 0, fn {_, v}, acc -> acc + v end)
    result_l = RedBlackTree.reduce_left(tree, 0, fn acc, {_, v} -> acc + v end)
    assert result == 3
    assert result_l == 3
  end

  test "fold_left", %{tree: tree} do
    tree = RedBlackTree.insert(tree, :a, 1) |> RedBlackTree.insert(:b, 2)
    result = RedBlackTree.fold_left(RedBlackTree.to_list(tree), 0, fn acc, {_, v} -> acc + v end)
    assert result == 3
  end

  test "fold_right", %{tree: tree} do
    tree = RedBlackTree.insert(tree, :a, 1) |> RedBlackTree.insert(:b, 2)
    result = RedBlackTree.fold_right(RedBlackTree.to_list(tree), 0, fn {_, v}, acc -> acc + v end)
    assert result == 3
  end

  test "Enumerable implementation", %{tree: tree} do
    tree = RedBlackTree.insert(tree, :a, 1)
    tree = RedBlackTree.insert(tree, :b, 2)
    assert Enum.count(tree) == 2
    assert Enum.member?(tree, :a) == true
    assert Enum.member?(tree, :c) == false
  end

  test "reduce_nodes" do
    assert RedBlackTree.reduce_nodes(RedBlackTree.new(), :unchanged, fn el, acc -> acc + el end) ==
             :unchanged

    initial_tree = RedBlackTree.new(d: 1, b: 2, f: 3, g: 4, c: 5, a: 6, e: 7)

    aggregator = fn %Node{key: key}, acc ->
      acc ++ [key]
    end

    # should default to in-order
    no_order_members = RedBlackTree.reduce_nodes(initial_tree, [], aggregator)
    in_order_members = RedBlackTree.reduce_nodes(:in_order, initial_tree, [], aggregator)
    pre_order_members = RedBlackTree.reduce_nodes(:pre_order, initial_tree, [], aggregator)
    post_order_members = RedBlackTree.reduce_nodes(:post_order, initial_tree, [], aggregator)

    assert in_order_members == [:a, :b, :c, :d, :e, :f, :g]
    assert no_order_members == in_order_members
    assert pre_order_members == [:d, :b, :a, :c, :f, :e, :g]
    assert post_order_members == [:a, :c, :b, :e, :g, :f, :d]
  end

  test "custom inspect" do
    assert "#RedBlackTree<[a: 1, b: 2, c: 3]>" ==
             inspect(RedBlackTree.new(b: 2, a: 1, c: 3))
  end

  test "altering depth" do
    tree = RedBlackTree.new()

    depth_aggregator = fn %Node{key: key, depth: depth}, acc ->
      Map.put(acc, key, depth)
    end

    one_level_tree = RedBlackTree.insert(tree, :a, 10)
    assert one_level_tree.root.depth == 1

    two_level_tree = RedBlackTree.insert(one_level_tree, :c, 20)
    assert %{a: 1, c: 2} == RedBlackTree.reduce_nodes(two_level_tree, %{}, depth_aggregator)

    three_level_tree = RedBlackTree.insert(two_level_tree, :d, 30)

    assert %{a: 1, c: 2, d: 3} ==
             RedBlackTree.reduce_nodes(three_level_tree, %{}, depth_aggregator)

    still_three_level_tree = RedBlackTree.insert(three_level_tree, :b, 20)

    assert %{a: 1, b: 3, c: 2, d: 3} ==
             RedBlackTree.reduce_nodes(still_three_level_tree, %{}, depth_aggregator)
  end

  test "has_key?" do
    assert RedBlackTree.has_key?(RedBlackTree.new(a: 1, b: 2), :b)
    assert not RedBlackTree.has_key?(RedBlackTree.new(a: 1, b: 2), :c)
  end

  test "with a custom comparator" do
    comparison = fn key1, key2 ->
      cond do
        key1 < key2 -> 1
        key1 > key2 -> -1
        true -> 0
      end
    end

    tree = RedBlackTree.new([], comparator: comparison)

    tree_as_list =
      tree
      |> RedBlackTree.insert(1, 3)
      |> RedBlackTree.insert(5, 1)
      |> RedBlackTree.insert(3, 2)
      |> RedBlackTree.to_list()

    assert [{5, 1}, {3, 2}, {1, 3}] == tree_as_list
  end

  #
  #              B (Black)
  #             /         \
  #            A          D (Red)
  #                      /       \
  #                     C         F (Red)
  #                              /       \
  #                             E         G
  #
  test "balancing a right-heavy red tree" do
    unbalanced = %RedBlackTree{
      size: 5,
      root: %Node{
        key: :b,
        depth: 1,
        color: :black,
        left: %Node{key: :a, depth: 2},
        right: %Node{
          key: :d,
          depth: 2,
          color: :red,
          left: %Node{key: :c, depth: 3},
          right: %Node{
            key: :f,
            depth: 3,
            color: :red,
            left: %Node{key: :e, depth: 4},
            right: %Node{key: :g, depth: 4}
          }
        }
      }
    }

    balanced = RedBlackTree.balance(unbalanced)
    assert balanced_tree() == balanced
    assert RedBlackTree.to_list(unbalanced) == RedBlackTree.to_list(balanced)
  end

  #
  #         B (Black)
  #        /         \
  #       A       F (Red)
  #              /       \
  #           D (Red)     G
  #          /       \
  #         C         E
  #
  test "balancing a center-right-heavy tree" do
    unbalanced = %RedBlackTree{
      size: 5,
      root: %Node{
        key: :b,
        depth: 1,
        color: :black,
        left: %Node{key: :a, depth: 2},
        right: %Node{
          key: :f,
          depth: 2,
          color: :red,
          left: %Node{
            key: :d,
            depth: 3,
            color: :red,
            left: %Node{key: :c, depth: 4},
            right: %Node{key: :e, depth: 4}
          },
          right: %Node{key: :g, depth: 3}
        }
      }
    }

    balanced = RedBlackTree.balance(unbalanced)
    assert balanced_tree() == balanced
    assert RedBlackTree.to_list(unbalanced) == RedBlackTree.to_list(balanced)
  end

  #                 F (Black)
  #                /         \
  #               D (Red)     G
  #              /       \
  #           B (Red)     E
  #          /       \
  #         A          C
  #
  #
  test "balancing a left-heavy tree" do
    unbalanced = %RedBlackTree{
      size: 5,
      root: %Node{
        key: :f,
        depth: 1,
        color: :black,
        left: %Node{
          key: :d,
          depth: 2,
          color: :red,
          left: %Node{
            key: :b,
            depth: 3,
            color: :red,
            left: %Node{key: :a, depth: 4},
            right: %Node{key: :c, depth: 4}
          },
          right: %Node{key: :e, depth: 3}
        },
        right: %Node{key: :g, depth: 2}
      }
    }

    balanced = RedBlackTree.balance(unbalanced)
    assert balanced_tree() == balanced
    assert RedBlackTree.to_list(unbalanced) == RedBlackTree.to_list(balanced)
  end

  #
  #               F (Black)
  #              /         \
  #          B (Red)        G
  #         /       \
  #        A         D (Red)
  #                 /       \
  #                C         E
  #
  test "balancing a center-left-heavy tree" do
    unbalanced = %RedBlackTree{
      size: 5,
      root: %Node{
        key: :f,
        depth: 1,
        color: :black,
        left: %Node{
          key: :b,
          depth: 2,
          color: :red,
          left: %Node{key: :a, depth: 3},
          right: %Node{
            key: :d,
            depth: 3,
            color: :red,
            left: %Node{key: :c, depth: 4},
            right: %Node{key: :e, depth: 4}
          }
        },
        right: %Node{key: :g, depth: 2}
      }
    }

    balanced = RedBlackTree.balance(unbalanced)
    assert balanced_tree() == balanced
    assert RedBlackTree.to_list(unbalanced) == RedBlackTree.to_list(balanced)
  end

  test "implements Collectable" do
    members = [d: 1, b: 2, f: 3, g: 4, c: 5, a: 6, e: 7]
    tree1 = Enum.into(members, RedBlackTree.new())
    tree2 = RedBlackTree.new(members)

    # The trees won't be identical due to the comparator function
    assert RedBlackTree.to_list(tree1) == RedBlackTree.to_list(tree2)
  end

  test "implements Access" do
    tree = RedBlackTree.new(d: 1, b: 2, f: 3, g: 4, c: 5, a: 6, e: 7)
    assert 1 == tree[:d]
    assert 2 == tree[:b]
    assert 3 == tree[:f]
    assert 4 == tree[:g]

    {6, %{tree: new_tree}} =
      get_and_update_in(%{tree: tree}, [:tree, :a], fn prev ->
        {prev, prev * 2}
      end)

    assert 12 == RedBlackTree.get(new_tree, :a)
  end

  #
  #            D (Red)
  #           /       \
  #     B (Black)      F (Black)
  #    /         \    /         \
  #   A           C  E           G
  #
  defp balanced_tree do
    %RedBlackTree{
      size: 5,
      root: %Node{
        key: :d,
        depth: 1,
        color: :red,
        left: %Node{
          key: :b,
          depth: 2,
          color: :black,
          left: %Node{key: :a, depth: 3},
          right: %Node{key: :c, depth: 3}
        },
        right: %Node{
          key: :f,
          depth: 2,
          color: :black,
          left: %Node{key: :e, depth: 3},
          right: %Node{key: :g, depth: 3}
        }
      }
    }
  end
end
