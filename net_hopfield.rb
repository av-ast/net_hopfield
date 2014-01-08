require 'RMagick'

module NetHopfield

  class Neuron
    attr_accessor :s, :x
    attr_reader :y, :index

    def initialize(index)
      @index = index
    end

    def change_state
      @y = s.zero? ? 0 : (s > 0 ? 1 : -1)
    end
  end

  class Net
    SIZE = 100  # neurons count

    attr_reader :net, :matrix, :last_y

    def initialize
      @last_y = []
      @matrix = []
      @net = []

      0.upto(SIZE) do |i|
        @matrix[i] = []
        @net.push(Neuron.new(i))
        0.upto(SIZE) do |j|
          @matrix[i][j] = 0
        end
      end
    end

    def init(input)
      0.upto(SIZE) do |i|
        0.upto(SIZE) do |j|
          if i == j
            @matrix[i][j] = 0
          else
            @matrix[i][j] += (input[i] * input[j])
          end
        end
      end
    end

    def find_image(input)
      # fill input values
      0.upto(SIZE) do |i|
        @net[i].x = input[i]
        @last_y[i] = @net[i].y
      end

      # evaluate state and output
      0.upto(SIZE) do |k|
        @net[k].s = 0

        0.upto(SIZE) do |i|
          @net[k].s += (@matrix[i][@net[k].index] * @net[i].x)
        end

        @net[k].change_state

        flag = true

        0.upto(SIZE) do |i|
          flag = @last_y[i] != @net[i].y
          break unless flag
        end

        unless flag
          tmp_net = []
          0.upto(SIZE) { |i| tmp_net[i] = @net[i].y }

          find_image(tmp_net)
        end
      end

    end

  end

  class PixelsFetcher
    include Magick

    attr_reader :pixels

    def initialize(image_path = "")
      raise "File does not exist" unless File.exists?(image_path)
      @pixels = []
      @image_path = image_path
    end

    def fetch_pixels()
      image = ImageList.new(@image_path)
      image[0].each_pixel do |pixel, c, r|
        @pixels.push(black_pixel?(pixel) ? 1 : -1)
      end
      @pixels
    end

    private

    def black_pixel?(pixel)
      pixel.red.zero? && pixel.green.zero? && pixel.blue.zero?
    end
  end

end
