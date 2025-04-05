SendRawToServer({
    type = "service_call",
    endpoint = "data_stream",
    action = "set_format",
    format = {
        type = "line_graph"
    },
    data_stream_name = "test_stream",
})
-- SendRawToServer({
--     type = "service_call",
--     endpoint = "data_stream",
--     action = "subscribe",
--     data_stream_name = "test_stream"
-- })


while true do
    local dataToSend = {}
    for i = 1, 20 do
        dataToSend[i] = math.random(0, 100)
    end
    SendRawToServer({
        type = "service_call",
        endpoint = "data_stream",
        action = "new_entry",
        data_stream_name = "test_stream",
        entry = {
            data = dataToSend
        }
    })
    os.sleep(5)
end