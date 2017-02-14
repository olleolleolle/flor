#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

module Flor

  class Waiter

    DEFAULT_TIMEOUT = 4 # seconds

    def initialize(exid, opts)

      serie, timeout, repeat = expand_args(opts)

      @exid = exid
      @original_serie = repeat ? Flor.dup(serie) : nil
      @serie = serie
      @timeout = timeout == true ? DEFAULT_TIMEOUT : timeout

      @queue = []
      @mutex = Mutex.new
      @var = ConditionVariable.new
    end

    def to_s

      "#{super[0..-2]}#{
        { exid: @exid,
          original_serie: @original_serie,
          timeout: @timeout }.inspect
      }>"
    end

    def notify(executor, message)

      @mutex.synchronize do

        return false unless match?(message)

        @serie.shift
        return false unless @serie.empty?

        @queue << [ executor, message ]
        @var.signal
      end

      # then...
      # returning false: do not remove me, I want to listen/wait further
      # returning true: remove me

      return true unless @original_serie

      @serie = Flor.dup(@original_serie) # reset serie

      false # do not remove me
    end

    def wait

      @mutex.synchronize do

        if @queue.empty?

          @var.wait(@mutex, @timeout)
            # will wait "in aeternum" if @timeout is nil

          fail(RuntimeError, "timeout for #{self.to_s}") if @queue.empty?
        end

        executor, message = @queue.shift

        message
      end
    end

    protected

    def match?(message)

      mpoint = message['point']

      return false if @exid && @exid != message['exid'] && mpoint != 'idle'

      nid, points = @serie.first
      mnid = message['nid']

      return false if nid && mnid && nid != mnid
      return false if ! points.include?(mpoint)

      true
    end

    def expand_args(opts)

      owait = opts[:wait]
      orepeat = opts[:repeat] || false
      otimeout = opts[:timeout] || DEFAULT_TIMEOUT

      case owait
      when true
        [ [ [ nil, %w[ failed terminated ] ] ], # serie
          otimeout,
          orepeat ]
      when Numeric
        [ [ [ nil, %w[ failed terminated ] ] ], # serie
          owait, # timeout
          orepeat ]
      when String, Array
        [ parse_serie(owait), # serie
          otimeout,
          orepeat ]
      else
        fail ArgumentError.new(
          "don't know how to deal with #{owait.inspect} (#{owait.class})")
      end
    end

    def parse_serie(s)

      return s if s.is_a?(Array) && s.collect(&:class).uniq == [ Array ]

      (s.is_a?(String) ? s.split(';') : s)
        .collect { |s|
          ni, pt = s.strip.match(/\A([0-9_\-]+)? *([a-z|, ]+)\z/)[1, 2]
          [ ni, pt.split(/[|,]/).collect(&:strip) ]
        }
    end
  end
end

