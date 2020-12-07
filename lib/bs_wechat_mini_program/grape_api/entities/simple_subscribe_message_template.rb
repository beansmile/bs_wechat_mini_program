# frozen_string_literal: true
module BsWechatMiniProgram::GrapeAPI::Entities
  class SimpleSubscribeMessageTemplate < Model
    expose :name
    expose :event
    expose :pri_tmpl_id
  end
end
