defmodule Aoc2025.D7P2 do
  require IEx
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.split("\n", trim: true)
    # add an extra entry just so we can use drop_every to remove the lines with only dots
    |> then(fn lines -> ["blank"] ++ lines end)
    |> Enum.drop_every(2)
    |> Enum.map(&String.codepoints(&1))
    |> build_graph()
    |> depth_first_counter()
  end

  def run(:example), do: File.read(Path.join(__DIR__, "d7-example.txt")) |> elem(1) |> run
  def run(:challenge), do: File.read(Path.join(__DIR__, "d7.txt")) |> elem(1) |> run

  def build_graph(lines) do
    nodes =
      lines
      |> Stream.with_index()
      |> Enum.map(fn {row, row_idx} ->
        for col <- find_all_indicies(row, ["^"]) do
          {row_idx, col}
        end
      end)
      |> List.flatten()

    # manually add the beam entry nodes (but actually there is only one but IDK)
    nodes = (find_all_indicies(List.first(lines), ["S"]) |> Enum.map(&{0, &1})) ++ nodes

    [first_line | _rest] = lines
    exit_row_y_idx = length(lines)

    # add implicity end nodes (because beams need to exit)
    # not all of these will ultimately connect with edges
    nodes =
      nodes ++
        (first_line
         |> Enum.with_index()
         |> Enum.map(fn {_v, x_idx} -> {exit_row_y_idx, x_idx} end))

    edges =
      nodes
      |> Enum.reduce([], fn {nodeY, nodeX} = source_node, acc ->
        case nodeY do
          0 ->
            first_splitter =
              Enum.find(nodes, fn {searchY, searchX} ->
                searchY > nodeY and nodeX == searchX
              end)

            acc ++ [{{nodeY, nodeX}, first_splitter}]

          _ ->
            left = nodeX - 1
            right = nodeX + 1

            left_node =
              Enum.find(nodes, fn {searchY, searchX} ->
                searchY > nodeY and left == searchX
              end)

            right_node =
              Enum.find(nodes, fn {searchY, searchX} ->
                searchY > nodeY and right == searchX
              end)

            edges = []

            edges = if not is_nil(left_node), do: edges ++ [{source_node, left_node}], else: edges

            edges =
              if not is_nil(right_node), do: edges ++ [{source_node, right_node}], else: edges

            acc ++ edges
        end
      end)

    {nodes, edges}
  end

  def find_all_indicies(list, search) do
    list
    |> Stream.with_index()
    |> Stream.filter(fn {value, _idx} -> value in search end)
    |> Enum.map(fn {_v, idx} -> idx end)
  end

  def depth_first_counter({[first | _rest], _edges} = graph) do
    depth_first_counter(graph, first, [], 0)
  end

  def depth_first_counter(:exhausted, paths) do
    paths
  end

  def depth_first_counter({nodes, edges} = graph, current, visited, paths) do
    children = get_children(graph, current)

    to_visit = List.first(children |> Enum.filter(&(not Kernel.in(&1, visited))))

    cond do
      is_nil(to_visit) and current |> elem(0) == 0 ->
        depth_first_counter(:exhausted, paths)

      is_nil(to_visit) ->
        parent = get_parent(graph, current)

        # update visited if the current node isnt already visited
        visited = if current not in visited, do: [current] ++ visited, else: visited

        # count the paths if we reach an end node
        paths = if current |> elem(0) == 8, do: paths + 1, else: paths

        depth_first_counter(graph, parent, visited, paths)

      true ->
        visited = if current not in visited, do: [current] ++ visited, else: visited
        depth_first_counter(graph, to_visit, visited, paths)
    end
  end

  def get_children({_nodes, edges}, {parent_y, parent_x}) do
    Enum.reduce(edges, [], fn {{source_y, source_x}, child}, children ->
      if parent_x == source_x and parent_y == source_y do
        [child] ++ children
      else
        children
      end
    end)
    |> Enum.sort(fn {ay, _ax}, {by, _bx} -> by > ay end)
  end

  def get_parent({_nodes, edges}, {source_child_y, source_child_x}) do
    case Enum.find(edges, fn {_parent, {child_y, child_x}} ->
           source_child_y == child_y and source_child_x == child_x
         end) do
      nil -> nil
      {parent, _child} -> parent
    end
  end
end
