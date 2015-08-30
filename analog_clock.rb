#coding: utf-8

module MikutterSinCosClock
  require "rubygems"
  require "gtk2"
  require "cairo"

  # 時計用のミクぺた
  class MiraclePainterClock < Gdk::MiraclePainter
    def height
      width
    end

    def render_to_context(context)
      MikutterSinCosClock::draw_clock(Time.now, width, context)
    end
  end

  def self.hour_angle(time)
    base_angle = (360.0 * ((time.hour.to_f % 12.0) / 12.0)) - 90.0
    angle = base_angle + ((time.min.to_f % 60.0) / 60.0 * 30.0)

    angle * Math::PI / 180.0
  end

  def self.min_angle(time)
    angle = (360.0 * (time.min.to_f / 60.0)) - 90.0

    angle * Math::PI / 180.0
  end

  def self.sec_angle(time)
    angle = (360.0 * (time.sec.to_f / 60.0)) - 90.0

    angle * Math::PI / 180.0
  end

  # 時計を描画する
  def self.draw_clock(time, width, context)
    x1 = width / 2
    y1 = width / 2

    context.save {
      context.set_source_color([1.0, 1.0, 1.0])
      context.paint

      pixbuf = Gdk::Pixbuf.new(Skin.get("icon.png"))
      context.scale(width.to_f / pixbuf.width.to_f, width.to_f / pixbuf.height.to_f)
      context.set_source_pixbuf(pixbuf)
      context.paint(0.5)
    }

    context.set_source_color([0.0, 0.0, 0.0])
    context.set_line_width(10)
    context.circle(x1, y1, width / 2 - 5)
    context.stroke

    [
      # 分
      {
        :angle => min_angle(time),
        :distance => width / 2.3,
        :color => [0.0, 0.0, 1.0],
        :width => 8,
      },
      # 時
      {
        :angle => hour_angle(time),
        :distance => width / 3.2,
        :color => [1.0, 0.0, 0.0],
        :width => 10,
      },
      # 秒
      {
        :angle => sec_angle(time),
        :distance => width / 2.3,
        :color => [0.0, 0.0, 0.0],
        :width => 2,
      },
    ].each { |param| 

      x2 = param[:distance] * Math.cos(param[:angle])
      y2 = param[:distance] * Math.sin(param[:angle])

      context.set_line_cap(Cairo::LineCap::ROUND)
      context.set_source_color(param[:color])
      context.set_line_width(param[:width])
      context.move_to(x1.to_i, y1.to_i)
      context.line_to(x2.to_i + x1.to_i, y2.to_i + y1.to_i)
      context.stroke
    } 

    context
  end
end
