# Load the rails application
require File.expand_path('../application', __FILE__)

# force utf-8 encoding
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Bhcms::Application.initialize!
