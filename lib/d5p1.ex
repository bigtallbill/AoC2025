defmodule Aoc2025.D5P1 do
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> parse_db()
    |> find_fresh()
    |> Enum.count()
  end

  def run(:example), do: File.read(Path.join(__DIR__, "d5-example.txt")) |> elem(1) |> run
  def run(:challenge), do: File.read(Path.join(__DIR__, "d5.txt")) |> elem(1) |> run

  def parse_db([ranges, ingredients]) do
    ranges = Enum.map(ranges, &parse_range(&1))
    ingredients = Enum.map(ingredients, &(Integer.parse(&1) |> elem(0)))

    {ranges, ingredients}
  end

  def parse_range(range_str) do
    range_str
    |> String.split("-", trim: true)
    |> Enum.map(&(Integer.parse(&1) |> elem(0)))
    |> then(fn [first, second] -> first..second end)
  end

  def find_fresh({ranges, ingredients}) do
    for ingredient <- ingredients, range <- ranges, ingredient in range do
      ingredient
    end
    |> Enum.uniq()
  end
end
