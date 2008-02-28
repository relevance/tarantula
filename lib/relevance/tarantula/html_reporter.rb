class Relevance::Tarantula::HtmlReporter
  include Relevance::Tarantula
  attr_accessor :basedir, :results
  def self.report(basedir, results)
    self.new(basedir, results)
  end

  def initialize(basedir, results)
    @basedir = basedir
    @results = results
    copy_styles
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
  
  def copy_styles
    # not using cp_r because it picks up .svn crap
    Dir.glob("#{tarantula_home}/laf/*.css").each do |file|
      FileUtils.cp(file, basedir) 
    end
    FileUtils.mkdir_p(File.join(basedir, "images"))
    Dir.glob("#{tarantula_home}/laf/images/*.{jpg,gif,png}").each do |file|
      FileUtils.cp(file, File.join(basedir, "images")) 
    end
    FileUtils.mkdir_p(File.join(basedir, "javascripts"))
    Dir.glob("#{tarantula_home}/laf/javascripts/*.js").each do |file|
      FileUtils.cp(file, File.join(basedir, "javascripts")) 
    end
  end
  
  def create_index
    template = ERB.new(template("index.html.erb"))
    output("index.html", template.result(results.send(:binding)))
  end

  def create_detail_reports
    template = ERB.new(template("detail.html.erb"))
    results.successes.each do |result|
      result.extend HtmlReportHelper
      output(result.file_name, template.result(result.send(:binding)))
    end
    results.failures.each do |result|
      result.extend HtmlReportHelper
      output(result.file_name, template.result(result.send(:binding)))
    end
  end
end