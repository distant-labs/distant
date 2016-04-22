
require 'rspec/expectations'
RSpec::Matchers.define :belong_to do |expected|
  match do |actual|
    actual.class.belongs_to_rels.include? expected.to_sym
  end
end
