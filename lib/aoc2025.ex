defmodule Aoc2025 do
  @moduledoc """
  Documentation for `Aoc2025`.
  """

  def run(:challenge) do
    tests = [
      {:d1p1, Aoc2025.D1P1},
      {:d1p2, Aoc2025.D1P2},
      {:d2p1, Aoc2025.D2P1},
      {:d2p2, Aoc2025.D2P2},
      {:d3p1, Aoc2025.D3P1}
    ]

    out = "Running challenges...\n"
    IO.puts(out)

    Enum.each(tests, fn {name, module} ->
      {time_microseconds, result} = :timer.tc(fn -> module.run(:challenge) end)
      time_ms = time_microseconds / 1000
      IO.puts("#{name}: #{result} (#{Float.round(time_ms, 3)}ms)\n")
    end)

    {:ok, out}
  end
end
