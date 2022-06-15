# frozen_string_literal: true

require 'redcarpet'
require 'pygments'

module Markdoc
  class Renderer < Redcarpet::Render::HTML
    def block_code(code, language)
      case language
      when 'pseudo', 'pseudocode'
        wrap_svg Pseudocode.draw(code)
      when 'seq', 'sequence'
        wrap_svg Sequence.draw(code)
      else
        Pygments.highlight(code, lexer: language)
      end
    end

    # removes xml or doctype meta info
    def wrap_svg(source)
      stripped = source
                 .sub(/<\?xml[^>]+>/i, '')
                 .sub(/<!DOCTYPE[^>]+>/im, '')
                 .gsub(/<!--[^>]+-->/, '')

      %(<div class="svg-holder">\n#{stripped}\n</div>)
    end

    def doc_header
      <<~HEADER
        <html>
        <head>
          <title>Doc</title>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
          <style>
        #{IO.read File.expand_path('../../css/style.css', __dir__)}
        #{IO.read File.expand_path('../../css/pygments.css', __dir__)}
          </style>
        </head>
        <body>
      HEADER
    end

    def doc_footer
      "</body>\n</html>"
    end
  end
end
