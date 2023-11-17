defmodule Issues.GithubIssues do
  require Logger

  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]

  # use a module attribute to fetch the value at compile time
  @github_url Application.fetch_env!(:issues, :github_url)

  def fetch(user, project) do
    Logger.info("Fetching #{user}'s project #{project}")

    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  # get URL for request
  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  # Handle API Response
  def handle_response({ _, %{status_code: status_code, body: body}}) do
    Logger.info("Got response: status_code=#{status_code}")
    Logger.debug(fn -> inspect(body) end)
    {
      status_code |> check_for_error(),
      body |> Poison.Parser.parse!()
    }
  end

  # check for API errors
  defp check_for_error(200), do: :ok
  defp check_for_error(_),   do: :error

end
