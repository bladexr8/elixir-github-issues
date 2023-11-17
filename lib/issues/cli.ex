defmodule Issues.CLI do

  import Issues.TableFormatter, only: [ print_table_for_columns: 2 ]

  require Logger

  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help

  Otherwise it is a github user name, project name, and (optionally)
  the nuber of entries to format.

  Return a tuple of `{ user, project, count }`, or `:help` if help was given
  """
  def parse_args(argv) do
    OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help])
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation([user, project, count]) do
    { user, project, String.to_integer(count)}
  end

  def args_to_internal_representation([user, project]) do
    { user, project, @default_count }
  end

  # bad arg or --help
  def args_to_internal_representation(_) do
    :help
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  # main processing logic
  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response()
    |> sort_into_descending_order()
    |> last(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  # if API call successful, return result
  def decode_response({:ok, body}) do
    Logger.debug("***Decoding API Response...")
    body
  end

  # if API call unsuccessful, print error and exit
  def decode_response(({:error, error})) do
    IO.puts "Error fetching from Github: #{error["message"]}"
    System.halt(2)
  end

  # sort returned issues in descending order
  def sort_into_descending_order(list_of_issues) do
    Logger.debug("***Sorting into Descending Order...")
    list_of_issues
    |> Enum.sort(fn i1, i2 ->
      i1["created_at"] >= i2["created_at"]
    end)
  end

  # extract first n entries from list
  def last(list, count) do
    Logger.debug("Extracting First #{count} items from list...")
    list
    |> Enum.take(count)
    |> Enum.reverse
  end

end
