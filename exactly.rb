#!/usr/bin/env ruby

HAYSTACK = ""
NEEDLE = ""
COUNT_PATTERN = /\W(\d+)\Winsertions.*\W(\d+)\Wdeletions/
SYMBOL = "="

def main
	list_of_changes = {}
  Dir.chdir(HAYSTACK) do
  	current_revision = `git rev-parse HEAD`
		revisions = `git log --format=%H .`.split
	  revisions.reverse.each do |revision|
			`git checkout --quiet #{revision}`
		  output = `git diff --no-index --ignore-all-space --ignore-blank-lines --shortstat #{HAYSTACK} #{NEEDLE}`
			list_of_changes[revision] = count_changed_lines_from output
		end
		`git checkout --force --quiet #{current_revision}`
	end
  print_formated_report list_of_changes.sort_by {|key, value| value}
end

def count_changed_lines_from(output)
	COUNT_PATTERN.match(output)
	$1.to_i + $2.to_i
end

def print_formated_report(hash)
  header = SYMBOL + "Revision".center(50) + SYMBOL + "Lines Changed".center(15) + SYMBOL
	print_line_with header.size
  puts header
	print_line_with header.size
	hash.each do |key, value|
		puts SYMBOL + key.to_s.center(50) + SYMBOL + value.to_s.center(15) + SYMBOL
	end
	print_line_with header.size
end

def print_line_with(width)
	puts SYMBOL * width
end

main()
