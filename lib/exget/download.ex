defmodule Exget.Download do
  alias Exget.Error

  @expath System.get_env("EXPATH")

  def process(arg) do
    IO.puts "start downloading #{arg}"
    case get_user_and_repo_from_url(arg) do
      {user, repo} ->
        with path <- get_path(user),
        url <- get_clone_url(user, repo) do
          case mkdir(path) do
            {:error, reason} -> {:error, %Error{reason: reason}}
            _ ->
              cd(path)
              clone(url)
              {:ok}
          end
        end
      error -> {:error, error}
    end

  end

  def get_user_and_repo_from_url(url) do
    {repo, path} = String.split(url, "/") |> List.pop_at(-1)
    if length(path) < 2 or repo == "" do
      %Error{reason: :invalid_input}
    else
      user = Enum.at(path, 1)
      {user, repo}
    end
  end

  def get_path(user) do
    "#{@expath}/src/github.com/#{user}"
  end

  def get_clone_url(user, repo) do
    "git@github.com:#{user}/#{repo}.git"
  end

  defp mkdir(path) do
    if !File.exists?(path) do
      IO.puts path
      case File.mkdir(path) do
        {:error, reason} -> {:error, reason}
        _ -> {:ok}
      end
    else
      {:ok}
    end
  end

  defp clone(url) do
    System.cmd("git", ["clone", url])
  end

  defp cd(path) do
    File.cd(path)
  end
end
