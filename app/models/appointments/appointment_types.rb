# frozen_string_literal: true

# This class keeps all appointment types.
# Each type is defined as a constant.
# TYPES hash is used to define an enum in booking. It could be used by any other models which would require it.
# DURATION keeps each duration per type.
# This could be turned into a model, if we want to make it different per clinic.

module Appointments
  class AppointmentTypes
    CHECK_IN = 'CHECK_IN'
    STANDARD = 'STANDARD'
    INITIAL_CONSULTATION = 'INITIAL_CONSULTATION'

    TYPES = {
      CHECK_IN => CHECK_IN,
      STANDARD => STANDARD,
      INITIAL_CONSULTATION => INITIAL_CONSULTATION
    }.freeze

    DURATION = {
      CHECK_IN => 30.minutes,
      STANDARD => 60.minutes,
      INITIAL_CONSULTATION => 90.minutes
    }.freeze
  end
end
