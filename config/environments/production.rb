require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true

  Bullet.enable = false

  config.consider_all_requests_local = false
  config.server_timing = true

  config.active_storage.service = :local

  # メールの設定
  config.action_mailer.raise_delivery_errors = true # メール送信エラーを通知
  config.action_mailer.perform_deliveries = true # メールを実際に送信する
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "https://readlink.onrender.com/", protocol: 'https' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'readlink.onrender.com', #自分のアプリのドメイン
    user_name:            ENV['MAILER_SENDER'],
    password:             ENV['MAILER_PASSWORD'],
    authentication:       'plain',
    enable_starttls_auto: true 
  }


  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_job.verbose_enqueue_logs = true

  config.assets.quiet = true
  config.action_view.annotate_rendered_view_with_filenames = true

  config.action_controller.raise_on_missing_callback_actions = true
end
