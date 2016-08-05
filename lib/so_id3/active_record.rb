require 'active_record'
require 'so_id3/tags'
require "so_id3/background_jobs"

module SoId3
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def has_tags(opts)
        self.send(:define_method, :so_id3_column) do
          self.send(opts[:column].to_sym)
        end
        if opts[:artwork_column]
          self.send(:define_method, :so_id3_artwork_column) do
            self.send(opts[:artwork_column].to_sym)
          end
        end
        self.send(:define_method, :so_id3_storage) do
          (opts[:storage] || :filesystem).to_sym
        end
        self.send(:define_method, :s3_credentials) do
          opts[:s3_credentials]
        end
        include SoId3::ActiveRecord::LocalInstanceMethods
      end

      def after_tags_synced *methods
        self.send(:define_method, :after_tags_synced_callbacks) do
          methods.to_a
        end
      end
    end

    module LocalInstanceMethods
      attr_reader :tags, :after_tags_synced_callbacks

      def update_tags_in_background
        ::SoId3::Jobs::UpdateTagsJob.perform_later self
      end

      def sync_tags_in_background
        ::SoId3::Jobs::SyncTagsJob.perform_later self
      end

      def tags
        @tags ||= SoId3::Tags.new(so_id3_column, self, so_id3_storage, s3_credentials, so_id3_artwork_column)
      end
    end
  end
end

ActiveRecord::Base.send :include, SoId3::ActiveRecord
