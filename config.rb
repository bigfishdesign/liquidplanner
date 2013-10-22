require "rubygems"
require "liquidplanner"
require 'pry'

# Assumes a file called ~/.lprc exists that contains:
# { "email": "foo@example.com", "pass": "pa55w0rd", "space": 1234 }
config = JSON.parse(IO.read(File.expand_path("~/.lprc")))

$lp = LiquidPlanner::Base.new(email: config["email"], password: config["pass"])

$workspace = $lp.workspaces(config["space"])

$members = Hash[$workspace.members.map { |m| [m.id, m.user_name] }]

