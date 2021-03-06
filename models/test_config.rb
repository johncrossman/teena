class TestConfig

  attr_accessor :id, :test_course_data, :test_user_data

  # Sets a unique ID (the epoch) for a test run
  def initialize
    @id = "QA Test #{Time.now.to_i}"
  end

  # Parses a JSON file containing test data
  # @param file [String]
  # @return [Hash]
  def parse_test_data(file)
    JSON.parse File.read(file)
  end

end
