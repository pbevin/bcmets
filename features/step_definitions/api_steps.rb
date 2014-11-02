def http_request(method, path, params)
  method = method.to_s.downcase
  fail "Bad method" unless %w(get post put delete).include?(method)
  page.driver.send(method, path, params)
end

When /^I send HTTP (GET|POST|PUT|DELETE) to "([^\"]*)"(?: with #{capture_fields})?$/ do |method, path, args|
  http_request(method, path, parse_fields(args))
  pp JSON.parse(response.body) if ENV['TRACE']
end

When /^I send HTTP (GET|POST|PUT|DELETE) to "([^"]*)" with the following parameters:$/ do |method, path, table|
  params = table.raw.map { |k, v| "#{k}=#{URI.encode(v)}" }.join("&")
  http_request(method, path, params)
  pp JSON.parse(response.body) if ENV['TRACE']
end

def api_get(path, params = {})
  http_request(:get, path, params)
end

def api_post(path, params = {})
  http_request(:post, path, params)
end

def api_put(path, params = {})
  http_request(:put, path, params)
end

def api_delete(path, params = {})
  http_request(:delete, path, params)
end

def api_post_json(path, json)
  page.driver.post path, json, "CONTENT_TYPE" => "application/json"
end

def follow_redirects(&_block)
  response = yield
  if response.redirect?
    visit response.header["Location"]
  else
    fail "HTTP Response didn't include a redirect."
  end
end

def processed_table_data(raw)
  params = MultiMap.new
  for k, v in raw
    if v =~ %r{^ \[ (.*) \] $}x
      v = eval($1)
    end
    params[k] = v
  end
  params
end

class ResponseAdapter
  extend Forwardable

  def_delegators :@response, :body, :content_type
  def_delegator :@response, :status, :code
  def_delegator :@response, :successful?, :success?

  def initialize(response)
    @response = response
  end

  def status
    "#{@response.status} #{message(@response.status)}"
  end

  def message(status)
    Rack::Utils::HTTP_STATUS_CODES[status.to_i] || status.to_s
  end
end

def response
  ResponseAdapter.new(page.driver.browser.last_response)
end

When /^I send HTTP (GET|POST|PUT|DELETE) to "([^"]*)" with the following JSON:$/ do |method, path, json|
  method = method.to_s.downcase
  fail "Bad method" unless %w(get post put delete).include?(method)
  page.driver.send(method, path, json, "CONTENT_TYPE" => "application/json")
  pp JSON.parse(response.body) if ENV['TRACE']
end

Then /^show me the response$/ do
  pp response.body
end

Then /^the response should be "([^"]*)" with the(?: following)? (?:JSON|json):$/ do |status, json|
  if response.status != status
    fail "Expected #{status.inspect}, got #{response.status.inspect} with #{response.body}"
  end
  assert_json_response(json)
end

def assert_json_response(json)
  # JSON matching taken from https://gist.github.com/572468
  response_json = JSON.parse(response.body)
  expected_json = JSON.parse(replace_placeholders(json))

  compare_response_to_expected(response_json, expected_json)
end

def replace_placeholders_in_path(data)
  data = data.to_s

  # Do we need to replace any evals? e.g., [@customer.id]
  re = /\[@([^\]]*)\]/
  while data =~ re
    replacement = eval("@#{$1}")
    data = data.sub re, replacement.to_s
  end

  data
end

def replace_placeholders(data, mode = :json)
  data = data.to_s

  # Do we need to replace any evals? e.g., [@customer.id]
  re = /\[@([^\]]*)\]/
  while data =~ re
    replacement = eval("@#{$1}")
    data.sub! re, replacement.nil? ? '' : replacement.inspect
  end

  # Replace `your value` and `auto generated` with null
  re = /(`your value`|`auto generated`|`something`)/
  null = (mode == :json) ? 'null' : ''
  while data =~ re
    data.sub! re, null
  end

  re = /(`(\d+) elements?`)/
  while data =~ re
    data.sub! re, ([nil] * $1.to_i).inspect
  end

  data
end

def compare_response_to_expected(response, expected, path = [])
  case response
  when Hash
    # Check attribute presence
    response.keys.sort.should == expected.keys.sort

    # Check attribute values
    expected.each do |key, value|
      unless value.nil?
        if !compare_response_to_expected(response[key], value, path + [key])
          { key => response[key] }.should == { key => value }
        end
      end
    end
  when Array
    begin
      response.length.should == expected.length
      for response_item, expected_item in response.zip(expected)
        compare_response_to_expected(response_item, expected_item, path)
      end
    rescue
      response.should == expected
    end
  else
    if response != expected
      error = [
        "For path: #{path.join('.')}:",
        "expected: #{expected.inspect}",
        "     got: #{response.inspect}"
      ]
      fail error.join("\n")
    end
  end
end
