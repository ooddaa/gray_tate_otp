defmodule Mastery.Boundary.Worker do
  def work(val) do
    if :rand.uniform(10) == 1 do
      raise "Oops!"
    else
      {:result, :rand.uniform(val * 100)}
    end
  end

  def make_work_safe(dangerous_work, arg) do
    try do
      apply(dangerous_work, [arg])
    rescue
      error ->
        {:error, error, arg}
    end
  end

  def stream_work do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(fn i -> make_work_safe(&work(&1), i) end)
  end
end
