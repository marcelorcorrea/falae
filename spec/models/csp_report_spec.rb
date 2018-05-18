require 'rails_helper'

RSpec.describe CspReport, type: :model do
  subject { build(:csp_report) }

  it { is_expected.to be_valid }
end
