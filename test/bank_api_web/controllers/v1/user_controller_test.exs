defmodule BankApiWeb.V1.UserControllerTest do
  use BankApiWeb.ConnCase

  alias BankApi.Accounts.Guardian

  @create_attrs %{
    opening_balance: "120.5",
    first_name: "some first_name",
    last_name: "some last_name",
    cpf: "some cpf",
    password: "some password_hash"
  }
  @invalid_attrs %{balance: nil, first_name: nil, last_name: nil, cpf: nil, password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    setup [:create_session]

    test "renders user when data is valid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/v1/users", @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/v1/users/#{id}")

      assert %{
               "id" => ^id,
               "opening_balance" => "120.5",
               "balance" => "120.5",
               "cpf" => "some cpf",
               "first_name" => "some first_name",
               "last_name" => "some last_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
