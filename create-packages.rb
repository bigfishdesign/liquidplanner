# Creates a year's worth of weekly packages, each named after the Monday
# of that week.
#
# For example:
#
# W/C 2 December
# W/C 9 December
#
# These packages are placed under the main Scheduled folder.

require_relative 'config.rb'

require "chronic"

monday  = Chronic.parse("last monday")
mondays = 1.upto(52).map { |n| monday + (n * 7 * 86400) }
weeks   = mondays.map { |d| d.strftime("W/C %-d %B") }

packages      = $workspace.packages(:all, filter: 'is_done is false').select { |p| p.name =~ %r{^W/C} }
package_names = packages.map { |p| p.name }

scheduled = $workspace.packages(:all, filter: 'name = Scheduled').first.id

last_package = packages.last.id

to_create = weeks - package_names

to_create.each do |week|
  name        = week
  delay_until = Chronic.parse(week.sub("W/C ", ""))
  promise_by  = Chronic.parse("friday", now: delay_until)

  puts "Creating package for #{week}..."

  package = $workspace.create_package(name: name, parent_id: scheduled, delay_until: delay_until, promise_by: promise_by, owner_id: $members.invert["Rob"])
  package.move_after(last_package)

  last_package = package.id

  puts "Done."
end

