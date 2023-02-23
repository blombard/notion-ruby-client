# frozen_string_literal: true
module Notion
  module Faraday
    module Response
      class RaiseError < ::Faraday::Response::Json
        def on_complete(env)
          raise Notion::Api::Errors::TooManyRequests, env.response if env.status == 429

          return if env.success?

          body = env.body
          return unless body

          error_code = body['code']
          error_message = body['message']
          error_details = body['details']

          error_class = Notion::Api::Errors::ERROR_CLASSES[error_code]
          error_class ||= Notion::Api::Errors::NotionError
          raise error_class.new(error_message, error_details, env.response)
        end

        def call(env)
          super
        rescue ::Faraday::ParsingError
          raise Notion::Api::Errors::ParsingError.new('parsing_error', env.response)
        end
      end
    end
  end
end
