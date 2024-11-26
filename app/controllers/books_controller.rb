<h1>本の検索</h1>

<%= form_with url: books_path, method: :get do %>
  <%= label_tag :keyword, "キーワード" %>
  <%= text_field_tag :keyword, params[:keyword] %>
  <%= submit_tag "検索" %>
<% end %>

<h2>検索結果</h2>
<% if @books.present? %>
  <ul>
    <% @books.each do |book| %>
      <li><%= book["title"] %> - <%= book["author"] %></li>
    <% end %>
  </ul>
<% else %>
  <p>本が見つかりませんでした。</p>
<% end %>
