require_relative '../../util/spec_helper'

describe 'Canvas groups events' do

  include Logging

  test_id = Utils.get_test_id
  event = Event.new({test_id: test_id})

  before(:all) do

    @driver = Utils.launch_browser

    @canvas = Page::CanvasGroupsPage.new @driver
    @canvas_discussions_page = Page::CanvasAnnounceDiscussPage.new @driver
    @cal_net = Page::CalNetPage.new @driver

    # Script requires a minimum of one teacher and three students in test data
    user_test_data = LRSUtils.load_lrs_test_data.select { |data| data['tests']['groups'] }
    users = user_test_data.map { |user_data| User.new(user_data) }
    students = users.select { |user| user.role == 'Student' }
    @teacher = users.find { |user| user.role == 'Teacher' }

    @canvas.log_in(@cal_net, Utils.super_admin_username, Utils.super_admin_password)
    @course = Course.new({title: "LRS Groups Test #{test_id}"})
    @canvas.create_generic_course_site(Utils.canvas_qa_sub_account, @course, users, test_id)

    # TEACHER-CREATED GROUPS

    @test_group_identifier = Utils.get_test_id
    @teacher_group = Group.new({title: "Teacher Group #{@test_group_identifier}", members: students, group_set: "Teacher Group Set #{@test_group_identifier}"})
    event.actor = @teacher
    @canvas.masquerade_as(@teacher, @course)
    @canvas.instructor_create_grp(@course, @teacher_group, event)

    students.each do |student|
      event.actor = student
      @canvas.masquerade_as(student, @course)
      @canvas.student_join_grp(@course, @teacher_group, event)
    end

    # GROUP ACTIVITIES

    @test_activity_identifier = Utils.get_test_id
    event.actor = @teacher
    @canvas.masquerade_as(@teacher, @course)

    # Announcement
    @announcement = Announcement.new("Teacher Group Announcement #{@test_activity_identifier}", 'This is a teacher-created group announcement')
    @canvas_discussions_page.create_group_announcement(@teacher_group, @announcement, event)

    # Discussion
    @discussion = Discussion.new("Teacher Group Discussion #{@test_activity_identifier}")
    @canvas_discussions_page.create_group_discussion(@teacher_group, @discussion, event)
    # Student 1 creates an entry on the topic
    event.actor = students[0]
    @canvas_discussions_page.masquerade_as students[0]
    @canvas_discussions_page.add_reply(@discussion, nil, 'Discussion entry by student 1', event)
    # Student 2 creates two entries on the topic
    event.actor = students[1]
    @canvas_discussions_page.masquerade_as students[1]
    @canvas_discussions_page.add_reply(@discussion, nil, 'Discussion entry by student 2', event)
    @canvas_discussions_page.add_reply(@discussion, nil, 'Discussion entry by student 2', event)
    # Student 1 replies to User 2's first entry
    event.actor = students[0]
    @canvas_discussions_page.masquerade_as(students[0], @course)
    @canvas_discussions_page.add_reply(@discussion, 1, 'Reply by student 1', event)
    # Student 2 replies to User 1's entry
    event.actor = students[1]
    @canvas_discussions_page.masquerade_as(students[1], @course)
    @canvas_discussions_page.add_reply(@discussion, 0, 'Reply by student 2', event)

    # Delete announcement and discussion
    @canvas_discussions_page.masquerade_as(@teacher, @course)
    @canvas_discussions_page.delete_activity(@announcement.title, @announcement.url)
    @canvas_discussions_page.delete_activity(@discussion.title, @discussion.url)

    # Student leaves group
    @canvas.masquerade_as(students[0], @course)
    @canvas.student_leave_grp(@course, @teacher_group)

    # Delete group
    @canvas.masquerade_as(@teacher, @course)
    @canvas.instructor_delete_grp_set(@course, @teacher_group)

    @canvas.wait_for_event
  end

  after(:all) do
    Utils.quit_browser @driver
    LRSUtils.get_all_test_events(event, event.csv)
  end

  it('end up in the LRS database') { LRSUtils.verify_canvas_events event }

end
