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
  describe 'validations' do
    it 'does not create Clinic when missing data' do
      clinic = Clinic.build(name: nil, close_time: nil, open_time: nil, timezone: nil)
      expect(clinic.valid?).to be(false)
      expect(clinic.errors[:name]).to eq(["can't be blank"])
      expect(clinic.errors[:close_time]).to eq(['is invalid'])
      expect(clinic.errors[:open_time]).to eq(['is invalid'])
      expect(clinic.errors[:timezone]).to eq(["can't be blank"])
    end

    it { is_expected.to have_many(:practitioners) }
    it { is_expected.to have_many(:patients) }
    it { is_expected.to have_many(:appointments) }
    it { is_expected.to validate_presence_of(:timezone) }
    it { is_expected.to validate_presence_of(:name) }

    describe 'time format' do
      shared_examples 'time validation' do |field:|
        it 'validates that time is a valid time' do
          clinic.send("#{field}=", '55:90')
          expect(clinic.valid?).to be(false)
          expect(clinic.errors[field]).to eq(['is invalid'])
          clinic.send("#{field}=", 'abc')
          expect(clinic.valid?).to be(false)
          expect(clinic.errors[field]).to eq(['is invalid'])
          clinic.send("#{field}=", '15:58')
          expect(clinic.valid?).to be(true)
        end
      end

      let(:clinic) do
        FactoryBot.create(:clinic, name: 'Physio Jane', open_time: '09:00',
                                   close_time: '17:00', timezone: TimeUtils.tz('-3'))
      end

      it_behaves_like 'time validation', field: :open_time
      it_behaves_like 'time validation', field: :close_time
    end
  end

  describe 'when calling time methods consider timezone' do
    let(:clinic) do
      FactoryBot.create(:clinic, name: 'Physio Jane', open_time: '09:00',
                                 close_time: '17:00', timezone: TimeUtils.tz('-3'))
    end

    it "returns clinic's current time based on timezone" do
      Timecop.freeze(Time.find_zone(TimeUtils.tz('-3')).parse('2002-10-30 08:00')) do
        expect(clinic.current_time.iso8601).to eq('2002-10-30T08:00:00-03:00')
        expect(clinic.opening_time.iso8601).to eq('2002-10-30T09:00:00-03:00')
        expect(clinic.closing_time.iso8601).to eq('2002-10-30T17:00:00-03:00')
      end
    end

    it "returns clinic's open time" do
      expect(clinic.open_time).to eq('09:00')
    end

    it "returns clinic's close time" do
      expect(clinic.close_time).to eq('17:00')
    end
  end
end
