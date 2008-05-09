class Relevance::Tarantula::HtmlReporter
  
  include Relevance::Tarantula
  attr_accessor :basedir, :results
  delegate :successes, :failures, :to => :results
  
  HtmlResultOverview = Struct.new(:code, :url, :description, :method, :referrer, :file_name)
  
  def initialize(basedir)
    @basedir = basedir
    @results = Struct.new(:successes, :failures).new([], [])
    FileUtils.mkdir_p(@basedir)
  end
  
  def report(result)
    return if result.nil?
    
    create_detail_report(result)
    
    collection = result.success ? results.successes : results.failures
    collection << HtmlResultOverview.new(
      result.code, result.url, result.description, result.method, result.referrer, result.file_name
    )
  end
  
  def finish_report
    puts "Writing results to #{basedir}"
    copy_styles
    create_index
  end
  
  def copy_styles
    # not using cp_r because it picks up .svn crap
    FileUtils.mkdir_p(File.join(basedir, "stylesheets"))
    Dir.glob("#{tarantula_home}/laf/stylesheets/*.css").each do |file|
      FileUtils.cp(file, File.join(basedir, "stylesheets")) 
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
    output("index.html", template.result(binding))
  end
  
  def template(name)
    File.read(File.join(File.dirname(__FILE__), name))
  end
  
  def output(name, body)
    File.open(File.join(basedir, name), "w") do |file|
      file.write body
    end
  end      
  
  def create_detail_report(result)
    template = ERB.new(template("detail.html.erb"))
    output(result.file_name, template.result(result.send(:binding)))
  end 
  
  # CSS class for HTML status codes
  def class_for_code(code)
    "r#{Integer(code)/100}" 
  end
  
  
end