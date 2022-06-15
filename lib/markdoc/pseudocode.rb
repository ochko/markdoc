# frozen_string_literal: true

require 'polyglot'
require 'treetop'

module Markdoc
  module Pseudocode
    class Register
      def self.id
        @id ||= 0
        @id += 1
        "N#{@id}"
      end
    end

    class ActionLiteral < Treetop::Runtime::SyntaxNode
      def out(file)
        file.write %(#{id} [shape=box label="#{label}"]\n)
      end

      def id
        sentence.id
      end

      def label
        sentence.value
      end

      def ends
        [id]
      end
    end

    class IfLiteral < Treetop::Runtime::SyntaxNode
      def out(file)
        file.write %(#{id} [shape=diamond label="#{cond.value}"]\n)

        unless yes.nil?
          yes.out(file)
          file.write %(  #{id} -> #{yes.id} [label="Yes"]\n)
        end
        unless no.nil?
          no.out(file)
          file.write %(  #{id} -> #{no.id} [label="No"]\n)
        end
      end

      def id
        cond.id
      end

      def ends
        ary = []
        ary << if yes.elements.empty?
                 yes.id
               else
                 yes.elements.last.ends
               end
        ary << if no.elements.empty?
                 no.id
               else
                 no.elements.last.ends
               end
        ary.flatten
      end
    end

    class SentenceLiteral < Treetop::Runtime::SyntaxNode
      def value
        text_value.strip
      end

      def id
        @id ||= Register.id
      end
    end

    class ExpressionLiteral < Treetop::Runtime::SyntaxNode
      def out(file)
        prev = nil
        elements.each do |node|
          next if node.nil?

          node.out(file)
          prev&.ends&.each do |endid|
            file.write %(#{endid} -> #{node.id}\n)
          end
          prev = node
        end
      end

      def id
        elements.first.id
      end

      def ends
        ary = []
        elements.each do |node|
          ary << if node.elements.empty?
                   node.id
                 else
                   node.ends
                 end
        end
        ary.flatten
      end
    end

    def self.draw(code, format = :svg)
      parser = PseudocodeParser.new
      tree = parser.parse(code)

      if tree.nil?
        puts parser.failure_reason
        raise "Can't generate graphviz code"
      else
        digest = Digest::MD5.hexdigest code

        graphviz = nil
        Tempfile.open([digest, '.gv']) do |file|
          file.write "digraph G {\n"
          tree.out(file)
          file.write "}\n"
          graphviz = file.path
        end

        return IO.read(graphviz) if format == :graphviz

        image = Tempfile.new([digest, ".#{format}"])
        image.close

        if system("dot -n -T#{format} -o#{image.path} #{graphviz}")
          IO.read image
        else
          raise "Can't generate flowchart"
        end
      end
    end
  end

  Treetop.load File.join(File.dirname(__FILE__), 'pseudocode')
end
