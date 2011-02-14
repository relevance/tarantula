module Relevance	
	module Tarantula
		class Railtie < ::Rails::Railtie
		  rake_tasks do
			load "relevance/tasks/tarantula_tasks.rake"
		  end
		end
	end
end
