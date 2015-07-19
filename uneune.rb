# Constructing a path for maze
# Copyright (c) 2015 kaityo256 https://github.com/kaityo256
# Distributed under the Boost Software License, Version 1.0.
# (See copy at http://www.boost.org/LICENSE_1_0.txt)

module Uneune

class Grid
  def initialize(l)
    @L = l
    @grid = Array.new(@L**2){false}
  end
  def [](x,y)
    return false if x<0 
    return false if y<0 
    return false if x> @L-1 
    return false if y> @L-1
    @grid[x+y*@L]
  end
  def []=(x,y,b)
    @grid[x+y*@L] = b
  end
  def show(f)
    @L.times{|x|
      @L.times{|y|
        f.puts "#{x} #{y}" if self[x,y]
      }
    }
  end
end

class MyPath
  attr_accessor :a
  def initialize(l)
    @L = l
    @g = Grid.new(l)
    @a = Array.new
    (l-1).times{|i|
    @g[i,i] = true
    @g[i,i+1] = true
    @a.push [i,i]
    @a.push [i,i+1]
   }
   @a.push [@L-1,@L-1]
   @g[@L-1,@L-1] = true
  end

  def make_double
    a2 = @a
    @a = Array.new
    @L = @L*2-1
    @g = Grid.new(@L)
    (a2.size - 1).times{|i|
      (x1,y1) = a2[i]
      (x2,y2) = a2[i+1]
      @a.push [x1*2,y1*2]
      @a.push [(x1+x2),(y1+y2)]
      @g[x1*2,y1*2] = true
      @g[(x1+x2),(y1+y2)] = true
    }
    (x,y) = a2.last
    @a.push [x*2,y*2]
    @g[x*2,y*2] = true

  end

  def stretch(a,g)
    index = rand(a.length-1)+1
  (x1,y1) = a[index]
  (x2,y2) = a[index+1]
  b = rand(2)*2-1
  changed = false
  if(x1==x2 && x1+b>=0 && x1+b <@L)
    if(!g[x1+b,y1] && !g[x2+b,y2])
      a.insert(index+1,[x1+b,y1])
      a.insert(index+2,[x2+b,y2])
      g[x1+b,y1] = true
      g[x2+b,y2] = true
     changed = true
    end
  end
  if(y1==y2 && y1+b>=0 && y1+b <@L)
    if(!g[x1,y1+b] && !g[x2,y2+b])
      a.insert(index+1,[x1,y1+b])
      a.insert(index+2,[x2,y2+b])
      g[x1,y1+b] = true
      g[x2,y2+b] = true
     changed = true
    end
  end
  changed
end

def flip(a,g)
  index = rand(a.length-1)+1
  (x1,y1) = a[index-1]
  (x2,y2) = a[index]
  (x3,y3) = a[index+1]
  changed = false
  if(x1==x2 && y2==y3 && !g[x3,y1])
    g[x2,y2] = false
    a[index] = [x3,y1] 
    g[x3,y1] = true
    changed = true
  end
  if(y1==y2 && x2==x3 && !g[x1,y3])
    g[x2,y2] = false
    a[index] = [x1,y3] 
    g[x1,y3] = true
    changed = true
  end
  changed
end

def exportEPS(filename,a,show_lattice=false)
  gs = 512/(@L-1)
  xm = 20 
  ym = 20 
  xe = xm*2+(@L-1)*gs
  ye = ym*2+(@L-1)*gs
  f = open(filename,"w")
  f.puts "%!PS-Adobe-2.0"
  f.puts "%%BoundingBox: 0 0 #{xe} #{ye}"
  f.puts "%%EndComments"
  f.puts "/mydict 120 dict def"
  f.puts "mydict begin"
  f.puts "gsave"
  f.puts "0.1 setlinewidth"
  f.puts "1 setgray 0 0 moveto 0 #{ye} lineto #{xe} #{ye} lineto #{xe} 0 lineto stroke closepath fill 0 setgray"
  f.puts "#{xm} #{ym} moveto"
  a.each{|v|
    x = v[0]
    y = v[1]
    x = x * gs + xm 
    y = y * gs + ym 
    f.puts "#{x} #{y} lineto" 
  } 
  f.puts "stroke"
  if show_lattice
    f.puts "1 0 0 setrgbcolor"
    @L.times{|x|
      @L.times{|y|
        f.puts "#{x*gs + xm} #{y*gs+ym} 2 0 360 arc stroke" if !@g[x,y]
      }
    }
  end

  f.puts "grestore"
  f.puts "end"
end
  
  def makepath(s, th=0.5)
    (s-2).times{|i|
      make_double
      (@L/2).times{
        (@L*10).times{
          flip(@a,@g)
          stretch(@a,@g)
        }
      }
    }
    make_double
    make_double
    (@L*1000).times{|i|
      flip(@a,@g)
      stretch(@a,@g)
      ratio = @a.size/@L**2.to_f
      break if ratio > th
    }
    (@L*100).times{
      flip(@a,@g)
    }
  end

  def fill
    index = 0
    6.times{|i|
      make_double
      (@L/2).times{
        (@L*10).times{
          flip(@a,@g)
          stretch(@a,@g)
        }
        filename = sprintf "r%04d.eps",index
        index = index + 1
        puts filename
        exportEPS(filename,@a)
      }
    }
  end

  def make
  100.times{|i|
    filename = sprintf "r%04d.eps",i
    puts filename
    exportEPS(filename,@a)
    (@L*10).times{
      flip(@a,@g)
      stretch(@a,@g)
    }
  }
  end
end

end
