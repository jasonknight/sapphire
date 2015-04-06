module Sapphire
	require './token'
	class Monster
		attr_accessor :name,
					  :alphabet,
					  :tigger,
					  :begins,
					  :ends,
					  :validator,
					  :stream,
					  :try,
					  :token_type,
					  :esc,
					  :esc_handler
		def initialize(name,ttype=:string,alpha=nil,tig=true,beg="",en="", &block)
			@name = name
			@alphabet = alpha
			@tigger = tig
			@begins = beg
			@ends = en
			@validator = block
			@stream = nil
			@token_type = ttype
			@esc = nil
			@try = lambda do |mon,stream,pos|
				buffer = ""
				token_needs_interpolation = nil
				start_pos = pos
				catch (:done) do

					while c = stream[pos] do
						if mon.tigger then
							if mon.alphabet.include? c or mon.begins.include? c then
								buffer += c
								pos += 1
							elsif mon.ends.include? c then
								buffer += c
								pos += 1
								return [buffer,pos]
							else
								break
							end
						else
							# This is an eeyore
							#puts "This is a eeyore, mon.esc is: #{mon.esc} and c is: #{c}"
							if mon.esc == c then
								nextc = stream[pos+1]
								case nextc
								when "n"
									#puts "new_c is now newline"
									new_c = "\n"
								when "r"
									new_c = "\r"
								when "t"
									new_c = "\t"
								when "f"
									new_c = "\f"
								when /\d+/
									num_str = nextc + stream[pos+2] + stream[pos+3]
									int_char = num_str.to_i
									if int_char <= 255 then
										new_c = int_char.chr()
										buffer += new_c
										pos += 4
										next
									end
								else
									new_c = nextc
								end
								buffer += new_c
								pos += 2
								next
							end
							if mon.begins.include? c then
								#puts "mon.begins.include? #{c}"
								# this is for c-style comments
								# or just a comment line
								if mon.begins.length > 1 then
									#puts "mon.begins.length = #{mon.begins.length}"
									tbuf = ""
									tpos = pos
									epos = tpos + mon.begins.length
									while tpos < epos do
										tbuf += stream[tpos]
										tpos += 1
									end
									#puts "tbuf is #{tbuf}"
									if not mon.begins == tbuf or mon.ends == tbuf then
										throw :done
									else
										pos = epos
									end
								else
									pos += 1
								end
								
							elsif mon.alphabet.include?(c) or mon.ends.include?(c) then
								if mon.ends.length > 1 then
									tbuf = ""
									tpos = pos
									epos = tpos + mon.ends.length
									while tpos < epos do
										tbuf += stream[tpos]
										tpos += 1
									end
									if mon.ends == tbuf then
										throw :done
									else
										pos += 1
									end
								else
									throw :done
								end
							else
								buffer += c
								pos += 1
							end
						end
					end
				end
				if buffer.length > 0 then
					token = Token.new(mon.token_type,buffer,start_pos)
					return [token,pos]
				else
					return nil
				end
			end
		end
		def consume(stream,pos)
			res = @try.call(self,stream,pos)
			if res then
				return res
			else
				return [nil,pos]
			end
		end
		def valid?
			return @validator.call()
		end
	end
end