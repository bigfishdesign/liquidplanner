require_relative 'config.rb'

require 'chronic'

cutoff = Chronic.parse('60 days ago')
puts "Finding projects with no activity since #{cutoff.strftime('%-d %B %Y')}.\n\n"

projects = $workspace.projects(:all, filter: 'is_done is false')

to_delete = {}

projects.each do |project|
  begin
    tasks = $workspace.tasks(:all, filter: "project_id = #{project.id}")

    next if project.name =~ /account management/i

    # If there are hours remaining in the project, we can discard it
    next if project.high_effort_remaining > 0

    # If the last done task was after our cutoff, we can also discard it
    last_activity = tasks.select { |t| t.is_done }.map { |t| Chronic.parse(t.done_on) }.minmax.last
    next if last_activity && last_activity > cutoff

    project.define_singleton_method("last_activity") { last_activity }
    project.define_singleton_method("tasks") { tasks }
    project.define_singleton_method("active_tasks") { tasks.reject { |t| t.is_done } }

    to_delete[$members[project.owner_id]] ||= []
    to_delete[$members[project.owner_id]] << project
  rescue ActiveResource::ServerError => e
    if e.message =~ /503/
      sleep 15
      retry
    else
      next
    end
  end
end

to_delete.each do |owner, dead_projects|
  owner ||= "unassigned"

  puts owner,
    "=" * owner.length,
    "\n"

  dead_projects.each do |project|
    puts "* #{project.name} (#{project.client_name}) "

    puts "    * was created on #{Chronic.parse(project.created_at).strftime('%-d %B %Y')}"

    if project.last_activity
      puts "    * but hasn't been updated since #{project.last_activity.strftime('%-d %B %Y')}"
    else
      puts "    * but doesn't seem to have ever had a task completed"
    end

    if project.active_tasks.length > 0
      puts "    * has tasks remaining, but no hours"
    else
      puts "    * has no tasks remaining"
    end

    puts "\n"
  end

  puts "\n\n"
end

