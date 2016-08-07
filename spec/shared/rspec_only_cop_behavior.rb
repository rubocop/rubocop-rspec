RSpec.shared_examples 'an rspec only cop' do
  it 'does not deem lib/feature/thing.rb to be a relevant file' do
    expect(cop.relevant_file?('lib/feature/thing.rb')).to be_falsey
  end

  it 'deems spec/feature/thing_spec.rb to be a relevant file' do
    expect(cop.relevant_file?('spec/feature/thing_spec.rb')).to be(true)
  end
end
