module BsWechatMiniProgram
  module GrapeAPI
    module DSLMethods
      def bs_wmp_apis(*args, &block)
        options = args.extract_options!
        actions = args.flatten

        entity_namespace = "BsWechatMiniProgram::GrapeAPI::Entities"
        options[:resource_class] ||= "BsWechatMiniProgram::#{base.name.split("::")[-1].singularize}".constantize
        options[:collection_entity] ||= "BsWechatMiniProgram::GrapeAPI::Entities::#{base.name.split("::")[-1].singularize}".constantize
        options[:resource_entity] ||= "BsWechatMiniProgram::GrapeAPI::Entities::#{base.name.split("::")[-1].singularize}Detail".constantize

        apis(*actions, options, &block)
      end
    end

    Grape::API::Instance.extend(DSLMethods)
  end
end

[
  :entities,
  :applications,
  :subscribe_message_templates,
  :wxacodes,
  :analyses,
].each do |name|
  require "bs_wechat_mini_program/grape_api/#{name}"
end
