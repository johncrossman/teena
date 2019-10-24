require_relative '../../util/spec_helper'

describe 'A BOA advisor' do

  include Logging

  before(:all) do
    @test = BOACTestConfig.new
    @test.user_role_advisor

    # Get ASC test data
    @test_asc = BOACTestConfig.new
    @test_asc.user_role_asc @test
    asc_inactive_student_data = @test.searchable_data.select { |s| s[:asc_sports].any? && !s[:asc_active] }
    asc_test_student_data = (asc_inactive_student_data.sort_by { |s| s[:last_name_sortable_cohort] }).first
    @asc_test_student_sports = asc_test_student_data[:asc_sports].map { |s| s.gsub(' (AA)', '') }
    @asc_test_student = @test.students.find { |s| s.sis_id == asc_test_student_data[:sid] }

    # Get CoE test data
    @test_coe = BOACTestConfig.new
    @test_coe.user_role_coe @test
    coe_inactive_student_data = @test.searchable_data.select { |s| s[:coe_inactive] }
    sorted = coe_inactive_student_data.sort_by { |s| s[:last_name_sortable_cohort] }
    @coe_test_student = @test_coe.students.find { |s| s.sis_id == sorted.first[:sid] }

    # Get L&S test data
    @test_l_and_s = BOACTestConfig.new
    @test_l_and_s.user_role_l_and_s @test
    @l_and_s_cohorts = BOACUtils.get_everyone_filtered_cohorts BOACDepartments::L_AND_S
    @l_and_s_groups = BOACUtils.get_everyone_curated_groups BOACDepartments::L_AND_S

    @admin_cohorts = BOACUtils.get_everyone_filtered_cohorts BOACDepartments::ADMIN
    @admin_groups = BOACUtils.get_everyone_curated_groups BOACDepartments::ADMIN

    @driver = Utils.launch_browser @test.chrome_profile
    @homepage = BOACHomePage.new @driver
    @student_page = BOACStudentPage.new @driver
    @api_student_page = BOACApiStudentPage.new @driver
    @cohort_page = BOACFilteredCohortPage.new(@driver, @test_asc.advisor)
    @group_page = BOACGroupPage.new @driver
    @settings_page = BOACFlightDeckPage.new @driver
    @api_admin_page = BOACApiAdminPage.new @driver
  end

  after(:all) { Utils.quit_browser @driver }

  context 'with ASC' do

    before(:all) { @homepage.dev_auth @test_asc.advisor }

    after(:all) do
      @homepage.load_page
      @homepage.log_out
    end

    context 'visiting Everyone\'s Cohorts' do

      it 'sees only filtered cohorts created by ASC advisors' do
        expected = BOACUtils.get_everyone_filtered_cohorts(BOACDepartments::ASC).map(&:id).sort
        visible = (@cohort_page.visible_everyone_cohorts.map &:id).sort
        @cohort_page.wait_until(1, "Missing: #{expected - visible}. Unexpected: #{visible - expected}") { visible == expected }
      end

      it 'cannot hit an admin filtered cohort URL' do
        @admin_cohorts.any? ?
            @cohort_page.hit_non_auth_cohort(@admin_cohorts.first) :
            logger.warn('Skipping test for ASC access to admin cohorts because admins have no cohorts.')
      end

      it 'cannot hit a non-ASC filtered cohort URL' do
        coe_everyone_cohorts = BOACUtils.get_everyone_filtered_cohorts BOACDepartments::COE
        coe_everyone_cohorts.any? ?
            @cohort_page.hit_non_auth_cohort(coe_everyone_cohorts.first) :
            logger.warn('Skipping test for ASC access to CoE cohorts because CoE has no cohorts.')
      end
    end

    context 'visiting Everyone\'s Groups' do

      it 'sees only curated groups created by ASC advisors' do
        expected = BOACUtils.get_everyone_curated_groups(BOACDepartments::ASC).map(&:id).sort
        visible = (@group_page.visible_everyone_groups.map &:id).sort
        @group_page.wait_until(1, "Missing: #{expected - visible}. Unexpected: #{visible - expected}") { visible == expected }
      end

      it 'cannot hit an admin curated group URL' do
        @admin_groups.any? ?
            @group_page.hit_non_auth_group(@admin_groups.first) :
            logger.warn('Skipping test for ASC access to admin curated groups because admins have no groups.')
      end

      it 'cannot hit a non-ASC curated group URL' do
        coe_everyone_groups = BOACUtils.get_everyone_curated_groups BOACDepartments::COE
        coe_everyone_groups.any? ?
            @group_page.hit_non_auth_group(coe_everyone_groups.first) :
            logger.warn('Skipping test for ASC access to CoE curated groups because CoE has no groups.')
      end
    end

    context 'visiting a student page' do

      it 'sees team information' do
        @student_page.load_page @asc_test_student
        expect(@student_page.sports.sort).to eql(@asc_test_student_sports.sort)
      end

      it('sees ASC Inactive information') { expect(@student_page.inactive_asc_flag?).to be true }

      it 'sees no COE Inactive information' do
        @student_page.load_page @coe_test_student
        expect(@student_page.inactive_coe_flag?).to be false
      end
    end

    context 'visiting a student API page' do

      it 'cannot see COE profile data' do
        api_page = BOACApiStudentPage.new @driver
        api_page.get_data(@driver, @coe_test_student)
        api_page.coe_profile.each_value { |v| expect(v).to be_nil }
      end
    end

    context 'visiting a cohort page' do

      before(:all) do
        @inactive_search = CohortFilter.new
        @inactive_search.set_custom_filters({:asc_inactive => true})
        @inactive_cohort = FilteredCohort.new({:search_criteria => @inactive_search})

        @homepage.load_page
        @homepage.click_sidebar_create_filtered
        @cohort_page.click_new_filter_button
        @cohort_page.wait_until(1) { @cohort_page.new_filter_option_elements.any? &:visible? }
      end

      it('sees an Entering Term filter') { expect(@cohort_page.new_filter_option('enteringTerms').visible?).to be true }
      it('sees an Expected Graduation Term filter') { expect(@cohort_page.new_filter_option('expectedGradTerms').visible?).to be true }
      it('sees a GPA filter') { expect(@cohort_page.new_filter_option('gpaRanges').visible?).to be true }
      it('sees a Level filter') { expect(@cohort_page.new_filter_option('levels').visible?).to be true }
      it('sees a Major filter') { expect(@cohort_page.new_filter_option('majors').visible?).to be true }
      it('sees a Transfer Student filter') { expect(@cohort_page.new_filter_option('transfer').visible?).to be true }
      it('sees a Units Completed filter') { expect(@cohort_page.new_filter_option('unitRanges').visible?).to be true }

      it('sees an Ethnicity filter') { expect(@cohort_page.new_filter_option('ethnicities').visible?).to be true }
      it('sees a Gender filter') { expect(@cohort_page.new_filter_option('genders').visible?).to be true }
      it('sees an Underrepresented Minority filter') { expect(@cohort_page.new_filter_option('underrepresented')) }

      it('sees an Inactive filter') { expect(@cohort_page.new_filter_option('isInactiveAsc').visible?).to be true }
      it('sees an Intensive filter') { expect(@cohort_page.new_filter_option('inIntensiveCohort').visible?).to be true }
      it('sees a Team filter') { expect(@cohort_page.new_filter_option('groupCodes').visible?).to be true }

      it('sees a Last Name filter') { expect(@cohort_page.new_filter_option('lastNameRanges').visible?).to be true }
      it('sees a My Students filter') { expect(@cohort_page.new_filter_option('cohortOwnerAcademicPlans').visible?).to be true }

      it('sees no Advisor filter') { expect(@cohort_page.new_filter_option('coeAdvisorLdapUids').exists?).to be false }
      it('sees no Ethnicity (COE) filter') { expect(@cohort_page.new_filter_option('coeEthnicities').exists?).to be false }
      it('sees no Gender (COE) filter') { expect(@cohort_page.new_filter_option('coeGenders').exists?).to be false }
      it('sees no Inactive (COE) filter') { expect(@cohort_page.new_filter_option('isInactiveCoe').exists?).to be false }
      it('sees no PREP filter') { expect(@cohort_page.new_filter_option('coePrepStatuses').exists?).to be false }
      it('sees no Probation filter') { expect(@cohort_page.new_filter_option('coeProbation').exists?).to be false }

      context 'with results' do

        before(:all) do
          @homepage.load_page
          @homepage.click_sidebar_create_filtered
          @cohort_page.perform_search @inactive_cohort
        end

        it('sees team information') do
          visible_sports = @cohort_page.student_sports(@driver, @asc_test_student).sort
          expect(visible_sports).to eql(@asc_test_student_sports.sort)
        end
        it('sees ASC Inactive information') { expect(@cohort_page.student_inactive_asc_flag? @asc_test_student).to be true }
      end
    end

    context 'looking for admin functions' do

      before(:all) do
        @homepage.load_page
        @homepage.click_header_dropdown
      end

      it('can access the settings page') { expect(@homepage.settings_link?).to be true }
      it('cannot access the flight deck page') { expect(@homepage.flight_deck_link?).to be false }
      it('cannot access the passenger manifest page') { expect(@homepage.pax_manifest_link?).to be false }

      it 'can toggle demo mode' do
        @settings_page.load_page
        @settings_page.demo_mode_toggle_element.when_present Utils.short_wait
      end

      it('cannot post status alerts') { expect(@settings_page.status_heading?).to be false }

      it 'cannot hit the cachejob page' do
        @api_admin_page.load_cachejob
        @api_admin_page.unauth_msg_element.when_visible Utils.medium_wait
      end
    end
  end

  context 'with CoE' do

    before(:all) { @homepage.dev_auth @test_coe.advisor }

    after(:all) do
      @homepage.load_page
      @homepage.log_out
    end

    context 'visiting Everyone\'s Cohorts' do

      it 'sees only filtered cohorts created by CoE advisors' do
        expected = BOACUtils.get_everyone_filtered_cohorts(BOACDepartments::COE).map(&:id).sort
        visible = (@cohort_page.visible_everyone_cohorts.map &:id).sort
        @cohort_page.wait_until(1, "Missing: #{expected - visible}. Unexpected: #{visible - expected}") { visible == expected }
      end

      it 'cannot hit an admin filtered cohort URL' do
        @admin_cohorts.any? ?
            @cohort_page.hit_non_auth_cohort(@admin_cohorts.first) :
            logger.warn('Skipping test for ASC access to admin cohorts because admins have no cohorts.')
      end

      it 'cannot hit a non-COE filtered cohort URL' do
        asc_cohorts = BOACUtils.get_everyone_filtered_cohorts BOACDepartments::ASC
        asc_cohorts.any? ?
            @cohort_page.hit_non_auth_cohort(asc_cohorts.first) :
            logger.warn('Skipping test for COE access to ASC cohorts because ASC has no cohorts.')
      end
    end

    context 'visiting Everyone\'s Groups' do

      it 'sees only curated groups created by CoE advisors' do
        expected = BOACUtils.get_everyone_curated_groups(BOACDepartments::COE).map(&:id).sort
        visible = (@group_page.visible_everyone_groups.map &:id).sort
        @group_page.wait_until(1, "Missing: #{expected - visible}. Unexpected: #{visible - expected}") { visible == expected }
      end

      it 'cannot hit an admin curated group URL' do
        @admin_groups.any? ?
            @group_page.hit_non_auth_group(@admin_groups.first) :
            logger.warn('Skipping test for ASC access to admin curated groups because admins have no groups.')
      end

      it 'cannot hit a non-COE curated group URL' do
        asc_groups = BOACUtils.get_everyone_curated_groups BOACDepartments::ASC
        asc_groups.any? ?
            @group_page.hit_non_auth_group(asc_groups.first) :
            logger.warn('Skipping test for COE access to ASC curated groups because ASC has no groups.')
      end
    end

    context 'visiting a COE student page' do

      before(:all) { @student_page.load_page @coe_test_student }

      it('sees COE Inactive information') { expect(@student_page.inactive_coe_flag?).to be true }
    end

    context 'visiting an ASC student page' do

      before(:all) { @student_page.load_page @asc_test_student }

      it('sees team information') { expect(@student_page.sports.sort).to eql(@asc_test_student_sports.sort) }
      it('sees no ASC Inactive information') { expect(@student_page.inactive_asc_flag?).to be false }
    end

    context 'visiting a cohort page' do

      before(:all) do
        @inactive_search = CohortFilter.new
        @inactive_search.set_custom_filters({:asc_inactive => true})
        @inactive_cohort = FilteredCohort.new({:search_criteria => @inactive_search})

        @homepage.load_page
        @homepage.click_sidebar_create_filtered
        @cohort_page.click_new_filter_button
        @cohort_page.wait_until(1) { @cohort_page.new_filter_option_elements.any? &:visible? }
      end

      it('sees an Entering Term filter') { expect(@cohort_page.new_filter_option('enteringTerms').visible?).to be true }
      it('sees an Expected Graduation Term filter') { expect(@cohort_page.new_filter_option('expectedGradTerms').visible?).to be true }
      it('sees a GPA filter') { expect(@cohort_page.new_filter_option('gpaRanges').visible?).to be true }
      it('sees a Level filter') { expect(@cohort_page.new_filter_option('levels').visible?).to be true }
      it('sees a Major filter') { expect(@cohort_page.new_filter_option('majors').visible?).to be true }
      it('sees a Transfer Student filter') { expect(@cohort_page.new_filter_option('transfer').visible?).to be true }
      it('sees a Units filter') { expect(@cohort_page.new_filter_option('unitRanges').visible?).to be true }

      it('sees an Ethnicity filter') { expect(@cohort_page.new_filter_option('ethnicities').visible?).to be true }
      it('sees a Gender filter') { expect(@cohort_page.new_filter_option('genders').visible?).to be true }
      it('sees an Underrepresented Minority filter') { expect(@cohort_page.new_filter_option('underrepresented')) }

      it('sees no Inactive (ASC) filter') { expect(@cohort_page.new_filter_option('isInactiveAsc').visible?).to be false }
      it('sees no Intensive filter') { expect(@cohort_page.new_filter_option('inIntensiveCohort').visible?).to be false }
      it('sees no Team filter') { expect(@cohort_page.new_filter_option('groupCodes').visible?).to be false }

      it('sees a Last Name filter') { expect(@cohort_page.new_filter_option('lastNameRanges').visible?).to be true }
      it('sees a My Students filter') { expect(@cohort_page.new_filter_option('cohortOwnerAcademicPlans').visible?).to be true }

      it('sees an Advisor filter') { expect(@cohort_page.new_filter_option('coeAdvisorLdapUids').visible?).to be true }
      it('sees an Ethnicity (COE) filter') { expect(@cohort_page.new_filter_option('coeEthnicities').visible?).to be true }
      it('sees a Gender (COE) filter') { expect(@cohort_page.new_filter_option('coeGenders').visible?).to be true }
      it('sees an Inactive COE filter') { expect(@cohort_page.new_filter_option('isInactiveCoe').exists?).to be true }
      it('sees a PREP filter') { expect(@cohort_page.new_filter_option('coePrepStatuses').visible?).to be true }
      it('sees a Probation filter') { expect(@cohort_page.new_filter_option('coeProbation').exists?).to be true }
      it('sees an Underrepresented Minority (COE) filter') { expect(@cohort_page.new_filter_option('coeUnderrepresented').exists?).to be true }
    end

    context 'looking for admin functions' do

      before(:all) do
        @homepage.load_page
        @homepage.click_header_dropdown
      end

      it('can access the settings page') { expect(@homepage.settings_link?).to be true }
      it('cannot access the flight deck page') { expect(@homepage.flight_deck_link?).to be false }
      it('cannot access the passenger manifest page') { expect(@homepage.pax_manifest_link?).to be false }

      it 'can toggle demo mode' do
        @settings_page.load_page
        @settings_page.demo_mode_toggle_element.when_present Utils.short_wait
      end

      it('cannot post status alerts') { expect(@settings_page.status_heading?).to be false }

      it 'cannot hit the cachejob page' do
        @api_admin_page.load_cachejob
        @api_admin_page.unauth_msg_element.when_visible Utils.medium_wait
      end
    end
  end

  context 'with a department other than ASC or COE' do

    before(:all) { @homepage.dev_auth @test_l_and_s.advisor }

    after(:all) do
      @homepage.load_page
      @homepage.log_out
    end

    context 'visiting Everyone\'s Cohorts' do

      it 'sees only filtered cohorts created by advisors in its own department' do
        expected = @l_and_s_cohorts.map(&:id).sort
        visible = (@cohort_page.visible_everyone_cohorts.map &:id).sort
        @cohort_page.wait_until(1, "Missing: #{expected - visible}. Unexpected: #{visible - expected}") { visible == expected }
      end

      it 'cannot hit an admin filtered cohort URL' do
        @admin_cohorts.any? ?
            @cohort_page.hit_non_auth_cohort(@admin_cohorts.first) :
            logger.warn('Skipping test for ASC access to admin cohorts because admins have no cohorts.')
      end
    end

    context 'visiting another user\'s cohort' do

      before(:all) { @cohort_page.load_cohort @l_and_s_cohorts.find { |c| c.owner_uid != @test_l_and_s.advisor.uid } }

      it('can view the filters') { @cohort_page.show_filters }
      it('cannot edit the filters') { expect(@cohort_page.cohort_edit_button_elements).to be_empty }
      it('can export the student list') { expect(@cohort_page.export_list_button?).to be true }
      it('cannot rename the cohort') { expect(@cohort_page.rename_cohort_button?).to be false }
      it('cannot delete the cohort') { expect(@cohort_page.delete_cohort_button?).to be false }
    end

    context 'visiting Everyone\'s Groups' do

      it 'sees only curated groups created by advisors in its own department' do
        expected = @l_and_s_groups.map(&:id).sort
        visible = (@group_page.visible_everyone_groups.map &:id).sort
        @group_page.wait_until(1, "Missing: #{expected - visible}. Unexpected: #{visible - expected}") { visible == expected }
      end

      it 'cannot hit an admin curated group URL' do
        @admin_groups.any? ?
            @group_page.hit_non_auth_group(@admin_groups.first) :
            logger.warn('Skipping test for ASC access to admin curated groups because admins have no groups.')
      end
    end

    context 'visiting another user\'s curated group' do

      before(:all) { @group_page.load_page @l_and_s_groups.find { |g| g.owner_uid != @test_l_and_s.advisor.uid } }

      it('can export the student list') { expect(@group_page.export_list_button?).to be true }
      it('cannot add students') { expect(@group_page.add_students_button?).to be false }
      it('cannot rename the cohort') { expect(@group_page.rename_cohort_button?).to be false }
      it('cannot delete the cohort') { expect(@group_page.delete_cohort_button?).to be false }
    end

    context 'visiting an ASC student page' do

      before(:all) { @student_page.load_page @asc_test_student }

      it('sees team information') { expect(@student_page.sports.sort).to eql(@asc_test_student_sports.sort) }
      it('sees no ASC Inactive information') { expect(@student_page.inactive_asc_flag?).to be false }
    end

    context 'visiting a COE student page' do

      before(:all) { @student_page.load_page @coe_test_student }

      it('sees no COE Inactive information') { expect(@student_page.inactive_coe_flag?).to be false }
    end

    context 'visiting a student API page' do

      it 'cannot see COE profile data on the student API page' do
        api_page = BOACApiStudentPage.new @driver
        api_page.get_data(@driver, @coe_test_student)
        api_page.coe_profile.each_value { |v| expect(v).to be_nil }
      end
    end

    context 'performing a filtered cohort search' do

      before(:all) do
        @homepage.load_page
        @homepage.click_sidebar_create_filtered
        @cohort_page.wait_for_update_and_click @cohort_page.new_filter_button_element
        @cohort_page.wait_until(1) { @cohort_page.new_filter_option_elements.any? &:visible? }
      end

      it('sees an Entering Term filter') { expect(@cohort_page.new_filter_option('enteringTerms').visible?).to be true }
      it('sees an Expected Graduation Term filter') { expect(@cohort_page.new_filter_option('expectedGradTerms').visible?).to be true }
      it('sees a GPA filter') { expect(@cohort_page.new_filter_option('gpaRanges').visible?).to be true }
      it('sees a Level filter') { expect(@cohort_page.new_filter_option('levels').visible?).to be true }
      it('sees a Major filter') { expect(@cohort_page.new_filter_option('majors').visible?).to be true }
      it('sees a Transfer Student filter') { expect(@cohort_page.new_filter_option('transfer').visible?).to be true }
      it('sees a Units Completed filter') { expect(@cohort_page.new_filter_option('unitRanges').visible?).to be true }

      it('sees an Ethnicity filter') { expect(@cohort_page.new_filter_option('ethnicities').visible?).to be true }
      it('sees a Gender filter') { expect(@cohort_page.new_filter_option('genders').visible?).to be true }
      it('sees an Underrepresented Minority filter') { expect(@cohort_page.new_filter_option('underrepresented')) }

      it('sees no Inactive (ASC) filter') { expect(@cohort_page.new_filter_option('isInactiveAsc').visible?).to be false }
      it('sees no Intensive filter') { expect(@cohort_page.new_filter_option('inIntensiveCohort').visible?).to be false }
      it('sees no Team filter') { expect(@cohort_page.new_filter_option('groupCodes').visible?).to be false }

      it('sees a Last Name filter') { expect(@cohort_page.new_filter_option('lastNameRanges').visible?).to be true }
      it('sees a My Students filter') { expect(@cohort_page.new_filter_option('cohortOwnerAcademicPlans').visible?).to be true }

      it('sees no Advisor filter') { expect(@cohort_page.new_filter_option('coeAdvisorLdapUids').exists?).to be false }
      it('sees no Ethnicity (COE) filter') { expect(@cohort_page.new_filter_option('coeEthnicities').exists?).to be false }
      it('sees no Gender (COE) filter') { expect(@cohort_page.new_filter_option('coeGenders').exists?).to be false }
      it('sees no Inactive (COE) filter') { expect(@cohort_page.new_filter_option('isInactiveCoe').exists?).to be false }
      it('sees no PREP filter') { expect(@cohort_page.new_filter_option('coePrepStatuses').exists?).to be false }
      it('sees no Probation filter') { expect(@cohort_page.new_filter_option('coeProbation').exists?).to be false }
    end

    context 'looking for admin functions' do

      before(:all) do
        @homepage.load_page
        @homepage.click_header_dropdown
      end

      it('can access the settings page') { expect(@homepage.settings_link?).to be true }
      it('cannot access the flight deck page') { expect(@homepage.flight_deck_link?).to be false }
      it('cannot access the passenger manifest page') { expect(@homepage.pax_manifest_link?).to be false }

      it 'can toggle demo mode' do
        @settings_page.load_page
        @settings_page.demo_mode_toggle_element.when_present Utils.short_wait
      end

      it('cannot post status alerts') { expect(@settings_page.status_heading?).to be false }

      it 'cannot hit the cachejob page' do
        @api_admin_page.load_cachejob
        @api_admin_page.unauth_msg_element.when_visible Utils.medium_wait
      end
    end
  end
end
