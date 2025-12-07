defmodule Aoc2025.D6P2 do
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.zip_reduce({0, %{}}, &process_columns/2)
  end

  def process_columns([d1, d2, d3, operator], {total, constructed}) do
    cond do
      d1 == " " and d2 == " " and d3 == " " and operator == " " ->
        # todo calculate total using operator
        {total + calculate(constructed), %{}}

      true ->
        new_value = add_char(d1) <> add_char(d2) <> add_char(d3)

        constructed =
          Map.put(constructed, :values, Map.get(constructed, :values, []) ++ [new_value])

        constructed =
          if operator != " " do
            Map.put(constructed, :operator, operator)
          else
            constructed
          end

        {total, constructed}
    end
  end

  def calculate(%{values: [first | values], operator: operator}) do
    first = first |> Integer.parse() |> elem(0)

    values
    |> Enum.reduce(first, fn val, acc ->
      val = val |> Integer.parse() |> elem(0)

      case operator do
        "+" -> acc + val
        "*" -> acc * val
        "-" -> acc - val
        "/" -> acc / val
      end
    end)
  end

  def add_char(digit) do
    cond do
      digit == " " -> ""
      true -> digit
    end
  end

  def run(:example), do: File.read(Path.join(__DIR__, "d6-example.txt")) |> elem(1) |> run
  def run(:challenge), do: File.read(Path.join(__DIR__, "d6.txt")) |> elem(1) |> run
end
