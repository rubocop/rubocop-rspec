RSpec.describe 'Project requires' do
  it 'alphabetizes cop requires' do
    source   = SpecHelper::ROOT.join('lib', 'rubocop-rspec.rb').read
    requires = source.split("\n").grep(%r{rubocop/cop/rspec/[^(?:cop)]})

    expect(requires.join("\n")).to eql(requires.sort.join("\n"))
  end
end
