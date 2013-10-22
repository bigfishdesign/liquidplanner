require_relative 'config.rb'

require 'chronic'
require 'active_support/all'

context = ARGV[0] == 'last' ? 'yesterday' : 'tomorrow'

monday = Chronic.parse('last monday, 11am', now: Chronic.parse(context))
week_package = "W/C #{monday.day.ordinalize} #{monday.strftime('%B')}"

puts week_package
puts "=" * week_package.length
puts "\n"

package_id = $workspace.packages(:all, filter: "name = '#{week_package}'").first.id

tasks = $workspace.tasks(:all, filter: "package_id = '#{package_id}'")
  .select   { |t| Chronic.parse(t.created_at) >= monday }

worst_ams = tasks
  .group_by { |t| $members[t.created_by] }
  .sort_by  { |p, t| t.length }
  .reverse

worst_ams.each do |person, created|
  puts "#{person} created #{created.length} task#{'s' unless created.length == 1}:"

  created.each do |task|
    puts "* #{task.name} (for #{$members[task.owner_id]})"
  end

  puts "\n"
end

puts "========\n\n"

most_dumped_on = tasks
  .group_by { |t| $members[t.owner_id] }
  .sort_by  { |p, t| t.length }
  .reverse

most_dumped_on.each do |person, created|
  puts "#{person} had #{created.length} task#{'s' unless created.length == 1} dumped on them:"

  created.each do |task|
    puts "* #{task.name} (by #{$members[task.created_by]})"
  end

  puts "\n"
end

