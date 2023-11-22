# frozen_string_literal: true

##
# BaseService has general validations that are required for all services
# As all services require clinic, so results can be correctly scoped,
# this class validates if clinic_id or clinic was passed.
# It also has memoized getters to return clinic and clinic_id
# It has a 'call' class method so the service can be automatically instantiated.
class BaseService
  def initialize(args)
    @arguments = args
  end

  def self.call(args)
    validate_clinic_arguments(args)

    new(args).call
  end

  def call
    raise NotImplementedError, 'This is an abstract base method. Implement in your subclass.'
  end

  private

  def self.validate_clinic_arguments(args)
    raise ::AppointmentService::Errors::ClinicMissing, 'Missing clinic' if args[:clinic_id].nil? && args[:clinic].nil?
  end

  attr_reader :arguments

  def clinic
    @clinic ||= find_clinic
  end

  def find_clinic
    return arguments.clinic if arguments.respond_to?(:clinic) && arguments.clinic.present?

    clinic = Clinic.find_by(id: arguments[:clinic_id])

    raise ::AppointmentService::Errors::ClinicNotFound, 'Clinic not found' if clinic.blank?

    clinic
  end

  def clinic_id
    @clinic_id ||= (arguments[:clinic_id] || clinic.id)
  end
end
