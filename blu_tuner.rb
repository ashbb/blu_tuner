# blu_tuner.rb
require 'bloops'
require 'slide'

OPTS1 = %w[volume punch attack sustain decay freq limit slide dslide square sweep vibe]
OPTS2 = %w[vspeed vdelay lpf lsweep resonance hpf hsweep arp aspeed phase psweep repeat]
OPTS = OPTS1 + OPTS2
TYPES = {'square' => Bloops::SQUARE, 'noise' => Bloops::NOISE, 
      'sawtooth' => Bloops::SAWTOOTH, 'sine' => Bloops::SINE}

Shoes.app title: 'blu tuner for bloopsaphone v0.1' do
  background darkslategray
  style Para, stroke: white
  style Link, stroke: gold, underline: nil
  style LinkHover, stroke: gold, underline: nil, fill: nil, weight: "bold"
  
  types, bks = [], []
  TYPES.keys.each_with_index do |type, i|
    bks << rect(30 + 100 * i, 14, type.length * 12, 16, fill: darkslategray, stroke: darkslategray)
    types << para(type.upcase, left: 30 + 100 * i, top: 10)
    bks[i].hover{types[i].style weight: 'bold'}
    bks[i].leave{types[i].style weight: 'normal'}
    bks[i].click{types.each_with_index{|t, n| t.style stroke: (n == i ? steelblue : white)}}
  end
  types.first.style stroke: steelblue
  @type = types.first.text.downcase
  
  line 30, 280, 550, 280, stroke: gold
  
  slides = []
  OPTS1.each_with_index do |opt, i|
    para opt, left: 30, top: 30 + 20 * i
    slides << slide(opt, 130, 20 * (2 + i), 100)
  end
  OPTS2.each_with_index do |opt, i|
    para opt, left: 310, top: 30 + 20 * i
    slides << slide(opt, 400, 20 * (2 + i), 100)
  end
  
  motion{|l, | slides.each{|sd| sd.lever.move l}}
  
  def bloops slides, types
    b = Bloops.new
    b.tempo = 100
    types.each{|t| @type = t.text.downcase if t.style[:stroke] == steelblue}
    s = b.sound TYPES[@type]
    OPTS.each_with_index do |opt, i|
      eval "s.#{opt} = #{slides[i].scale}" unless slides[i].scale.zero?
    end
    b.tune s, '32 C C C 4 A A A'
    b.play
    sleep 0.1 until b.stopped?
  end
  
  def show_blus base, slides
    names, data = [], []
    Dir['sounds/*.blu'].each do |file|
      names << File.basename(file)[0...-4]
      h = {}
      IO.readlines(file).each{|line| k, v = line.split; h[k] = v}
      data << h
    end
    
    base.clear do
      names.each_with_index do |name, i|
        bg = nil
        f = flow width: 100, height: 28 do
          background rosybrown(0.2), curve: 10
          bg = background(rosybrown(0.2), curve: 10).hide
          para name, align: 'center', stroke: silver
        end
        f.hover{bg.toggle}; f.leave{bg.toggle}
        f.click do
          slides.each do |sd|
            sd.lever.style flag: true
            sd.lever.set data[i][sd.name] ? data[i][sd.name].to_f : 0.0
            sd.lever.style flag: false
          end
        end
      end
    end
  end
  
  base = flow left: 30, top: 320, width: 540
  
  para link('listen'){bloops slides, types}, left: 30, top: 290
  
  para link('clear'){
    slides.each{|sd| sd.lever.style flag: true; sd.lever.set 0.0; sd.lever.style flag: false}
  }, left: 80, top: 290
  
  para link('save'){
    file = ask_save_file
    open file, 'w' do |f|
      f.puts "type #{@type}"
      OPTS.each_with_index do |opt, i|
        f.puts "#{opt} #{slides[i].scale}" unless slides[i].scale.zero?
      end
    end if file
    show_blus base, slides
  }, left: 130, top: 290
  
  show_blus base, slides
end
