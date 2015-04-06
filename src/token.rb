module Sapphire
    class Token
        attr_accessor :type,
                      :string,
                      :pos
        def initialize(t,s,pos)
            @type = t
            @string = s
            @pos = pos
        end
    end
end