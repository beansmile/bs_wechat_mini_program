# frozen_string_literal: true

require "custom_grape"

require "bs_wechat_mini_program/engine"
require "bs_wechat_mini_program/api"
require "bs_wechat_mini_program/client"
require "bs_wechat_mini_program/mixin"
require "bs_wechat_mini_program/result"
require "bs_wechat_mini_program/errors"

module BsWechatMiniProgram
  mattr_accessor :aes_key
end

ActiveSupport.on_load(:active_record) do
  include BsWechatMiniProgram::Mixin
end
