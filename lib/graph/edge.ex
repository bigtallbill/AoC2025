defmodule Aoc2025.Graph.Edge do
  alias Aoc2025.Graph.Node
  defstruct [:source, :target, :direction]

  @type direction :: :forward | :backward | :bidirectional

  @type t :: %__MODULE__{
          source: Node.t(),
          target: Node.t(),
          direction: direction()
        }

  @spec new(Node.t(), Node.t(), direction) :: %__MODULE__{}
  def new(source, target, direction \\ :forward) do
    %__MODULE__{source: source, target: target, direction: direction}
  end
end
