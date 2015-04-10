module Markdoc
  module Sequence
    def self.draw(code, format = :svg)
      parser = Parser.new(code)

      digest = Digest::MD5.hexdigest code

      pic = nil
      Tempfile.open([digest, '.pic']) do |file|
        file.write parser.parse
        pic = file.path
      end

      if format == :pic
        return IO.read(pic)
      end

      image = Tempfile.new([digest, ".#{format}"])
      image.close

      if system("pic2plot -T#{format} #{pic} > #{image.path}")
        IO.read image
      else
        raise "Can't generate sequence diagram"
      end
    end

    class Role
      attr_accessor :type, :id, :label, :active
      def initialize(type, id, label)
        self.type, self.id, self.label = type, id, label
        self.active = false
      end
      def activate
        return if active
        self.active = true
        "active(#{id});"
      end
      def deactivate
        return unless active
        self.active = false
        "inactive(#{id});"
      end
    end

    class Message
      attr_accessor :type, :source, :dest, :label, :comment
      def initialize(type, source, dest, label, comment)
        self.type, self.source, self.dest, self.label, self.comment = type, source, dest, label.strip, comment.strip
      end

      def roles
        [source, dest]
      end

      def deliver
        %Q[#{type}(#{source.id},#{dest.id}, "#{label}");]
      end

      def describe
        return if comment.empty?
        width = comment.length > 10 ? 1 : comment.length * 0.13
        width = 0.5 if width < 0.5
        %Q[comment(#{dest.id},C,up 0.2 right, wid #{'%.1f' % width} ht 0.3 "#{comment}");]
      end

      def height
        source == dest ? 2 : 1
      end
    end

    class Parser
      attr_accessor :source, :variables, :roles, :messages, :output

      def defaults
        {
          boxht:     '0.5', # Object box height
          boxwid:    '1.3', # Object box width
          awid:      '0.1', # Active lifeline width
          spacing:   '0.25', # Spacing between messages
          movewid:   '0.75', # Spacing between objects
          dashwid:   '0.05', # Interval for dashed lines
          maxpswid:  '20', # Maximum width of picture
          maxpsht:   '20', # Maximum height of picture
          underline: '0', # Underline the name of objects
        }
      end

      def initialize(source, options = {})
        self.source = source
        self.output = []
        self.roles = []
        self.messages = []
        self.variables = defaults.dup
        options.each do |key, value|
          variables[key] = value
        end
      end

      def find(id)
        id.strip!
        roles.detect{|role| role.id == id}
      end

      def parse
        source.split("\n").each do |line|
          next if line.strip.empty?
          if match = line.match(/^([a-zA-Z0-9_ \t]+) *= *([a-zA-Z0-9_ \t]+)/)
            if match[2] =~ /Actor/
              roles << Role.new(:actor, match[1].strip, match[1].strip)
            else
              roles << Role.new(:object, match[1].strip, match[2].strip)
            end
          elsif match = line.match(/^([a-zA-Z0-9_ \t]+) *([<\-~>]{2}) *([a-zA-Z0-9_ \t]+):([^#]+)#?(.*)/)
            role1, role2, op = find(match[1]), find(match[3]), match[2]

            if op.index('>')
              source, dest = role1, role2
            elsif op.index('<')
              source, dest = role2, role1
            else
              raise "Message direction must be one of ->, ~>, <-, <~"
            end

            if op.index('-')
              type = :message
            elsif op.index('~')
              type = :rmessage
            else
              raise "Message direction must be one of ->, ~>, <-, <~"
            end

            message = Message.new(type, source, dest, match[4], match[5])
            # deactivate prev messages roles
            if last = messages.last
              (last.roles - message.roles).each do |role|
                output << role.deactivate if role.active
              end
            end
            # activate source before send message
            output << source.activate unless source.active
            output << message.deliver
            output << message.describe
            # activate dest
            output << dest.activate unless dest.active
            messages << message
          elsif match = line.match(/^([a-zA-Z0-9_ \t]+) *:([^#]+)#?(.*)/)
            role = find(match[1])
            message = Message.new(:message, role, role, match[2], match[3])
            # deactivate prev messages roles
            if last = messages.last
              (last.roles - message.roles).each do |role|
                output << role.deactivate if role.active
              end
            end
            # activate role before send message
            output << role.activate unless role.active
            output << message.deliver
            output << message.describe
            messages << message
          end
        end

        header
        footer

        output.compact.join("\n")
      end

      def macros
        IO.read File.join(File.dirname(__FILE__), 'sequence.pic')
      end

      def header
        headers = []
        headers << '.PS'
        headers << ''
        headers << macros
        headers << ''
        headers << '# Variables'
        # calculate height

        variables[:maxpsht] = ((variables[:spacing].to_f *
                                messages.map(&:height).reduce(:+)) +
                               variables[:boxht].to_f).ceil

        variables.each do |key, value|
          headers << "#{key} = #{value};"
        end
        headers << '# Actors and Objects'
        roles.each do |object|
          headers << %Q[#{object.type}(#{object.id},"#{object.label}");]
        end
        headers << 'step();'
        headers << ''
        self.output =  headers + output
      end

      def footer
        output << ''
        output << 'step();'
        output << '# Complete the lifelines'
        roles.each do |object|
          output << "complete(#{object.id});"
        end
        output << ''
        output << '.PE'
      end
    end
  end
end
