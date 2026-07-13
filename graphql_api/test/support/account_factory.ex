defmodule GraphqlApi.AccountFactory do
  def build(:account) do
    unique =
      [:positive]
      |> System.unique_integer()
      |> Integer.to_string()

    %{
      # id: String.to_integer(unique),
      name: "Randy #{unique}",
      email: "r#{unique}@codingp.com",
      preferences: %{
        likes_emails: false,
        likes_phone_calls: false,
        likes_faxes: false
      }
    }
  end

  def build(:preferences) do
    %{
      likes_emails: false,
      likes_phone_calls: false,
      likes_faxes: false
    }
  end

  def build(factory, key, val) do
    factory |> build() |> Map.replace(key, val)
  end

  def build_8(:account) do
    names = ~w/Adam Barbara Charlie Debbie Evan Fiona George Hestia/s

    for x <- 0..7 do
      name = Enum.at(names, x)
      <<email::1, call::1, fax::1>> = <<x::3>>

      %{
        name: name,
        email: "#{name}@codingp.com",
        preferences: %{
          likes_emails: email == 1,
          likes_phone_calls: call == 1,
          likes_faxes: fax == 1
        }
      }
    end
  end
end
