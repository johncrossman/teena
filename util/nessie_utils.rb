require_relative 'spec_helper'

class NessieUtils < Utils

  @config = Utils.config['nessie']

  def self.nessie_db_credentials
    {
      :host => @config['db_host'],
      :port => @config['db_port'],
      :name => @config['db_name'],
      :user => @config['db_user'],
      :password => @config['db_password']
    }
  end

  def self.nessie_env
    nessie_db_credentials[:name][7..-1]
  end

  # The number of hours that synced Canvas data is behind actual site usage data
  def self.canvas_data_lag_hours
    @config['canvas_data_lag_hours']
  end

  # Whether or not to test Caliper last activity data
  def self.include_caliper_tests
    @config['include_caliper_tests']
  end

  # The number of seconds that is the max acceptable diff between last activity shown in Canvas vs Caliper
  def self.caliper_time_margin
    @config['caliper_time_margin']
  end

  # DATABASE - ASSIGNMENTS

  # Returns the assignments associated with a user in a course site
  # @param user [User]
  # @param course [Course]
  # @return [Array<Assignment>]
  def self.get_assignments(user, course)
    query = "SELECT assignment_id, due_at, submitted_at, assignment_status
              FROM boac_analytics.assignment_submissions_scores
              WHERE course_id = #{course.site_id}
                AND canvas_user_id = #{user.canvas_id}
              ORDER BY assignment_id;"
    results = query_redshift_db(nessie_db_credentials, query)
    results.map do |r|
      submitted = %w(on_time late submitted graded).include? r['assignment_status']
      Assignment.new({:id => r['assignment_id'], :due_date => r['due_at'], :submission_date => r['submitted_at'], :submitted => submitted})
    end
  end

  # Returns the Caliper last activity metric for a user in a course site
  # @param user [BOACUser]
  # @param site_id [String]
  # @return [Time]
  def self.get_caliper_last_activity(user, site_id)
    query = "SELECT last_activity
              FROM lrs_caliper_analytics.last_activity_caliper
              WHERE canvas_course_id = #{site_id}
                AND canvas_user_id = #{user.canvas_id};"
    results = query_redshift_db(nessie_db_credentials, query)
    activities = results.map { |r| Time.parse(r['last_activity'] += ' UTC') }
    activities.max
  end

  # DATABASE - ALL STUDENTS

  # Converts a students result object to an array of users
  # @param athletes [PG::Result]
  # @return [Array<User>]
  def self.student_result_to_users(student_result, dept)
    # If a user has multiple sports, they will be on multiple rows and should be merged. The 'status' refers to active or inactive athletes.
    students = student_result.group_by { |h1| h1['uid'] }.map do |k,v|
      # Athletes with two sports can be active in one and inactive in the other. Drop the inactive sport altogether.
      if v.length > 1 && (%w(t f) & (v.map { |i| i['active_asc'] }) == %w(t f))
        v.delete_if { |r| r['active_asc'] == 'f' }
      end
      # ASC status only applies to athletes
      active_asc = if v[0]['active_asc']
                     (v.map { |i| i['active_asc'] }).include?('t')
                   end
      {
        :uid => k,
        :sid => v[0]['sid'],
        :dept => dept,
        :active_asc => active_asc,
        :first_name => v[0]['first_name'],
        :last_name => v[0]['last_name'],
        :group_code => v.map { |h2| h2['group_code'] }.join(' ')
      }
    end

    # Convert to Users
    students.map do |a|
      attributes = {
        :uid => a[:uid],
        :sis_id => a[:sid],
        :depts => [a[:dept]],
        :active_asc => a[:active_asc],
        :first_name => a[:first_name],
        :last_name => a[:last_name],
        :full_name => "#{a[:first_name]} #{a[:last_name]}",
        :sports => a[:group_code].split.uniq
      }
      BOACUser.new attributes
    end
  end

  # Returns all students
  # @return [Array<User>]
  def self.get_all_students
    # Get a separate set of student users for each department
    asc_students = student_result_to_users(query_all_asc_students, BOACDepartments::ASC)
    coe_students = student_result_to_users(query_all_coe_students, BOACDepartments::COE)
    physics_students = student_result_to_users(query_all_physics_students, BOACDepartments::PHYSICS)

    # Find students served by more than one department and merge their attributes into a new user
    all_students = asc_students + coe_students + physics_students
    logger.info "There are #{asc_students.length} ASC students, #{coe_students.length} CoE students, and #{physics_students.length} Physics students, for a total of #{all_students.length}"
    merged_students = []
    all_students.group_by { |s| s.uid }.map do |k,v|
      if v.length > 1
        depts = (v.map &:depts).flatten
        athlete = v.find { |i| i.sports.any? }
        if athlete
          active_asc = athlete.active_asc
          sports = athlete.sports
        end

        attributes = {
            :uid => k,
            :sis_id => v[0].sis_id,
            :depts => (depts ? depts : v[0].depts),
            :active_asc => (active_asc ? active_asc : v[0].active_asc),
            :sports => (sports ? sports : v[0].sports),
            :first_name => v[0].first_name,
            :last_name => v[0].last_name,
            :full_name => v[0].full_name
        }
        merged_students << BOACUser.new(attributes)
      end
    end

    # Replace the duplicates with the merged users
    merged_student_sids = merged_students.map &:sis_id
    all_students.delete_if { |s| merged_student_sids.include? s.sis_id }
    net = all_students + merged_students
    logger.info "There are #{merged_students.length} overlapping students, for a net total of #{net.length}"
    net
  end

  # DATABASE - ASC STUDENTS

  # Returns all ASC students
  # @return [PG::Result]
  def self.query_all_asc_students
    query = "SELECT students.sid AS sid,
                    students.active AS active_asc,
                    students.group_code AS group_code,
                    persons.ldap_uid AS uid,
                    persons.first_name AS first_name,
                    persons.last_name AS last_name
             FROM boac_advising_asc.students
             JOIN calnet_ext_#{nessie_env}.persons ON calnet_ext_#{nessie_env}.persons.sid = boac_advising_asc.students.sid
             ORDER BY students.sid;"
    Utils.query_redshift_db(nessie_db_credentials, query)
  end

  # Returns all the distinct teams associated with team members
  # @return [Array<Team>]
  def self.get_asc_teams
    # Get the squads associated with ASC students
    query = 'SELECT DISTINCT group_code
              FROM boac_advising_asc.students;'
    results = Utils.query_redshift_db(nessie_db_credentials, query)
    results = results.map { |r| r['group_code'] }
    squads = Squad::SQUADS.select { |squad| results.include? squad.code }
    squads.sort_by { |s| s.name }

    # Get the teams associated with the squads
    teams = squads.map &:parent_team
    teams.uniq!
    logger.info "Teams are #{teams.map &:name}"
    teams.sort_by { |t| t.name }
  end

  # Returns all the users associated with a team. If the full set of athlete users is already available,
  # will use that. Otherwise, obtains the full set too.
  # @param team [Team]
  # @param all_athletes [Array<User>]
  # @return [Array<User>]
  def self.get_asc_team_members(team, all_athletes)
    team_squads = Squad::SQUADS.select { |s| s.parent_team == team }
    squad_codes = team_squads.map &:code
    team_members = all_athletes.select { |u| (u.sports & squad_codes).any? }
    team_members
  end

  # DATABASE - CoE STUDENTS

  # Returns all CoE students
  # @return [PG::Result]
  def self.query_all_coe_students
    query = "SELECT students.sid AS sid,
                    persons.ldap_uid AS uid,
                    persons.first_name AS first_name,
                    persons.last_name AS last_name
             FROM boac_advising_coe.students
             JOIN calnet_ext_#{nessie_env}.persons ON calnet_ext_#{nessie_env}.persons.sid = boac_advising_coe.students.sid
             ORDER BY students.sid;"
    Utils.query_redshift_db(nessie_db_credentials, query)
  end

  # Returns all the CoE students associated with a given advisor
  # @param advisor [User]
  # @param all_coe_students [Array<User>]
  # @return [Array<User>]
  def self.get_coe_advisor_students(advisor, all_coe_students)
    query = "SELECT students.sid
              FROM boac_advising_coe.students
              WHERE students.advisor_ldap_uid = '#{advisor.uid}'
              ORDER BY students.sid;"
    result = Utils.query_redshift_db(nessie_db_credentials, query)
    result = result.map { |r| r['sid'] }
    all_coe_students.select { |s| result.include? s.sis_id }
  end

  # Returns all Physics students
  # @return [PG::Result]
  def self.query_all_physics_students
    query = "SELECT students.sid AS sid,
                    persons.ldap_uid AS uid,
                    persons.first_name AS first_name,
                    persons.last_name AS last_name
             FROM boac_advising_physics.students
             JOIN calnet_ext_#{nessie_env}.persons ON calnet_ext_#{nessie_env}.persons.sid = boac_advising_physics.students.sid
             ORDER BY students.sid;"
    Utils.query_redshift_db(nessie_db_credentials, query)
  end

  # SEARCHABLE STUDENT DATA

  # Parses a file containing searchable user data if it exists
  # @return [Array<Hash>]
  def self.parse_stored_searchable_data
    users_data_file = BOACUtils.searchable_data
    JSON.parse(File.read(users_data_file), {:symbolize_names => true}) if File.exist? users_data_file
  end

  # To support cohort search tests, returns all relevant user data for a given set of students, writing it to a file for
  # subsequent test runs.
  # @param users [Array<BOACUser>]
  # @return [Array<Hash>]
  def self.get_and_store_searchable_data(users)
    logger.warn 'Cannot find a searchable user data file created today, collecting data and writing it to a file for reuse today'

    # Delete older searchable data files before writing the new one
    Dir.glob("#{Utils.config_dir}/boac-searchable-data*").each { |f| File.delete f }

    # Get student data that is not already associated with the users. This will probably return more students than those present
    # in the combined CoE and ASC students tables.
    query = 'SELECT student.student_profiles.sid AS sid,
                    student.student_profiles.profile AS profile,
                    student.student_academic_status.gpa AS gpa,
                    student.student_academic_status.level AS level_code,
                    student.student_majors.major AS majors,
                    boac_advising_asc.students.intensive AS intensive_asc,
                    boac_advising_coe.students.advisor_ldap_uid AS advisor,
                    boac_advising_coe.students.gender AS gender,
                    boac_advising_coe.students.ethnicity AS ethnicity,
                    boac_advising_coe.students.minority AS minority,
                    boac_advising_coe.students.did_prep AS prep,
                    boac_advising_coe.students.prep_eligible AS prep_elig,
                    boac_advising_coe.students.did_tprep AS t_prep,
                    boac_advising_coe.students.tprep_eligible AS t_prep_elig,
                    boac_advising_coe.students.probation AS probation,
                    boac_advising_coe.students.status AS status_coe
             FROM student.student_profiles
             LEFT JOIN student.student_majors ON student.student_majors.sid = student.student_profiles.sid
             LEFT JOIN student.student_academic_status ON student.student_academic_status.sid = student.student_profiles.sid
             LEFT JOIN boac_advising_asc.students ON boac_advising_asc.students.sid = student.student_profiles.sid
             LEFT JOIN boac_advising_coe.students ON boac_advising_coe.students.sid = student.student_profiles.sid
             ORDER BY sid;'

    results = query_redshift_db(nessie_db_credentials, query)

    # Create a hash for each student in the results. Multiple majors mean multiple rows, so merge them.
    student_hashes = results.group_by { |h1| h1['sid'] }.map do |k,v|
      logger.debug "Getting data for SID #{k}"
      level = case v[0]['level_code']
                when '10'
                  'Freshman'
                when '20'
                  'Sophomore'
                when '30'
                  'Junior'
                when '40'
                  'Senior'
                when 'GR'
                  'Graduate'
                else
                  logger.error "Unknown level code '#{v[0]['level_code']}'"
                  nil
              end
      profile = JSON.parse(v[0]['profile'])['sisProfile']
      expected_grad = profile && profile['expectedGraduationTerm']
      cumulative_units = profile && profile['cumulativeUnits']
      {
        :sid => k,
        :gpa => v[0]['gpa'],
        :level => level,
        :units_completed => (cumulative_units ? cumulative_units : nil),
        :major => (v.map { |h| h['majors'] }),
        :expected_grad_term_id => (expected_grad && expected_grad['id']),
        :intensive_asc => (v[0]['intensive_asc'] == 't'),
        :advisor => v[0]['advisor'],
        :gender => v[0]['gender'],
        :ethnicity => v[0]['ethnicity'],
        :underrepresented_minority => (v[0]['minority'] == 't'),
        :prep => (v[0]['prep'] == 't'),
        :prep_elig => (v[0]['prep_elig'] == 't'),
        :t_prep => (v[0]['t_prep'] == 't'),
        :t_prep_elig => (v[0]['t_prep_elig'] == 't'),
        :inactive_coe => %w(D P U W X Z).include?(v[0]['status_coe']),
        :probation_coe => (v[0]['probation'] == 't')
      }
    end

    # Find the student hash associated with each CoE and ASC user and combine it with the data already known about the user.
    filtered_student_hashes = users.map do |user|
      logger.debug "Completing data for SID #{user.sis_id}"
      user_hash = student_hashes.find { |h| h[:sid] == user.sis_id }
      # Get the squad names to use as search criteria if the students are athletes
      user_squad_names = user.sports.map do |squad_code|
        squad = Squad::SQUADS.find { |s| s.code == squad_code }
        squad ? squad.name : (logger.error "Unrecognized squad code '#{squad_code}'")
      end
      addl_user_data = {
        :first_name => user.first_name,
        :first_name_sortable => user.first_name.gsub(/\W/, '').downcase,
        :last_name => user.last_name,
        :last_name_sortable => user.last_name.gsub(/\W/, '').downcase,
        :squad_names => user_squad_names,
        :active_asc => user.active_asc
      }
      user_hash.merge! addl_user_data if user_hash
      user_hash
    end

    # Write the data to a file for reuse.
    filtered_student_hashes.compact!
    File.open(BOACUtils.searchable_data, 'w') { |f| f.write filtered_student_hashes.to_json }
    filtered_student_hashes
  end

  # If a current file containing student search data exists, parse and return it. Otherwise, obtain the data, write it to a
  # file and return it
  # @param students [Array<BOACUser>]
  # @return [Array<Hash>]
  def self.searchable_student_data(students)
    (data = parse_stored_searchable_data) ? data : get_and_store_searchable_data(students)
  end

  # Returns legacy advising notes associated with a given student
  # @param student [BOACUser]
  # @return [Array<Note>]
  def self.get_legacy_notes(student)
    query = "SELECT boac_advising_notes.advising_notes.id AS id,
                    boac_advising_notes.advising_notes.note_category AS category,
                    boac_advising_notes.advising_notes.note_subcategory AS subcategory,
                    boac_advising_notes.advising_notes.note_body AS body,
                    boac_advising_notes.advising_notes.created_by AS advisor_uid,
                    boac_advising_notes.advising_notes.created_at AS created_date,
                    boac_advising_notes.advising_notes.updated_at AS updated_date,
                    boac_advising_notes.advising_note_topics.note_topic AS topic,
                    boac_advising_notes.advising_note_attachments.sis_file_name AS file_name
            FROM boac_advising_notes.advising_notes
            LEFT JOIN boac_advising_notes.advising_note_topics
              ON boac_advising_notes.advising_notes.id = boac_advising_notes.advising_note_topics.advising_note_id
            LEFT JOIN boac_advising_notes.advising_note_attachments
              ON boac_advising_notes.advising_notes.id = boac_advising_notes.advising_note_attachments.advising_note_id
            WHERE boac_advising_notes.advising_notes.sid = '#{student.sis_id}';"

    results = query_redshift_db(nessie_db_credentials, query)
    notes_data = results.group_by { |h1| h1['id'] }.map do |k,v|
      {
        :id => k,
        :category => v[0]['category'],
        :subcategory => v[0]['subcategory'],
        :body => v[0]['body'],
        :advisor_uid => v[0]['advisor_uid'],
        :created_date => Time.parse(v[0]['created_date'].to_s),
        :updated_date => Time.parse(v[0]['updated_date'].to_s),
        :topics => (v.map { |t| t['topic'] }).compact,
        :attachment_files => (v.map { |a| a['file_name'] }).compact.uniq
      }
    end

    notes_data.map { |d| Note.new d }
  end
end
