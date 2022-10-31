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
    subject(:entries) { lines.grep(/^\*/).map(&:chomp) }

    let(:lines) { changelog.each_line }

    it 'has a whitespace between the * and the body' do
      expect(entries).to all(match(/^\* \S/))
    end

    it 'has a link to the contributors at the end' do
      expect(entries).to all(match(/\(\[@\S+\]\[\](?:, \[@\S+\]\[\])*\)$/))
    end

    describe 'link to related issue on github' do
      let(:issues) do
        entries.map do |entry|
          entry.match(/\[(?<number>[#\d]+)\]\((?<url>[^)]+)\)/)
        end.compact
      end

      it 'has an issue number prefixed with #' do
        issues.each do |issue|
          expect(issue[:number]).to match(/^#\d+$/)
        end
      end

      it 'has a valid URL' do
        issues.each do |issue|
          number = issue[:number].gsub(/\D/, '')
          pattern = %r{^https://github\.com/.+/.+/(?:issues|pull)/#{number}$}
          expect(issue[:url]).to match(pattern)
        end
      end

      it 'has a colon and a whitespace at the end' do
        entries_including_issue_link = entries.select do |entry|
          entry.match(/^\*\s*\[/)
        end

        expect(entries_including_issue_link).to all(include('): '))
      end
    end

    describe 'body' do
      let(:bodies) do
        entries.map do |entry|
          entry
            .sub(/^\*\s*(?:\[.+?\):\s*)?/, '')
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
    end
  end
end
