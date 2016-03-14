commands = ['forward', 'left']
current_command = 0

out_msg_left('stop')

loop do
  while msg_empty?
    sleep(0.001)
  end

  msg = shift_msg

  if msg != 'ready'
    next
  end

  puts commands[current_command]
  out_msg_left(commands[current_command])

  current_command += 1
  if current_command == commands.size
    current_command = 0
  end
end
