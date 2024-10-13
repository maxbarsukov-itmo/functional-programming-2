defmodule RBSet do
  @moduledoc """
  A Set implementation using a Red-Black Tree.
  """

  alias RedBlackTree

  defstruct tree: %RedBlackTree{}

  @type t :: %__MODULE__{
          tree: RedBlackTree.t() | nil
        }

  @doc """
  Returns a new set.

  See MapSet `new/0` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#new/0)
  """
  @spec new() :: t
  def new do
    %RBSet{tree: RedBlackTree.new()}
  end

  @doc """
  Creates a set from an enumerable..

  See MapSet `new/1` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#new/1)
  """
  @spec new(Enum.t()) :: t
  def new(enumerable) do
    %RBSet{tree: RedBlackTree.new(enumerable)}
  end

  @doc """
  Creates a set from an enumerable via the transformation function.

  See MapSet `new/2` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#new/2)
  """
  @spec new(Enum.t(), function()) :: t
  def new(enumerable, transform) do
    new(enumerable |> Enum.map(transform))
  end

  @doc """
  Returns a new set with the elements transformed by the given function.
  """
  @spec map(t, (any -> any)) :: t
  def map(set, fun) do
    Enum.reduce(set, new(), fn element, acc -> put(acc, fun.(element)) end)
  end

  @doc """
  Returns a new set with the elements that satisfy the given predicate.
  """
  @spec filter(t, (any -> boolean)) :: t
  def filter(set, predicate) do
    Enum.reduce(set, new(), fn element, acc ->
      if predicate.(element) do
        put(acc, element)
      else
        acc
      end
    end)
  end

  @doc """
  Invokes fun for each element in the enumerable with the accumulator.
  """
  @spec reduce(t, any, any) :: any
  def reduce(set, acc, fun), do: fold_right(set, acc, fun)
  def fold_left(set, acc, fun), do: RedBlackTree.fold_left(RBSet.to_list(set), acc, fun)
  def fold_right(set, acc, fun), do: RedBlackTree.fold_right(RBSet.to_list(set), acc, fun)

  @doc """
  Adds an element to the set.

  See MapSet `put/2` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#put/2)
  """
  @spec put(t, any) :: t
  def put(%RBSet{tree: tree}, element) do
    %RBSet{tree: RedBlackTree.insert(tree, element, element)}
  end

  @doc """
  Checks if an element is in the set.

  See MapSet `member?/2` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#member?/2)
  """
  @spec member?(t, any) :: boolean
  def member?(%RBSet{tree: tree}, element) do
    RedBlackTree.has_key?(tree, element)
  end

  @doc """
  Checks if two sets are equal.

  See MapSet `equal?/2` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#equal?/2)
  """
  @spec equal?(t, t) :: boolean
  def equal?(%RBSet{tree: tree1}, %RBSet{tree: tree2}) do
    RedBlackTree.equal_keys?(tree1, tree2)
  end

  @doc """
  Removes an element from the set.

  See MapSet `delete/2` at [hexdocs](https://hexdocs.pm/elixir/1.18/MapSet.html#delete/2)
  """
  @spec delete(t, any) :: t
  def delete(%RBSet{tree: tree}, element) do
    %RBSet{tree: RedBlackTree.delete(tree, element)}
  end

  @doc """
  Returns the size of the set.

  See MapSet `size/1` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#size/1)
  """
  @spec size(t) :: non_neg_integer
  def size(%RBSet{tree: tree}) do
    RedBlackTree.size(tree)
  end

  @doc """
  Returns a list of elements in the set.

  See MapSet `to_list/1` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#to_list/1)
  """
  @spec to_list(t) :: list
  def to_list(%RBSet{tree: tree}) do
    RedBlackTree.to_list(tree) |> Enum.map(fn {key, _} -> key end)
  end

  @doc """
  Returns a new set containing elements that are common to both sets.

  See MapSet `intersection/2` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#intersection/2)
  """
  @spec intersection(t, t) :: t
  def intersection(set1, set2) do
    filter(set1, fn el -> member?(set2, el) end)
  end

  @doc """
  Returns true if the two sets have no elements in common, false otherwise.

  See MapSet `disjoint?/2` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#disjoint?/2)
  """
  @spec disjoint?(t, t) :: boolean
  def disjoint?(set1, set2) do
    Enum.all?(set1, fn element ->
      not member?(set2, element)
    end)
  end

  @doc """
  Returns a new set containing elements that are in the first set but not in the second.

  See MapSet `difference/2` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#difference/2)
  """
  @spec difference(t, t) :: t
  def difference(set1, set2) do
    filter(set1, fn el -> not member?(set2, el) end)
  end

  @spec t <<< t :: t
  def set1 <<< set2 do
    difference(set1, set2)
  end

  @spec t >>> t :: t
  def set1 >>> set2 do
    difference(set2, set1)
  end

  @doc """
  Returns true if the first set is a subset of the second, false otherwise.

  See MapSet `subset?/2` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#subset?/2)
  """
  @spec subset?(t, t) :: boolean
  def subset?(set1, set2) do
    Enum.all?(set1, fn element -> member?(set2, element) end)
  end

  @spec t <~ t :: boolean
  def set1 <~ set2 do
    subset?(set2, set1)
  end

  @spec t ~> t :: boolean
  def set1 ~> set2 do
    subset?(set1, set2)
  end

  @doc """
  Returns a new set containing all elements from both sets.

  See MapSet `union/2` at [hexdocs](https://hexdocs.pm/elixir/1.17/MapSet.html#union/2)
  """
  @spec union(t, t) :: t
  def union(%RBSet{tree: tree1}, %RBSet{tree: tree2}) do
    %RBSet{tree: RedBlackTree.union(tree1, tree2)}
  end

  @spec t ||| t :: t
  def set1 ||| set2 do
    union(set1, set2)
  end
end

defimpl Enumerable, for: RBSet do
  @spec count(RBSet.t()) :: {:ok, non_neg_integer()}
  def count(set) do
    {:ok, RBSet.size(set)}
  end

  @spec member?(RBSet.t(), any()) :: {:ok, boolean()}
  def member?(set, val) do
    {:ok, RBSet.member?(set, val)}
  end

  @spec slice(RBSet.t()) :: {:ok, non_neg_integer(), (any() -> any())}
  def slice(set) do
    size = RBSet.size(set)
    {:ok, size, &RBSet.to_list/1}
  end

  @spec reduce(RBSet.t(), {:cont, any()} | {:halt, any()} | {:suspend, any()}, any()) ::
          {:done, any()}
          | {:halted, any()}
          | {:suspended, any(), ({any(), any()} -> {any(), any()} | {any(), any(), any()})}
  def reduce(set, acc, fun) do
    Enumerable.List.reduce(RBSet.to_list(set), acc, fun)
  end
end

defimpl Collectable, for: RBSet do
  @doc """
  Returns an initial accumulator and a "collector" function.

      Enum.into(RBSet.new([1,2,3,4,5]), MapSet.new())
  """
  @spec into(RBSet.t()) :: {any(), (any(), :done | :halt | {any(), any()} -> any())}
  def into(set) do
    collector_fun = fn
      set_acc, {:cont, element} -> RBSet.put(set_acc, element)
      set_acc, :done -> set_acc
      _, :halt -> :ok
    end

    {set, collector_fun}
  end
end

defimpl Inspect, for: RBSet do
  import Inspect.Algebra

  def inspect(set, opts) do
    opts = %Inspect.Opts{opts | charlists: :as_lists}
    concat(["RBSet.new(", Inspect.List.inspect(RBSet.to_list(set), opts), ")"])
  end
end
