# frozen_string_literal: true

require 'digest'
require 'tempfile'

require 'markdoc/pseudocode'
require 'markdoc/sequence'
require 'markdoc/renderer'

module Markdoc
  def self.render(doc)
    markdown = Redcarpet::Markdown.new(Renderer, fenced_code_blocks: true)
    markdown.render(doc)
  end
end
