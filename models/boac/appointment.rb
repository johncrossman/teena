class Appointment < TimelineNoteAppt

  attr_accessor :advisor,
                :cancel_reason,
                :cancel_detail,
                :detail,
                :reserve_advisor,
                :status,
                :status_date,
                :type

  def initialize(data)
    data.each { |k, v| public_send("#{k}=", v) }
    @topics ||= []
  end

end
