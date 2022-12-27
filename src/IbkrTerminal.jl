module IbkrTerminal

loop = true

function handle(cmd)
    if cmd == "net_worth" || cmd == "nw"
        println("Display net worth")
    elseif cmd == "exit" || cmd == "quit"
        exit()
    else
        println("Command not found")
    end
end

function run()
    println("Welcome to IBKR Terminal")
    while loop
        try
            print("> ")
            handle(readline())
        catch _
            println("Bye!")
            exit()
        end
    end
end

run()
end
