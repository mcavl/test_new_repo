# frozen_string_literal: true

module AppointmentService
  module Errors
    class ClinicIsClosed < StandardError; end
    class ClinicNotFound < StandardError; end
    class ClinicIdMissing < StandardError; end
    class DateInThePast < StandardError; end
    class PatientAlreadyBooked < StandardError; end
    class PractitionerNotAvailable < StandardError; end
    class TimeNotAvailable < StandardError; end
  end
end
