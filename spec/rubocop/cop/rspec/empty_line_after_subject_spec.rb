# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyLineAfterSubject do
  it 'registers an offense for empty line after subject' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `subject`.
        let(:params) { foo }
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        let(:params) { foo }
      end
    RUBY
  end

  it 'registers an offense for empty line after subject!' do
    expect_offense(<<-RUBY)
      RSpec.describe User do
        subject! { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after `subject!`.
        let(:params) { foo }
      end
    RUBY

    expect_correction(<<-RUBY)
      RSpec.describe User do
        subject! { described_class.new }

        let(:params) { foo }
      end
    RUBY
  end

  it 'does not register an offense for empty line after subject' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        subject { described_class.new }

        let(:params) { foo }
      end
    RUBY
  end

  it 'does not register an offense for empty line after subject!' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        subject! { described_class.new }

        let(:params) { foo }
      end
    RUBY
  end

  it 'does not register an offense for multiline subject block' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        subject do
          described_class.new
        end

        let(:params) { foo }
      end
    RUBY
  end

  it 'does not register an offense for subject being the latest node' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe User do
        subject { described_user }
      end
    RUBY
  end
end
