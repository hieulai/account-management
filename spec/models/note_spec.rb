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
#  owner_id   :integer
#

require 'rails_helper'

RSpec.describe Note, :type => :model do
  it_behaves_like "a paranoid"

  describe "Attributes" do
    it { should respond_to(:content) }
    it { should respond_to(:owner) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :user }
    it { expect(subject).to validate_presence_of :owner }
  end

  describe "Scopes" do
    let(:user) { FactoryGirl.create :user }
    describe "created_by" do
      subject { FactoryGirl.create :note, owner_id: user.id }
      it { expect(Note.created_by(user)).to include(subject) }
    end
  end
end
