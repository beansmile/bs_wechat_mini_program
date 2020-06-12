# frozen_string_literal: true

require "bs_wechat_mini_program/engine"
require "bs_wechat_mini_program/api"
require "bs_wechat_mini_program/client"

module BsWechatMiniProgram
  mattr_accessor :appid, :secret, :get_access_token_api_prefix

  def self.configuration
    yield self
  end

  def self.client
    @@client ||= BsWechatMiniProgram::Client.new(appid, secret, { get_access_token_api_prefix: get_access_token_api_prefix })
  end
end
