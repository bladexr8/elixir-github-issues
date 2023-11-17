defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  # get URL for request
  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  # 200 - Success Response
  def handle_response({ :ok, %{status_code: 200, body: body}}) do
    { :ok, body}
  end

  # treat any other response as an error
  def handle_response({_, %{status_code: _, body: body}}) do
    { :error, body}
  end
end
