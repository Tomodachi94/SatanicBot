require 'cinch'

module Plugins
  module Commands
    class CategoryMembers
      include Cinch::Plugin

      match(/categorymembers (.+)/i)

      def execute(msg, category)
        authedusers = Variables::NonConstants.get_authenticated_users
        category = "Category:#{category}" if /^Category:/ !~ category
        if authedusers.include?(msg.user.authname)
          butt = LittleHelper.init_wiki
          members = butt.get_category_members(category, 5000)
          paste_hash = {}
          members.each do |page|
            categories = butt.get_categories_in_page(page)
            categories.each do |cat|
              paste_hash[cat] = [] unless paste_hash.key?(cat)
              paste_hash[cat] << page
            end
          end
          paste_contents = "Comprehensive summary of #{category} members\n\n"
          paste_hash.each do |cat, pages|
            page_string = pages.join("\n* ")
            paste_contents << "## #{cat}\n* #{page_string}\n\n"
          end
          pastee = LittleHelper.init_pastee
          id = pastee.submit(paste_contents, "Summary of #{category} members.")
          msg.reply("http://paste.ee/p/#{id}")
        else
          msg.reply('You must be authenticated for this command.')
        end
      end
    end
  end
end