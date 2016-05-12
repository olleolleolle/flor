#--
# Copyright (c) 2015-2016, John Mettraux, jmettraux+flon@gmail.com
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

  class Scheduler

    attr_reader :conf, :env
    attr_reader :logger, :waiter, :storage

    attr_reader :thread_status

    def initialize(conf={})

      @conf = conf.is_a?(Hash) ? conf : Flor::Conf.read(conf)
      @env = @conf['env'] ||= 'dev'

      @logger = Flor::Logger.new(self)
      @waiter = Flor::Waiter.new(self)
      @storage = Flor::Storage.new(self)

      @reload_frequency = @conf[:sch_reload_frequency] || 60
      @max_executors = @conf[:sch_max_executors] || 1

      @reloaded_at = nil
      @timers = []
      @exids = []

      @executors = []
    end

    def shutdown

      @thread_status = :shutdown
      @thread = nil

      @logger.shutdown
      @waiter.shutdown
      @storage.shutdown
    end

    def start

      # TODO heartbeat, every x minutes, when idle, log something

      @thread_status = :running

      @thread =
        if @thread

          @thread.run

        else

          Thread.new do
            loop do

              begin

                Thread.stop if @thread_status == :stop
                break if @thread_status == :shutdown

                reload
                trigger_timers
                trigger_executions

              rescue => e
                # TODO enhance me
                puts "-" * 80
                p e
                puts e.backtrace[0, 7]
                puts ("-" * 80) + ' .'
                $stdout.flush
              end
            end
          end
        end

      self
    end

    def stop

      @thread_status = :stop
    end

    def running?; @thread_status == :running; end
    def stopped?; ! running?; end

    def join

      @thread.join
    end

    def launch(tree, opts={})

      exid = Flor.generate_exid(
        opts[:domain] || @conf[:domain] || 'domain0',
        opts[:unit] || @conf[:unit] || 'u0')

      m = Flor.make_launch_msg(exid, tree, opts)

      @storage.put_message(m)

      opts[:wait] ? @waiter.wait(exid, %w[ failed terminated ]) : exid
    end

    def log(pos, message)

      if pos == :pre
        @logger.log(message)
      else # :post
        @waiter.log(message)
      end
    end

    protected

    def reload

      now = Time.now

      return if @reloaded_at && (now - @reloaded_at < @reload_frequency)

      @reloaded_at = now
      @timers = load_timers
      @exids = load_exids
    end

    def load_timers

      @storage.load_timers.sort_by { |t| t[:id] }
        # FIXME
    end

    def load_exids

      @storage.load_exids
    end

    def trigger_timers

      now = Time.now

      loop do

        timer = @timers.first
        break if timer == nil || timer.at > now

        trigger_timer(@timers.shift)
      end
    end

    def trigger_executions

      return if @exids.empty?

      @executors = @executors.select { |e| e.alive? }
      exids = @executors.collect { |e| e.exid }

      @exids.each do |exid|

        break if @executors.size > @max_executors
        next if exids.include?(exid)

        @executors << UnitExecutor.new(self, exid).run
      end
    end
  end
end

