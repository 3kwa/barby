require 'barby/outputter'
require 'png'

module Barby

  #Renders the barcode to a PNG image using the "png" gem (gem install png)
  #
  #Registers the to_png and to_canvas methods
  class PngOutputter < Outputter

    register :to_png, :to_canvas

    attr_accessor :xdim, :ydim, :width, :height, :margin


    #Creates a PNG::Canvas object and renders the barcode on it
    def to_canvas(opts={})
      orig_opts = opts.inject({}){|h,p| send("#{p.first}=", p.last) if respond_to?("#{p.first}="); h.update(p.first => p.last) }
      canvas = PNG::Canvas.new(full_width, full_height, PNG::Color::White)

      if barcode.two_dimensional?
        x, y = margin, margin
        barcode.encoding.reverse_each do |line|
          line.split(//).map{|c| c == '1' }.each do |bar|
            if bar
              x.upto(x+(xdim-1)) do |xx|
                y.upto y+(ydim-1) do |yy|
                  canvas[xx,yy] = PNG::Color::Black
                end
              end
            end
            x += xdim
          end
          y += ydim
          x = margin
        end
      else
        x, y = margin, margin
        booleans.each do |bar|
          if bar
            x.upto(x+(xdim-1)) do |xx|
              y.upto y+(height-1) do |yy|
                canvas[xx,yy] = PNG::Color::Black
              end
            end
          end
          x += xdim
        end
      end

      orig_opts.each{|k,v| send("#{k}=", v) if respond_to?("#{k}=") }
      canvas
    end


    #Renders the barcode to a PNG image
    def to_png(*a)
      PNG.new(to_canvas(*a)).to_blob
    end


    def width
      length * xdim
    end

    def height
      barcode.two_dimensional? ? (ydim * barcode.encoding.length) : (@height || 100)
    end

    def full_width
      width + (margin * 2)
    end

    def full_height
      height + (margin * 2)
    end

    def xdim
      @xdim || 1
    end

    def ydim
      @ydim || 1
    end

    def margin
      @margin || 10
    end

    def length
      barcode.two_dimensional? ? barcode.encoding.first.length : barcode.encoding.length
    end


  end

end
