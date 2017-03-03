RSpec.describe 'CHANGELOG.md' do
  subject(:changelog) { SpecHelper::ROOT.join('CHANGELOG.md').read }

  it 'has link definitions for all implicit links' do
    implicit_link_names = changelog.scan(/\[([^\]]+)\]\[\]/).flatten.uniq
    implicit_link_names.each do |name|
      expect(changelog).to include("[#{name}]: http")
    end
  end

  describe 'entry' do
    subject(:entries) { lines.grep(/^\*/).map(&:chomp) }

    let(:lines) { changelog.each_line }

    it 'has a whitespace between the * and the body' do
      entries.each do |entry|
        expect(entry).to match(/^\* \S/)
      end
    end

    it 'has a link to the contributors at the end' do
      entries.each do |entry|
        expect(entry).to match(/\(\[@\S+\]\[\](?:, \[@\S+\]\[\])*\)$/)
      end
    end

    describe 'link to related issue on github' do
      let(:issues) do
        entries.map do |entry|
          entry.match(/\[(?<number>[#\d]+)\]\((?<url>[^\)]+)\)/)
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
          pattern = %r{^https://github\.com/.+/.+/(?:issues|pull)/#{number}$} # rubocop:disable LineLength
          expect(issue[:url]).to match(pattern)
        end
      end

      it 'has a colon and a whitespace at the end' do
        entries_including_issue_link = entries.select do |entry|
          entry.match(/^\*\s*\[/)
        end

        entries_including_issue_link.each do |entry|
          expect(entry).to include('): ')
        end
      end
    end

    describe 'body' do
      let(:bodies) do
        entries.map do |entry|
          entry
            .sub(/^\*\s*(?:\[.+?\):\s*)?/, '')
            .sub(/\s*\([^\)]+\)$/, '')
        end
      end

      it 'does not start with a lower case' do
        bodies.each do |body|
          expect(body).not_to match(/^[a-z]/)
        end
      end

      it 'ends with a punctuation' do
        bodies.each do |body|
          expect(body).to match(/[\.\!]$/)
        end
      end
    end
  end
end
