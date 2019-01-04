if !$debug_init
    $debug_init = true
    [STDIN, STDOUT, STDERR].each{|x| x.binmode}

    module Debug
        extend self
        REGISTER = {}
        def fresh
            @id ||= 0
            @id += 1
            :"_#{@id}"
        end

        def run(command, id = fresh, &block)
            REGISTER[id] = block
            Marshal.dump([id, command], STDOUT).flush
        end

        def update
            rs, ws = IO.select([STDIN], [], [], 0.01)
            if rs && rs[0]
                id, ret = Marshal.load(STDIN)
                if REGISTER[id]
                    REGISTER[id].call(ret)
                end
            end
        end

        def eval(str, id = fresh, &block)
            run([:eval, str], id, &block)
        end

        def build_channel(id, &block)
            run [], id, &block
        end
    end

    class << Graphics
        alias debug_update update
        def update
            debug_update
            Debug.update
        end
    end
end

id = 0
Debug.build_channel(:debug) do |ret|
    if String === ret
        begin
            eval ret, TOPLEVEL_BINDING, "<debug:#{id+=1}>", 1
        rescue Exception
            Debug.run([:report, $!.backtrace.unshift($!.to_s).join("\n")]){}
        end
    end
end

r = load_data(RUNARGS[2])
    r.each{|x|
    x[3] = Zlib::Inflate.inflate(x[2])
    begin
        eval x[3], TOPLEVEL_BINDING, x[1], 1
    rescue Exception
        msgbox $!.backtrace.unshift($!.to_s).join("\n")
    end
}
