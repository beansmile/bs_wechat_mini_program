# frozen_string_literal: true

require "httparty"
require "openssl"
require "base64"
require "json"

module BsWechatMiniProgram
  class Client
    include HTTParty
    include BsWechatMiniProgram::API::Auth
    include BsWechatMiniProgram::API::SubscribeMessage
    include BsWechatMiniProgram::API::Wxacode
    include BsWechatMiniProgram::API::Security

    base_uri "https://api.weixin.qq.com"

    @@logger = ::Logger.new("./log/mini_program.log")

    ACCESS_TOKEN_CACHE_KEY_PREFIX = "mini_program_access_token"
    ENV_FALLBACK_ARRAY = [:production, :staging, :development]
    HTTP_ERRORS = [
      EOFError,
      Errno::ECONNRESET,
      Errno::EINVAL,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Timeout::Error
    ]
    TIMEOUT = 5

    attr_accessor :name, :appid, :secret, :get_access_token_api_prefix
    mattr_accessor :rel
    @@appid_clients = {}
    @@name_clients = {}

    def self.appid_clients
      @@appid_clients
    end

    def self.name_clients
      @@name_clients
    end

    def self.find_by_appid(appid)
      appid_clients[appid]
    end

    def self.find_by_name(name)
      name_clients[name]
    end

    def initialize(name, appid, secret, options = {})
      @name = name
      @appid = appid
      @secret = secret
      @get_access_token_api_prefix = if options[:get_access_token_api_prefix].present?
                                 options[:get_access_token_api_prefix]
                               else
                                 "/app_api/v1"
                               end
      self.class.appid_clients[appid] = self
      self.class.name_clients[name] = self
    end

    def host_key
      :host
    end

    def api_authorization_token_key
      :api_authorization_token
    end

    def decrypt!(session_key, encrypted_data, iv)
      begin
        cipher = OpenSSL::Cipher::AES.new 128, :CBC
        cipher.decrypt
        cipher.padding = 0
        cipher.key = Base64.decode64(session_key)
        cipher.iv  = Base64.decode64(iv)
        data = cipher.update(Base64.decode64(encrypted_data)) << cipher.final
        result = JSON.parse data[0...-data.last.ord]
      rescue StandardError => e
        @@logger.debug("[UserData] decrypt error: #{e.message}")
        raise "微信解析数据错误"
      end

      if result.dig("watermark", "appid") != appid
        @@logger.debug("[UserData] decrypt error: #{result}")
        raise "微信解析数据错误"
      end

      result
    end

    def access_token_cache_key
      @access_token_cache_key ||= "#{ACCESS_TOKEN_CACHE_KEY_PREFIX}_#{appid}"
    end

    # return token
    def get_access_token
      access_token = Rails.cache.fetch(access_token_cache_key)

      return access_token if access_token

      ENV_FALLBACK_ARRAY.each do |env|
        if Rails.env == env.to_s
          access_token = refresh_access_token

          break
        else
          host = Rails.application.credentials.dig(env, host_key)

          # 未部署的环境暂时不配置host
          next if host.blank?

          resp = http_get("#{host}/#{get_access_token_api_prefix}/wechat_mini_program/access_token?appid=#{appid}", { headers: { "api-authorization-token" => Rails.application.credentials.dig(env, api_authorization_token_key) } }, false)

          next unless access_token = resp["access_token"]

          Rails.cache.write(access_token_cache_key, access_token, expires_in: 5.minutes)

          break
        end
      end

      access_token
    end

    def refresh_access_token
      resp = http_get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{appid}&secret=#{secret}", {}, false)

      access_token = resp["access_token"]
      Rails.cache.write(access_token_cache_key, access_token, expires_in: 100.minutes)

      access_token
    end

    [:get, :post].each do |method|
      define_method "http_#{method}" do |path, options = {}, need_access_token = true|
        body = (options[:body] || {})
        headers = (options[:headers] || {}).reverse_merge({
          "Content-Type" => "application/json"
        })
        path = "#{path}?access_token=#{get_access_token}" if need_access_token

        uuid = SecureRandom.uuid

        @@logger.debug("request[#{uuid}]: method: #{method}, url: #{path}, body: #{body}, headers: #{headers}")

        response = begin
                     body = self.class.send(method, path, body: JSON.pretty_generate(body), headers: headers, timeout: TIMEOUT).body
                     JSON.parse(body)
                   rescue JSON::ParserError
                     body
                   rescue *HTTP_ERRORS
                     { "errmsg" => "连接超时" }
                   end

        @@logger.debug("response[#{uuid}]: #{response}")

        response
      end
    end
  end
end
