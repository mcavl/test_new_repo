# frozen_string_literal: true

# == Schema Information
#
# Table name: appointments
#
#  id               :integer          not null, primary key
#  appointment_type :string           not null
#  end_time         :datetime         not null
#  start_time       :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  clinic_id        :integer          not null
#  patient_id       :integer          not null
#  practitioner_id  :integer          not null
#
# Indexes
#
#  index_appointments_on_clinic_id                      (clinic_id)
#  index_appointments_on_clinic_id_and_patient_id       (clinic_id,patient_id)
#  index_appointments_on_clinic_id_and_practitioner_id  (clinic_id,practitioner_id)
#  index_appointments_on_patient_id                     (patient_id)
#  index_appointments_on_practitioner_id                (practitioner_id)
#
# Foreign Keys
#
#  clinic_id        (clinic_id => clinics.id)
#  patient_id       (patient_id => patients.id)
#  practitioner_id  (practitioner_id => practitioners.id)
#
require 'rails_helper'

RSpec.describe Appointment, type: :model do
  let(:gmt_offset) { '-8' }
  let(:clinic) do
    FactoryBot.create(:clinic, name: 'Physio Jane', open_time: '09:00',
                               close_time: '17:00', timezone: TimeUtils.tz(gmt_offset))
  end
  let(:practitioner) do
    FactoryBot.create(:practitioner, first_name: 'Kristina', last_name: 'Zuniga', specialty: 'Physiotherapy',
                                     clinic:)
  end
  let(:patient) { FactoryBot.create(:patient, first_name: 'Robin', last_name: 'Clark', clinic:) }

  describe 'create' do
    it 'creates an appointment when all parameters are valid' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:00')) do
        expect do
          appointment = Appointment.create!(clinic:, practitioner:, patient:,
                                            start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 09:00'),
                                            end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 10:30'),
                                            appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION)
          expect(appointment.id).to be_kind_of(Numeric)
        end.to change { Appointment.count }.by(1)
      end
    end
  end

  describe 'invalid patient' do
    let(:clinic2) do
      FactoryBot.create(:clinic, name: 'Physio Jane', open_time: '09:00',
                                 close_time: '17:00', timezone: TimeUtils.tz(gmt_offset))
    end

    let!(:patient) { FactoryBot.create(:patient, first_name: 'Robin', last_name: 'Clark', clinic: clinic2) }
    it 'does not create an appointment when patient does not belong to same clinic' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:00')) do
        appointment = Appointment.build(clinic:, practitioner:, patient:,
                                        start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 09:00'),
                                        end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 10:30'),
                                        appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION)
        expect(appointment.valid?).to be(false)
        expect(appointment.errors[:patient_id]).to eq(['should belong to same clinic'])
      end
    end
  end

  describe 'invalid practitioner' do
    let(:clinic2) do
      FactoryBot.create(:clinic, name: 'Physio Jane', open_time: '09:00',
                                 close_time: '17:00', timezone: TimeUtils.tz(gmt_offset))
    end

    let(:practitioner) do
      FactoryBot.create(:practitioner, first_name: 'Kristina', last_name: 'Zuniga', specialty: 'Physiotherapy',
                                       clinic: clinic2)
    end
    it 'does not create an appointment when patient does not belong to same clinic' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:00')) do
        appointment = Appointment.build(clinic:, practitioner:, patient:,
                                        start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 09:00'),
                                        end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 10:30'),
                                        appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION)
        expect(appointment.valid?).to be(false)
        expect(appointment.errors[:practitioner_id]).to eq(['should belong to same clinic'])
      end
    end
  end

  describe 'missing data' do
    it 'does not create an appointment when patient does not belong to same clinic' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:00')) do
        appointment = Appointment.build(clinic: nil, practitioner: nil, patient: nil,
                                        start_time: nil,
                                        end_time: nil,
                                        appointment_type: nil)
        expect(appointment.valid?).to be(false)
        expect(appointment.errors.size).to eq(5)

        expect(appointment.errors[:patient]).to eq(['must exist'])
        expect(appointment.errors[:practitioner]).to eq(['must exist'])
        expect(appointment.errors[:clinic]).to eq(['must exist'])
        expect(appointment.errors[:start_time]).to eq(["can't be blank"])
        expect(appointment.errors[:end_time]).to eq(["can't be blank"])
      end
    end
  end

  describe 'invalid dates' do
    it 'does not create an appointment when end_time is before start_time' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:00')) do
        appointment = Appointment.build(clinic:, practitioner:, patient:,
                                        start_time: Time.find_zone(clinic.timezone).parse('2002-10-31 09:00'),
                                        end_time: Time.find_zone(clinic.timezone).parse('2002-10-31 08:30'),
                                        appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION)
        expect(appointment.valid?).to be(false)
        expect(appointment.errors[:end_time]).to eq(["can't be before start_time"])
      end
    end

    it 'does not create an appointment when dates are in the past' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:00')) do
        appointment = Appointment.build(clinic:, practitioner:, patient:,
                                        start_time: Time.find_zone(clinic.timezone).parse('2002-09-31 09:00'),
                                        end_time: Time.find_zone(clinic.timezone).parse('2002-09-31 10:30'),
                                        appointment_type: Appointments::AppointmentTypes::INITIAL_CONSULTATION)
        expect(appointment.valid?).to be(false)
        expect(appointment.errors[:start_time]).to eq(["can't be in the past"])
        expect(appointment.errors[:end_time]).to eq(["can't be in the past"])
      end
    end
  end
end
