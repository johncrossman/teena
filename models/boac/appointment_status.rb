class AppointmentStatus

  attr_reader :name, :code

  def initialize(name, code)
    @name = name
    @code = code
  end

  STATUSES = [
      CANCELED = new('Cancelled', 'cancelled'),
      CHECKED_IN = new('Checked in', 'checked_in'),
      RESERVED = new('Reserved', 'reserved'),
      WAITING = new('Waiting', 'waiting')
  ]

end
