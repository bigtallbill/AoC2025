defmodule Aoc2025.D5P2 do
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> parse_db()
    |> find_all_fresh_ids()
    |> count_fresh()
    |> then(fn {a, b} -> a - b end)
  end

  def run(:example), do: File.read(Path.join(__DIR__, "d5-example.txt")) |> elem(1) |> run
  def run(:challenge), do: File.read(Path.join(__DIR__, "d5.txt")) |> elem(1) |> run

  def count_fresh({full, gaps}) do
    gaps = Enum.sort(gaps, fn gapA, gapB -> gapA.first > gapB.first end)

    full_length = Enum.count(full)

    combined =
      Enum.map(gaps, fn gap ->
        case Enum.count(gap) do
          2 -> 0
          count -> count - 2
        end
      end)
      |> Enum.sum()

    {full_length, combined}
  end

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

  def find_all_fresh_ids({[first | ranges] = _ranges, _ingredients}) do
    merge_ranges(ranges, first, [])
  end

  def merge_ranges([], merged, all_gaps) do
    {merged, all_gaps}
  end

  def merge_ranges([second | rest], first, all_gaps) do
    all_gaps =
      Enum.reduce(all_gaps, [], fn gap, filtered_gaps ->
        range_not(second, gap) ++ filtered_gaps
      end)

    {new_range, gaps} = range_union(first, second)

    merge_ranges(rest, new_range, all_gaps ++ gaps)
  end

  @doc """
  performs B NOT A operation.

  returns a list of ranges of B not in A

  If A covers B entirely then nil is returned

  If B is disjoint from A then B is returned unmodified
  """
  @spec range_not(Range.t(), Range.t()) :: [Range.t()]
  def range_not(a, b) do
    case relationship(a, b) do
      :within ->
        []

      :covers ->
        [b.first..a.first, a.last..b.last]

      :overlap_left ->
        [b.first..a.first]

      :overlap_right ->
        [a.last..b.last]

      :disjoint_left ->
        [b]

      :disjoint_right ->
        [b]

      :equal ->
        []
    end
  end

  @doc """
  Unions the given ranges.

  returns a tuple with the new range and if the ranges are disjoint, the range that covers the gap
  """
  @spec range_union(a :: Range, b :: Range) :: {Range, [Range]}
  def range_union(a, b) do
    relationship = relationship(a, b)

    case relationship do
      :equal ->
        {b, []}

      :within ->
        {a, []}

      :covers ->
        {b, []}

      :overlap_right ->
        {a.first..b.last, []}

      :overlap_left ->
        {b.first..a.last, []}

      :disjoint_right ->
        gap =
          if b.first - a.last > 1 do
            [disjoint_gap(a, b, :disjoint_right)]
          else
            []
          end

        {a.first..b.last, gap}

      :disjoint_left ->
        gap =
          if a.first - b.last > 1 do
            [disjoint_gap(a, b, :disjoint_left)]
          else
            []
          end

        {b.first..a.last, gap}
    end
  end

  def disjoint_gap(a, b, :disjoint_left) do
    b.last..a.first
  end

  def disjoint_gap(a, b, :disjoint_right) do
    a.last..b.first
  end

  @doc """
  Gets the relationship of the B relative to the A

  ## Example
      iex(1)> Aoc2025.D5P2.relationship(10..20, 15..25)
      iex(1)> :overlap_right

      iex(1)> Aoc2025.D5P2.relationship(15..25, 10..20)
      iex(1)> :overlap_left

      iex(1)> Aoc2025.D5P2.relationship(10..20, 12..18)
      iex(1)> :within

      iex(1)> Aoc2025.D5P2.relationship(10..20, 8..22)
      iex(1)> :covers

      iex(1)> Aoc2025.D5P2.relationship(10..20, 25..30)
      iex(1)> :disjoint_right

      iex(1)> Aoc2025.D5P2.relationship(10..20, 1..5)
      iex(1)> :disjoint_left
  """
  def relationship(a, b) do
    cond do
      a.first == b.first and a.last == b.last -> :equal
      b.first >= a.first and b.last <= a.last -> :within
      b.first < a.first and b.last > a.last -> :covers
      b.first >= a.first and b.first <= a.last and b.last > a.last -> :overlap_right
      b.last > a.last -> :disjoint_right
      b.first <= a.first and b.last >= a.first -> :overlap_left
      b.last < a.first -> :disjoint_left
    end
  end
end
