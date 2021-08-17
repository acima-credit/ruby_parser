class Item
  attr_accessor :summary, :description, :type

  def initialize(summary:, description:, type:)
    @summary = summary
    @description = description
    @type = type
  end

  def to_s
    summary
  end
end
