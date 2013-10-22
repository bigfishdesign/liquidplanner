require_relative 'config.rb'

has_contract_value = ->(project)  { project.contract_value }
number_of_projects = ->(projects) { projects.last.length }
owner_name         = ->(object)   { $members[object.owner_id] }

unvalued_projects = $workspace.projects(:all, filter: "is_done is false")
  .reject(&has_contract_value)
  .group_by(&owner_name)
  .sort_by(&number_of_projects)
  .reverse

unvalued_projects.each do |owner, projects|
  puts "Projects for #{owner}:"

  projects.each do |project|
    puts "* #{project.name}"
  end

  puts "\n\n"
end
