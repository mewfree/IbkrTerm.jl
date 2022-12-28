module IbkrTerm

import HTTP
import JSON

Base.exit_on_sigint(false)

url = "https://localhost:5000/v1/portal"

loop = true
accounts = nothing

function handle(cmd)
    if cmd == "accounts"
        accounts === nothing ? fetch_accounts() : nothing
        println(accounts)
    elseif cmd ∈ ["exit", "quit"]
        stop()
    else
        println("Command not found")
    end
end

function fetch_accounts()
    r = HTTP.request("GET", url * "/portfolio/accounts", require_ssl_verification=false)
    s = String(r.body)
    j = JSON.parse(s)
    global accounts = j
    return accounts
end

function stop()
    println("Bye!")
    exit()
end

function run()
    println("Welcome to IBKR Terminal")
    while loop
        try
            print("> ")
            handle(readline())
        catch _
            stop()
        end
    end
end

run()
end
