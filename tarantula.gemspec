# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tarantula}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Relevance, Inc."]
  s.date = %q{2009-03-11}
  s.description = %q{A big hairy fuzzy spider that crawls your site, wreaking havoc}
  s.email = %q{opensource@thinkrelevance.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["CHANGELOG", "MIT-LICENSE", "Rakefile", "README.rdoc", "VERSION.yml", "examples/example_helper.rb", "examples/relevance", "examples/relevance/core_extensions", "examples/relevance/core_extensions/ellipsize_example.rb", "examples/relevance/core_extensions/file_example.rb", "examples/relevance/core_extensions/response_example.rb", "examples/relevance/core_extensions/test_case_example.rb", "examples/relevance/tarantula", "examples/relevance/tarantula/attack_form_submission_example.rb", "examples/relevance/tarantula/attack_handler_example.rb", "examples/relevance/tarantula/crawler_example.rb", "examples/relevance/tarantula/form_example.rb", "examples/relevance/tarantula/form_submission_example.rb", "examples/relevance/tarantula/html_document_handler_example.rb", "examples/relevance/tarantula/html_report_helper_example.rb", "examples/relevance/tarantula/html_reporter_example.rb", "examples/relevance/tarantula/invalid_html_handler_example.rb", "examples/relevance/tarantula/io_reporter_example.rb", "examples/relevance/tarantula/link_example.rb", "examples/relevance/tarantula/log_grabber_example.rb", "examples/relevance/tarantula/rails_integration_proxy_example.rb", "examples/relevance/tarantula/result_example.rb", "examples/relevance/tarantula/tidy_handler_example.rb", "examples/relevance/tarantula/transform_example.rb", "examples/relevance/tarantula_example.rb", "laf/images", "laf/images/button_active.png", "laf/images/button_hover.png", "laf/images/button_inactive.png", "laf/images/header_bg.jpg", "laf/images/logo.png", "laf/images/tagline.png", "laf/javascripts", "laf/javascripts/jquery-1.2.3.js", "laf/javascripts/jquery-ui-tabs.js", "laf/javascripts/jquery.tablesorter.js", "laf/javascripts/niftycube-details.js", "laf/javascripts/niftycube.js", "laf/javascripts/niftyLayout.js", "laf/javascripts/tarantula.js", "laf/stylesheets", "laf/stylesheets/tarantula.css", "laf/v2", "laf/v2/detail.html", "laf/v2/images", "laf/v2/images/button_active.png", "laf/v2/images/button_hover.png", "laf/v2/images/button_inactive.png", "laf/v2/images/header_bg.jpg", "laf/v2/images/logo.png", "laf/v2/images/tagline.png", "laf/v2/index.html", "laf/v2/stylesheets", "laf/v2/stylesheets/tarantula.v2.css", "lib/relevance", "lib/relevance/core_extensions", "lib/relevance/core_extensions/ellipsize.rb", "lib/relevance/core_extensions/file.rb", "lib/relevance/core_extensions/metaclass.rb", "lib/relevance/core_extensions/response.rb", "lib/relevance/core_extensions/string_chars_fix.rb", "lib/relevance/core_extensions/test_case.rb", "lib/relevance/tarantula", "lib/relevance/tarantula/attack.rb", "lib/relevance/tarantula/attack_form_submission.rb", "lib/relevance/tarantula/attack_handler.rb", "lib/relevance/tarantula/crawler.rb", "lib/relevance/tarantula/detail.html.erb", "lib/relevance/tarantula/form.rb", "lib/relevance/tarantula/form_submission.rb", "lib/relevance/tarantula/html_document_handler.rb", "lib/relevance/tarantula/html_report_helper.rb", "lib/relevance/tarantula/html_reporter.rb", "lib/relevance/tarantula/index.html.erb", "lib/relevance/tarantula/invalid_html_handler.rb", "lib/relevance/tarantula/io_reporter.rb", "lib/relevance/tarantula/link.rb", "lib/relevance/tarantula/log_grabber.rb", "lib/relevance/tarantula/rails_integration_proxy.rb", "lib/relevance/tarantula/recording.rb", "lib/relevance/tarantula/response.rb", "lib/relevance/tarantula/result.rb", "lib/relevance/tarantula/test_report.html.erb", "lib/relevance/tarantula/tidy_handler.rb", "lib/relevance/tarantula/transform.rb", "lib/relevance/tarantula.rb", "tasks/tarantula_tasks.rake", "template/tarantula_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/relevance/tarantula}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A big hairy fuzzy spider that crawls your site, wreaking havoc}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
