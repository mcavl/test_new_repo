# frozen_string_literal: true

class BaseService
  def initialize(args)
    @arguments = args
  end

  def self.call(args)
    raise ::AppointmentService::Errors::ClinicIdMissing, 'Missing clinic id' if args[:clinic_id].nil?

    new(args).call
  end

  def call
    raise NotImplementedError, 'This is an abstract base method. Implement in your subclass.'
  end

  private

  attr_reader :arguments

  def clinic
    @clinic ||= find_clinic
  end

  def find_clinic
    clinic = Clinic.find_by(id: arguments[:clinic_id])

    raise ::AppointmentService::Errors::ClinicNotFound, 'Clinic not found' if clinic.nil?

    clinic
  end
end
