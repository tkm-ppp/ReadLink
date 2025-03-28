require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  config.after_initialize do
    Bullet.enable        = true      # Bulletを有効にする
    Bullet.alert         = true      # アラートを表示する
    Bullet.bullet_logger  = true      # Bulletのログを記録する
    Bullet.console       = true      # コンソールに表示する
    Bullet.rails_logger  = true      # Railsのログに記録する
    Bullet.add_footer    = true      # フッターに情報を追加する
  end

  config.web_console.whitelisted_ips = '172.18.0.1'

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).

  config.active_storage.service = :local

  # メールの設定
  config.action_mailer.raise_delivery_errors = true # メール送信エラーを通知
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3001 }

  # 開発環境用: Letter Opener Webを使用
  if Rails.env.development?
    config.action_mailer.delivery_method = :letter_opener_web
    config.action_mailer.perform_deliveries = true
  end

  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_job.verbose_enqueue_logs = true

  config.assets.quiet = true
  config.action_view.annotate_rendered_view_with_filenames = true

  config.action_controller.raise_on_missing_callback_actions = true
end


