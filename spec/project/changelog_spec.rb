# frozen_string_literal: true

RSpec.describe 'CHANGELOG.md' do
  subject(:changelog) { SpecHelper::ROOT.join('CHANGELOG.md').read }

  it 'has link definitions for all implicit links' do
    entries, contributors =
      changelog.split("<!-- Contributors (alphabetically) -->\n\n")

    implicit_link_names = entries.scan(/\[@(.+?)\]/).flatten.uniq
    expected_links = implicit_link_names.sort_by(&:downcase).map do |name|
      "[@#{name.downcase}]: https://github.com/#{name}\n"
    end.join

    expect(contributors).to eq(expected_links)
  end

  describe 'contributors list' do
    let(:contributors) do
      changelog.split("<!-- Contributors (alphabetically) -->\n\n").last
        .lines
    end

    it 'does not contain duplicates' do
      expect(contributors.uniq).to eq(contributors)
    end

    it 'is alphabetically sorted (case insensitive)' do
      expect(contributors.sort_by(&:downcase)).to eq(contributors)
    end
  end

  describe 'entry' do
    subject(:entries) { lines.grep(/^-/).map(&:chomp) }

    let(:lines) { changelog.each_line }

    it 'has some entries' do
      expect(entries).not_to be_empty
    end

    it 'has a link to the contributors at the end' do
      expect(entries).to all(match(/\(\[@\S+\](?:, \[@\S+\])*\)$/))
    end

    describe 'body' do
      let(:bodies) do
        entries.map do |entry|
          entry
            .sub(/^-\s*(?:\[.+?\):\s*)?/, '')
            .sub(/\s*\([^)]+\)$/, '')
        end
      end

      it 'does not start with a lower case' do
        bodies.each do |body|
          expect(body).not_to match(/^[a-z]/)
        end
      end

      it 'ends with a punctuation' do
        expect(bodies).to all(match(/[.!]$/))
      end

      it 'does not use consecutive whitespaces' do
        entries.each do |entry|
          expect(entry).not_to match(/\s{2,}/)
        end
      end
    end
  end
end
