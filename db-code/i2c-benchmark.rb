puts "Start script"
send_time = Time.now
socket.send('04INIT18!1!0!0!1')
msg = false

hwtime = -1
delay = -1

loop do
  while msg_empty?
    sleep 0.000001
  end

  if msg
    hwtime = shift_msg.to_i/1000.0
  else
    puts "MSG #{shift_msg}"
    delay = Time.now - send_time
    msg = true
    next
  end

  if msg
    puts "Total: #{delay*1000}ms"
    puts "ON HARDWARE: #{hwtime}ms"
    msg = false
    send_time = Time.now
    socket.send('18!1!0!0!1')
  end
end
