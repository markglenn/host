defmodule HostWeb.VirtualMachineLiveTest do
  use HostWeb.ConnCase

  import Phoenix.LiveViewTest
  import Host.VirtualMachinesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_virtual_machine(_) do
    virtual_machine = virtual_machine_fixture()
    %{virtual_machine: virtual_machine}
  end

  describe "Index" do
    setup [:create_virtual_machine]

    test "lists all virtual_machines", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, _index_live, html} = live(conn, ~p"/virtual_machines")

      assert html =~ "Listing Virtual machines"
      assert html =~ virtual_machine.name
    end

    test "saves new virtual_machine", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/virtual_machines")

      assert index_live |> element("a", "New Virtual machine") |> render_click() =~
               "New Virtual machine"

      assert_patch(index_live, ~p"/virtual_machines/new")

      assert index_live
             |> form("#virtual_machine-form", virtual_machine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#virtual_machine-form", virtual_machine: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/virtual_machines")

      html = render(index_live)
      assert html =~ "Virtual machine created successfully"
      assert html =~ "some name"
    end

    test "updates virtual_machine in listing", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, index_live, _html} = live(conn, ~p"/virtual_machines")

      assert index_live |> element("#virtual_machines-#{virtual_machine.id} a", "Edit") |> render_click() =~
               "Edit Virtual machine"

      assert_patch(index_live, ~p"/virtual_machines/#{virtual_machine}/edit")

      assert index_live
             |> form("#virtual_machine-form", virtual_machine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#virtual_machine-form", virtual_machine: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/virtual_machines")

      html = render(index_live)
      assert html =~ "Virtual machine updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes virtual_machine in listing", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, index_live, _html} = live(conn, ~p"/virtual_machines")

      assert index_live |> element("#virtual_machines-#{virtual_machine.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#virtual_machines-#{virtual_machine.id}")
    end
  end

  describe "Show" do
    setup [:create_virtual_machine]

    test "displays virtual_machine", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, _show_live, html} = live(conn, ~p"/virtual_machines/#{virtual_machine}")

      assert html =~ "Show Virtual machine"
      assert html =~ virtual_machine.name
    end

    test "updates virtual_machine within modal", %{conn: conn, virtual_machine: virtual_machine} do
      {:ok, show_live, _html} = live(conn, ~p"/virtual_machines/#{virtual_machine}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Virtual machine"

      assert_patch(show_live, ~p"/virtual_machines/#{virtual_machine}/show/edit")

      assert show_live
             |> form("#virtual_machine-form", virtual_machine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#virtual_machine-form", virtual_machine: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/virtual_machines/#{virtual_machine}")

      html = render(show_live)
      assert html =~ "Virtual machine updated successfully"
      assert html =~ "some updated name"
    end
  end
end
