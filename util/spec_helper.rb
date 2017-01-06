require 'rspec'
require 'logger'
require 'csv'
require 'json'
require 'selenium-webdriver'
require 'page-object'
require 'fileutils'

require_relative '../models/user'
require_relative '../models/course'
require_relative '../models/section'
require_relative '../models/canvas/assignment'
require_relative '../models/canvas/announcement'
require_relative '../models/canvas/discussion'
require_relative '../models/suitec/activities'
require_relative '../models/suitec/asset'
require_relative '../models/suitec/whiteboard'
require_relative '../models/suitec/suite_c_tools'

require_relative '../logging'
require_relative 'utils'
require_relative '../pages/page'
require_relative '../pages/cal_net_page'
require_relative '../pages/canvas_page'
require_relative '../pages/calcentral/calcentral_pages'
require_relative '../pages/calcentral/api_my_academics_page'
require_relative '../pages/calcentral/api_my_classes_page'
require_relative '../pages/calcentral/splash_page'
require_relative '../pages/calcentral/my_dashboard_page'
require_relative '../pages/calcentral/my_academics_class_page'
require_relative '../pages/calcentral/my_dashboard_my_classes_card'
require_relative '../pages/calcentral/my_dashboard_notifications_card'
require_relative '../pages/calcentral/my_dashboard_tasks_card'
require_relative '../pages/calcentral/my_academics_class_sites_card'
require_relative '../pages/calcentral/my_academics_course_captures_card'
require_relative '../pages/calcentral/canvas_site_creation_page'
require_relative '../pages/calcentral/canvas_create_course_site_page'
require_relative '../pages/suitec/suite_c_pages'
require_relative '../pages/suitec/asset_library_page'
require_relative '../pages/suitec/engagement_index_page'
require_relative '../pages/suitec/whiteboards_page'