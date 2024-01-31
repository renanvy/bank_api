defmodule BankApiWeb.V1.SessionControllerTest do
  use BankApiWeb.ConnCase, async: true

  import BankApi.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "login" do
    test "with valid credentials", %{conn: conn} do
      user = user_fixture()
      user_id = user.id

      conn =
        post(conn, ~p"/api/v1/login", %{
          cpf: user.cpf,
          password: "secret123"
        })

      assert %{"id" => ^user_id, "token" => _token} = json_response(conn, 200)
    end

    test "with invalid credentials", %{conn: conn} do
      user = user_fixture()

      conn =
        post(conn, "/api/v1/login", %{
          cpf: user.cpf,
          password: "wrong_password"
        })

      assert json_response(conn, 401)["error"] =~ "Invalid credentials"
    end
  end
end
