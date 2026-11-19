# frozen_string_literal: true

require 'fileutils'
require 'json'

##
# Lets the workers of one parallel_tests run share a report directory.
#
# Every worker of a run gets the same PARALLEL_PID_FILE, so it identifies the run.
# The first worker of a new run empties the report directory. The other workers keep
# what it contains. Each worker saves its groups as JSON, and each worker writes the
# overview from the groups of all the workers that have finished. The last worker to
# finish writes the complete overview.
#
# Outside parallel_tests, or with a parallel_tests version that does not set
# PARALLEL_PID_FILE, the reporter works as one process.
##
module RspecPrettyHtmlParallel
  STATE_DIR = '.parallel'

  def self.worker?
    !ENV['PARALLEL_TEST_GROUPS'].to_s.empty? && !ENV['PARALLEL_PID_FILE'].to_s.empty?
  end

  ##
  # Runs the block while it holds a lock that all the workers share.
  # A single process does not lock.
  # @param [String] report_path The report directory
  ##
  def self.synchronize(report_path)
    return yield unless worker?

    FileUtils.mkpath(File.dirname(report_path))
    File.open("#{report_path}.lock", File::RDWR | File::CREAT) do |lock|
      lock.flock(File::LOCK_EX)
      yield
    end
  end

  ##
  # @param [String] report_path The report directory
  # @return [Boolean] True when another worker of this run has prepared the report directory
  ##
  def self.current_run?(report_path)
    File.read(run_file(report_path)) == ENV['PARALLEL_PID_FILE']
  rescue Errno::ENOENT
    false
  end

  ##
  # Records that the report directory belongs to this run.
  # @param [String] report_path The report directory
  ##
  def self.mark_run(report_path)
    FileUtils.mkpath(File.join(report_path, STATE_DIR))
    File.write(run_file(report_path), ENV['PARALLEL_PID_FILE'])
  end

  ##
  # Saves the groups of this worker, then returns the groups of all the workers that have finished.
  # @param [String] report_path The report directory
  # @param [Hash] groups        The groups of this worker, by the name of their report file
  # @return [Hash]              The groups of all the finished workers, in worker order
  ##
  def self.merge_groups(report_path, groups)
    File.write(groups_file(report_path, worker_number), JSON.generate(groups))

    Dir[groups_file(report_path, '*')].sort_by { |path| path[/(\d+)\.json\z/, 1].to_i }.each_with_object({}) do |path, all|
      JSON.parse(File.read(path), symbolize_names: true).each { |name, group| all[name.to_s] = group }
    end
  end

  ##
  # The first worker has an empty TEST_ENV_NUMBER, unless parallel_tests runs with --first-is-1.
  ##
  def self.worker_number
    ENV['TEST_ENV_NUMBER'].to_s.empty? ? 1 : ENV['TEST_ENV_NUMBER'].to_i
  end

  def self.run_file(report_path)
    File.join(report_path, STATE_DIR, 'run')
  end

  def self.groups_file(report_path, number)
    File.join(report_path, STATE_DIR, "groups-#{number}.json")
  end
end
