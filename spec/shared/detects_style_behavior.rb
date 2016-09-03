RSpec.shared_examples 'detects style' do |source, detected_style|
  it 'generates a todo based on the detected style' do
    inspect_source(cop, source, 'foo_spec.rb')

    expect(cop.config_to_allow_offenses)
      .to eq('EnforcedStyle' => detected_style)
  end
end
