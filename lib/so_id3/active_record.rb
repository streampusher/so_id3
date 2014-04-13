require 'active_record'
require 'so_id3/tags'

module SoId3
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def has_tags(opts)
        SoId3::ActiveRecord::LocalInstanceMethods.send(:define_method, :so_id3_column) do
          # self.send(opts[:column].to_sym).path
          self.send(opts[:column].to_sym)
        end
        SoId3::ActiveRecord::LocalInstanceMethods.send(:define_method, :so_id3_storage) do
          (opts[:storage] || :filesystem).to_sym
        end
        SoId3::ActiveRecord::LocalInstanceMethods.send(:define_method, :s3_credentials) do
          opts[:s3_credentials]
        end
        include SoId3::ActiveRecord::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def tags
        @tags ||= SoId3::Tags.new(so_id3_column, self, so_id3_storage, s3_credentials)
      end
    end
  end
end

ActiveRecord::Base.send :include, SoId3::ActiveRecord
