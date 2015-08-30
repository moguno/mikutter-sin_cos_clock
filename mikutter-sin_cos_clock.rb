#coding: utf-8

# モンキーパッチ
module Gtk
  class CellRendererMessage
    # MiraclePainterを生成して返す
    def create_miracle_painter(message)
      # 時計用に独自のミクぺたを返す
      if message[:clock]
        MikutterSinCosClock::MiraclePainterClock.new(message, avail_width).set_tree(@tree)
      else
        Gdk::MiraclePainter.new(message, avail_width).set_tree(@tree)
      end
    end
  end
end


# プラグイン
Plugin.create(:"mikutter-sin_cos_clock") {
  require File.join(File.dirname(__FILE__), "analog_clock.rb")

  # 定周期ループ
  def loop_start(sec, &block)
    loop_proc = lambda { |_proc|
      block.call

      Reserver.new(sec) {
        _proc.call(_proc)
      }
    }

    Reserver.new(sec) {
      loop_proc.call(loop_proc)
    }
  end

  # 起動時処理
  on_boot { |service|
    if service == Service.primary
      @clock_message = Message.new(:message => "clock", :system => true)
      @clock_message[:clock] = true
      @clock_message[:modified] = Time.now + 1000000

      Plugin::GUI::Timeline.cuscaded[:home_timeline] << @clock_message

      loop_start(1) {
        Delayer.new {
          Gdk::MiraclePainter.findbymessage(@clock_message).first.on_modify
        }
      }
    end
  }
}
