class Relevance::Tarantula::HtmlReporter
  attr_accessor :basedir, :results
  def self.report(basedir, results)
    self.new(basedir, results)
  end

  def initialize(basedir, results)
    @basedir = basedir
    @results = results
    create_index
    create_detail_reports
  end
  
  def template(name)
    File.read(File.join(File.dirname(__FILE__), name))
  end
  
  def output(name, body)
    File.open(File.join(basedir, name), "w") do |file|
      file.write body
    end
  end
  
  def create_index
    template = ERB.new(template("index.html.erb"))
    output("index.html", template.result(results.send(:binding)))
  end

  def create_detail_reports
    template = ERB.new(template("detail.html.erb"))
    results.successes.each do |result|
      output(result.file_name, template.result(result.send(:binding)))
    end
    results.failures.each do |result|
      output(result.file_name, template.result(result.send(:binding)))
    end
  end
end