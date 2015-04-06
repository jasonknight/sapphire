module Sapphire
	require './token'
	WHITESPACE ="\n \t\r"
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
					  :esc_handler, 
					  :match_times
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
			@match_times = 0
			@try = lambda do |mon,stream,pos|
				buffer = ""
				token_needs_interpolation = nil
				start_pos = pos
				if mon.validator.nil? then
					mon.validator = lambda do |b,s,p|
						return true
					end
				end
				catch (:done) do
					#puts "Considering: " + mon.inspect
					while c = stream[pos] do
						if mon.tigger then
							#puts "It's a tigger"
							# This is for parsing keywords, or exact matches
							# To get an exact match, the begin and ends fields must be
							# set to the same value, the alphabet is empty.
							if mon.alphabet.empty? and mon.begins.length > 1 and mon.begins == mon.ends then
								tbuf = ""
								tpos = pos
								epos = tpos + mon.begins.length
								while not WHITESPACE.include? stream[tpos] do
									if stream[tpos].nil? then
										throw :done
									end
									tbuf += stream[tpos]
									tpos += 1
								end
								if tbuf == mon.begins then
									pos = epos
									buffer = tbuf
									throw :done
								else
									throw :done
								end
							end
							if mon.alphabet.include? c or mon.begins.include? c then
								buffer += c
								pos += 1
								if mon.match_times > 0 then
									if mon.match_times == buffer.length then
										throw :done
									end
								end
							elsif mon.ends.include? c then
								buffer += c
								pos += 1
								throw :done
							else
								#puts "throwing done"
								throw :done
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
									
									if mon.begins == mon.ends and mon.begins == tbuf then
										#puts "tbuf is #{tbuf}"
										pos = epos
										buffer = tbuf
									end
									if not mon.begins == tbuf or mon.ends == tbuf then
										throw :done
									else
										pos = epos
									end
								else
									#puts "mon.begins is of length 1"
									pos += 1
								end
								
							elsif mon.ends.include?(c) then
								#puts "mon.ends.include? #{c}"
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
							elsif not mon.alphabet.include? c then

								buffer += c
								pos += 1
							else
								throw :done
							end
						end
					end
				end
				if buffer.length > 0 and mon.validator.call(buffer,stream,pos) then
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