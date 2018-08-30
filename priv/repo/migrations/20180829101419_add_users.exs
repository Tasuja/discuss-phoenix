defmodule Discuss.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :provider, :string
      add :token, :string

      timestamps() #for every record in the table users, timestamps() will generated created_at and updated_at time
    end
  end
end
