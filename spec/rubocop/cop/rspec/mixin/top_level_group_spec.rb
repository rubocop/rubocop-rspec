# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::TopLevelGroup do
  describe '#top_level_group?' do
    let(:stub_class) do
      Class.new do
        include RuboCop::Cop::RSpec::TopLevelGroup

        def initialize
          @top_level_groups = []
        end

        def test_top_level_group
          top_level_group?(nil)
        end
      end
    end

    it 'warns because it is deprecated' do
      expect { stub_class.new.test_top_level_group }.to \
        output(/warning: top_level_group\? is deprecated/).to_stderr
    end
  end
end
