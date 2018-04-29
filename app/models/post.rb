class Post < ApplicationRecord
  belongs_to :user
  include ImageUploader::Attachment.new(:image)
  validates :image_data, presence: true
  validates :caption, presence: true, length: { maximum: 500 }
  validates_associated :user
end
