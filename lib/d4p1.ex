defmodule Aoc2025.D4P1 do
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.splitter("\n", trim: true)
    |> parse_grid()
    |> walk_grid()
    |> Enum.map(&has_4_neighboring_rolls?(&1))
    |> Enum.reject(fn {_x, _y, char, count} ->
      cond do
        char == "." -> true
        count >= 4 -> true
        true -> false
      end
    end)
    |> Enum.count()
  end

  def run(:example), do: File.read(Path.join(__DIR__, "d4-example.txt")) |> elem(1) |> run
  def run(:challenge), do: File.read(Path.join(__DIR__, "d4.txt")) |> elem(1) |> run

  def parse_grid(lines) do
    grid =
      for {line, y} <- Enum.with_index(lines),
          {char, x} <- String.splitter(line, "", trim: true) |> Enum.with_index() do
        {x, y, char}
      end

    map =
      Enum.reduce(grid, %{}, fn {x, y, char}, grid_map ->
        Map.get_and_update(grid_map, y, fn row_map ->
          updated =
            case row_map do
              nil -> Map.put(%{}, x, char)
              row_map -> Map.put(row_map, x, char)
            end

          {row_map, updated}
        end)
        |> elem(1)
      end)

    w = Map.get(map, 0) |> Enum.count()
    h = Enum.count(map)

    {w, h, map}
  end

  def walk_grid({w, h, map}) do
    for y <- 0..(h - 1), x <- 0..(w - 1) do
      {_x, _y, char} = get_at(map, {x, y})
      {x, y, char, get_neighbors(map, {x, y})}
    end
  end

  def get_neighbors(map, {x, y}) do
    nw = {x - 1, y - 1}
    n = {x, y - 1}
    ne = {x + 1, y - 1}
    e = {x + 1, y}
    se = {x + 1, y + 1}
    s = {x, y + 1}
    sw = {x - 1, y + 1}
    w = {x - 1, y}

    %{
      north_west: map |> get_at(nw),
      north: map |> get_at(n),
      north_east: map |> get_at(ne),
      east: map |> get_at(e),
      south_east: map |> get_at(se),
      south: map |> get_at(s),
      south_west: map |> get_at(sw),
      west: map |> get_at(w)
    }
  end

  def get_at(map, {x, y}) do
    {x, y, map |> Map.get(y, %{}) |> Map.get(x)}
  end

  def has_4_neighboring_rolls?({x, y, char, neighbors}) do
    count =
      neighbors
      |> Enum.reduce_while(0, fn neighbor, count ->
        cond do
          count > 3 ->
            {:halt, count}

          true ->
            case neighbor do
              {_dir, {_x, _y, "@"}} -> {:cont, count + 1}
              _ -> {:cont, count}
            end
        end
      end)

    {x, y, char, count}
  end
end
