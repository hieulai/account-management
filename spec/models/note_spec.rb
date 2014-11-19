# == Schema Information
#
# Table name: notes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  content    :text
#  deleted_at :time
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Note, :type => :model do
  it_behaves_like "a paranoid"

  describe "Attributes" do
    it { should respond_to(:content) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :user }
  end
end
