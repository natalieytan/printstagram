require 'rails_helper'

describe Post, :type => :model do
  context 'validations' do
    it { should validate_presence_of :image_data }
    it { should validate_presence_of :caption }
    it { should belong_to :user }
    it { should validate_length_of(:caption).is_at_most(500) }
  end
end