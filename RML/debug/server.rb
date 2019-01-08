require 'open3'
TIMEOUT = 0.02
CHANNEL  = {}
INQUEUE  = {}
OUTQUEUE = {}
@id = 0

def fresh
  :"_#{@id += 1}"
end

def yield_msg(obj)
    Thread.current[:out] << obj if obj != nil
    nil
end

def post_msg(id, obj)
    OUTQUEUE[id] << obj  if obj != nil
end

def get_msg
    Thread.current[:in].shift
end

def send_msg(id, obj)
    CHANNEL[id][:in] << obj if obj != nil
end

def debug_eval(str)
    post_msg :debug, str
    nil
end

def start_daemon(port)
    @daemon = Thread.new {
        Thread.stop
        loop do
            CHANNEL.to_a.each{|id, thrd|
                if not OUTQUEUE[id].empty?
                    IO.select([], [port], [])
                    Marshal.dump([id, OUTQUEUE[id].shift], port).flush
                end
                Thread.pass
            }
            Thread.pass
        end
    }
    @daemon.abort_on_exception = false
    @daemon.report_on_exception = true
end

def report(str)
    str = str.to_s
    puts ""
    str.split("\n").each{|x|
        puts "[REPORT]#{x}"
    }
    puts ""
end

def channel_run_once
    CHANNEL.to_a.each{|id, thrd|
        if thrd.alive?
            thrd.wakeup if thrd.stop?
            thrd.join TIMEOUT
        end
    }
    [@daemon].each{|thrd|
        thrd.wakeup if thrd.stop?
        thrd.join TIMEOUT
    }
end

def channel(sym = fresh, &block)
    t = Thread.new {
        Thread.stop
        block.call
    }

    t.abort_on_exception  = false
    t.report_on_exception = true
    t[:in]  = INQUEUE[sym] = Queue.new
    t[:out] = OUTQUEUE[sym] = Queue.new
    puts "Build channel #{sym}" unless sym.to_s[0] == "_"
    CHANNEL[sym] = t
end

def process_input((stdin, stdout, stderr))
    rs, ws, = IO.select([stdout], [], [], TIMEOUT)
    if rs && rs[0]
        begin
            msg = Marshal.load(stdout)
        rescue EOFError
            exit!
        end
        id, obj = msg
        if CHANNEL[id] && CHANNEL[id].alive?
            send_msg id, obj
        else
            channel(id){
                if !obj.empty?
                    yield_msg send *obj    
                else
                    
                end
            }
        end
    end
end

open("pid", "a") { |f| f.write "#{Process.pid}\n" }
IO.write "pid", "#{Process.pid}\n"
@main = Thread.new do
    Open3.popen3("Game.exe") do |stdin, stdout, stderr, thr|
        ios = [stdin, stdout, stderr]
        open("pid", "a") { |f| f.write "#{thr.pid}\n" }
        ios.each(&:binmode)
        start_daemon(stdin)
        loop do
            process_input(ios)
            channel_run_once
            sleep 0.01
        end
    end
end

require 'irb'
IRB.start