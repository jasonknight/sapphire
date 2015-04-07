module Sapphire
    # So far we aren't differentiating between a token and an ATOM. Some tokens become SEXPs
    class Token
        attr_accessor :type,
                      :string,
                      :pos,
                      :line,
                      :file, 
                      :parent_id
        def initialize(t,s,pos)
            @type = t
            @string = s
            @pos = pos
        end
        def to_s
            return "<#{self.string} type=#{self.real_type} file=#{self.file} line=#{self.line} pos=#{self.pos}>"
        end
        def real_type
            case @string
            when "("
                return :lparen
            when ")"
                return :rparen
            when "{"
                return :lbrace
            when "}"
                return :rbrace
            when "["
                return :lbracket
            when "]"
                return :rbracket
            when /^[\+\-]{0,1}[0-9]+\.[0-9]+/
                return :float
            else
                return @type
            end
        end
    end
end