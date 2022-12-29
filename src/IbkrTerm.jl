module IbkrTerm

import HTTP
import JSON
using Format

Base.exit_on_sigint(false)

url = "https://localhost:5000/v1/portal"

loop = true
accounts = nothing

function handle(cmd)
    if cmd == "accounts"
        accounts === nothing ? fetch_accounts() : nothing
        println(accounts)
    elseif cmd ∈ ["net liquidation value", "nlv"]
        accounts === nothing ? fetch_accounts() : nothing
        for account in accounts
            nlv = fetch_nlv(account["id"])
            println(account["accountAlias"] * " (" * account["id"] * ") " * "Net Liquidation Value: " * format(nlv["amount"], commas=true, precision=0) * " " * nlv["currency"])
        end
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

function fetch_nlv(accountId)
    r = HTTP.request("GET", url * "/portfolio/" * accountId * "/summary", require_ssl_verification=false)
    s = String(r.body)
    j = JSON.parse(s)
    return j["netliquidation"]
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
