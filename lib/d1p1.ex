defmodule Aoc2025.D1P1 do
  @behaviour Aoc2025.DayBehaviour

  @starting_point 50

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.split("\n", trim: true)
    |> Stream.map(&String.split_at(&1, 1))
    |> Stream.map(fn {direction, magnitude_str} ->
      {direction, Integer.parse(magnitude_str) |> elem(0)}
    end)
    |> Enum.reduce({0, @starting_point}, fn {direction, magnitude}, {zeroes_count, position} ->
      new_position = wrap(position, direction, magnitude)

      {zeroes_count + if(new_position == 0, do: 1, else: 0), new_position}
    end)
    |> elem(0)
  end

  def run(:example), do: run(Path.join(__DIR__, "d1p1-example.txt") |> File.read() |> elem(1))
  def run(:challenge), do: run(Path.join(__DIR__, "d1p1.txt") |> File.read() |> elem(1))

  @doc """
  Takes a starting point and direction, then wraps around if magnitude exceeds the size or zero.
  """
  def wrap(starting_point, direction, magnitude, size \\ 100) do
    magnitude = rem(magnitude, size)

    new_pos =
      case direction do
        "R" -> starting_point + magnitude
        "L" -> starting_point - magnitude
      end

    new_pos = if new_pos < 0, do: new_pos + size, else: new_pos
    if new_pos > size - 1, do: new_pos - size, else: new_pos
  end
end
