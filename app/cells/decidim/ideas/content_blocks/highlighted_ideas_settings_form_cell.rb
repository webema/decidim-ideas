# frozen_string_literal: true

module Decidim
  module Ideas
    module ContentBlocks
      class HighlightedIdeasSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def max_results_label
          I18n.t("decidim.ideas.admin.content_blocks.highlighted_ideas.max_results")
        end

        def order_label
          I18n.t("decidim.ideas.admin.content_blocks.highlighted_ideas.order.label")
        end

        def order_select
          [
            [I18n.t("decidim.ideas.admin.content_blocks.highlighted_ideas.order.default"), "default"],
            [I18n.t("decidim.ideas.admin.content_blocks.highlighted_ideas.order.most_recent"), "most_recent"]
          ]
        end
      end
    end
  end
end
