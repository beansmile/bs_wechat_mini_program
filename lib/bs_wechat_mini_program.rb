# frozen_string_literal: true

require "bs_wechat_mini_program/engine"
require "bs_wechat_mini_program/api"
require "bs_wechat_mini_program/client"
require "bs_wechat_mini_program/mixin"

module BsWechatMiniProgram
  mattr_accessor :redis, :get_client_by_appid

  mattr_accessor :set_wxacode_page_option
  @@set_wxacode_page_option = true

  def self.configuration
    yield self
  end

  def self.client(appid, secret, options = {})
    @@client ||= BsWechatMiniProgram::Client.new(appid, secret, { get_access_token_api_prefix: options[:get_access_token_api_prefix] })
  end
end

ActiveSupport.on_load(:active_record) do
  include BsWechatMiniProgram::Mixin
end
