# frozen_string_literal: true

diff = git.diff_for_file('config/default.yml')
if diff && diff.patch =~ /^\+\s*Enabled: true$/
  warn(<<~MESSAGE)
    There is a cop that became `Enabled: true` due to this pull request.
    Please review the diff and make sure there are no issues.
  MESSAGE
end
