defmodule JsonParsingChallenge do
  def run(url) do
    url
    |> get_data
    |> decode_json
    |> sort_names_and_credit_cards
    |> create_output
  end

  def get_data(url) do
    HTTPoison.start

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Resource Not Found - 404"
        exit(:normal)
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts "There was an error when trying to GET url: #{url}"
        IO.puts "Reason: #{inspect reason}"
        exit(:normal)
    end
  end

  def decode_json(json_data), do: Poison.decode!(json_data)

  def sort_names_and_credit_cards(json) do
    for %{"name" => name, "creditcard" => credit_card} <- json, !is_nil(credit_card) do
      [name, credit_card]
    end
  end

  def create_output(data) do
    File.open(gen_csv_file_name, [:write], fn(file) ->
      data |> CSV.encode |> Enum.each(&IO.write(file, &1))
    end)
  end

  def gen_csv_file_name do
    :erlang.now
    |> :calendar.now_to_datetime
    |> parse_date
    |> build_file_name
  end

  def parse_date({{year, month, day}, _}), do: "#{year}#{month}#{day}"
  def build_file_name(date), do: "#{date}.csv"
end

JsonParsingChallenge.run "https://gist.githubusercontent.com/jorin-vogel/7f19ce95a9a842956358/raw/e319340c2f6691f9cc8d8cc57ed532b5093e3619/data.json"
