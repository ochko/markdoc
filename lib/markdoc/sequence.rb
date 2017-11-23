module Markdoc
  module Sequence
    DEFAULTS = {
      diagram: {
        offsetx: 10,
        offsety: 10,
        width:   900,
        height:  600
      },
      role: {
        font: "'Roboto Condensed', sans-serif",
        border: '#3c4260',
        fill:   '#dcd7d7',
        radius:  2,
        spacing: 100,
        width:   100,
        height:  55,
        line:    3,
      },
      message: {
        color: '#3c4260',
        font: "'Roboto Condensed', sans-serif",
        size: 11,
        spacing: 40,
        offset: 100, # from top
        line:    3,
        dash: '4,2'
      }
    }

    def self.draw(code)
      diagram = Diagram.new(code)
      diagram.parse
      diagram.print
    end

    class Role
      include Comparable

      attr_accessor :id, :label, :messages, :column,
                    :offsetx, :offsety, :border, :fill, :radius, :spacing, :width, :height, :line, :font,
                    :prev, :succ

      def initialize(args)
        self.messages = []
        self.id = args[:id].strip
        self.label = args[:label].strip

        # ui settings
        self.column = args[:column]
        self.offsetx = args[:diagram][:offsetx]
        self.offsety = args[:diagram][:offsety]
        self.border = args[:ui][:border]
        self.fill = args[:ui][:fill]
        self.radius = args[:ui][:radius]
        self.spacing = args[:ui][:spacing]
        self.width = args[:ui][:width]
        self.height = args[:ui][:height]
        self.line = args[:ui][:line]
        self.font = args[:ui][:font]
      end

      def <=> o
        column <=> o.column
      end

      def type
        case label
        when /actor/i
          :actor
        when /database/i
          :database
        when /site|web/i
          :website
        when /application|system/i
          :system
        else
          :component
        end
      end

      def center
        x + width/2
      end

      def x
        offsetx + column*(width + spacing)
      end

      def y
        offsety
      end

      def print
        elements = []
        case type
        when :actor
          elements << %Q[<g transform="translate(#{x+10},0)"><path d="M74,64 a30,30 0 0,0 -27,-27 a16,18 0 1,0 -16,0 a30,30 0, 0,0 -27,27 z" stroke-width="#{line}" fill="#{fill}" stroke="#{border}"/></g>]
          elements << %Q[<text x="#{x+46-2*id.size}" y="#{y+height-5}" font-family="#{font}" font-size="12" fill="#{border}">#{id}</text>]
        else
          elements << %Q[<rect fill="#{fill}" stroke="#{border}" rx="#{radius}" ry="#{radius}" x="#{x}" y="#{y}" width="#{width}" height="#{height}" stroke-width="#{line}"/>]
          elements << %Q[<text x="#{x+10}" y="#{y+20}" font-family="#{font}" font-size="12" fill="#{border}">#{label}</text>]
        end

        x1 = center
        y1 = offsety + height
        x2 = center
        y2 = messages.last.y + 10
        elements << %Q[<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}" stroke="#{border}" stroke-width="#{line}"/>]

        elements.join("\n")
      end
    end

    class Message
      attr_accessor :source, :dest, :op, :label, :comment, :row,
                    :offset, :color, :font, :size, :spacing, :line, :dash,
                    :options

      def initialize(args)
        self.options = []
        self.label = args[:label].strip
        self.comment = args[:comment].strip

        self.op = args[:op]
        self.row = args[:row]
        # ui
        self.offset  = args[:ui][:offset]
        self.color   = args[:ui][:color]
        self.font    = args[:ui][:font]
        self.size    = args[:ui][:size]
        self.spacing = args[:ui][:spacing]
        self.line    = args[:ui][:line]
        self.dash    = args[:ui][:dash]

        if op.index('~')
          options << %Q[stroke-dasharray="#{dash}"]
        elsif op.index('-').nil?
          raise "Message direction must be one of ->, ~>, <-, <~"
        end

        if op.index('>')
          self.source, self.dest = args[:role1], args[:role2]
        elsif op.index('<')
          self.source, self.dest = args[:role2], args[:role1]
        else
          raise "Message direction must be one of ->, ~>, <-, <~"
        end

        source.messages << self
        dest.messages << self unless source.eql?(dest)
      end

      def print
        role1, role2 = *(source < dest ? [source, dest] : [dest, source])
        elements = []

        if role1.eql?(role2)
          x1 = role1.center
          y1 = y
          x2 = x1 + 50
          y2 = y1 + spacing

          elements << %Q(<polyline points="#{x1},#{y1} #{x2},#{y1} #{x2},#{y2} #{x1+5},#{y2}" fill="none" stroke-width="2" stroke-linejoin="round" stroke="#{color}" #{options.join ' '}/>)
          elements << %Q(<polygon points="#{x1+10},#{y2-5} #{x1},#{y2} #{x1+10},#{y2+5}" fill="#{color}"/>)
          elements << %Q(<text x="#{x1+10}" y="#{y1-5}" font-family="#{font}" font-size="#{size}" fill="#{color}">#{label}</text>)
        else
          x1 = role1.center
          x2 = role2.center

          if role1 == source
            x2 -= 10
            elements << %Q(<polygon points="#{x2},#{y-5} #{x2+10},#{y} #{x2},#{y+5}" fill="#{color}"/>)
          else
            x1 += 10
            elements << %Q(<polygon points="#{x1},#{y-5} #{x1-10},#{y} #{x1},#{y+5}" fill="#{color}"/>)
          end

          elements << %Q(<line x1="#{x1}" y1="#{y}" x2="#{x2}" y2="#{y}" stroke="#{color}" stroke-width="2" #{options.join ' '}/>)
          elements << %Q(<text x="#{x1+40}" y="#{y-5}" font-family="#{font}" font-size="#{size}" fill="#{color}">#{label}</text>)

          if comment.size > 0
            x = role2.prev.center + 15
            elements << %Q(<path fill="#eeeeee" d="M#{x2-30},#{y+1} L#{x2-30},#{y+10} H#{x} V#{y+2*spacing - 25} H#{x2} V#{y+10} H#{x2-20} z" />)
            elements << %Q(<text x="#{x+5}" y="#{y+23}" font-family="#{font}" font-size="#{size}" fill="#{color}">)
            split(comment).each_with_index do |line, i|
              elements << %Q(<tspan x="#{x+5}" y="#{y+23+13*i}">#{line}</tspan>)
            end
            elements << '</text>'
          end
        end

        elements.join("\n")
      end

      def y
        offset + row*spacing
      end

      private

      def split(text, max = 35)
        ary = []
        line = ''
        text.split.each do |word|
          if (line + word).length < max
            line << ' ' << word
          else
            ary << line
            line = word
          end
        end
        ary << line if line.length > 0
        ary
      end

    end

    class Diagram
      attr_accessor :input, :output, :attributes, :roles, :messages, :rows

      def initialize(input, options = {})
        self.input = input
        self.output = []
        self.roles = []
        self.messages = []
        self.rows = 0
        self.attributes = DEFAULTS.dup

        options.each do |key, value|
          attributes.merge!(key => value)
        end
      end

      def find(id)
        roles.detect{|role| role.id == id.strip} or raise("Non-declared role: #{id}")
      end

      def parse
        input.split("\n").each do |line|
          next if line.strip.empty?

          if matches = line.match(/^(?<id>[a-zA-Z0-9_ \t]+) *= *(?<label>[a-zA-Z0-9_ \t]+)/)
            # User = Actor
            roles << Role.new(
              id: matches[:id],
              label: matches[:label],
              column: roles.size,
              diagram: attributes[:diagram],
              ui: attributes[:role]
            )
          elsif matches = line.match(/^(?<role1>[a-zA-Z0-9_ \t]+) *(?<op>[<\-~>]{2}) *(?<role2>[a-zA-Z0-9_ \t]+):(?<label>[^#]+)#?(?<comment>.*)/)
            # User -> Web : Login
            messages << Message.new(
              role1: find(matches[:role1]),
              role2: find(matches[:role2]),
              row: rows,
              op: matches[:op],
              label: matches[:label],
              comment: matches[:comment],
              diagram: attributes[:diagram],
              ui: attributes[:message]
            )
            self.rows += 1
            # comment takes 1 more row
            self.rows += 1 if matches[:comment].length > 0
          elsif matches = line.match(/^(?<role>[a-zA-Z0-9_ \t]+) *:(?<label>[^#]+)#?(?<comment>.*)/)
            # Web : Save the form
            messages << Message.new(
              role1: find(matches[:role]),
              role2: find(matches[:role]),
              row: rows,
              op: '->',
              label: matches[:label],
              comment: matches[:comment],
              diagram: attributes[:diagram],
              ui: attributes[:message]
            )
            # self message takes 2 rows
            self.rows += 2
          end
        end

        prev = nil
        roles.each do |succ|
          succ.prev = prev
          prev.succ = succ if prev
          prev = succ
        end
      end

      def print
        template % {
          width: width,
          height: height,
          content: (roles + messages).map(&:print).join("\n")
        }
      end

      def height
        attributes[:message][:offset] +
          attributes[:message][:spacing] * rows +
          attributes[:diagram][:offsety] * 2
      end

      def width
        (attributes[:role][:spacing] + attributes[:role][:width]) * roles.size +
          attributes[:diagram][:offsetx]
      end

      private

      def template
        '<svg xmlns="http://www.w3.org/2000/svg" '+
          'xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" '+
          'width="%{width}" height="%{height}" '+
          'viewBox="0 0 %{width} %{height}">'+
          '%{content}</svg>'
      end

    end
  end
end
