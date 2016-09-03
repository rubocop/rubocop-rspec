RSpec.shared_examples 'autocorrect' do |original, corrected|
  it "autocorrects `#{original}` to `#{corrected}`" do
    autocorrected = autocorrect_source(cop, original, 'spec/foo_spec.rb')

    expect(autocorrected).to eql(corrected)
  end
end
