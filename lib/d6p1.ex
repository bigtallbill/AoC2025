defmodule Aoc2025.D6P1 do
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ~r/\s/, trim: true))
    |> Enum.zip_with(fn [n1, n2, n3, n4, operator] ->
      n1 = Integer.parse(n1) |> elem(0)
      n2 = Integer.parse(n2) |> elem(0)
      n3 = Integer.parse(n3) |> elem(0)
      n4 = Integer.parse(n4) |> elem(0)

      case operator do
        "*" -> n1 * n2 * n3 * n4
        "+" -> n1 + n2 + n3 + n4
      end
    end)
    |> Enum.sum()
  end

  def run(:example), do: File.read(Path.join(__DIR__, "d6-example.txt")) |> elem(1) |> run
  def run(:challenge), do: File.read(Path.join(__DIR__, "d6.txt")) |> elem(1) |> run
end
