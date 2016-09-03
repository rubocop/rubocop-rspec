RSpec.shared_examples 'autocorrect' do |original, corrected|
  it "autocorrects `#{original}` to `#{corrected}`" do
    corrected = autocorrect_source(cop, original, 'spec/foo_spec.rb')

    expect(corrected).to eql(corrected)
  end
end
