require 'active_job'
require "so_id3/jobs/sync_tags_job"
require "so_id3/jobs/update_tags_job"
require "so_id3/tags"

module SoId3
  module BackgroundJobs
    extend ActiveSupport::Concern

    included do
      after_commit :update_tags_in_background, on: :update,
        :if => :tags_changed?

      after_commit :sync_tags_in_background, on: :create

      private
      def tags_changed?
        artwork_column = "#{self.so_id3_artwork_column.name}_updated_at"
        (SoId3::Tags::VALID_TAGS+[artwork_column]).each do |tag|
          if (self.previous_changes.key?(tag.to_sym) && self.previous_changes[tag.to_sym].first != self.previous_changes[tag.to_sym].last)
            return true
          end
        end
        false
      end
    end
  end
end
