# frozen_string_literal: true

module Decidim
  module Ideas
    module Admin
      # Controller that allows managing all the attachments for an idea
      class IdeaAttachmentsController < Decidim::Ideas::Admin::ApplicationController
        include IdeaAdmin
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          idea_attachments_path(current_idea)
        end

        def attached_to
          current_idea
        end
      end
    end
  end
end
