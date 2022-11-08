# frozen_string_literal: true

require_relative 'avoid_setup_hook'
require_relative 'have_http_status'
begin
  require_relative 'http_status'
rescue LoadError
  # Rails/HttpStatus cannot be loaded if rack/utils is unavailable.
end
