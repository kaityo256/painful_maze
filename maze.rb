# Constructing a maze with a clustering algorithm
# Copyright (c) kaityo256 https://github.com/kaityo256
# Distributed under the Boost Software License, Version 1.0.
# (See copy at http://www.boost.org/LICENSE_1_0.txt)

require './uneune.rb'

class Maze
  def initialize(s, th=0.5)
    @lx = 2**(1+s)+1
    @ly = 2**(1+s)+1
    @bond_h = Array.new((@lx+1)*@ly) { false}
    @bond_v = Array.new(@lx*(@ly+1)) { false}
    @point = Array.new(@lx*@ly*2) {|i| i}
    @GridSize = 512/(@lx-1)

    @LeftMargin = @GridSize
    @TopMargin = @GridSize
    @p = Uneune::MyPath.new(3)
    @p.makepath(s,th)
    (@p.a.size - 1).times{|i|
      (y1,x1) = @p.a[i]
      (y2,x2) = @p.a[i+1]
      if(x1==x2)
        y = [y1,y2].min+1
        @bond_v[(y)*@lx+x1] = true
        connect(x1,y1,x2,y2)
      elsif(y1==y2)
        x = [x1,x2].min
        @bond_h[(@lx+1)*y1+x+1] = true
        connect(x1,y1,x2,y2)
      end
    }
    makeMaze
  end
  
  def getClasterIndex(x, y)
    index = @lx*y+x
    while(index != @point[index])
      index = @point[index]
    end
    return index
  end
  
  def connect(ix1, iy1, ix2, iy2)
    i1 = getClasterIndex(ix1,iy1)
    i2 = getClasterIndex(ix2,iy2)
    if i1<i2
      @point[i2] = i1
    else
      @point[i1] = i2
    end
  end
  
  def makeMazeSub
    rate = 0.8
    for ix in 0..@lx-2
      for iy in 0..@ly-1
        next if rand <rate
        next if getClasterIndex(ix,iy) == getClasterIndex(ix+1,iy)
        @bond_h[(@lx+1)*iy+ix+1] = true
        connect(ix,iy,ix+1,iy)
      end
    end
    for ix in 0..@lx-1
      for iy in 0..@ly-2
        next if rand <rate
        next if getClasterIndex(ix,iy) == getClasterIndex(ix,iy+1)
        @bond_v[(iy+1)*@lx+ix] = true
        connect(ix,iy,ix,iy+1)
      end
    end
  end
  
  def makeMazeFinal
    for ix in 1..@lx-2
      for iy in 1..@ly-1
        next if getClasterIndex(ix,iy) == getClasterIndex(ix+1,iy)
        @bond_h[iy*(@lx+1)+ix+1] = true
        connect(ix,iy,ix+1,iy)
      end
    end
  end
  
  def makeMaze
    for i in 0..10
      makeMazeSub
    end
    makeMazeFinal
    @bond_h[0] = true
    @bond_h[(@lx+1)*@ly-1] = true
  end
  
  def exportEPS (filename, showanswer = false)
    g = @GridSize
    h = @GridSize*0.5
    f = open(filename,"w")
    f.puts "%!PS-Adobe-2.0"
    f.puts "%%BoundingBox: 0 0 #{g*@lx+@LeftMargin*2} #{g*@ly+@TopMargin*2}"
    f.puts "%%EndComments"
    f.puts "/mydict 120 dict def"
    f.puts "mydict begin"
    f.puts "gsave"
    f.puts "0.3 setlinewidth"

    f.puts "/arrow {gsave translate "
    f.puts "0 0 moveto "
    f.puts g.to_s + " 0 lineto stroke"
    f.puts g.to_s + " 0  moveto "
    f.puts h.to_s + " -" + h.to_s + " lineto "
    f.puts h.to_s + " " + h.to_s + " lineto "
    f.puts "closepath fill stroke grestore} def"

    f.puts @LeftMargin.to_s + " " + @TopMargin.to_s + " translate "
    f.puts "-" + g.to_s + " " + (g*0.5).to_s + " arrow "
    f.puts "" + (g*@lx).to_s + " " + (g*(@ly-0.5)).to_s + " arrow "

    for ix in 0..@lx
      for iy in 0..@ly-1
        x = ix * @GridSize
        y = iy * @GridSize
        next if @bond_h[iy*(@lx+1)+ix]
        f.puts x.to_s + " " + y.to_s + " moveto "
        f.puts x.to_s + " " + (y+@GridSize).to_s + " lineto stroke"
      end
    end
    for ix in 0..@lx-1
      for iy in 0..@ly
        x = ix * @GridSize
        y = iy * @GridSize
        next if @bond_v[iy*@lx+ix]
        f.puts x.to_s + " " + y.to_s + " moveto "
        f.puts ""+(x+@GridSize).to_s + " " + y.to_s + " lineto stroke"
      end
    end
    if showanswer
      f.puts "1 0 0 setrgbcolor"
      f.puts "#{@GridSize*0.5} #{@GridSize*0.5} moveto"
      @p.a.size.times{|i|
        (x,y)  = @p.a[i]
        f.puts "#{y*@GridSize+@GridSize*0.5} #{x*@GridSize+@GridSize*0.5} lineto"
      }
      f.puts "stroke" 
    end
    f.puts "grestore"
    f.puts "end"
  end
end

s = 5    # Size = 2**(1+s)+1
th = 0.5 # Threshold
s = ARGV[0].to_i if ARGV.size > 0
th = ARGV[1].to_f if ARGV.size > 1

s = 3 if s < 3

m = Maze.new(s,th)
m.exportEPS("maze.eps")
m.exportEPS("maze_a.eps",true)
puts "Size = #{2**(1+s)+1}"
puts "Threshold = #{th}"
puts "A maze is constructed."
puts "The filenames are maze.eps and maze_a.eps."
