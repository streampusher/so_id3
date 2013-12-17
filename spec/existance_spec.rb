require 'so_id3'

describe SoId3 do
  it "version must be defined" do
    SoId3::VERSION.should be_true
  end
end
