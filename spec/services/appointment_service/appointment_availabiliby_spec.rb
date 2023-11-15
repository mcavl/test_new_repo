# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppointmentService::AppointmentAvailability, type: service do
  let(:gmt_offset) { '-10' }
  let!(:clinic) do
    FactoryBot.create(:clinic, name: 'Physio Jane', open_time: '09:00',
                               close_time: '17:00', timezone: TimeUtils.tz(gmt_offset))
  end
  let!(:practitioner) do
    FactoryBot.create(:practitioner, first_name: 'Kristina', last_name: 'Zuniga', specialty: 'Physiotherapy',
                                     clinic:)
  end

  let!(:patient1) { FactoryBot.create(:patient, first_name: 'Robin', last_name: 'Clark', clinic:) }
  let!(:patient2) { FactoryBot.create(:patient, first_name: 'Darcie', last_name: 'Cervantes', clinic:) }

  describe 'available appointments on a day' do
    let!(:appointments) do
      [
        Appointment.create(clinic:, practitioner:, patient: patient1,
                           start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 09:00'),
                           end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 10:30'),
                           appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION),
        Appointment.create(clinic:, practitioner:, patient: patient1,
                           start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 12:30'),
                           end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 13:00'),
                           appointment_type: Appointments::AppointmentTypes::CHECK_IN),
        Appointment.create(clinic:, practitioner:, patient: patient1,
                           start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 15:30'),
                           end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 16:30'),
                           appointment_type: Appointments::AppointmentTypes::STANDARD)
      ]
    end

    describe 'full day appointments' do
      # Expected result:
      # Considering we are booking in the future, the whole day will be considered.
      # Practitioner has an appointment from 09:00am until 10:30am, so there's no available time before 10:30am,
      # as the clinic opens at 09:00 am.
      # Practitioner has an appointment from 12:30 until 13:00, so the time from 12:30-13:00 won't be available.
      # Practitioner has an appointment from 15:30 until 16:30, so the time from 15:30-16:00 and 16:00-16:30 won't be available
      # as the clinic closes at 17:00 (5:00 pm).
      let(:expected_result) do
        [
          { start_time: '2002-10-31T10:30:00-10:00', end_time: '2002-10-31T11:00:00-10:00' },
          { start_time: '2002-10-31T11:00:00-10:00', end_time: '2002-10-31T11:30:00-10:00' },
          { start_time: '2002-10-31T11:30:00-10:00', end_time: '2002-10-31T12:00:00-10:00' },
          { start_time: '2002-10-31T12:00:00-10:00', end_time: '2002-10-31T12:30:00-10:00' },
          { start_time: '2002-10-31T13:00:00-10:00', end_time: '2002-10-31T13:30:00-10:00' },
          { start_time: '2002-10-31T13:30:00-10:00', end_time: '2002-10-31T14:00:00-10:00' },
          { start_time: '2002-10-31T14:00:00-10:00', end_time: '2002-10-31T14:30:00-10:00' },
          { start_time: '2002-10-31T14:30:00-10:00', end_time: '2002-10-31T15:00:00-10:00' },
          { start_time: '2002-10-31T15:00:00-10:00', end_time: '2002-10-31T15:30:00-10:00' },
          { start_time: '2002-10-31T16:30:00-10:00', end_time: '2002-10-31T17:00:00-10:00' }
        ]
      end

      it 'returns available appointments on a future date' do
        current_time = '2002-09-30 08:15'
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
          args = AppointmentService::AppointmentAvailability::INPUT.new(
            {
              date: '2002-10-31',
              practitioner_id: practitioner.id,
              clinic_id: clinic.id,
              appointment_type: Appointments::AppointmentTypes::CHECK_IN
            }
          )
          result = described_class.call(args)
          expect(result.map { |r| r.to_iso8601(clinic.timezone) }).to eq(expected_result)
        end
      end

      it 'returns available appointments on same day when time is before starting date' do
        current_time = '2002-10-31 04:15'
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
          args = AppointmentService::AppointmentAvailability::INPUT.new(
            {
              date: '2002-10-31',
              practitioner_id: practitioner.id,
              clinic_id: clinic.id,
              appointment_type: Appointments::AppointmentTypes::CHECK_IN
            }
          )
          result = described_class.call(args)
          expect(result.map { |r| r.to_iso8601(clinic.timezone) }).to eq(expected_result)
        end
      end
    end

    it 'returns available appointments considering the 2 hour on the same day' do
      current_time = '2002-10-31 9:51'
      # Expected result:
      # Considering it's 9:51am on Dec 31st, and appointments can only be booked on the hour (or half-hour),
      # next allowed time slot will be at 12:00pm.
      # Practitioner has an appointment from 12:30 until 13:00, so the time from 12:30-13:30 won't be available.
      # Practitioner has an appointment from 15:30 pm until 16:30, so everything after 15:30 won't be allowed,
      # as the clinic closes at 17:00 (5:00 pm).
      expected_result = [
        { start_time: '2002-10-31T12:00:00-10:00', end_time: '2002-10-31T13:00:00-10:00' },
        { start_time: '2002-10-31T13:00:00-10:00', end_time: '2002-10-31T14:00:00-10:00' },
        { start_time: '2002-10-31T13:30:00-10:00', end_time: '2002-10-31T14:30:00-10:00' },
        { start_time: '2002-10-31T14:00:00-10:00', end_time: '2002-10-31T15:00:00-10:00' },
        { start_time: '2002-10-31T14:30:00-10:00', end_time: '2002-10-31T15:30:00-10:00' }
      ]
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
        args = AppointmentService::AppointmentAvailability::INPUT.new(
          {
            date: '2002-10-31',
            practitioner_id: practitioner.id,
            clinic_id: clinic.id,
            appointment_type: Appointments::AppointmentTypes::STANDARD
          }
        )
        result = described_class.call(args)
        expect(result.map { |r| r.to_iso8601(clinic.timezone) }).to eq(expected_result)
      end
    end

    it 'returns available appointments considering the 2 hour on the same day when after closing time' do
      current_time = '2002-10-31 18:00'
      # Expected result:
      # Considering it's 19:51am on Dec 31st, and the clinic closes at 17:00,
      # it should not have any availability for the day
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
        args = AppointmentService::AppointmentAvailability::INPUT.new(
          {
            date: '2002-10-31',
            practitioner_id: practitioner.id,
            clinic_id: clinic.id,
            appointment_type: Appointments::AppointmentTypes::STANDARD
          }
        )
        expect(described_class.call(args)).to be_empty
      end
    end
  end

  describe 'raise errors' do
    it 'does not allow availability checks on the past' do
      expect do
        current_time = '2002-10-31 9:51'
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(current_time)) do
          args = AppointmentService::AppointmentAvailability::INPUT.new(
            {
              date: '2002-09-30',
              practitioner_id: practitioner.id,
              clinic_id: clinic.id,
              appointment_type: Appointments::AppointmentTypes::STANDARD
            }
          )
          expect(::PractitionerService::PractitionerAppointments).not_to receive(:call)
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
              practitioner_id: practitioner.id,
              clinic_id: 0,
              appointment_type: Appointments::AppointmentTypes::STANDARD
            }
          )
          expect(::PractitionerService::PractitionerAppointments).not_to receive(:call)
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
              practitioner_id: practitioner.id,
              appointment_type: Appointments::AppointmentTypes::STANDARD
            }
          )
          expect(::PractitionerService::PractitionerAppointments).not_to receive(:call)
          described_class.call(args)
        end
      end.to raise_error(::AppointmentService::Errors::ClinicIdMissing, 'Missing clinic id')
    end
  end
end
