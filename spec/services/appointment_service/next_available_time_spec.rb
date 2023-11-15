# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppointmentService::NextAvailableTime do
  describe 'when obtaining next available start time' do
    let(:gmt_offset) { '-3' }
    let(:clinic) do
      FactoryBot.create(:clinic, name: 'Physio Jane', open_time: '09:00',
                                 close_time: '17:00', timezone: TimeUtils.tz(gmt_offset))
    end
    let(:input) do
      AppointmentService::NextAvailableTime::INPUT.new(clinic_id: clinic.id)
    end
    it 'returns start time based on current time when minute equals 0' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 12:00')) do
        expect(described_class.call(input).iso8601).to eq('2002-10-30T14:00:00-03:00')
      end
    end

    it 'returns start time based on current time when minute is greater than 0 and less than 30' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 09:10')) do
        expect(described_class.call(input).iso8601).to eq('2002-10-30T11:30:00-03:00')
      end
    end

    it 'returns start time based on current time when minute is greater than 30' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 09:34')) do
        expect(described_class.call(input).iso8601).to eq('2002-10-30T12:00:00-03:00')
      end
    end

    it 'returns start time based on current time when time is before starting time' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 03:34')) do
        expect(described_class.call(input).iso8601).to eq('2002-10-30T09:00:00-03:00')
      end
    end

    it 'returns start time based on current time when time is after closing time' do
      Timecop.freeze(Time.find_zone(TimeUtils.tz(gmt_offset)).parse('2002-10-30 19:34')) do
        expect(described_class.call(input).iso8601).to eq('2002-10-30T17:00:00-03:00')
      end
    end
  end
end
