# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppointmentService::PractitionerAppointments do
  let(:gmt_offset) { '-8' }
  let!(:clinic) do
    FactoryBot.create(:clinic, name: 'Physio Jane', open_time: '09:00',
                               close_time: '17:00', timezone: TimeUtils.tz(gmt_offset))
  end
  let!(:practitioner1) do
    FactoryBot.create(:practitioner, first_name: 'Kristina', last_name: 'Zuniga', specialty: 'Physiotherapy',
                                     clinic:)
  end

  let!(:patient1) { FactoryBot.create(:patient, first_name: 'Robin', last_name: 'Clark', clinic:) }
  let!(:patient2) { FactoryBot.create(:patient, first_name: 'Darcie', last_name: 'Cervantes', clinic:) }

  describe 'practitioner appointments on a day' do
    let!(:appointments) do
      [
        Appointment.create(clinic:, practitioner: practitioner1, patient: patient1,
                           start_time: Time.find_zone(clinic.timezone).parse('2002-09-01 11:00'),
                           end_time: Time.find_zone(clinic.timezone).parse('2002-09-01 12:30'),
                           appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION),
        Appointment.create(clinic:, practitioner: practitioner1, patient: patient1,
                           start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 09:00'),
                           end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 10:30'),
                           appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION),
        Appointment.create(clinic:, practitioner: practitioner1, patient: patient1,
                           start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 12:30'),
                           end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 13:00'),
                           appointment_type: Appointments::AppointmentTypes::CHECK_IN),
        Appointment.create(clinic:, practitioner: practitioner1, patient: patient1,
                           start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 15:30'),
                           end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 16:30'),
                           appointment_type: Appointments::AppointmentTypes::STANDARD)
      ]
    end

    it 'returns practitioner appointments on a future date' do
      current_time = '2002-10-30 08:15'
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
        args = AppointmentService::AppointmentAvailability::INPUT.new(
          {
            date: '2002-10-31',
            practitioner_id: practitioner1.id,
            clinic_id: clinic.id
          }
        )
        result = described_class.call(args)
        expect(result.map(&:id)).to eq(appointments.map(&:id)[1..])
      end
    end

    it 'returns empty results if there are no appointments' do
      current_time = '2002-10-30 08:15'
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
        args = AppointmentService::AppointmentAvailability::INPUT.new(
          {
            date: '2002-12-31',
            practitioner_id: practitioner1.id,
            clinic_id: clinic.id
          }
        )
        result = described_class.call(args)
        expect(result.size).to eq(0)
      end
    end
  end

  describe 'errors' do
    it 'does not allow availability checks on the past' do
      expect do
        current_time = '2002-10-31 9:51'
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
          args = AppointmentService::AppointmentAvailability::INPUT.new(
            {
              date: '2002-09-30',
              practitioner_id: practitioner1.id,
              clinic_id: clinic.id,
              appointment_type: Appointments::AppointmentTypes::STANDARD
            }
          )
          expect(::Appointment).not_to receive(:practitioner_agenda_on)
          described_class.call(args)
        end
      end.to raise_error(::AppointmentService::Errors::DateInThePast, 'Date should be greater or equals today')
    end

    it 'raises an error if clinic does not exist' do
      expect do
        current_time = '2002-10-31 9:51'
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
          args = AppointmentService::AppointmentAvailability::INPUT.new(
            {
              date: '2002-11-30',
              practitioner_id: practitioner1.id,
              clinic_id: 0,
              appointment_type: Appointments::AppointmentTypes::STANDARD
            }
          )
          expect(::Appointment).not_to receive(:practitioner_agenda_on)
          described_class.call(args)
        end
      end.to raise_error(::AppointmentService::Errors::ClinicNotFound, 'Clinic not found')
    end

    it 'raises an error if clinic id is missing' do
      expect do
        current_time = '2002-10-31 9:51'
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
          args = AppointmentService::AppointmentAvailability::INPUT.new(
            {
              date: '2002-11-30',
              practitioner_id: practitioner1.id,
              appointment_type: Appointments::AppointmentTypes::STANDARD
            }
          )
          expect(::Appointment).not_to receive(:practitioner_agenda_on)
          described_class.call(args)
        end
      end.to raise_error(::AppointmentService::Errors::ClinicIdMissing, 'Missing clinic id')
    end
  end
end
