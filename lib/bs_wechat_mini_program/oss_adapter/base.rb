# frozen_string_literal: true

module BsWechatMiniProgram
  module OssAdapter
    class Base
      def self.oss_config
        BsWechatMiniProgram.oss_config
      end

      def self.upload_through_path!(path)
        upload_through_file!(File.open(path))
      end

      def self.upload_through_file!(file)
        raise "子类重写该方法"
      end

      def self.signature
        raise "子类重写该方法"
      end

      def self.upload_path
        @upload_path ||= "media/uploads"
      end
    end
  end
end
