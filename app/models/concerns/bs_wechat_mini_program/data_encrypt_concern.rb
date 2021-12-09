# frozen_string_literal: true

module BsWechatMiniProgram
  module DataEncryptConcern
    # concerns
    extend ActiveSupport::Concern

    def aes128_encrypt(data)
      self.class.aes128_encrypt(data)
    end

    def aes128_decrypt(data)
      self.class.aes128_decrypt(data)
    end

    class_methods do
      def aes128_encrypt(data)
        return nil if data.nil?
        cipher = OpenSSL::Cipher::AES.new(128, :ECB)
        cipher.encrypt
        cipher.key = BsWechatMiniProgram.aes_key
        Base64.strict_encode64(cipher.update(data.to_s) << cipher.final)
      end

      def aes128_decrypt(data)
        cipher = OpenSSL::Cipher::AES.new(128, :ECB)
        cipher.decrypt
        cipher.key = BsWechatMiniProgram.aes_key
        cipher.update(Base64.decode64(data)) << cipher.final
      end
    end
  end
end

