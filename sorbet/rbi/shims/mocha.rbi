class Object
  include ::Mocha::ObjectMethods
end

class Class
  include ::Mocha::ClassMethods
end

class Minitest::Test
  include ::Mocha::API
  include ::Mocha::ParameterMatchers
end

module Mocha
end

module Mocha::ClassMethods
  def any_instance(); end
end

module Mocha::ObjectMethods
  def expects(expected_methods_vs_return_values); end
  def stubs(stubbed_methods_vs_return_values); end
  def unstub(*method_names); end
end

module Mocha::API
  include ::Mocha::ParameterMatchers
  def mock(*arguments, &block); end
  def sequence(name); end
  def states(name); end
  def stub(*arguments, &block); end
  def stub_everything(*arguments, &block); end
end

module Mocha::ParameterMatchers
  def Not(matcher); end
  def all_of(*matchers); end
  def any_of(*matchers); end
  def any_parameters(); end
  def anything(); end
  def equals(value); end
  def equivalent_uri(uri); end
  def has_entries(entries); end
  def has_entry(*options); end
  def has_equivalent_query_string(uri); end
  def has_key(key); end
  def has_value(value); end
  def includes(*items); end
  def instance_of(klass); end
  def is_a(klass); end
  def kind_of(klass); end
  def optionally(*matchers); end
  def regexp_matches(regexp); end
  def responds_with(message, result); end
  def yaml_equivalent(object); end
end
