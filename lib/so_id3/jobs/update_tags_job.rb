module SoId3::Jobs
  class UpdateTagsJob < ActiveJob::Base
    queue_as :default

    def perform taggable
      taggable.tags.sync_tags_from_db_to_file
      if taggable.after_tags_synced_callbacks
        taggable.after_tags_synced_callbacks.each do |method|
          taggable.send(method.to_sym)
        end
      end
    end
  end
end
