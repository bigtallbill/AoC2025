defmodule Aoc2025.D7P1 do
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.split("\n", trim: true)
    # add an extra entry just so we can use drop_every to remove the lines with only dots
    |> then(fn lines -> ["blank"] ++ lines end)
    |> Enum.drop_every(2)
    |> Enum.map(&String.codepoints(&1))
    |> send_beam()
  end

  def run(:example), do: File.read(Path.join(__DIR__, "d7-example.txt")) |> elem(1) |> run
  def run(:challenge), do: File.read(Path.join(__DIR__, "d7.txt")) |> elem(1) |> run

  def send_beam(rows) do
    [first | splitter_rows] = rows

    start_indicies = find_all_indicies(first, "S")

    send_beam(splitter_rows, {0, start_indicies})
  end

  def send_beam([], last_state), do: last_state

  def send_beam([row | remaining], {splits, last_state}) do
    splitter_indicies = find_all_indicies(row, "^")

    {new_splits, new_state} = continue_beam(last_state, splitter_indicies)
    send_beam(remaining, {splits + new_splits, new_state})
  end

  def continue_beam(incoming_beams, splitters) do
    {splits, new_beams} =
      Enum.reduce(incoming_beams, {0, []}, fn beam_index, {splits, new_beams} ->
        cond do
          beam_index in splitters -> {splits + 1, new_beams ++ [beam_index - 1, beam_index + 1]}
          true -> {splits, new_beams ++ [beam_index]}
        end
      end)

    {splits, new_beams |> Enum.uniq()}
  end

  def find_all_indicies(list, search) do
    list
    |> Stream.with_index()
    |> Stream.filter(fn {value, _idx} -> value == search end)
    |> Enum.map(fn {_v, idx} -> idx end)
  end
end
