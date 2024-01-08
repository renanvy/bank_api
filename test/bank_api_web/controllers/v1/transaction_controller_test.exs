defmodule BankApiWeb.V1.TransactionControllerTest do
  use BankApiWeb.ConnCase

  import BankApi.TransactionsFixtures

  @create_attrs %{
    amount: "120.5",
    reverted_at: ~U[2024-01-07 20:01:00Z]
  }
  @invalid_attrs %{amount: nil, reverted_at: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create transaction" do
    test "renders transaction when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/transactions", @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/v1/transactions/#{id}")

      assert %{
               "id" => ^id,
               "amount" => "120.5",
               "reverted_at" => "2024-01-07T20:01:00Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/transactions", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
