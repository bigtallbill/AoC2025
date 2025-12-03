defmodule Aoc2025.D2P2 do
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.splitter(",")
    |> Stream.map(&parse_range(&1))
    |> Stream.map(&find_range_duplicates(&1))
    |> Stream.map(&Enum.sum(&1))
    |> Enum.sum()
  end

  def run(:example),
    do:
      Path.join(__DIR__, "d2p1-example.txt")
      |> File.read()
      |> elem(1)
      # just handle the trailing newline at end of the file
      |> String.split("\n")
      |> List.first()
      |> run

  def run(:challenge),
    do:
      Path.join(__DIR__, "d2p1.txt")
      |> File.read()
      |> elem(1)
      |> String.split("\n")
      |> List.first()
      |> run

  @doc """
  Accepts a range string `11-22` and converts it to a range enumerable.

  ## Example
      iex(1)> Aoc2025.D2P1.parse_range("11-22")
      iex(1)> 11..22
  """
  def parse_range(range_str) do
    [first, second] = String.split(range_str, "-")

    {first, _} = Integer.parse(first)
    {second, _} = Integer.parse(second)

    first..second
  end

  @doc """
  Finds all numbers in `range` that have duplicate halves (inclusive).

  ## Example
      iex(1)> Aoc2025.D2P1.process_range(11..33)
      iex(1)> [11, 22, 33]
  """
  def find_range_duplicates(range) do
    Enum.reduce(range, [], fn num, acc ->
      case has_unique_substr?(num) do
        true -> [num] ++ acc
        false -> acc
      end
    end)
  end

  @doc """
  Detects if the given string has any length of repeating substrings

  ## Example
      iex(1)> Aoc2025.D2P2.has_unique_substr?("1212")
      iex(1)> true

      iex(1)> Aoc2025.D2P2.has_unique_substr?("1213")
      iex(1)> false
  """
  def has_unique_substr?(number) when is_integer(number),
    do: Integer.to_string(number) |> has_unique_substr?

  def has_unique_substr?(number) when is_binary(number) do
    number_split = String.split(number, "", trim: true)
    has_unique_substr?(number_split, length(number_split), 1)
  end

  def has_unique_substr?(:found), do: true
  def has_unique_substr?(:exhausted), do: false

  def has_unique_substr?(number, number_length, kernel_size) when is_list(number) do
    cond do
      kernel_size >= number_length ->
        has_unique_substr?(:exhausted)

      true ->
        case Enum.chunk_every(number, kernel_size) |> Enum.uniq() |> Enum.count() do
          1 -> has_unique_substr?(:found)
          _ -> has_unique_substr?(number, number_length, kernel_size + 1)
        end
    end
  end
end
