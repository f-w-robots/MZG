require_relative 'unix_connection.rb'

@unix = UNIXConnection.new lambda {|msg| on_message(msg)}

def on_message msg

end

sleep

# Example, circle move
#
# @unix.send_message('forward')
# @last_command = 'forward'
#
# def on_message msg
#   if(msg == 'ready')
#     if(@last_command == 'forward')
#       @unix.send_message('left')
#       @last_command = 'left'
#     else
#       @unix.send_message('forward')
#       @last_command = 'forward'
#     end
#   end
# end
#
# sleep
