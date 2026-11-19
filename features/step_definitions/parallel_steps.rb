# frozen_string_literal: true

def parallel_overview
  Capybara.string(File.read(File.join(Fig.parallel_report_path, 'overview.html')))
end

Given('a parallel report has been generated') do
end

Then('the parallel overview has {int} links to other pages') do |number|
  expect(parallel_overview).to have_css('tbody tr td a', count: number)
end

Then('the parallel overview displays the totals {string}, {string} and {string}') do |pending, failed, passed|
  totals = parallel_overview.all('tbody tr').last.all('td').map(&:text)
  expect(totals.values_at(3, 4, 5)).to eq([pending, failed, passed])
end

Then('every link in the parallel overview opens a different report file') do
  links = parallel_overview.all('tbody tr td a').map { |link| link[:href] }
  expect(links.uniq.size).to eq(links.size)
  links.each { |link| expect(File.exist?(File.join(Fig.parallel_report_path, link))).to be true }
end

Then('the file {string} is not in the parallel report') do |name|
  expect(File.exist?(File.join(Fig.parallel_report_path, name))).to be false
end
