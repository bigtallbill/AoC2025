defmodule GraphTest do
  use ExUnit.Case
  alias Aoc2025.Graph
  alias Aoc2025.Graph.Node
  alias Aoc2025.Graph.Edge

  test "new graph" do
    graph = Graph.new()
    assert graph.nodes == []
    assert graph.edges == []
  end

  test "new graph with nodes" do
    nodes = ["A", "B", "C"]
    graph = Graph.new(nodes)
    assert graph.nodes == nodes
    assert graph.edges == []
  end

  test "new graph with edges" do
    edges = [{1, 2}, {2, 3}]
    graph = Graph.new([], edges)
    assert graph.nodes == []
    assert graph.edges == edges
  end

  describe "depth_first_walk" do
    test "visits nodes in depth-first order" do
      # Mermaid diagram:
      # ```mermaid
      # graph TD
      #   A --> B
      #   A --> C
      #   B --> D
      # ```

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})
      node_d = Node.new(%{id: "D"})

      nodes = [node_a, node_b, node_c, node_d]

      # Create edges: A -> B, A -> C, B -> D
      edges = [
        Edge.new(node_a, node_b, :forward),
        Edge.new(node_a, node_c, :forward),
        Edge.new(node_b, node_d, :forward)
      ]

      graph = Graph.new(nodes, edges)

      # Track visited nodes
      visited_nodes = []

      callback = fn node ->
        visited_nodes = visited_nodes ++ [node.data.id]
        send(self(), {:visited, node.data.id})
      end

      Graph.depth_first_walk(graph, node_a, callback)

      # Collect messages
      visited = collect_messages([])

      # Should visit all reachable nodes
      assert length(visited) == 4
      assert "A" in visited
      assert "B" in visited
      assert "C" in visited
      assert "D" in visited

      # Should visit A first
      assert hd(visited) == "A"
    end

    test "handles bidirectional edges" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A <--> B
      #   B --> C
      # ```

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})

      nodes = [node_a, node_b, node_c]

      # Create bidirectional edge: A <-> B, and forward edge: B -> C
      edges = [
        Edge.new(node_a, node_b, :bidirectional),
        Edge.new(node_b, node_c, :forward)
      ]

      graph = Graph.new(nodes, edges)

      callback = fn node ->
        send(self(), {:visited, node.data.id})
      end

      # Start from B, should be able to reach A (via bidirectional) and C (via forward)
      Graph.depth_first_walk(graph, node_b, callback)

      visited = collect_messages([])

      assert length(visited) == 3
      assert "A" in visited
      assert "B" in visited
      assert "C" in visited
    end

    test "handles backward edges" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   B --> A
      # ```
      # Note: Backward edge means B can traverse to A

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})

      nodes = [node_a, node_b]

      # Create backward edge: A <- B (which means we can traverse from B to A)
      edges = [
        Edge.new(node_a, node_b, :backward)
      ]

      graph = Graph.new(nodes, edges)

      callback = fn node ->
        send(self(), {:visited, node.data.id})
      end

      # Start from B, should be able to reach A via backward edge
      Graph.depth_first_walk(graph, node_b, callback)

      visited = collect_messages([])

      assert length(visited) == 2
      assert "A" in visited
      assert "B" in visited
    end

    test "avoids infinite loops in cyclic graphs" do
      # Mermaid diagram:
      # ```mermaid
      # graph TD
      #   A --> B
      #   B --> C
      #   C --> A
      # ```

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})

      nodes = [node_a, node_b, node_c]

      # Create cycle: A -> B -> C -> A
      edges = [
        Edge.new(node_a, node_b, :forward),
        Edge.new(node_b, node_c, :forward),
        Edge.new(node_c, node_a, :forward)
      ]

      graph = Graph.new(nodes, edges)

      callback = fn node ->
        send(self(), {:visited, node.data.id})
      end

      Graph.depth_first_walk(graph, node_a, callback)

      visited = collect_messages([])

      # Each node should be visited exactly once
      assert length(visited) == 3
      assert length(Enum.uniq(visited)) == 3
    end

    test "handles disconnected nodes" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A --> B
      #   C --> D
      # ```
      # Two disconnected components

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})
      node_d = Node.new(%{id: "D"})

      nodes = [node_a, node_b, node_c, node_d]

      # Create edges: A -> B, C -> D (two disconnected components)
      edges = [
        Edge.new(node_a, node_b, :forward),
        Edge.new(node_c, node_d, :forward)
      ]

      graph = Graph.new(nodes, edges)

      callback = fn node ->
        send(self(), {:visited, node.data.id})
      end

      # Start from A, should only reach A and B
      Graph.depth_first_walk(graph, node_a, callback)

      visited = collect_messages([])

      assert length(visited) == 2
      assert "A" in visited
      assert "B" in visited
      refute "C" in visited
      refute "D" in visited
    end

    test "handles single node with no edges" do
      # Mermaid diagram:
      # ```mermaid
      # graph TD
      #   A
      # ```

      # Create single node
      node_a = Node.new(%{id: "A"})

      graph = Graph.new([node_a], [])

      callback = fn node ->
        send(self(), {:visited, node.data.id})
      end

      Graph.depth_first_walk(graph, node_a, callback)

      visited = collect_messages([])

      assert visited == ["A"]
    end
  end

  # Helper function to collect messages
  defp collect_messages(acc) do
    receive do
      {:visited, id} -> collect_messages(acc ++ [id])
    after
      0 -> acc
    end
  end

  describe "path_to" do
    test "finds path between directly connected nodes" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A --> B
      #   B --> C
      # ```

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})

      nodes = [node_a, node_b, node_c]

      # Create edges: A -> B -> C
      edges = [
        Edge.new(node_a, node_b, :forward),
        Edge.new(node_b, node_c, :forward)
      ]

      graph = Graph.new(nodes, edges)

      # Find path from A to B
      path = Graph.path_to(graph, node_a, node_b)
      assert path == [node_a, node_b]

      # Find path from A to C (through B)
      path = Graph.path_to(graph, node_a, node_c)
      assert path == [node_a, node_b, node_c]
    end

    test "returns nil when no path exists" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A --> B
      #   C
      # ```
      # C is isolated

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})

      nodes = [node_a, node_b, node_c]

      # Create edges: A -> B (C is isolated)
      edges = [
        Edge.new(node_a, node_b, :forward)
      ]

      graph = Graph.new(nodes, edges)

      # No path from A to C
      path = Graph.path_to(graph, node_a, node_c)
      assert path == nil

      # No path from B to A (forward edge only)
      path = Graph.path_to(graph, node_b, node_a)
      assert path == nil
    end

    test "finds path with bidirectional edges" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A <--> B
      #   B <--> C
      # ```

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})

      nodes = [node_a, node_b, node_c]

      # Create bidirectional edges: A <-> B <-> C
      edges = [
        Edge.new(node_a, node_b, :bidirectional),
        Edge.new(node_b, node_c, :bidirectional)
      ]

      graph = Graph.new(nodes, edges)

      # Path from A to C
      path = Graph.path_to(graph, node_a, node_c)
      assert path == [node_a, node_b, node_c]

      # Path from C to A (reverse direction works with bidirectional)
      path = Graph.path_to(graph, node_c, node_a)
      assert path == [node_c, node_b, node_a]
    end

    test "finds path with backward edges" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   B --> A
      # ```
      # Backward edge allows traversal from B to A

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})

      nodes = [node_a, node_b]

      # Create backward edge: A <- B (can traverse from B to A)
      edges = [
        Edge.new(node_a, node_b, :backward)
      ]

      graph = Graph.new(nodes, edges)

      # Path from B to A via backward edge
      path = Graph.path_to(graph, node_b, node_a)
      assert path == [node_b, node_a]

      # No path from A to B
      path = Graph.path_to(graph, node_a, node_b)
      assert path == nil
    end

    test "finds shortest path in presence of cycles" do
      # Mermaid diagram:
      # ```mermaid
      # graph TD
      #   A --> B
      #   B --> C
      #   C --> D
      #   D --> B
      # ```

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})
      node_d = Node.new(%{id: "D"})

      nodes = [node_a, node_b, node_c, node_d]

      # Create edges with cycle: A -> B -> C -> D -> B
      edges = [
        Edge.new(node_a, node_b, :forward),
        Edge.new(node_b, node_c, :forward),
        Edge.new(node_c, node_d, :forward),
        # Creates cycle
        Edge.new(node_d, node_b, :forward)
      ]

      graph = Graph.new(nodes, edges)

      # Should find path without getting stuck in cycle
      path = Graph.path_to(graph, node_a, node_d)
      assert path == [node_a, node_b, node_c, node_d]
    end

    test "returns path of single node when source equals target" do
      # Mermaid diagram:
      # ```mermaid
      # graph TD
      #   A
      # ```

      # Create single node
      node_a = Node.new(%{id: "A"})

      graph = Graph.new([node_a], [])

      # Path from A to A is just [A]
      path = Graph.path_to(graph, node_a, node_a)
      assert path == [node_a]
    end

    test "finds path in complex graph" do
      # Mermaid diagram:
      # ```mermaid
      # graph TD
      #   A --> B
      #   A --> C
      #   B --> D
      #   C --> D
      #   D --> E
      # ```
      # Multiple paths from A to E

      # Create a more complex graph
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})
      node_d = Node.new(%{id: "D"})
      node_e = Node.new(%{id: "E"})

      nodes = [node_a, node_b, node_c, node_d, node_e]

      # Create edges: A -> B, A -> C, B -> D, C -> D, D -> E
      edges = [
        Edge.new(node_a, node_b, :forward),
        Edge.new(node_a, node_c, :forward),
        Edge.new(node_b, node_d, :forward),
        Edge.new(node_c, node_d, :forward),
        Edge.new(node_d, node_e, :forward)
      ]

      graph = Graph.new(nodes, edges)

      # Find path from A to E (multiple possible paths)
      path = Graph.path_to(graph, node_a, node_e)

      # Should be either [A, B, D, E] or [A, C, D, E]
      assert path in [
               [node_a, node_b, node_d, node_e],
               [node_a, node_c, node_d, node_e]
             ]
    end
  end

  describe "get_neighbors" do
    test "returns neighbors for forward edges" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A --> B
      #   A --> C
      # ```

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})

      nodes = [node_a, node_b, node_c]

      # Create forward edges: A -> B, A -> C
      edges = [
        Edge.new(node_a, node_b, :forward),
        Edge.new(node_a, node_c, :forward)
      ]

      graph = Graph.new(nodes, edges)

      # Get neighbors of A
      neighbors = Graph.get_neighbors(graph, node_a)
      assert length(neighbors) == 2
      assert node_b in neighbors
      assert node_c in neighbors

      # B has no outgoing edges
      neighbors = Graph.get_neighbors(graph, node_b)
      assert neighbors == []
    end

    test "returns neighbors for backward edges" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   B --> A
      #   C --> A
      # ```
      # Backward edges mean B and C can reach A

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})

      nodes = [node_a, node_b, node_c]

      # Create backward edges: A <- B, A <- C
      # This means we can traverse from B to A and C to A
      edges = [
        Edge.new(node_a, node_b, :backward),
        Edge.new(node_a, node_c, :backward)
      ]

      graph = Graph.new(nodes, edges)

      # A has no neighbors (edges point to A, not from A)
      neighbors = Graph.get_neighbors(graph, node_a)
      assert neighbors == []

      # B can reach A via backward edge
      neighbors = Graph.get_neighbors(graph, node_b)
      assert neighbors == [node_a]

      # C can reach A via backward edge
      neighbors = Graph.get_neighbors(graph, node_c)
      assert neighbors == [node_a]
    end

    test "returns neighbors for bidirectional edges" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A <--> B
      #   B <--> C
      # ```

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})

      nodes = [node_a, node_b, node_c]

      # Create bidirectional edges: A <-> B <-> C
      edges = [
        Edge.new(node_a, node_b, :bidirectional),
        Edge.new(node_b, node_c, :bidirectional)
      ]

      graph = Graph.new(nodes, edges)

      # A's neighbors
      neighbors = Graph.get_neighbors(graph, node_a)
      assert neighbors == [node_b]

      # B's neighbors (both A and C)
      neighbors = Graph.get_neighbors(graph, node_b)
      assert length(neighbors) == 2
      assert node_a in neighbors
      assert node_c in neighbors

      # C's neighbors
      neighbors = Graph.get_neighbors(graph, node_c)
      assert neighbors == [node_b]
    end

    test "handles mixed edge directions" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A --> B
      #   C --> A
      #   A <--> D
      # ```
      # Note: C->A backward edge means A can reach C

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})
      node_c = Node.new(%{id: "C"})
      node_d = Node.new(%{id: "D"})

      nodes = [node_a, node_b, node_c, node_d]

      # Mixed edges:
      # A -> B (forward)
      # C <- A (backward edge from C to A, means A can reach C)
      # A <-> D (bidirectional)
      edges = [
        Edge.new(node_a, node_b, :forward),
        Edge.new(node_c, node_a, :backward),
        Edge.new(node_a, node_d, :bidirectional)
      ]

      graph = Graph.new(nodes, edges)

      # A's neighbors: B (forward), C (via backward edge), D (bidirectional)
      neighbors = Graph.get_neighbors(graph, node_a)
      assert length(neighbors) == 3
      assert node_b in neighbors
      assert node_c in neighbors
      assert node_d in neighbors

      # B has no neighbors
      neighbors = Graph.get_neighbors(graph, node_b)
      assert neighbors == []

      # C has no neighbors (backward edge points away from C)
      neighbors = Graph.get_neighbors(graph, node_c)
      assert neighbors == []

      # D can reach A via bidirectional edge
      neighbors = Graph.get_neighbors(graph, node_d)
      assert neighbors == [node_a]
    end

    test "returns empty list for node with no edges" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A
      #   B
      # ```
      # No edges between nodes

      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})

      # B is in the graph but has no edges
      graph = Graph.new([node_a, node_b], [])

      neighbors = Graph.get_neighbors(graph, node_a)
      assert neighbors == []

      neighbors = Graph.get_neighbors(graph, node_b)
      assert neighbors == []
    end

    test "handles self-loops correctly" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A --> A
      # ```
      # Self-loops

      # Create node
      node_a = Node.new(%{id: "A"})

      # Create self-loop edges
      edges = [
        # A -> A
        Edge.new(node_a, node_a, :forward),
        # A <-> A
        Edge.new(node_a, node_a, :bidirectional)
      ]

      graph = Graph.new([node_a], edges)

      # A should have itself as neighbor twice (once for each edge)
      neighbors = Graph.get_neighbors(graph, node_a)
      assert length(neighbors) == 2
      assert Enum.all?(neighbors, &(&1 == node_a))
    end

    test "handles duplicate edges correctly" do
      # Mermaid diagram:
      # ```mermaid
      # graph LR
      #   A --> B
      #   A --> B
      # ```
      # Duplicate edges

      # Create nodes
      node_a = Node.new(%{id: "A"})
      node_b = Node.new(%{id: "B"})

      # Create duplicate edges (same nodes, same direction)
      edges = [
        Edge.new(node_a, node_b, :forward),
        # duplicate
        Edge.new(node_a, node_b, :forward)
      ]

      graph = Graph.new([node_a, node_b], edges)

      # Should return B twice (once for each edge)
      neighbors = Graph.get_neighbors(graph, node_a)
      assert length(neighbors) == 2
      assert Enum.all?(neighbors, &(&1 == node_b))
    end
  end
end
