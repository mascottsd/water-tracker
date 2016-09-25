class Track::Util::Bootgrid

  def self.format_response(array, page, total)

    rows = array.collect {|x| x.attributes}
    response = {total: total, current: page, rows: rows}
    response.to_json

  end

end # class Track::Util::Bootgrid
