require 'complex'
include Math

def sgn(a)
  tmp = a.abs
  if (tmp == a)
    1.0
  else
    -1.0
  end
end

def func_e(e)
  ((1.0+e)**(-1.5)-1)**-1
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

#a = Complex.new(0, 1)
e0 = 0.1037
z0 = Complex.new(0.001438, 0.001438)
l0 = 0.01

e_start = e0
masses = 5.178*(10**-5)
g = 2.23956667

for i in 1..10000
  z_new = z0 + (Complex::I*g*Math.exp(Complex::I*l0))/(e_start**2)*masses
  l_new = l0+4.0*Math::PI/(3.0*e_start)-8.0*Math::PI*(z_new.abs**2-z0.abs**2)/(9*e_start**3)
  l_new = by_mod(l_new)
  #y_new = y_new*(Math.exp(-1.0*Math::PI*Complex::I*func_e(e_new)))  
  
  z0 = z_new
  l0 = l_new

  #puts "y0 = #{y0}, e0 = #{e0}"
  #puts "e = #{e_new}, l = #{l_new}"
  puts "#{z_new.real}, #{z_new.image}"
  
end