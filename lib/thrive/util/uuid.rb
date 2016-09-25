require 'uuidtools'

class Track::Util::Uuid

  # Simple UUID generator that will return 1 or many identifiers. If more than
  # a single identifier is required, pass the quantity needed.
  def self.generate qty=1
  	result = (1..qty).map {|x| UUIDTools::UUID.timestamp_create.to_s.gsub('-','').upcase }
    qty == 1 ? result.first : result
  end # def self.generate

end # class Track::Util::Crypto
