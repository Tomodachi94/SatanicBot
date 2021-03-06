require 'string-utility'
require 'timerizer'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    class Editathon < BaseCommand
      include Cinch::Plugin
      include Plugins::Wiki
      using StringUtility
      ignore_ignored_users

      set(help: 'Provides information for the current, upcoming, or most recent editathon.', plugin_name: 'editathon')
      match(/editathon/i)

      FORMAT = '%B %e %Y %H:%M:%S UTC'.freeze

      def execute(msg)
        newest_editathon = wiki.get_category_members('Category:Editathons').max do |a, b|
          wiki.first_edit_timestamp(a) <=> wiki.first_edit_timestamp(b)
        end
        url = wiki.get_article_path(newest_editathon.underscorify)
        text = wiki.get_text(newest_editathon)
        # Text can't be nil, and if it is, then there's a serious problem with the code. There are always going to be editathons.
        # noinspection RubyNilAnalysis
        dates = text.scan(/<!--start: (.+) \/ end: (.+)-->/).flatten
        if dates.empty?
          msg.reply("Possibly upcoming editathon: #{url} with no currently specified starting and ending dates")
          return
        end
        start_date = Time.parse(dates[0]).utc
        end_date = Time.parse(dates[1]).utc
        current = Time.now.utc
        if current.in_progress?(start_date, end_date)
          msg.reply("Current editathon: #{url} ending in #{Time.until(end_date)} (#{end_date.strftime(FORMAT)})")
        elsif current < start_date
          msg.reply("Upcoming editathon: #{url} starting in #{Time.until(start_date)} (#{start_date.strftime(FORMAT)})")
        elsif current > end_date
          msg.reply("Past editathon: #{url} ended #{Time.since(end_date)} ago (#{end_date.strftime(FORMAT)})")
        end
      end
    end
  end
end
