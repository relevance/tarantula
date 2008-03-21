module Relevance::Tarantula::HtmlReportHelper 
  include Relevance::Tarantula
  def wrap_in_line_number_table(text, &blk)
    x = Builder::XmlMarkup.new
    x.table(:class => "tablesorter") do      
      x.thead do
        x.tr do
          x.th("Line \#")
          x.th("Line")
        end
      end
      text.split("\n").each_with_index do |line, index|
        x.tr do
          x.td(index+1)
          if block_given?
            x.td {x << yield(line)}
          else
            x.td(line)
          end
        end
      end   
    end
    x.target!
  end 
                                                                            
  def textmate_url(file, line_no)
    "txmt://open?url=file://#{File.expand_path(File.join(rails_root,file))}&line_no=#{line_no}"
  end
  
  def wrap_stack_trace_line(text)
    if text =~ %r{^\s*(/[^:]+):(\d+):([^:]+)$}
      file = $1.to_s_xss_protected
      line_number = $2
      message = $3.to_s_xss_protected
      "<a href='#{textmate_url(file, line_number)}'>#{file}:#{line_number}</a>:#{message}".mark_as_xss_protected
    else
      text.to_s_xss_protected
    end
  end
end
