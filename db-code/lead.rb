out_msg_left('04INIT')
out_msg_left('18!0"0#0$0~')

loop do
  while msg_empty?
    sleep(0.001)
  end

  msg = shift_msg

  ########
  package = {
    :forward => '18!0"1#1$0~',
    :back => '18!1"0#0$1~',
    :right => '18!1"0#1$0~',
    :left => '18!0"1#0$1~',
    :right_wheel => '18!0"1#0$0~',
    :right_wheel_back => '18!1"0#0$0~',
    :left_wheel => '18!0"0#1$0~',
    :left_wheel_back => '18!0"0#0$1~',
    :stop => '18!0"0#0$0~',
  }

  sensors = {'c' => 2, 'r' => 3, 'l' => 1, 'rr' => 4, 'll' => 0}

  sensor = Proc.new {|s| msg[sensors[s]].to_i <= 4}

  result = if (sensor['c'] && sensor['r'] && sensor['l']) ||
      (sensor['c'] && !sensor['r'] && !sensor['l'])
    package[:back]
  elsif sensor['l']
    package[:right_wheel_back]
  elsif sensor['r']
    package[:left_wheel_back]
  elsif sensor['ll']
    package[:left]
  elsif sensor['rr']
    package[:right]
  else
    package[:stop]
  end

  ########
  out_msg_left(result)
end
