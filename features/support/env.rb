# frozen_string_literal: true

require 'byebug'
require 'capybara'
require 'capybara/cucumber'
require 'cucumber'
require 'fig_newton'
require 'selenium-webdriver'
require_relative 'test_helper'

Fig = FigNewton
Fig.yml_directory = 'fixtures'

TestHelper.remove_report_dir(FigNewton.reports_dir)
system("REPORT_PATH=#{FigNewton.test_report_path} bundle exec rspec --format RspecPrettyHtmlReporter spec")

# Two workers of one parallel_tests run, started together. The report directory holds a
# file from an earlier run, which the first worker of the new run must remove.
parallel_dir = FigNewton.parallel_report_path
FileUtils.mkpath(File.join(parallel_dir, '.parallel'))
File.write(File.join(parallel_dir, '.parallel', 'run'), 'an earlier run')
File.write(File.join(parallel_dir, 'stale.html'), '')
parallel_workers = {
  '' => 'spec/duplicate_failing_spec.rb spec/duplicate_passing_spec.rb spec/embed_graphics_spec.rb',
  '2' => 'spec/duplicate_pending_spec.rb spec/rspec_pretty_html_reporter_spec.rb spec/shared_example_spec.rb spec/turnip.feature'
}
parallel_workers.map do |number, files|
  env = { 'REPORT_PATH' => parallel_dir, 'TEST_ENV_NUMBER' => number, 'PARALLEL_TEST_GROUPS' => '2',
          'PARALLEL_PID_FILE' => 'cucumber-parallel-run' }
  spawn(env, "bundle exec rspec --format RspecPrettyHtmlReporter #{files}", out: File::NULL)
end.each { |pid| Process.wait(pid) }
