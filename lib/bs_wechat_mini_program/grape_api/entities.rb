# frozen_string_literal: true
module BsWechatMiniProgram
  module GrapeAPI
    module Entities
    end
  end
end

require "bs_wechat_mini_program/grape_api/entities/model"

[
  :application,
  :subscribe_message_template,
].each do |name|
  require "bs_wechat_mini_program/grape_api/entities/simple_#{name}"
  require "bs_wechat_mini_program/grape_api/entities/#{name}"
  require "bs_wechat_mini_program/grape_api/entities/#{name}_detail"
end
