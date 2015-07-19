all: maze.png

fractal: fracune.gif

uneune: uneune.gif

.eps.png:
	convert $< -background white -alpha deactivate $@

mpg: $(PNG)
	ffmpeg -i r%04d.png -b 2400k -flags loop test.mpg

fracune.gif:
	ruby fracune.rb
	convert -delay 6 r*.eps -background white -alpha deactivate -loop 0 fracune.gif

uneune.gif:
	ruby makeune.rb	
	convert -delay 6 r*.eps -background white -alpha deactivate -loop 0 uneune.gif

maze.eps:
	ruby maze.rb

maze.png: maze.eps
	convert -background white -alpha deactivate  +append maze.eps maze_a.eps maze.png

clean:
	rm -f r*.png r*.eps maze*.eps maze*.png maze.png
