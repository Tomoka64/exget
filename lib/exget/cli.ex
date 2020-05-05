defmodule Exget.CLI do
  alias Exget.{Download,Error}
  def main(args) do
    path = System.get_env("EXPATH")
    if path == "" do
      "make sure to set $EXPATH (example: $HOME/elixir)"
    else
      excute(args)
    end
  end

  def excute([]) do
    IO.puts "
  concurrently cloning github repository into your $EXPATH

  exget github.com/Tomoka64/exget github.com/Tomoka64...

  make sure to set $EXPATH (example: $HOME/elixir)
    "
  end

  def excute(args) do
    for arg <- args do
      Process.flag(:trap_exit, true)
      spawn_link(Download, :process, [arg])
      receive do
        {:error, reason} -> Error.message(reason)
        {:EXIT, _from_pid, reason} ->
          if reason != :normal, do: IO.puts("Exit reason: 'git' returned error")
      end
    end
  end
end
