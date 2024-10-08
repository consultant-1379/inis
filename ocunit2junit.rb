#!/usr/bin/env ruby
#
# ocunit2junit.rb was written by Christian Hedin <christian.hedin@jayway.com>
# Version: 0.1 - 30/01 2010
# Usage:
# xcodebuild -yoursettings | ocunit2junit.rb
# All output is just passed through to stdout so you don't miss a thing!
# JUnit style XML-report are put in the folder specified below.
#
# Known problems:
# * "Errors" are not cought, only "warnings".
# * It's not possible to click links to failed test in Hudson
# * It's not possible to browse the source code in Hudson
#
# Acknowledgement:
# Big thanks to Steen Lehmann for prettifying this script.
################################################################
# Edit these variables to match your system
#
#
# Where to put the XML-files from your unit tests
TEST_REPORTS_FOLDER = "test-reports"
SUPPORT_KIWI = true
#
#
# Don't edit below this line
################################################################

require 'time'
require 'fileutils'
require 'socket'

class ReportParser
    
    attr_reader :exit_code
    
    def initialize(piped_input)
        @piped_input = piped_input
        @exit_code = 0
        
        FileUtils.rm_rf(TEST_REPORTS_FOLDER)
        FileUtils.mkdir(TEST_REPORTS_FOLDER)
        parse_input
    end
    
    private
    
    def parse_input
        @piped_input.each do |piped_row|
            puts piped_row
            
            description_results = piped_row.scan(/\s\'(.+)\'\s/)
                                                 if description_results and description_results[0] and description_results[0]
                                                 description = description_results[0][0]
                                                 end
                                                 
                                                 case piped_row
                                                 
                                                 when /Test Suite '(\S+)'.*started at\s+(.*)/
                                                 t = Time.parse($2.to_s)
                                                 handle_start_test_suite(t)
                                                 @last_description = nil
                                                 
                                                 when /Test Suite '(\S+)'.*finished at\s+(.*)./
                                                 t = Time.parse($2.to_s)
                                                 handle_end_test_suite($1,t)
                                                 
                                                 when /Test Case '-\[\S+\s+(\S+)\]' started./
                                                 test_case = $1
                                                 @last_description = nil
                                                 
                                                 when /Test Case '-\[\S+\s+(\S+)\]' passed \((.*) seconds\)/
                                                 test_case = get_test_case_name($1, @last_description)
                                                 test_case_duration = $2.to_f
                                                 handle_test_passed(test_case,test_case_duration)
                                                 
                                                 when /(.*): error: -\[(\S+) (\S+)\] : (.*)/
                                                 error_location = $1
                                                 test_suite = $2
                                                 error_message = $4
                                                 test_case = get_test_case_name($3, description)
                                                 handle_test_error(test_suite,test_case,error_message,error_location)
                                                 
                                                 when /Test Case '-\[\S+ (\S+)\]' failed \((\S+) seconds\)/
                                                 test_case = get_test_case_name($1, @last_description)
                                                 test_case_duration = $2.to_f
                                                 handle_test_failed(test_case,test_case_duration)
                                                 
                                                 when /failed with exit code (\d+)/
                                                 @exit_code = $1.to_i
                                                 
                                                 when
                                                 /BUILD FAILED/
                                                 @exit_code = -1;
                                                 end
                                                 
                                                 unless description.nil?
                                                 @last_description = description
                                                 end
                                                 end
                                                 end
                                                 
                                                 def handle_start_test_suite(start_time)
                                                 @total_failed_test_cases = 0
                                                 @total_passed_test_cases = 0
                                                 @tests_results = Hash.new # test_case -> duration
                                                 @errors = Hash.new  # test_case -> error_msg
                                                 @ended_current_test_suite = false
                                                 @cur_start_time = start_time
                                                 end
                                                 
                                                 def handle_end_test_suite(test_name,end_time)
                                                 unless @ended_current_test_suite
                                                 current_file = File.open("#{TEST_REPORTS_FOLDER}/TEST-#{test_name}.xml", 'w')
                                                 host_name = string_to_xml Socket.gethostname
                                                 test_name = string_to_xml test_name
                                                 test_duration = (end_time - @cur_start_time).to_s
                                                 total_tests = @total_failed_test_cases + @total_passed_test_cases
                                                 suite_info = '<testsuite errors="0" failures="'+@total_failed_test_cases.to_s+'" hostname="'+host_name+'" name="'+test_name+'" tests="'+total_tests.to_s+'" time="'+test_duration.to_s+'" timestamp="'+end_time.to_s+'">'
                                                 current_file << "<?xml version='1.0' encoding='UTF-8' ?>\n"
                                                 current_file << suite_info
                                                 @tests_results.each do |t|
                                                 test_case = string_to_xml t[0]
                                                 duration = @tests_results[test_case]
                                                 current_file << "<testcase classname='#{test_name}' name='#{test_case}' time='#{duration.to_s}'"
                                                 unless @errors[test_case].nil?
                                                 # uh oh we got a failure
                                                 puts "tests_errors[0]"
                                                 puts @errors[test_case][0]
                                                 puts "tests_errors[1]"
                                                 puts @errors[test_case][1]
                                                 
                                                 message = string_to_xml @errors[test_case][0].to_s
                                                 location = string_to_xml @errors[test_case][1].to_s
                                                 current_file << ">\n"
                                                 current_file << "<failure message='#{message}' type='Failure'>#{location}</failure>\n"
                                                 current_file << "</testcase>\n"
                                                 else
                                                 current_file << " />\n"
                                                 end
                                                 end
                                                 current_file << "</testsuite>\n"
                                                 current_file.close
                                                 @ended_current_test_suite = true
                                                 end
                                                 end
                                                 
                                                 def string_to_xml(s)
                                                 s.gsub(/&/, '&amp;').gsub(/'/, '&quot;').gsub(/</, '&lt;')
                                                                           end
                                                                           
                                                                           def handle_test_passed(test_case,test_case_duration)
                                                                           @total_passed_test_cases += 1
                                                                           @tests_results[test_case] = test_case_duration
                                                                           end
                                                                           
                                                                           def handle_test_error(test_suite,test_case,error_message,error_location)
                                                                           #    error_message.tr!('<','').tr!('>','')
                                                                           @errors[test_case] = [ error_message, error_location ]
                                                                           end
                                                                           
                                                                           def handle_test_failed(test_case,test_case_duration) 
                                                                           @total_failed_test_cases +=1
                                                                           @tests_results[test_case] = test_case_duration
                                                                           end
                                                                           
                                                                           def get_test_case_name(test_case, description)
                                                                           if SUPPORT_KIWI and test_case == "example" and !description.nil?
                                                                           description
                                                                           else
                                                                           test_case
                                                                           end
                                                                           end
                                                                           
                                                                           end
                                                                           
                                                                           #Main
                                                                           #piped_input = File.open("tests_fail.txt") # for debugging this script
                                                                           piped_input = ARGF.readlines
                                                                           
                                                                           report = ReportParser.new(piped_input)
                                                                           
                                                                           exit report.exit_code