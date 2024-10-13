# Лабораторная работа 2

[![Elixir](https://github.com/maxbarsukov-itmo/functional-programming-2/actions/workflows/elixir.yml/badge.svg?branch=master)](https://github.com/maxbarsukov-itmo/functional-programming-2/actions/workflows/elixir.yml)
[![Markdown](https://github.com/maxbarsukov-itmo/functional-programming-2/actions/workflows/markdown.yml/badge.svg?branch=master)](https://github.com/maxbarsukov-itmo/functional-programming-2/actions/workflows/markdown.yml)
[![Coverage Status](https://coveralls.io/repos/github/maxbarsukov-itmo/functional-programming-2/badge.svg?branch=master)](https://coveralls.io/github/maxbarsukov-itmo/functional-programming-2?branch=master)

## Вариант `rb-set`

<img alt="dancing" src="./.resources/anime.gif" height="240">

> [!TIP]
> | Red-Black Tree | Your Girlfriend |
> | --- | --- |
> | Search is bounded by O(log n) time | Search time is unbounded |
> | Unlimited O(log n) insertion operations followed by a sequence of rotations | Limited number of insertion operations that can imply no movement at all |
> | Cannot have two consecutive red nodes | Period every month |
> | Takes O(n) space | Takes all the space in the bathroom and closet |
> | Fast construction, insertion, search and deletion parallel algorithms | Parallelization takes a lot of effort |

---

  * Студент: `Барсуков Максим Андреевич`
  * Группа: `P3315`
  * ИСУ: `367081`
  * Функциональный язык: `Elixir`

---

## Требования

Интерфейс — `Set`, структура данных — `Red-Black Tree`.

1. Функции:
    * [x] добавление и удаление элементов;
    * [x] фильтрация;
    * [x] отображение (`map`);
    * [x] свертки (левая и правая);
    * [x] структура должна быть [моноидом](https://ru.m.wikipedia.org/wiki/%D0%9C%D0%BE%D0%BD%D0%BE%D0%B8%D0%B4).
2. Структуры данных должны быть **неизменяемыми**.
3. Библиотека должна быть протестирована в рамках **unit testing**.
4. Библиотека должна быть протестирована в рамках **property-based** тестирования (*как минимум 3 свойства*, включая свойства моноида).
5. Структура должна быть **полиморфной**.
6. Требуется использовать идиоматичный для технологии стиль программирования. Примечание: некоторые языки позволяют получить большую часть API через реализацию небольшого интерфейса. Так как лабораторная работа про ФП, а не про экосистему языка — необходимо реализовать их вручную и по возможности — обеспечить совместимость.

---

## Ключевые элементы реализации

Добавление, получение и удаление элементов:

```elixir
# in `rb_set.ex`

@spec put(t, any) :: t
def put(%RBSet{tree: tree}, element) do
  %RBSet{tree: RedBlackTree.insert(tree, element, element)}
end

@spec delete(t, any) :: t
def delete(%RBSet{tree: tree}, element) do
  %RBSet{tree: RedBlackTree.delete(tree, element)}
end

@spec member?(t, any) :: boolean
def member?(%RBSet{tree: tree}, element) do
  RedBlackTree.has_key?(tree, element)
end


# in `red_black_tree.ex`

def insert(%RedBlackTree{root: nil} = tree, key, value) do
  %RedBlackTree{tree | root: Node.new(key, value), size: 1}
end

def insert(%RedBlackTree{root: root, size: size, comparator: comparator} = tree, key, value) do
  {nodes_added, new_root} = do_insert(root, key, value, 1, comparator)

  %RedBlackTree{
    tree
    | root: make_node_black(new_root),
      size: size + nodes_added
  }
end

defp do_insert(nil, insert_key, insert_value, depth, _comparator) do
  {
    1,
    %Node{
      Node.new(insert_key, insert_value, depth)
      | color: :red
    }
  }
end

defp do_insert(%Node{key: node_key} = node, insert_key, insert_value, depth, comparator) do
  case comparator.(insert_key, node_key) do
    0 -> {0, %Node{node | value: insert_value}}
    -1 -> do_insert_left(node, insert_key, insert_value, depth, comparator)
    1 -> do_insert_right(node, insert_key, insert_value, depth, comparator)
  end
end

defp do_insert_left(%Node{left: left} = node, insert_key, insert_value, depth, comparator) do
  {nodes_added, new_left} = do_insert(left, insert_key, insert_value, depth + 1, comparator)
  {nodes_added, %Node{node | left: do_balance(new_left)}}
end

defp do_insert_right(%Node{right: right} = node, insert_key, insert_value, depth, comparator) do
  {nodes_added, new_right} = do_insert(right, insert_key, insert_value, depth + 1, comparator)
  {nodes_added, %Node{node | right: do_balance(new_right)}}
end

def delete(%RedBlackTree{root: root, size: size, comparator: comparator} = tree, key) do
  {nodes_removed, new_root} = do_delete(root, key, comparator)

  %RedBlackTree{
    tree
    | root: new_root,
      size: size - nodes_removed
  }
end

defp do_delete(nil, _key, _comparator) do
  {0, nil}
end

defp do_delete(%Node{key: node_key} = node, delete_key, comparator) do
  case comparator.(delete_key, node_key) do
    0 -> do_delete_node(node)
    -1 -> do_delete_left(node, delete_key, comparator)
    1 -> do_delete_right(node, delete_key, comparator)
  end
end

defp do_delete_node(%Node{left: left, right: right}) do
  cond do
    # If both the right and left are nil, the new tree is nil. For example,
    # deleting A in the following tree results in B having no left
    #
    #        B
    #       / \
    #      A   C
    #
    left === nil && right === nil ->
      {1, nil}

    # If left is nil and there is a right, promote the right. For example,
    # deleting C in the following tree results in B's right becoming D
    #
    #        B
    #       / \
    #      A   C
    #           \
    #            D
    #
    left === nil && right ->
      {1, %Node{right | depth: right.depth - 1}}

    # If there is only a left promote it. For example,
    # deleting B in the following tree results in C's left becoming A
    #
    #        C
    #       / \
    #      B   D
    #     /
    #    A
    #
    left && right === nil ->
      {1, %Node{left | depth: left.depth - 1}}

    # If there are both left and right nodes, recursively promote the left-most
    # nodes. For example, deleting E below results in the following:
    #
    #        G      =>         G
    #       / \               / \
    #      E   H    =>       C   H
    #     / \               / \
    #    C   F      =>     B   D
    #   / \               /     \
    #  A   D        =>   A       F
    #   \
    #    B
    #
    #
    true ->
      {
        1,
        do_balance(%Node{
          left
          | depth: left.depth - 1,
            left: do_balance(promote(left)),
            right: right
        })
      }
  end
end

defp do_delete_left(%Node{left: left} = node, delete_key, comparator) do
  {nodes_removed, new_left} = do_delete(left, delete_key, comparator)

  {
    nodes_removed,
    %Node{
      node
      | left: do_balance(new_left)
    }
  }
end

defp do_delete_right(%Node{right: right} = node, delete_key, comparator) do
  {nodes_removed, new_right} = do_delete(right, delete_key, comparator)

  {
    nodes_removed,
    %Node{
      node
      | right: do_balance(new_right)
    }
  }
end


def get(%RedBlackTree{root: root, comparator: comparator}, key) do
  do_get(root, key, comparator)
end

defp do_get(nil, _key, _comparator) do
  nil
end

defp do_get(%Node{key: node_key, left: left, right: right, value: value}, get_key, comparator) do
  case comparator.(get_key, node_key) do
    0 -> value
    -1 -> do_get(left, get_key, comparator)
    1 -> do_get(right, get_key, comparator)
  end
end
```

Фильтрация:

```elixir
# in `rb_set.ex`

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
```

Отображение (`map`):

```elixir
# in `rb_set.ex`

@spec map(t, (any -> any)) :: t
def map(set, fun) do
  Enum.reduce(set, new(), fn element, acc -> put(acc, fun.(element)) end)
end
```

Свертки (левая и правая):

```elixir
# in `rb_set.ex`

@spec reduce(t, any, any) :: any
def reduce(set, acc, fun), do: fold_right(set, acc, fun)
def fold_left(set, acc, fun), do: RedBlackTree.fold_left(RBSet.to_list(set), acc, fun)
def fold_right(set, acc, fun), do: RedBlackTree.fold_right(RBSet.to_list(set), acc, fun)


# in `red_black_tree.ex`

def fold_left(list, acc, fun), do: do_fold_left(list, acc, fun)
defp do_fold_left([], acc, _fun), do: acc

defp do_fold_left([head | tail], acc, fun) do
  new_acc = fun.(acc, head)
  do_fold_left(tail, new_acc, fun)
end

def fold_right(list, acc, fun), do: do_fold_right(list, acc, fun)
defp do_fold_right([], acc, _fun), do: acc

defp do_fold_right([head | tail], acc, fun) do
  do_fold_right(tail, fun.(head, acc), fun)
end

def reduce(%RedBlackTree{root: nil}, acc, _fun), do: acc

def reduce(tree, acc, fun) do
  to_list(tree) |> fold_right(acc, fun)
end
```

### Соответствие свойству [моноида](https://ru.m.wikipedia.org/wiki/%D0%9C%D0%BE%D0%BD%D0%BE%D0%B8%D0%B4)

Определили пустой элемент:

```elixir
# in `rb_set.ex`

@spec new() :: t
def new do
  %RBSet{tree: RedBlackTree.new()}
end


# in `red_black_tree.ex`

def empty, do: new()
def new, do: %RedBlackTree{}
```

Определили бинарную операцию `union`:

```elixir
# in `rb_set.ex`

@spec union(t, t) :: t
def union(%RBSet{tree: tree1}, %RBSet{tree: tree2}) do
  %RBSet{tree: RedBlackTree.union(tree1, tree2)}
end

@spec t ||| t :: t
def set1 ||| set2 do
  union(set1, set2)
end


# in `red_black_tree.ex`

@spec union(t(), t()) :: t
def union(%RedBlackTree{root: nil} = _tree1, %RedBlackTree{} = tree2), do: tree2
def union(%RedBlackTree{} = tree1, %RedBlackTree{root: nil}), do: tree1
def union(%RedBlackTree{} = tree1, %RedBlackTree{} = tree2) do
  RedBlackTree.reduce(tree1, tree2, fn {k, v}, acc -> RedBlackTree.insert(acc, k, v) end)
end
```

## Тестирование

В рамках данной работы были применены два инструмента:

  * [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) - для модульного тестирования;
  * [Quixir](https://github.com/pragdave/quixir) - для тестирования свойств (property-based).

## Выводы

В данной лабораторной работе была реализована структура данных "Красно-чёрное дерево" (Red-Black Tree). Красно-чёрное дерево - это самобалансирующееся двоичное дерево поиска, которое обеспечивает эффективную вставку, удаление и поиск элементов.

В реализации были использованы следующие приёмы программирования:

  * Использование модулей: для реализации красно-чёрного дерева был создан отдельный модуль `RedBlackTree`, а для реализации множества на основе красно-чёрного дерева - модуль `RBSet`.
  * Использование структур данных: для представления узлов дерева была использована структура `Node`, а для представления самого дерева - структура `RedBlackTree`.
  * Для реализации операций над деревом, таких как вставка, удаление и поиск, были использованы функции высшего порядка.
  * Для реализации логики работы с деревом был использован pattern matching, который позволяет эффективно обрабатывать различные случаи и исключения.
  * Для реализации операций над деревом, таких как обход дерева и поиск элементов, была использована рекурсия -- обычная и хвостовая.
