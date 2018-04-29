require 'rails_helper'

describe ImageUploader do
  context "with a valid image" do
    let(:post) { create(:post) }

    it "can create a post" do
      expect(post).to be_valid
    end
    it "generates image thumbnails" do
      expect(post.image.keys).to match_array [:original, :small, :medium, :large]
    end
end
end