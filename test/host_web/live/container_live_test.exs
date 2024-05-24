defmodule HostWeb.ContainerLiveTest do
  use HostWeb.ConnCase

  import Phoenix.LiveViewTest
  import Host.ContainersFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_container(_) do
    container = container_fixture()
    %{container: container}
  end

  describe "Index" do
    setup [:create_container]

    test "lists all containers", %{conn: conn, container: container} do
      {:ok, _index_live, html} = live(conn, ~p"/containers")

      assert html =~ "Listing Containers"
      assert html =~ container.name
    end

    test "saves new container", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/containers")

      assert index_live |> element("a", "New Container") |> render_click() =~
               "New Container"

      assert_patch(index_live, ~p"/containers/new")

      assert index_live
             |> form("#container-form", container: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#container-form", container: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/containers")

      html = render(index_live)
      assert html =~ "Container created successfully"
      assert html =~ "some name"
    end

    test "updates container in listing", %{conn: conn, container: container} do
      {:ok, index_live, _html} = live(conn, ~p"/containers")

      assert index_live |> element("#containers-#{container.id} a", "Edit") |> render_click() =~
               "Edit Container"

      assert_patch(index_live, ~p"/containers/#{container}/edit")

      assert index_live
             |> form("#container-form", container: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#container-form", container: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/containers")

      html = render(index_live)
      assert html =~ "Container updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes container in listing", %{conn: conn, container: container} do
      {:ok, index_live, _html} = live(conn, ~p"/containers")

      assert index_live |> element("#containers-#{container.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#containers-#{container.id}")
    end
  end

  describe "Show" do
    setup [:create_container]

    test "displays container", %{conn: conn, container: container} do
      {:ok, _show_live, html} = live(conn, ~p"/containers/#{container}")

      assert html =~ "Show Container"
      assert html =~ container.name
    end

    test "updates container within modal", %{conn: conn, container: container} do
      {:ok, show_live, _html} = live(conn, ~p"/containers/#{container}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Container"

      assert_patch(show_live, ~p"/containers/#{container}/show/edit")

      assert show_live
             |> form("#container-form", container: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#container-form", container: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/containers/#{container}")

      html = render(show_live)
      assert html =~ "Container updated successfully"
      assert html =~ "some updated name"
    end
  end
end
