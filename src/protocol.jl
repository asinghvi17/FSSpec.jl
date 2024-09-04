const _PROTOCOL_REGEX = r"^(?'protocol'[[:alnum:]]+):\/\/\N*"

function splitprotocol(str::String)
    m = match(_PROTOCOL_REGEX, str)
    if isnothing(m) && isabspath
        return (protocol="file", path=str)
    else
        p = m["protocol"]
        return (protocol=p, path=str[(length(p) + 3):end])
    end
end