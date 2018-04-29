FactoryBot.define do

  factory :post do
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'images', 'image.jpg'), 'image/jpeg') }
    caption "test picture"
    association :user, factory: :user
  end

end