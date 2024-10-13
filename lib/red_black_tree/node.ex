defmodule RedBlackTree.Node do
  @moduledoc """
  Node of RB Tree
  """

  defstruct(
    color: :black,
    depth: 1,
    key: nil,
    value: nil,
    left: nil,
    right: nil
  )

  @type t :: %__MODULE__{
    color: :red | :black,
    depth: pos_integer(),
    key: any,
    value: any,
    left: t | nil,
    right: t | nil
  }

  def new(key, value, depth \\ 1) do
    %__MODULE__{key: key, value: value, depth: depth}
  end

  def color(%__MODULE__{} = node, color) do
    %__MODULE__{node | color: color}
  end
end
