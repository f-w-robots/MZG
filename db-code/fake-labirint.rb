loop do
  while msg_empty?
    sleep(0.1)
  end
  msg = shift_msg
  result = if msg[3] == '2'
    'ls'
  elsif msg[0] == '2'
    'fs'
  elsif msg[1] == '2'
    'rs'
  else
    if msg[3] == '0'
      'l'
    elsif msg[0] == '0'
      'f'
    elsif msg[1] == '0'
      'r'
    else
      'b'
    end
  end
  socket.send(result)
end
