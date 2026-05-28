defmodule UserServiceWeb.UserController do
  use UserServiceWeb, :controller
  alias UserService.Repo
  alias UserService.User
  import Ecto.Query

  # GET /api/users/:id
  def show(conn, %{"id" => id}) do
    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Usuario no encontrado"})

      user ->
        json(conn, %{
          id: user.id,
          email: user.email,
          password: user.password
        })
    end
  end

  # POST /users
  def create(conn, %{"email" => email, "password" => password}) do
    changeset = User.changeset(%User{}, %{email: email, password: password})

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{
          id: user.id,
          email: user.email,
          password: user.password
        })

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Error al crear usuario: #{inspect(changeset.errors)}"})
    end
  end

  # PUT /users/:id
  def update(conn, %{"id" => id_param, "email" => email, "password" => password}) do
    # 1. Validar y parsear el ID a entero
    case Integer.parse(id_param) do
      {id, ""} ->

        query = from(u in User, where: u.id == ^id)

        # 2. Ejecutar el UPDATE directo en un solo viaje a la base de datos
        case Repo.update_all(query, set: [email: email, password: password]) do
          {0, _} ->
            # Si afectó 0 filas, el usuario no existía (Equivalente a rowCount === 0)
            conn
            |> put_status(:not_found)
            |> json(%{error: "Usuario no encontrado"})

          {1, _} ->
            # Si afectó 1 fila, la actualización fue exitosa.
            # Retornamos los datos directamente simulando el objeto ya que conocemos los valores.
            json(conn, %{
              id: id,
              email: email,
              password: password
            })
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "ID inválido"})
    end
  end

  # DELETE /users/:id
  def delete(conn, %{"id" => id_param}) do
    # 1. Validar y parsear el ID a entero
    case Integer.parse(id_param) do
      {id, ""} ->

        query = from(u in User, where: u.id == ^id)

        # 2. Ejecutar el DELETE directo en un solo viaje a la base de datos
        case Repo.delete_all(query) do
          {0, _} ->
            # Si afectó 0 filas, el usuario no existía (Equivalente a rowCount === 0)
            conn
            |> put_status(:not_found)
            |> json(%{error: "Usuario no encontrado"})

          {1, _} ->
            # Si afectó 1 fila, se eliminó con éxito.
            # Retornamos el ID y el mensaje confirmando la eliminación limpia.
            json(conn, %{
              id: id,
              message: "Usuario eliminado"
            })
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "ID inválido"})
    end
  end
end
