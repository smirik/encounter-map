require 'map.rb'

gamma = axis_to_gamma(CONFIG['params']['axis'].to_f, CONFIG['params']['planet_axis'].to_f)

map = EncounterMap.new(gamma, CONFIG['params']['y_start'].to_f, CONFIG['params']['y_end'].to_f, 
                       CONFIG['params']['distribution_limit'], CONFIG['params']['iteration_limit'], 1, 
                       CONFIG['output']['gnuplot']['x_axis_start'], CONFIG['output']['gnuplot']['y_axis_start'],
                       CONFIG['output']['gnuplot']['x_axis_end'], CONFIG['output']['gnuplot']['y_axis_end'])
map.distribution
