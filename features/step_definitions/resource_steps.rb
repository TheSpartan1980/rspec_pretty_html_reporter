Then('every resource the reports reference exists') do
  files = Dir[File.join(Fig.test_report_path, '*.html')]
  expect(files).not_to be_empty

  files.each do |file|
    # Capybara treats <script> and <link> as hidden. Without visible: false, all() finds none of them.
    paths = Capybara.string(File.read(file))
                    .all('script[src], link[href]', visible: false)
                    .map { |node| node[:src] || node[:href] }
                    .grep(%r{\Aresources/})
    expect(paths).not_to be_empty, "#{file} references no resources"

    paths.each do |path|
      expect(File.exist?(File.join(Fig.test_report_path, path))).to be(true), "#{file} references missing #{path}"
    end
  end
end
