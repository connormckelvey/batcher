defmodule Batcher.App do
  use Batcher.Web, :model

  schema "apps" do
    field :name, :string
    field :api_key, :string
    belongs_to :user, Batcher.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :api_key])
    |> validate_required([:name])
  end

  def app_creation_changeset(model, params) do
    model
    |> changeset(params)
    |> validate_length(:name, min: 1, max: 100)
    |> generate_api_key
  end

  def generate_api_key(changeset) do
    IO.puts "______________________________________________APIIIII"
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :api_key, UUID.uuid4(:hex))
      _ ->
        changeset
    end
  end
end
