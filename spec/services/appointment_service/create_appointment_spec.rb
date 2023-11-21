# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppointmentService::CreateAppointment, type: :service do
  let(:gmt_offset) { '-10' }
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

  before do
    Appointment.create(clinic:, practitioner: practitioner1, patient: patient1,
                       start_time: TimeUtils.time_from_timezone(clinic.timezone, '2002-10-31 09:00'),
                       end_time: TimeUtils.time_from_timezone(clinic.timezone, '2002-10-31 10:30'),
                       appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION)
  end

  # rubocop:disable Metrics/BlockLength
  describe '#call' do
    it 'creates an appointment with valid parameters' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:00')) do
        start_time = '2002-10-31 11:00'
        args = {
          clinic_id: clinic.id,
          practitioner_id: practitioner1.id,
          patient_id: patient2.id,
          start_time: TimeUtils.time_from_timezone(clinic.timezone, start_time).iso8601,
          appointment_type: Appointments::AppointmentTypes::STANDARD
        }
        start_time = TimeUtils.time_from_timezone(clinic.timezone, args[:start_time])
        expect(Appointment).to receive(:create!).with({
                                                        clinic:,
                                                        practitioner_id: args[:practitioner_id],
                                                        patient_id: args[:patient_id],
                                                        start_time:,
                                                        end_time: (start_time + Appointments::AppointmentTypes::DURATION[args[:appointment_type]]),
                                                        appointment_type: args[:appointment_type]
                                                      })
        described_class.call(args)
      end
    end

    it 'does not create appointment when start_time is within 2 hours' do
      expect do
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-31 10:30')) do
          start_time = '2002-10-31 11:00'
          args = {
            clinic_id: clinic.id,
            practitioner_id: practitioner1.id,
            patient_id: patient2.id,
            start_time: TimeUtils.time_from_timezone(clinic.timezone, start_time).iso8601,
            appointment_type: Appointments::AppointmentTypes::STANDARD
          }
          expect(Appointment).not_to receive(:create!)
          described_class.call(args)
        end
      end.to raise_error(AppointmentService::Errors::TimeNotAvailable,
                         'Appointments cannot be made within 2 hours of the appointment start time.')
    end

    it 'does not create appointment when start_time is not the hour or half-hour' do
      expect do
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 10:30')) do
          start_time = '2002-10-31 11:22'
          args = {
            clinic_id: clinic.id,
            practitioner_id: practitioner1.id,
            patient_id: patient2.id,
            start_time: TimeUtils.time_from_timezone(clinic.timezone, start_time).iso8601,
            appointment_type: Appointments::AppointmentTypes::STANDARD
          }
          expect(Appointment).not_to receive(:create!)
          described_class.call(args)
        end
      end.to raise_error(AppointmentService::Errors::TimeNotAvailable, 'Appointments start on the hour or half-hour.')
    end

    it "does not create appointment when start_time is before clinic's work time" do
      expect do
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:30')) do
          start_time = '2002-10-31 08:00'
          args = {
            clinic_id: clinic.id,
            practitioner_id: practitioner1.id,
            patient_id: patient2.id,
            start_time: TimeUtils.time_from_timezone(clinic.timezone, start_time).iso8601,
            appointment_type: Appointments::AppointmentTypes::STANDARD
          }
          expect(Appointment).not_to receive(:create!)
          described_class.call(args)
        end
      end.to raise_error(AppointmentService::Errors::ClinicIsClosed, 'Clinic opens at 09:00')
    end

    it "does not create appointment when start_time is after clinic's work time" do
      expect do
        Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:30')) do
          start_time = '2002-10-31 19:00'
          args = {
            clinic_id: clinic.id,
            practitioner_id: practitioner1.id,
            patient_id: patient2.id,
            start_time: TimeUtils.time_from_timezone(clinic.timezone, start_time).iso8601,
            appointment_type: Appointments::AppointmentTypes::STANDARD
          }
          expect(Appointment).not_to receive(:create!)
          described_class.call(args)
        end
      end.to raise_error(AppointmentService::Errors::ClinicIsClosed, 'Clinic closes at 17:00')
    end

    describe 'patient overlapping time' do
      before do
        practitioner2 = FactoryBot.create(:practitioner, clinic:, first_name: 'doc', last_name: 'tor',
                                                         specialty: 'doctor')
        FactoryBot.create(:appointment, clinic:, practitioner: practitioner2, patient: patient1,
                                        start_time: TimeUtils.time_from_timezone(clinic.timezone, '2002-11-30 09:00'),
                                        end_time: TimeUtils.time_from_timezone(clinic.timezone, '2002-11-30 10:30'),
                                        appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION)
      end

      it "does not create appointment when patient's start time overlaps with another appointment" do
        # Patient1 has an appointment with Practitioner2 one from '2002-11-30 09:00' to '2002-11-30 10:30'
        # In this scenario, Patient1 can't book again in between these 2 times.
        expect do
          freeze_current_time = '2002-10-30 08:30'
          Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(freeze_current_time)) do
            patient_appointment_start_time = '2002-11-30 10:00'
            args = {
              clinic_id: clinic.id,
              practitioner_id: practitioner1.id,
              patient_id: patient1.id,
              start_time: TimeUtils.time_from_timezone(clinic.timezone, patient_appointment_start_time).iso8601,
              appointment_type: Appointments::AppointmentTypes::STANDARD
            }
            expect(Appointment).not_to receive(:create!)
            described_class.call(args)
          end
        end.to raise_error(AppointmentService::Errors::PatientAlreadyBooked, 'Patient already booked')
      end
    end

    describe 'practitioner overlapping time' do
      it "does not create appointment when practitioner's start time overlaps with another appointment" do
        # Patient 1 has an appointment with Practitioner one from '2002-10-31 09:00' to '2002-10-31 10:30'
        # In this scenario, practitioner 1 can't be booked in between these 2 times.
        expect do
          freeze_current_time = '2002-10-30 08:30'
          Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse(freeze_current_time)) do
            practitioner_appointment_start_time = '2002-10-31 10:00'
            args = {
              clinic_id: clinic.id,
              practitioner_id: practitioner1.id,
              patient_id: patient2.id,
              start_time: TimeUtils.time_from_timezone(clinic.timezone, practitioner_appointment_start_time).iso8601,
              appointment_type: Appointments::AppointmentTypes::STANDARD
            }
            expect(Appointment).not_to receive(:create!)
            described_class.call(args)
          end
        end.to raise_error(AppointmentService::Errors::PractitionerNotAvailable, 'Practitioner already booked')
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
