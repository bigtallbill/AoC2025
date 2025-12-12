defmodule Aoc2025.Graph do
  alias Aoc2025.Graph.Node
  alias Aoc2025.Graph.Edge

  defstruct [:nodes, :edges, :node_lookup]

  @type t :: %__MODULE__{
          nodes: [Node.t()],
          edges: [Edge.t()],
          node_lookup: %{map() => Node.t()}
        }

  @spec new() :: %__MODULE__{}
  def new(nodes \\ [], edges \\ []) do
    node_lookup = build_node_lookup(nodes)
    %__MODULE__{nodes: nodes, edges: edges, node_lookup: node_lookup}
  end

  defp build_node_lookup(nodes) do
    Enum.reduce(nodes, %{}, fn node, acc ->
      # Only store the first occurrence of each data value
      Map.put_new(acc, node.data, node)
    end)
  end

  def depth_first_walk(graph, start, callback) do
    visited = MapSet.new()
    do_dfs(graph, start, callback, visited)
  end

  defp do_dfs(graph, node, callback, visited) do
    if MapSet.member?(visited, node) do
      visited
    else
      # Mark node as visited
      visited = MapSet.put(visited, node)

      # Call the callback on this node
      callback.(node)

      # Find all edges from this node and visit neighbors
      neighbors = get_neighbors(graph, node)

      Enum.reduce(neighbors, visited, fn neighbor, acc_visited ->
        do_dfs(graph, neighbor, callback, acc_visited)
      end)
    end
  end

  def get_neighbors(graph, node) do
    graph.edges
    |> Enum.filter(fn edge ->
      case edge.direction do
        :forward -> edge.source == node
        :backward -> edge.target == node
        :bidirectional -> edge.source == node or edge.target == node
      end
    end)
    |> Enum.map(fn edge ->
      case edge.direction do
        :forward when edge.source == node -> edge.target
        :backward when edge.target == node -> edge.source
        :bidirectional when edge.source == node -> edge.target
        :bidirectional when edge.target == node -> edge.source
      end
    end)
    # Remove any nil values
    |> Enum.filter(& &1)
  end

  def path_to(graph, node_a, node_b) do
    visited = MapSet.new()
    find_path(graph, node_a, node_b, visited, [node_a])
  end

  defp find_path(_graph, node_a, node_b, _visited, path) when node_a == node_b do
    path
  end

  defp find_path(graph, current, target, visited, path) do
    if MapSet.member?(visited, current) do
      nil
    else
      visited = MapSet.put(visited, current)
      neighbors = get_neighbors(graph, current)

      Enum.find_value(neighbors, fn neighbor ->
        if not MapSet.member?(visited, neighbor) do
          new_path = path ++ [neighbor]
          find_path(graph, neighbor, target, visited, new_path)
        end
      end)
    end
  end

  def get_node(graph, data) do
    Map.get(graph.node_lookup, data)
  end
end
