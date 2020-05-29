require_relative '../color/colors'
require_relative '../lib/utils'
require_relative 'asset_builder'

require 'json'

class Pixelator
  include Colors
  include Utils

  def initialize(neo_pixel:, mode: :layer, frame_rate: 30, osc_control_port: nil, settings: OpenStruct.new)
    @neo_pixel = neo_pixel
    @mode = mode
    @frame_rate = frame_rate
    @settings = settings
    @builder = AssetBuilder.new(default_size: pixel_count, settings: settings)

    OscControlHooks.new(self, port: osc_control_port, settings: settings).start if osc_control_port

    @base = [BLACK] * pixel_count
    @started = false
    clear
  end

  attr_reader :neo_pixel, :frame_rate, :started, :base, :builder, :settings
  private :base, :builder

  def pixel_count
    neo_pixel.pixel_count
  end

  attr_accessor :mode
  private :mode=

  AssetBuilder::ASSET_TYPES.each do |type|
    define_method "#{type}_mode" do
      self.mode = type
      clear
      self
    end
  end

  attr_accessor :object
  private :object=
  alias_method :get, :object

  def clear
    self.object = builder.send("new_#{mode}".to_sym)
    render
    self
  end

  def build(config)
    self.object = builder.send("build_#{mode}".to_sym, config)
  end

  def load_file(name)
    self.object = builder.send("load_#{mode}".to_sym, name)
  end

  def save_file(name)
    builder.send("save_#{mode}".to_sym, name, object)
  end

  def render_period
    1.0 / frame_rate
  end

  def start(period = render_period)
    raise AlreadyStarted if started

    @started = true

    @render_thread = Thread.new do
      while started
        ticker = Time.now

        object.update
        render

        if (elapsed = Time.now - ticker) < period
          sleep period - elapsed
        end
      end
    end

    self
  end

  def buffer
    object.render_over(base)
  end

  def render
    neo_pixel.write(buffer).render
  end

  def stop
    return unless started

    @started = false
    @render_thread.join

    self
  end

  def inspect
    "<Pixelator[#{started ? '▶' : '■'}] adapter:#{neo_pixel} mode:#{mode}>"
  end

  def filename(name)
    builder.filename(mode, name)
  end

end

AlreadyStarted = Class.new(StandardError)
