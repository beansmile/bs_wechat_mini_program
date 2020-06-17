# frozen_string_literal: true

module BsWechatMiniProgram
  class SetUnlimitedWxacodeJob < ApplicationJob
    def perform(resource, column)
      resource.send("set_#{column}_with_unlimited_wxacode")
    end
  end
end
