# frozen_string_literal: true

module BsWechatMiniProgram
  module OssAdapter
    class Tencent < Base
      def self.client
        @client ||= ::Aws::S3::Resource.new(region: oss_config[:region], credentials: ::Aws::Credentials.new(oss_config[:access_key_id], oss_config[:secret_access_key]), endpoint: endpoint)
      end

      def self.bucket
        @bucket ||= client.bucket(oss_config[:bucket])
      end

      def self.upload_through_file!(file)
        save_path = "#{upload_path}/#{File.basename(file.path)}"
        content_type = Rack::Mime.mime_type(File.extname(file.path))

        obj = bucket.object(save_path)

        resp = obj.put(body: file, content_type: content_type, acl: "public-read")

        "https://#{oss_config[:bucket]}.cos.#{oss_config[:region]}.myqcloud.com/#{save_path}"
      end

      def self.signature
        presigned_data = bucket.presigned_post(
          key: "#{upload_path}/${filename}",
          success_action_status: "201",
          acl: "public-read"
        )
        {
          url: presigned_data.url.to_s,
          signature_expiration: presigned_data.instance_variable_get(:@signature_expiration),
          form_data: presigned_data.fields.as_json
        }
      end

      def self.endpoint
        "https://cos.#{oss_config[:region]}.myqcloud.com"
      end
    end
  end
end
