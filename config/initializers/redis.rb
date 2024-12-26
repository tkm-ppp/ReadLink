# require 'redis'
# require 'yaml'

# redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]

# begin
#   REDIS = Redis.new(url: redis_config['url'])
#   Rails.logger.info "Connected to Redis: #{REDIS.info}" # 接続に成功したら情報をログに出力
# rescue Redis::CannotConnectError => e
#   Rails.logger.error "Failed to connect to Redis: #{e.message}"
#   REDIS = nil # 接続失敗時のフォールバック処理
# rescue StandardError => e
#   Rails.logger.error "An error occurred while connecting to Redis: #{e.message}"
#   REDIS = nil
# end