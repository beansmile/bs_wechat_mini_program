# frozen_string_literal: true

module BsWechatMiniProgram
  module OssAdapter
    class Aws < Base
      def self.upload_through_file!(file)
        save_path = "wechat_mini_program/#{File.basename(file.path)}"
        content_type = Rack::Mime.mime_type(File.extname(file.path))

        credentials = ::Aws::Credentials.new(oss_config[:access_key_id], oss_config[:secret_access_key])
        s3 = ::Aws::S3::Resource.new(region: oss_config[:region], credentials: credentials)
        obj = s3.bucket(oss_config[:bucket]).object(save_path)

        resp = obj.put(body: file, content_type: content_type, acl: "public-read")

        "https://#{oss_config[:bucket]}.s3-#{oss_config[:region]}.amazonaws.com/#{save_path}"
      end
    end
  end
end
