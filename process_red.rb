require "bundler"
Bundler.require

require 'google_reader_api'
require 'readline'

begin
  require File.expand_path('~/.process_red')
  raise "Undefined credetials" unless CREDENTIALS
rescue Exception => ex
  puts "Please define your Google Reader credentials in the ~/.process_red file:"
  puts "CREDENTIALS = { email: 'user@gmail.com', password: 'p4assword' }"
  exit
end


HOST = "red.uniqsys.ru"
BASE = "https://#{HOST}"

def user
  @user ||= GoogleReaderApi::User.new CREDENTIALS
rescue GoogleLogin::ClientLogin::BadAuthentication
  puts "Invalid Google Reader username and/or password, specified in the configuration file."
  puts "Cowardly refusing to continue."
  exit
end

def red_feed
  @red_feed ||= user.feeds.find {|feed| feed.url.include?(HOST) }
end

def new_red_feed_items
  red_feed.unread_items(red_feed.unread_count)
end

def issues_entries_hash
  @issues_entries_hash ||= { }.tap do |entries_hash|
    new_red_feed_items.each do |entry|
      if entry.entry.link.to_s =~ /issues\/(\d+)/m 
        entries_hash[$1.to_i] ||= [ ]
        entries_hash[$1.to_i] << entry
      end
    end
  end
end

def mark_issue_read(issue_no)
  issues_entries_hash[issue_no.to_i].each do |entry|
    entry.toggle_read
  end
end

def issue_updates_count(issue_no)
  return 0 unless issues_entries_hash[issue_no.to_i].kind_of?(Array)
  issues_entries_hash[issue_no.to_i].size
end

def issue_url(issue_no)
  "#{BASE}/issues/#{issue_no}"
end

def read_next_issue
  next_issue_no = issues_entries_hash.to_a.flatten.first
  Launchy.open issue_url(next_issue_no)
  return next_issue_no
end

puts "Preloading issues..."
issues_entries_hash
puts "Done!"
puts ""
puts "Try: n - to read the next issue"

cmd = ''
while cmd != 'q'
  if cmd == 'n'
    issue_no = read_next_issue
    puts "Opening #{issue_no}..."
    should_mark_read = Readline.readline('Mark as read? [Yes/No/Skip] ')
    if should_mark_read == 'y'
      puts "Marking #{issue_updates_count(issue_no)} update(s) of the ##{issue_no} as read"
      mark_issue_read(issue_no)
      puts "Marked!"
    elsif should_mark_read == 's'
      puts "OK, skipping it, you hesitating bastard"
      issues_entries_hash.delete(issue_no)
    else
      puts "NOT marking as read"
    end
  end
  puts ""
  cmd = Readline.readline('> ', true)
end

