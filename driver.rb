require 'map.rb'

map = EncounterMap.new(CONFIG['params']['gamma'].to_f, CONFIG['params']['y_start'].to_f, CONFIG['params']['y_end'].to_f, 
                       CONFIG['params']['distribution_limit'], CONFIG['params']['iteration_limit'], 1, 
                       CONFIG['output']['gnuplot']['x_axis'], CONFIG['output']['gnuplot']['y_axis'])
map.distribution
