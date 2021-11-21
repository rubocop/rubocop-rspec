# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::FileFixture, :config do
  it 'registers an offense when using ' \
     '`"\#{Rails.root}/spec/fixtures/files/some_file.csv"`' do
    expect_offense(<<~RUBY)
      "\#{Rails.root}/spec/fixtures/files/some_file.csv"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('some_file.csv').path
    RUBY
  end

  it 'registers an offense when using ' \
     '`"\#{::Rails.root}/spec/fixtures/path/some_file.csv"`' do
    expect_offense(<<~RUBY)
      "\#{::Rails.root}/spec/fixtures/path/some_file.csv"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('../path/some_file.csv').path
    RUBY
  end

  it 'registers an offense when using ' \
     "`Rails.root.join('spec/fixtures/files/some_file.csv')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('spec/fixtures/files/some_file.csv')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('some_file.csv')
    RUBY
  end

  it 'registers an offense when using ' \
     "`::Rails.root.join('spec/fixtures/path/some_file.csv')`" do
    expect_offense(<<~RUBY)
      ::Rails.root.join('spec/fixtures/path/some_file.csv')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('../path/some_file.csv')
    RUBY
  end

  it 'registers an offense when using ' \
     "`Rails.root.join('spec', 'fixtures/path/some_file.csv')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('spec', 'fixtures/path/some_file.csv')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('../path/some_file.csv')
    RUBY
  end

  it 'registers an offense when using ' \
     "`Rails.root.join('spec/fixtures', 'path/some_file.csv')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('spec/fixtures', 'path/some_file.csv')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('../path/some_file.csv')
    RUBY
  end

  it 'registers an offense when using ' \
     "`Rails.root.join('spec/fixtures/path', 'some_file.csv')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('spec/fixtures/path', 'some_file.csv')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('../path/some_file.csv')
    RUBY
  end

  it 'registers an offense when using ' \
     "`Rails.root.join('spec', 'fixtures', 'path/some_file.csv')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('spec', 'fixtures', 'path/some_file.csv')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('../path/some_file.csv')
    RUBY
  end

  it 'registers an offense when using ' \
     "`Rails.root.join('spec', 'fixtures/path', 'some_file.csv')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('spec', 'fixtures/path', 'some_file.csv')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('../path/some_file.csv')
    RUBY
  end

  it 'registers an offense when using ' \
     "`Rails.root.join('spec/fixtures', 'path', 'some_file.csv')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('spec/fixtures', 'path', 'some_file.csv')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('../path/some_file.csv')
    RUBY
  end

  it 'registers an offense when using ' \
     "`Rails.root.join('spec', 'fixtures', 'path', 'some_file.csv')`" do
    expect_offense(<<~RUBY)
      Rails.root.join('spec', 'fixtures', 'path', 'some_file.csv')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `file_fixture`.
    RUBY

    expect_correction(<<~RUBY)
      file_fixture('../path/some_file.csv')
    RUBY
  end

  %i[binread binwrite open read write].each do |method|
    # This is handled by `Rails/RootPathnameMethods`
    it 'does not register an offense when using ' \
     "`File.#{method}(Rails.root.join(...))`" do
      expect_no_offenses(<<~RUBY)
        File.#{method}(Rails.root.join('spec', 'fixtures', 'path', 'some_file.csv'))
      RUBY
    end
  end
end
