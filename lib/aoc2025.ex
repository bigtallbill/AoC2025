defmodule Aoc2025 do
  @moduledoc """
  Documentation for `Aoc2025`.
  """

  def run(:challenge) do
    out = "Running challenges...\n"
    out = out <> "D1P1: #{Aoc2025.D1P1.run(:challenge)}\n"
    out = out <> "D1P2: #{Aoc2025.D1P2.run(:challenge)}\n"
    out = out <> "D2P1: #{Aoc2025.D2P1.run(:challenge)}\n"
    out = out <> "D2P2: #{Aoc2025.D2P2.run(:challenge)}\n"
    IO.puts(out)
  end
end
