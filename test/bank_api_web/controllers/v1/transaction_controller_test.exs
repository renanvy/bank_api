defmodule BankApiWeb.V1.TransactionControllerTest do
  use BankApiWeb.ConnCase, async: true

  import BankApi.AccountsFixtures
  import BankApi.TransactionsFixtures

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

  describe "create transaction" do
    @tag authenticated: false
    test "returns unauthorized when not authenticated", %{conn: conn} do
      params = %{
        "amount" => 10.0,
        "receiver_id" => Ecto.UUID.generate()
      }

      conn = post(conn, ~p"/api/v1/transactions", params)

      assert conn.resp_body =~ "unauthenticated"
      assert conn.status == 401
    end

    @tag authenticated: true
    test "renders transaction when data is valid", %{conn: conn} do
      receiver = user_fixture()

      params = %{
        "amount" => 10.0,
        "receiver_id" => receiver.id
      }

      conn = post(conn, ~p"/api/v1/transactions", params)

      assert %{"id" => _id, "amount" => "10.0", "reverted_at" => nil} = json_response(conn, 201)
    end

    @tag authenticated: true
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/transactions", %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "revert transaction" do
    @tag authenticated: false
    test "returns unauthorized when not authenticated", %{conn: conn} do
      transaction_id = Ecto.UUID.generate()

      conn = patch(conn, ~p"/api/v1/transactions/#{transaction_id}/revert")

      assert conn.resp_body =~ "unauthenticated"
      assert conn.status == 401
    end

    @tag authenticated: true
    test "renders transaction when is successfully reverted", %{conn: conn, user: user} do
      receiver = user_fixture()
      transaction = transaction_fixture(%{receiver_id: receiver.id, sender_id: user.id})

      conn = patch(conn, ~p"/api/v1/transactions/#{transaction.id}/revert")

      assert %{"id" => id, "amount" => amount, "reverted_at" => reverted_at} =
               json_response(conn, 200)

      assert id == transaction.id
      assert Decimal.new(amount) == transaction.amount
      assert reverted_at
    end
  end
end
