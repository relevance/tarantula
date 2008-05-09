require 'hpricot'

class Relevance::Tarantula::XssDocumentCheckerHandler 
  
  def initialize(attacks)
    @attacks = attacks
    @regexp = '(' + attacks.map {|a| Regexp.escape a['code']}.join('|') + ')'
  end
  
  def handle(result)
    response = result.response
    return unless response.html?
    if n = (response.body =~ /#{@regexp}/)
      error_result = result.dup
      error_result.success = false
      error_result.description = "XSS error found, match was: #{$1}"
      error_result.data = <<-STR
        ########################################################################
        # Text around unescaped string: #{$1}
        ########################################################################
        #{response.body[[0, n - 200].max , 400]}
        
        
        
        
        
        ########################################################################
        # Attack information:
        ########################################################################
        #{@attacks.select {|a| a['code'] == $1}[0].to_yaml}
      STR
      error_result
    end
  end
end
