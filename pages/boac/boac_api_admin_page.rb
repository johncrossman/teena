require_relative '../../util/spec_helper'

class BOACApiAdminPage

  include PageObject
  include Logging

  h1(:unauth_msg, xpath: '//*[contains(.,"Unauthorized")]')

  def load_cachejob
    navigate_to "#{BOACUtils.api_base_url}/api/admin/cachejob"
  end

end
