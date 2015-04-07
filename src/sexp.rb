require 'securerandom'
require './token'
module Sapphire
    class SEXP
        attr_accessor :children, :token, :uuid, :parent_id
        def initialize(tkn=nil)
            @uuid = SecureRandom.uuid
            @token = tkn
            @children = []
        end
        def to_s
            return "<SEXP id=#{@uuid} #{@token}>"
        end
        def append(el)
            el.parent_id = @uuid
            @children.push(el)
        end
    end
end