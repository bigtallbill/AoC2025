defmodule Aoc2025.Graph.Node do
  defstruct data: %{}

  @type t :: %__MODULE__{
          data: map()
        }

  def new(data) when is_map(data) do
    %__MODULE__{data: data}
  end
end
