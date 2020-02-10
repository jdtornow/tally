module JsonHelper

  def clear_response!
    @response_json = nil
  end

  def response_json
    @response_json ||= JSON.parse(response.body)
  end

  def read_json_fixture(name)
    JSON.parse(File.read(Rails.root.join("spec/support/#{ name }.json")))
  end

end
