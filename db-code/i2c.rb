puts "Start script"
send_time = Time.now
socket.send('04INIT18!1"0#0$1')
msg = false
sens = nil

hwtime = -1
delay = -1

right = false
right2 = false

stepx = false


xflag1 = false
xflag2 = false

loop do
  while msg_empty?
    sleep 0.000001
  end

  if msg
    hwtime = shift_msg.to_i/1000.0
  else
    sens = shift_msg
    # puts "MSG #{shift_msg}"
    delay = Time.now - send_time
    msg = true
    next
  end

  if msg
    # puts "Total: #{delay*1000}ms"
    # puts "ON HARDWARE: #{hwtime}ms"
    msg = false
    send_time = Time.now

    puts "#{sens[0]}    #{sens[4]}"
    if right
      socket.send('18!1"0#1$0');
      if right2
        if sens[0].to_i <= 2
          flag1 = true
        end
        if sens[4].to_i <= 2
          flag2 = true
        end
        if flag1 && flag2
          right = false;
          stepx = true
          right2 = false
          puts "X"*20
          socket.send('18!0"0#0$0')
        end
      else
        if sens[0].to_i >= 4 && sens[4].to_i >= 4
          right2 = true
          puts 'RRR' * 100
        end
      end
    else
      puts "F"*10
      if sens[0].to_i <= 2 && sens[4].to_i <= 2 && !stepx
        socket.send('18!0"0#0$0')
        right = true
      else
        socket.send('18!1"0#0$1')
      end
      if stepx
        if sens[0].to_i >= 4 && sens[4].to_i >= 4
          stepx = false
        end
      end
    end
  end
end
