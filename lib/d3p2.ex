defmodule Aoc2025.D3P2 do
  @behaviour Aoc2025.DayBehaviour

  @impl true
  def run(data) when is_binary(data) do
    data
    |> String.splitter("\n", trim: true)
    |> Enum.map(&parse_bank/1)
    |> Enum.map(&find_largest_n(&1, 12))
    |> Enum.sum()
  end

  def run(:example) do
    {:ok, contents} = Path.join(__DIR__, "d3p1-example.txt") |> File.read()
    run(contents)
  end

  def run(:challenge) do
    {:ok, contents} = Path.join(__DIR__, "d3p1.txt") |> File.read()
    run(contents)
  end

  def parse_bank(bank_str) do
    bank_str
    |> String.split("", trim: true)
    |> Enum.map(fn digit_str ->
      digit_str |> Integer.parse() |> elem(0)
    end)
  end

  def find_largest_n(bank, n) when is_list(bank) do
    to_remove = length(bank) - n

    {stack, to_remove} =
      Enum.reduce(bank, {[], to_remove}, fn current, {stack, to_remove} ->
        {stack, to_remove} = pop_smaller(stack, current, to_remove)
        {stack ++ [current], to_remove}
      end)

    # If we still have removals left, drop from the end
    stack =
      if to_remove > 0 do
        Enum.slice(stack, 0, length(stack) - to_remove)
      else
        stack
      end

    stack
    |> Enum.take(n)
    |> Integer.undigits()
  end

  defp pop_smaller(stack, _current, 0), do: {stack, 0}

  defp pop_smaller([], _current, to_remove), do: {[], to_remove}

  defp pop_smaller(stack, current, to_remove) do
    last = List.last(stack)

    if last < current do
      # drop the last digit
      new_stack = Enum.slice(stack, 0..-2//1)
      pop_smaller(new_stack, current, to_remove - 1)
    else
      {stack, to_remove}
    end
  end

  def test(number_str, n \\ 12) do
    number_str
    |> String.split("", trim: true)
    |> Enum.map(fn nstr -> nstr |> Integer.parse() |> elem(0) end)
    |> find_largest_n(n)
  end
end
