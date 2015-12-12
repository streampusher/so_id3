require 'active_job'
require "so_id3/jobs/sync_tags_job"
require "so_id3/jobs/update_tags_job"

module SoId3
  module BackgroundJobs
    extend ActiveSupport::Concern

    included do
      after_commit :update_tags_in_background, on: :update
      after_commit :sync_tags_in_background, on: :create
    end
  end
end
