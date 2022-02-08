# frozen_string_literal: true

BsWechatMiniProgram.aes_key = Rails.application.credentials.dig(Rails.env.to_sym, :aes_key)
