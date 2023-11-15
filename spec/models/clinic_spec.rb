# frozen_string_literal: true

# == Schema Information
#
# Table name: clinics
#
#  id         :integer          not null, primary key
#  close_time :string
#  name       :string
#  open_time  :string
#  timezone   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Clinic, type: :model do
  let(:gmt_offset) { '-3' }
  let(:clinic) do
    FactoryBot.create(:clinic, name: 'Physio Jane', open_time: '09:00',
                      close_time: '17:00', timezone: TimeUtils.tz(gmt_offset))
  end

  describe 'validations' do
    it 'does not create Clinic when missing data' do
      clinic = Clinic.build(name: nil, close_time: nil, open_time: nil, timezone: nil)
      expect(clinic.valid?).to be(false)
      expect(clinic.errors[:name]).to eq(["can't be blank"])
      expect(clinic.errors[:close_time]).to eq(["can't be blank"])
      expect(clinic.errors[:open_time]).to eq(["can't be blank"])
      expect(clinic.errors[:timezone]).to eq(["can't be blank"])
    end
  end

  describe 'when calling time methods consider timezone' do
    it "returns clinic's current time based on timezone" do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 08:00')) do
        expect(clinic.current_time.iso8601).to eq('2002-10-30T08:00:00-03:00')
        expect(clinic.opening_time.iso8601).to eq('2002-10-30T09:00:00-03:00')
        expect(clinic.closing_time.iso8601).to eq('2002-10-30T17:00:00-03:00')
      end
    end
  end

  describe 'when obtaining next available start time' do
    it 'returns start time based on current time when minute equals 0' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 12:00')) do
        expect(clinic.next_available_start_time.iso8601).to eq('2002-10-30T14:00:00-03:00')
      end
    end

    it 'returns start time based on current time when minute is greater than 0 and less than 30' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 09:10')) do
        expect(clinic.next_available_start_time.iso8601).to eq('2002-10-30T11:30:00-03:00')
      end
    end

    it 'returns start time based on current time when minute is greater than 30' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 09:34')) do
        expect(clinic.next_available_start_time.iso8601).to eq('2002-10-30T12:00:00-03:00')
      end
    end

    it 'returns start time based on current time when time is before starting time' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 03:34')) do
        expect(clinic.next_available_start_time.iso8601).to eq('2002-10-30T09:00:00-03:00')
      end
    end

    it 'returns start time based on current time when time is after closing time' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 19:34')) do
        expect(clinic.next_available_start_time.iso8601).to eq('2002-10-30T17:00:00-03:00')
      end
    end
  end
end
