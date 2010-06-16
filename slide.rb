class Slide < Shoes::Widget
  def initialize name = nil, l = 0, t = 0, w = 100, a = -1.0, b = 1.0
    @name = name
    min, max = l, l + w
    nostroke
    rect min, t, w, 8, fill: lightgrey(0.5), curve: 3
    scale = para a + (b - a) / 2, left: max + 10, top: t - 8, size: 10
    @lever = oval min + w / 2 - 5, t + 1, 10, 6, 
      fill: teal, flag: false, min: min, max: max, scale: scale, a: a, b: b
    @lever.click{@lever.style flag: true}
    @lever.release{@lever.style flag: false}
    
    def @lever.move l
      if style[:flag] and style[:min] <= l and l <= style[:max]
        super l - 5, top 
        style[:scale].text = "%.3f" % (style[:a] + ((l.to_f - style[:min]) / 
          (style[:max] - style[:min])) * (style[:b] - style[:a]))
      end
    end
    
    def @lever.set scale
      move (scale - style[:a]) * (style[:max] - style[:min]) / (style[:b] - style[:a]) + style[:min]
    end
  end
  
  attr_reader :lever, :name
  
  def scale
    @lever.style[:scale].text.to_f
  end
end
