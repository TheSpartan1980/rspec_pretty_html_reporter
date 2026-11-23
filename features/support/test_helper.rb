# frozen_string_literal: true

module TestHelper
  def self.remove_report_dir(dir_name)
    FileUtils.remove_dir(dir_name) if Dir.exist?(dir_name)
  end

  PARALLEL_WORKERS = {
    '' => 'spec/duplicate_failing_spec.rb spec/duplicate_passing_spec.rb spec/embed_graphics_spec.rb',
    '2' => 'spec/duplicate_pending_spec.rb spec/rspec_pretty_html_reporter_spec.rb spec/shared_example_spec.rb ' \
           'spec/turnip.feature'
  }.freeze

  # Runs two workers of one parallel_tests run together. With seed, the report directory
  # holds a file from an earlier run, which the first worker of the new run must remove.
  # Without it the directory is absent, so the workers must create it.
  # The example specs fail on purpose, so --failure-exit-code 0 makes a worker exit 0
  # unless it crashes or cannot load a spec.
  def self.generate_parallel_report(dir_name, seed: true)
    FileUtils.rm_rf(dir_name)
    if seed
      FileUtils.mkpath(File.join(dir_name, '.parallel'))
      File.write(File.join(dir_name, '.parallel', 'run'), 'an earlier run')
      File.write(File.join(dir_name, 'stale.html'), '')
    end

    PARALLEL_WORKERS.map do |number, files|
      env = { 'REPORT_PATH' => dir_name, 'TEST_ENV_NUMBER' => number, 'PARALLEL_TEST_GROUPS' => '2',
              'PARALLEL_PID_FILE' => 'cucumber-parallel-run' }
      spawn(env, "bundle exec rspec --failure-exit-code 0 --error-exit-code 2 --format RspecPrettyHtmlReporter #{files}",
            out: File::NULL)
    end.each do |pid|
      _, status = Process.wait2(pid)
      raise "parallel worker #{pid} exited #{status.exitstatus.inspect}" unless status.success?
    end
  end
end
