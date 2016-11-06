require 'yard'

require 'rubocop/rspec/description_extractor'

RSpec.describe RuboCop::RSpec::DescriptionExtractor do
  let(:yardocs) do
    [
      instance_double(
        YARD::CodeObjects::MethodObject,
        docstring: "Checks foo\n\nLong description",
        to_s: 'RuboCop::Cop::RSpec::Cop',
        type: :class,
        name: 'Foo',
        tags: [instance_double(YARD::Tags::Tag, tag_name: 'abstract')]
      ),
      instance_double(
        YARD::CodeObjects::MethodObject,
        docstring: "Checks foo\n\nLong description",
        to_s: 'RuboCop::Cop::RSpec::Foo',
        type: :class,
        name: 'Foo',
        tags: []
      ),
      instance_double(
        YARD::CodeObjects::MethodObject,
        docstring: 'Hi',
        to_s: 'RuboCop::Cop::RSpec::Foo#bar',
        type: :method,
        name: 'Foo#bar',
        tags: []
      ),
      instance_double(
        YARD::CodeObjects::MethodObject,
        docstring: 'This is not a cop',
        to_s: 'RuboCop::Cop::Mixin::Sneaky',
        type: :class,
        tags: []
      )
    ]
  end

  it 'builds a hash of descriptions' do
    expect(described_class.new(yardocs).to_h)
      .to eql('RSpec/Foo' => { 'Description' => 'Checks foo' })
  end
end
