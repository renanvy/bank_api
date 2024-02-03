defmodule BankApiWeb.V1.UserControllerTest do
  use BankApiWeb.ConnCase, async: true

  import BankApi.AccountsFixtures
  import BankApi.TransactionsFixtures

  alias BankApi.{Accounts.Schemas.User, Repo, Transactions.Schemas.Transaction}
  alias BankApiWeb.Auth.Guardian

  setup %{conn: conn} = context do
    conn = put_req_header(conn, "accept", "application/json")

    if Map.get(context, :authenticated, true) do
      user = user_fixture()
      conn = Guardian.Plug.sign_in(conn, user)
      {:ok, token, _claims} = Guardian.encode_and_sign(user)

      {:ok, conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
    else
      {:ok, conn: conn}
    end
  end

  describe "create user" do
    @tag authenticated: false
    test "renders user when data is valid", %{conn: conn} do
      attrs = %{
        "first_name" => "John",
        "last_name" => "Doe",
        "cpf" => "34323434333",
        "opening_balance" => 100,
        "password" => "secret123"
      }

      conn = post(conn, ~p"/api/v1/users", attrs)

      assert %{"id" => id, "token" => _token} = json_response(conn, 201)

      balance = Decimal.new("100")

      assert %User{
               id: ^id,
               opening_balance: ^balance,
               balance: ^balance,
               cpf: "34323434333",
               first_name: "John",
               last_name: "Doe"
             } = Repo.get(User, id)
    end

    @tag authenticated: false
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show user balance" do
    @tag authenticated: false
    test "returns unauthorized when not authenticated", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/my-balance")
      assert conn.resp_body =~ "unauthenticated"
      assert conn.status == 401
    end

    @tag authenticated: true
    test "renders user balance", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/my-balance")
      assert %{"balance" => "100.0"} = json_response(conn, 200)
    end
  end

  describe "show user transactions" do
    @tag authenticated: false
    test "returns unauthorized when not authenticated", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/my-transactions")
      assert conn.resp_body =~ "unauthenticated"
      assert conn.status == 401
    end

    @tag authenticated: true
    test "renders user transactions", %{conn: conn, user: user} do
      %Transaction{
        id: transaction_1_id,
        sender_id: transaction_1_sender_id,
        receiver_id: transaction_1_receiver_id,
        reverted_at: transaction_1_reverted_at
      } =
        transaction_fixture(%{
          amount: 100.0,
          receiver_id: user.id,
          inserted_at: ~U[2024-01-02 10:00:00Z]
        })

      %Transaction{
        id: transaction_2_id,
        sender_id: transaction_2_sender_id,
        receiver_id: transaction_2_receiver_id,
        reverted_at: transaction_2_reverted_at
      } =
        transaction_fixture(%{
          amount: 100.0,
          sender_id: user.id,
          inserted_at: ~U[2024-01-02 10:00:00Z]
        })

      conn =
        get(conn, ~p"/api/v1/my-transactions", %{start_date: "2024-01-01", end_date: "2024-01-31"})

      amount = "100.0"

      assert [
               %{
                 "amount" => ^amount,
                 "id" => ^transaction_1_id,
                 "receiver_id" => ^transaction_1_receiver_id,
                 "reverted_at" => ^transaction_1_reverted_at,
                 "sender_id" => ^transaction_1_sender_id
               },
               %{
                 "amount" => ^amount,
                 "id" => ^transaction_2_id,
                 "receiver_id" => ^transaction_2_receiver_id,
                 "reverted_at" => ^transaction_2_reverted_at,
                 "sender_id" => ^transaction_2_sender_id
               }
             ] = json_response(conn, 200)
    end

    @tag authenticated: true
    test "renders empty list when user has no transactions", %{conn: conn} do
      conn =
        get(conn, ~p"/api/v1/my-transactions", %{start_date: "2024-01-01", end_date: "2024-01-31"})

      assert [] = json_response(conn, 200)
    end
  end
end
