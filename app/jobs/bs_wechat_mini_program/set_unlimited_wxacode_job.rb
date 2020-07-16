# frozen_string_literal: true

module BsWechatMiniProgram
  class SetUnlimitedWxacodeJob < ApplicationJob
    def perform(resource, name, column)
      resource.send("set_#{column}_with_#{name}_unlimited_wxacode")
    end
  end
end
