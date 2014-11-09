RSpec.shared_examples "a paranoid" do
  subject { FactoryGirl.create described_class.name.demodulize.underscore.to_sym }

  describe "Acts_as_paranoid" do
    before do
      subject.destroy
    end
    it { expect(described_class.with_deleted).to include(subject) }
  end
end