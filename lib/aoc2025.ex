defmodule Aoc2025 do
  @moduledoc """
  Documentation for `Aoc2025`.
  """

  def run(:challenge) do
    out = "Running challenges...\n"
    out = out <> "D1P1: #{Aoc2025.D1P1.run(:challenge)}\n"
    IO.puts(out)
  end
end
