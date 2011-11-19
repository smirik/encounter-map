require 'complex'
include Math

require 'yaml'

if (!defined? CONFIG)
  CONFIG = YAML.load_file('config.yml')
end

# find sign of given value. Returns +1, -1 or 0. For fixnum & float class
class Float
  def sgn
    abs_value = self.abs
    if ((abs_value == self) && (!self.zero?))
      1.0
    elsif (self.zero?)
      0.0  
    else
      -1.0
    end
  end
end

class Fixnum
  def sgn
    abs_value = self.abs
    if ((abs_value == self) && (!self.zero?))
      1.0
    elsif (self.zero?)
      0.0  
    else
      -1.0
    end
  end
end

class EncounterMap

  attr_accessor :gamma

  @@masses = CONFIG['params']['masses'].to_f
  @@g = CONFIG['constants']['g'].to_f
  # Neptune
  #@@masses = 5.178*(10**-5)
  
  attr_accessor :e_start
  attr_accessor :y0, :e0, :y_new, :e_new
  attr_accessor :limit, :dist_limit, :coeff
  attr_accessor :y_start, :y_end 
  attr_accessor :c_file, :c_filename, :type
  attr_accessor :x_axis_start, :y_axis_start
  
  def initialize(gamma = 0.114665, y_start = -0.2, y_end = 0.2, dist_limit = 100, limit = 500, type = 1, x_axis_start = -0.2, y_axis_start = -0.2, x_axis_end = 0.2, y_axis_end = 0.2)
    @gamma = gamma
    @limit = limit
    @type  = type
    self.setInitial(y_start, y_end, dist_limit)
    if (type == 1)
      @c_filename = @gamma.to_s+'-'+@y_end.to_s+@y_start.to_s+'-'+@dist_limit.to_s+'-'+@limit.to_s
    else
      @c_filename = 'ln'+@y_end.to_s+@y_start.to_s+'-'+@dist_limit.to_s+'-'+@limit.to_s
    end
    @c_file = File.new(CONFIG['output']['dir']+'/'+@c_filename+'.dat', 'w')
    @c_file.puts "#--------------------------------------------------------------------------------------------------------"
    @c_file.puts "#INITIAL DATAS: from y0 = #{@y_start} + 0*i to y_end = #{y_end} + 0*i, e0 = #{@e0}, gamma = #{@gamma}, masses = #{@@masses}\r\n#STEP: #{@coeff}, ITERATION PER ONE DATA: #{@limit}, NUMBER OF STEPS: #{@dist_limit}"
    @c_file.puts "#--------------------------------------------------------------------------------------------------------"
    
    @x_axis_start = x_axis_start
    @y_axis_start = y_axis_start
    @x_axis_end   = x_axis_end
    @y_axis_end   = y_axis_end
  end
  
  def setInitial(y_start, y_end, dist_limit)
    @y_start    = y_start
    @y_end      = y_end
    @dist_limit = dist_limit
    @coeff      = (@y_end - @y_start)/@dist_limit.to_f

    @y0 = Complex.new(@y_start, 0.0)
    self.calcE0
    @e_start = @e0
  end
  
  def calcE0
    @e0 = Math.sqrt(4.0/3.0*(@gamma + (@y0.abs)**2))
  end

  def func_e(e)
    ((1.0+e)**(-1.5)-1.0)**(-1.0)
  end

  def by_mod(l)
    if (l > 2.0*Math::PI)
      while (l > 2.0*Math::PI)
        l = l - 2.0*Math::PI
      end
    else
      while (l < -2.0*Math::PI)
        l = l + 2.0*Math::PI
      end
    end
    l
  end

  def gnufile
    gnu_file = File.new(CONFIG['output']['dir']+'/'+@c_filename+'.gnu', 'w')
    gnu_file.puts "set term png size 600,600 font '/Library/Fonts/Microsoft/Calibri.ttf,15'\r\nset datafile separator ','\r\nset xlabel 'Re(y)'\r\nset ylabel 'Im(y)'\r\nset xtic auto\r\nset ytic auto\r\nset xrange[#{@x_axis_start}:#{@x_axis_end}]\r\nset yrange[#{@y_axis_start}:#{@y_axis_end}]\r\nset pointsize 1.0\r\nset grid\r\nplot '"+CONFIG['output']['dir']+"/"+@c_filename+".dat' notitle lt -1 lc -1 with dots"
    gnu_file.close
  end

  def iterate
    if (type == 1)
      @y_new = ((@y0*(Math.exp(-1.0*Math::PI*Complex::I*func_e(@e0)))-(Complex::I*@@g/(@e_start**2)*@e_start.sgn*@@masses)))
      @e_new = @e0*(Math.sqrt((1.0+((4*(@y_new.abs**2 - @y0.abs**2))/(3*@e0**2)))**1.0))
      @y_new = @y_new*(Math.exp(-1.0*Math::PI*Complex::I*func_e(@e_new)))

      @y0 = @y_new
      @e0 = @e_new
    else
      @y_new = @y0 + (Complex::I*@@g*Math.exp(Complex::I*@e0))/(@e_start**2)*@e_start.sgn*@@masses
      @e_new = @e0+4.0*Math::PI/(3.0*@e_start)-8.0*Math::PI*(@y_new.abs**2-@y0.abs**2)/(9*@e_start**3)
      @e_new = self.by_mod(@e_new)
      
      @y0 = @y_new
      @e0 = @e_new
    end
  end

  def calculate
    #puts "limit = #{@limit}"
    for i in 1..@limit
      self.iterate
      @c_file.puts "#{@y_new.real}, #{@y_new.image}"
    end  
  end  
  
  def distribution
    #puts "dist_limit = #{@dist_limit}"
    @coeff = @coeff*2
    @dist_limit = @dist_limit/2
    
    for i in 0..@dist_limit
      for j in 0..@dist_limit
        @y0 = Complex.new(@y_start+@coeff*i, @y_start+@coeff*j)
        self.calcE0
        @e_start = @e0
        self.calculate
      end
    end
    @c_file.close
    self.gnufile
    tmp = @c_filename+'.gnu > '+CONFIG['output']['dir']+'/'+@c_filename+'.png'
    tmp2 = @c_filename+'.png'
    `gnuplot #{CONFIG['output']['dir']}/#{tmp};`
    `open #{CONFIG['output']['dir']}/#{tmp2}`
  end
  
end

def gamma_to_axis(gamma, ap = false)
  aj   = 5.203363
  aj   = ap if ap
  eps  = (gamma/0.75)**0.5
  axis = -aj*eps+aj
end

def axis_to_gamma(axis, ap = false)
  aj    = 5.203363
  aj    = ap if ap
  eps   = (axis-aj)/aj
  gamma = 0.75*eps*eps
end
