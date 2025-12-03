defmodule Aoc2025.D3P1 do
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.splitter("\n", trim: true)
    |> Enum.map(&parse_bank(&1))
    |> Enum.map(&find_largest_two(&1))
    |> Enum.sum()
  end

  def run(:example),
    do:
      Path.join(__DIR__, "d3p1-example.txt")
      |> File.read()
      |> elem(1)
      |> run

  def run(:challenge),
    do:
      Path.join(__DIR__, "d3p1.txt")
      |> File.read()
      |> elem(1)
      |> run

  def parse_bank(bank_str) do
    bank_str
    |> String.split("", trim: true)
    |> Enum.map(fn battery_str ->
      Integer.parse(battery_str) |> elem(0)
    end)
  end

  def find_largest_two(bank) when is_list(bank) do
    find_largest_two(bank, [])
  end

  def find_largest_two([], combinations), do: combinations |> Enum.max()

  def find_largest_two([first | rest], combinations) do
    first_str = Integer.to_string(first)

    new_combinations =
      rest
      |> Enum.map(fn next_batt ->
        (first_str <> Integer.to_string(next_batt)) |> Integer.parse() |> elem(0)
      end)

    find_largest_two(rest, new_combinations ++ combinations)
  end
end
