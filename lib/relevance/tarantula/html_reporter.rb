class Relevance::Tarantula::HtmlReporter
  attr_accessor :basedir, :results
  def self.report(basedir, results)
    self.new(basedir, results)
  end

  def initialize(basedir, results)
    @basedir = basedir
    @results = results
    create_index
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
end