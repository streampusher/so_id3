require 'active_job'
require "so_id3/jobs/sync_tags_job"
require "so_id3/jobs/update_tags_job"

module SoId3
  module BackgroundJobs
    extend ActiveSupport::Concern

    included do
      after_save :update_tags_in_background
      after_create :sync_tags_in_background
    end
  end
end
