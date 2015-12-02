require 'fishbans'
require 'cinch'

module Plugins
  module Commands
    class BanInfo
      include Cinch::Plugin

      match(/banned (.+)/i)

      def execute(msg, username)
        bans = Fishbans.get_total_bans(username)
        if bans.is_a?(Fixnum)
          if bans > 0
            message = "#{username} has been banned! What a loser! They've " \
                      "been banned #{bans} times!"
          else
            message = "#{username} has not been banned! What a gentle person!"
          end
        else
          message = "Error: #{bans}"
        end

        msg.reply(message)
      end
    end
  end
end