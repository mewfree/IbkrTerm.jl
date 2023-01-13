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
    elseif cmd == "leverage"
        accounts === nothing ? fetch_accounts() : nothing
        for account in accounts
            leverage = fetch_leverage(account["id"])
            println(account["accountAlias"] * " (" * account["id"] * ") " * "Leverage: " * leverage["value"])
        end
    elseif startswith(cmd, "p")
        (_, symbol) = split(cmd, " ")
        conid = fetch_conid(symbol)
        md_snapshot = fetch_md_snapshot(conid)
        println(md_snapshot)
    elseif cmd ∈ ["exit", "quit"]
        stop()
    else
        println("Command not found")
    end
end

function is_gateway_up()
    r = HTTP.request("GET", "https://localhost:5000", require_ssl_verification=false)
    return r.status
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

function fetch_leverage(accountId)
    r = HTTP.request("GET", url * "/portfolio/" * accountId * "/summary", require_ssl_verification=false)
    s = String(r.body)
    j = JSON.parse(s)
    return j["leverage-s"]
end

function fetch_conid(symbol)
    r = HTTP.request("GET", url * "/trsrv/stocks?symbols=" * symbol, require_ssl_verification=false)
    s = String(r.body)
    j = JSON.parse(s)
    return j[symbol][1]["contracts"][1]["conid"]
end

function fetch_md_snapshot(conid)
    r = HTTP.request("GET", url * "/md/snapshot?conids=" * string(conid) * "&fields=31", require_ssl_verification=false)
    s = String(r.body)
    j = JSON.parse(s)
    return j[1]["31"]
end

function stop()
    println("Bye!")
    exit()
end

function run()
    try
        is_gateway_up()
        println("Welcome to IBKR Terminal")
    catch _
        println("IBKR Client Portal API Gateway doesn't appear to be running.")
        stop()
    end

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
