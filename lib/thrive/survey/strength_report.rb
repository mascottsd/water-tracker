class StrengthReport

  attr_reader :response

  def initialize(response)

    @response = response.response_record rescue nil
  end

  def data
    # if no response, just return an empty array so we don't actually graph anything
    return [] unless response

    Track::GlobalConstants::STRATEGIES.map do |strategy|
      {
        name: strategy,
        value: value_for(strategy.downcase)
      }
    end
  end

  def value_for(strategy)
    section = response["sections"].find { |s| s["strategy"] == strategy }
    # if for some reason we can't find that strategy's section, just return 0
    return 0 if !section

    responses = section["questions"].map {|q| q["response_value"] }

    if responses.compact.any?
      calculator = LogitCalculator.new(responses)
      calculator.calculate_strategy_strength
    else
      # If the user did not answer ANY questions in this strategy, we can't score them
      # Instead, return 0
      0
    end
  end
end
