require 'treetop'

module Pseudocode
  class Register
    def self.id
      @id ||= 0
      @id += 1
      "I#{@id}"
    end
  end

  class ActionLiteral < Treetop::Runtime::SyntaxNode
    def show
      puts %Q(#{id} [shape=box label="#{id}: #{label}"])
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
    def show
      puts %Q(#{id} [shape=diamond label="#{id}: #{cond.value}"])

      unless yes.nil?
        yes.show
        puts %Q(  #{id} -> #{yes.id} [label="Yes"])
      end
      unless no.nil?
        no.show
        puts %Q(  #{id} -> #{no.id} [label="No"])
      end
    end

    def id
      cond.id
    end
    def ends
      ary = []
      if yes.elements.empty?
        ary << yes.id
      else
        ary << yes.elements.last.ends
      end
      if no.elements.empty?
        ary << no.id
      else
        ary << no.elements.last.ends
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
    def show
      prev = nil
      elements.each do |node|
        next if node.nil?
        node.show
        unless prev.nil?
          prev.ends.each do |endid|
            puts %Q(#{endid} -> #{node.id} [label="E-#{prev.id}"])
          end
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
        if node.elements.empty?
          ary << node.id
        else
          ary << node.ends
        end
      end
      ary.flatten
    end
  end

end
