# frozen_string_literal: true

module AppointmentService
  ##
  # This class contains custom error type declaration.
  # Custom error types are better for error handling and logging purposes.
  # They are meant to be self explanatory.
  module Errors
    class ClinicIsClosed < StandardError; end
    class ClinicNotFound < StandardError; end
    class ClinicMissing < StandardError; end
    class DateInThePast < StandardError; end
    class PatientAlreadyBooked < StandardError; end
    class PractitionerNotAvailable < StandardError; end
    class TimeNotAvailable < StandardError; end
  end
end
